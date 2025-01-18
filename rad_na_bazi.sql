USE bp_2_projekt;

DROP PROCEDURE IF EXISTS prerasporediZaposlenikeGodisnji;
DELIMITER $$
-- maxNaGodisnjem -> najviše dozvoljeno zaposlenika firme na godisnjem
-- maxShift-> koliko se najviše dana smije pomaknuti godišnji

CREATE PROCEDURE prerasporediZaposlenikeGodisnji(IN maxNaGodisnjem INT, IN maxShift INT)  
BEGIN
    DECLARE done INT DEFAULT 0;
    
    DECLARE v_id INT;
    DECLARE v_zaposlenik_id INT;
    DECLARE v_orig_start DATE;
    DECLARE v_orig_end DATE;
    
    DECLARE moze_se_odobriti BOOLEAN;
    DECLARE trenutni_datum DATE;
    DECLARE ct INT;
    
    DECLARE s INT DEFAULT 0;
    DECLARE s_sign INT DEFAULT 1;
    DECLARE s_step INT DEFAULT 0;
      
    DECLARE c CURSOR FOR
        SELECT id, id_zaposlenik, pocetni_datum, zavrsni_datum
        FROM godisnji_odmori
        WHERE status = 'na čekanju'
        ORDER BY datum_podnosenja;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN c;
    main_loop: LOOP
        FETCH c INTO v_id, v_zaposlenik_id, v_orig_start, v_orig_end;
        IF done THEN
            LEAVE main_loop;
        END IF;
        
        SET s = 0;
        SET s_sign = 1;
        SET s_step = 0;

        SET moze_se_odobriti = FALSE;

        SHIFT_SEARCH: WHILE s_step <= maxShift * 2 DO
            -- Shift se konstruira tako da se rang širenja širi i u pozitivnom i u negativnom smjeru kako bi se pronašao najbliži idealni novi datum (zig-zag: 0, +1, -1, +2, -2, ...)
            IF s_step = 0 THEN
                SET s = 0;
            ELSE
                IF s_sign = 1 THEN
                    SET s = s_step;
                ELSE
                    SET s = -s_step;
                END IF;
            END IF;
            
            SET @novi_pocetni_datum = DATE_ADD(v_orig_start, INTERVAL s DAY);
            SET @novi_zavrsni_datum   = DATE_ADD(v_orig_end,   INTERVAL s DAY);

            SET moze_se_odobriti = TRUE;
            SET trenutni_datum = @novi_pocetni_datum;

            day_check: WHILE trenutni_datum <= @novi_zavrsni_datum DO
                SELECT COUNT(*) INTO ct
                FROM godisnji_odmori
                WHERE status = 'odobren' OR status = 'čeka prihvaćanje'
                  AND trenutni_datum BETWEEN pocetni_datum AND zavrsni_datum;

                IF ct >= maxNaGodisnjem THEN
                    SET moze_se_odobriti = FALSE;
                    LEAVE day_check;
                END IF;

                SET trenutni_datum = DATE_ADD(trenutni_datum, INTERVAL 1 DAY);
            END WHILE;

            IF moze_se_odobriti THEN
                UPDATE godisnji_odmori
                   SET pocetni_datum = @novi_pocetni_datum,
                       zavrsni_datum = @novi_zavrsni_datum,
                       status = 'čeka prihvaćanje'
                 WHERE id = v_id;
                
                LEAVE SHIFT_SEARCH;
            END IF;

            IF s_sign = 1 THEN
                SET s_sign = -1; 
            ELSE
                SET s_sign = 1;
                SET s_step = s_step + 1;
            END IF;
        END WHILE;

        IF NOT moze_se_odobriti THEN
            UPDATE godisnji_odmori
               SET status = 'odbijen'
             WHERE id = v_id;
        END IF;
    END LOOP main_loop;

    CLOSE c;
END$$

DELIMITER ;

CALL prerasporediZaposlenikeGodisnji(3, 60);

SELECT * FROM godisnji_odmori;


DROP PROCEDURE IF EXISTS korisnikPrihvacaGodisnji;
DELIMITER $$

CREATE PROCEDURE korisnikPrihvacaGodisnji(IN status_prihvacanja BOOL, IN id_godisnji INT)
BEGIN
	IF status_prihvacanja THEN
		UPDATE godisnji_odmori SET status = 'odobren' WHERE id = id_godisnji AND status = 'čeka prihvaćanje';
	ELSE
		UPDATE godisnji_odmori SET status = 'odbijen' WHERE id = id_godisnji AND status = 'čeka prihvaćanje';
	END IF;
END$$
DELIMITER ;

-- TESTIRANJE 
CALL korisnikPrihvacaGodisnji(TRUE, 1);
CALL korisnikPrihvacaGodisnji(FALSE, 2);
CALL korisnikPrihvacaGodisnji(TRUE, 3);
CALL korisnikPrihvacaGodisnji(FALSE, 4);

SELECT * FROM godisnji_odmori;


DROP PROCEDURE IF EXISTS GenerirajRaspored;
DELIMITER //

CREATE PROCEDURE GenerirajRaspored(
    IN pocetni_datum DATE, 
    IN zavrsni_datum DATE, 
    IN maxBrojUSmjeni INT
)
BEGIN
    DECLARE trenutni_datum DATE;
    DECLARE odjel_id INT;
    DECLARE smjena_id INT;
    DECLARE min_zaposlenika INT;
    DECLARE zaposlenik_id INT;
    DECLARE done INT DEFAULT 0;

    DECLARE odjel_cur CURSOR FOR 
        SELECT id FROM odjel;
    
    DECLARE smjena_cur CURSOR FOR 
        SELECT id, min_broj_zaposlenika FROM smjene;
    
    DECLARE zaposlenik_cur CURSOR FOR 
        SELECT id, id_odjel FROM zaposlenik ORDER BY datum_zaposljavanja ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SET trenutni_datum = pocetni_datum;

    WHILE trenutni_datum <= zavrsni_datum DO
        OPEN odjel_cur;
        SET done = 0;

        odjeli_loop: LOOP
            FETCH odjel_cur INTO odjel_id;
            IF done = 1 THEN 
                SET done = 0;
                LEAVE odjeli_loop;
            END IF;

            OPEN smjena_cur;
            SET done = 0;

            smjene_loop: LOOP
                FETCH smjena_cur INTO smjena_id, min_zaposlenika;
                IF done = 1 THEN 
                    SET done = 0; 
                    LEAVE smjene_loop;
                END IF;

                OPEN zaposlenik_cur;
                SET done = 0;

                SET min_zaposlenika = LEAST(min_zaposlenika, maxBrojUSmjeni);

                zaposlenici_loop: LOOP
                    FETCH zaposlenik_cur INTO zaposlenik_id, odjel_id;
                    IF done = 1 THEN 
                        SET done = 0;
                        LEAVE zaposlenici_loop;
                    END IF;

                    IF NOT EXISTS (
                        SELECT 1 FROM raspored_rada 
                        WHERE id_zaposlenik = zaposlenik_id 
                        AND datum = trenutni_datum
                    ) AND NOT EXISTS (
                        SELECT 1 FROM godisnji_odmori 
                        WHERE id_zaposlenik = zaposlenik_id 
                        AND trenutni_datum BETWEEN pocetni_datum AND zavrsni_datum
                    ) THEN
                    
                        INSERT INTO raspored_rada (id_zaposlenik, id_smjena, datum)
                        VALUES (zaposlenik_id, smjena_id, trenutni_datum);
                    
                        SET min_zaposlenika = min_zaposlenika - 1;
                        
                        IF min_zaposlenika = 0 THEN
                            LEAVE zaposlenici_loop;
                        END IF;
                    END IF;

                END LOOP;
                CLOSE zaposlenik_cur;

            END LOOP;
            CLOSE smjena_cur;

        END LOOP;
        CLOSE odjel_cur;
        
        SET trenutni_datum = DATE_ADD(trenutni_datum, INTERVAL 1 DAY);
    END WHILE;
END //

DELIMITER ;

CALL GenerirajRaspored('2025-05-01', '2025-05-31', 5);
SELECT * FROM raspored_rada ORDER BY datum;
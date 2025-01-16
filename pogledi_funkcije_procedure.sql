USE bp_2_projekt;
-- Pogledi, Procedure, Funkcije

-- 1. View zaposlenici i odjeli
DROP VIEW IF EXISTS zaposlenici_odjeli;

CREATE VIEW zaposlenici_odjeli AS
SELECT zaposlenik.id AS zaposlenik_id,
zaposlenik.ime,
zaposlenik.prezime,
odjel.naziv AS odjel_naziv
FROM zaposlenik
INNER JOIN odjel ON zaposlenik.id_odjel=odjel.id
ORDER BY zaposlenik_id ASC;

Select * FROM zaposlenici_odjeli;

-- 2. View aktivni projekti
DROP VIEW IF EXISTS aktivni_projekti;

CREATE VIEW aktivni_projekti AS
SELECT *
FROM projekti
WHERE status = 'aktivni';

SELECT * FROM aktivni_projekti;

/*----------------------------------------------------------------------------------*/
-- PROCEDURE ----
-- PROCEDURA BR.1 DODAJ ZAPOSLENIKA
DROP PROCEDURE IF EXISTS dodaj_zaposlenika;
DELIMITER //
CREATE PROCEDURE dodaj_zaposlenika(
    IN p_ime VARCHAR(20),
    IN p_prezime VARCHAR(20),
    IN p_oib CHAR(11),
    IN p_spol ENUM('M', 'Ž'),
    IN p_email VARCHAR(50),
    IN p_broj_telefona VARCHAR(20),
    IN p_datum_zaposljavanja DATE,
    IN p_pozicija VARCHAR(50),
    IN p_status_zaposlenika VARCHAR(30),
    IN p_satnica DECIMAL(10,2),
    IN p_id_odjel INT
)
BEGIN
    INSERT INTO zaposlenik(
        ime, prezime, oib, spol, email, broj_telefona, 
        datum_zaposljavanja, pozicija, status_zaposlenika, satnica, id_odjel
    )
    VALUES (
        p_ime, p_prezime, p_oib, p_spol, p_email, p_broj_telefona, 
        p_datum_zaposljavanja, p_pozicija, p_status_zaposlenika, p_satnica, p_id_odjel
    );
END //
DELIMITER ;
/*CALL dodaj_zaposlenika(
    'Marko', 'Horvat', '12345678923', 'M', 'marko.horvat@email.com', '0911234567', '2025-01-10', 'Developer', 'aktivan', 50.00, 1
);*/
-- Select * from zaposlenik;

-- PROCEDURA BR.2 BRISI ZAPOSLENIKA
DROP PROCEDURE IF EXISTS brisi_zaposlenika;
DELIMITER //
CREATE PROCEDURE brisi_zaposlenika(IN zap_id INT)
BEGIN
	DELETE FROM zaposlenik
    WHERE id=zap_id;
END//
DELIMITER ;

-- CALL brisi_zaposlenika(31);

-- Select * from zaposlenik;


-- PROCEDURA BR.3 DODAVANJE PROJEKTA
DROP PROCEDURE IF EXISTS dodaj_projekt;
DELIMITER //
CREATE PROCEDURE dodaj_projekt(
IN p_naziv VARCHAR(100),
IN p_opis TEXT,
IN p_datum_pocetka DATE,
IN p_datum_zavrsetka DATE,
IN p_status ENUM('aktivni', 'završeni', 'odgođeni'),
IN p_odgovorna_osoba INT
)
BEGIN
	INSERT INTO projekti (naziv, opis, datum_pocetka, datum_zavrsetka, status, odgovorna_osoba)
	VALUES(p_naziv, p_opis, p_datum_pocetka, p_datum_zavrsetka, p_status, p_odgovorna_osoba);
END //
DELIMITER ;

-- PROCEDURA BR.4 UKUPAN IZRACUM TROSKOVA PUTA
DROP PROCEDURE IF EXISTS ukupno_troskovi_sluzbeni_put;
DELIMITER //
CREATE PROCEDURE ukupno_troskovi_sluzbeni_put(IN p_zap_id INT, OUT ukupno_troskovi DECIMAL(10,2))
BEGIN
	SELECT 
    id_zaposlenik,
    troskovi
    FROM sluzbena_putovanja;
END //
DELIMITER ;

-- PROCEDURA BR.5 dodavanje godišnjeg odmora za zaposlenika
DROP PROCEDURE IF EXISTS dodaj_godisnji;
DELIMITER //
CREATE PROCEDURE dodaj_godisnji(IN p_id_zaposlenik INT, IN p_pocetni_datum DATE, IN p_zavrsni_datum DATE, IN p_broj_dana INT)
BEGIN
INSERT INTO godisnji_odmori(
id_zaposlenik, pocetni_datum, zavrsni_datum, broj_dana)
VALUES(p_id_zaposlenik, p_pocetni_datum, p_zavrsni_datum, YEAR(p_pocetni_datum), p_broj_dana);
END //
DELIMITER ;
-- PROCEDURA BR.6 prikaz svih smjena zaposlenika za određeni dan
DROP PROCEDURE IF EXISTS prikaz_smjene_zaposlenika;
DELIMITER //
CREATE PROCEDURE prikaz_smjene_zaposlenika(IN p_datum DATE)
BEGIN
    SELECT s.vrsta_smjene, z.ime, z.prezime
    FROM smjene s
    JOIN raspored_rada rr ON s.id = rr.id_smjena
    JOIN zaposlenik z ON rr.id_zaposlenik = z.id
    WHERE rr.datum = p_datum;
END //
DELIMITER ;
CALL prikaz_smjene_zaposlenika();
select * from smjene;
-- PROCEDURA BR.7 DODAVANJE BILJESKE ZA ZAPOSLENIKA
DROP PROCEDURE IF EXISTS dodavanje_biljeske_za_zaposlenika;
DELIMITER //
CREATE PROCEDURE dodaj_biljesku (
    IN p_id_zaposlenik INT,
    IN p_napomena TEXT,
    IN p_tip ENUM('pozitivna', 'negativna'),
    IN p_datum DATETIME
)
BEGIN
INSERT INTO napomene (id_zaposlenik, datum, napomena, tip)
    VALUES (p_id_zaposlenik, p_datum, p_napomena, p_tip);
END //

DELIMITER ;
-- PROCEDURA BR.8 Odobri godisnji
DROP PROCEDURE IF EXISTS odobrigodisnji;

DELIMITER //
CREATE PROCEDURE odobrigodisnji()
BEGIN
    DECLARE gotovo INT DEFAULT 0;
    DECLARE unesi_id INT;
    DECLARE pocetak DATE;
    DECLARE kraj DATE;
    DECLARE min_zaposlenika INT DEFAULT 3; 

    DECLARE izlazni_cur CURSOR FOR 
    SELECT id, pocetni_datum, zavrsni_datum 
    FROM godisnji_odmori 
    WHERE status = 'na čekanju';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET gotovo = 1;

    OPEN izlazni_cur;

    citaj_loop: LOOP
        FETCH izlazni_cur INTO unesi_id, pocetak, kraj;
        IF gotovo THEN
            LEAVE citaj_loop;
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM godisnji_odmori
            WHERE status = 'odobren'
            AND (
                (pocetni_datum BETWEEN pocetak AND kraj) OR
                (zavrsni_datum BETWEEN pocetak AND kraj) OR
                (pocetak BETWEEN pocetni_datum AND zavrsni_datum)
            )
        ) THEN
           
            IF (SELECT COUNT(*) 
                FROM zaposlenik z
                WHERE z.id NOT IN (
                    SELECT id_zaposlenik 
                    FROM godisnji_odmori 
                    WHERE status = 'odobren' 
                    AND (pocetni_datum BETWEEN pocetak AND kraj 
                        OR zavrsni_datum BETWEEN pocetak AND kraj))
            ) >= min_zaposlenika THEN
			
                UPDATE godisnji_odmori
                SET status = 'odobren'
                WHERE id = unesi_id;
            END IF;
        END IF;
    END LOOP;

    CLOSE izlazni_cur;
END //
DELIMITER ;

SELECT * FROM godisnji_odmori;

CALL odobrigodisnji();
-- PROCEDURA BR.9 Dodaj Zaposlenike u smjene
DROP PROCEDURE IF EXISTS dodajZaposlenikeUSmjene;

DELIMITER //
CREATE PROCEDURE dodajZaposlenikeUSmjene()
BEGIN
    DECLARE gotovo INT DEFAULT 0;
    DECLARE zaposlenik INT;
    DECLARE smjena_id INT;
    DECLARE datum_smjene DATE;

    DECLARE smjena_cur CURSOR FOR 
    SELECT id, DATE(pocetak_smjene) AS datum_smjene 
    FROM smjene 
    WHERE id NOT IN (SELECT id FROM raspored_rada);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET gotovo = 1;

    OPEN smjena_cur;

    loopaj: LOOP
        FETCH smjena_cur INTO smjena_id, datum_smjene;
        IF gotovo THEN
            LEAVE loopaj;
        END IF;

        SET zaposlenik = (
            SELECT id_zaposlenik 
            FROM preferencije_smjena 
            WHERE id = smjena_id
            AND id_zaposlenik NOT IN (
                SELECT id_zaposlenik 
                FROM raspored_rada 
                WHERE datum = datum_smjene
            )
            LIMIT 1
        );

        IF zaposlenik IS NOT NULL THEN
            INSERT INTO raspored_rada (id_zaposlenik, id_smjena, datum) 
            VALUES (zaposlenik, smjena_id, datum_smjene);
        END IF;
    END LOOP;

    CLOSE smjena_cur;
END //
DELIMITER ;


SELECT * FROM smjene;
SELECT * FROM raspored_rada;
SELECT * FROM preferencije_smjena;

DROP PROCEDURE IF EXISTS prerasporediZaposlenikeGodisnji;
DELIMITER $$
-- maxNaGodisnjem -> najviše dozvoljeno zaposlenika firme na godisnjem
-- maxShift-> koliko se najviše dana smije pomaknuti godišnji

-- PROCEDURA BR.10 Prerasporedi zaposlenike godisnji

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
		-- treba se promijeniti da se sortira po razini vaznosti u firmi (rola, npr. direktor - 999, menađer - 10, senior zaposlenik - 5, junior zaposlenik - 3, i slično)
        
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
-- PROCEDURA BR.11 Korisnik prihvaca godisnji
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
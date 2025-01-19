USE bp_2_projekt;
-- Pogledi, Procedure, Funkcije, Slozeni upiti
-- Slozeni upiti
-- Mateo
-- Zaposlenici s najviše odrađenih sati u proteklom mjesecu
SELECT CONCAT(ime, ' ', prezime) AS zaposlenik, email, godina_mjesec, (radni_sati + prekovremeni_sati) AS ukupno_sati 
FROM place AS p 
JOIN zaposlenik AS z ON p.id_zaposlenik = z.id 
WHERE godina_mjesec = DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01') 
ORDER BY ukupno_sati DESC LIMIT 5;

-- Popis svih zaposlenika s njihovim odjelima i ukupnom plaćom u određenom mjesecu
SELECT z.id AS zaposlenik_id, CONCAT(ime, ' ', prezime) AS puno_ime, o.naziv AS odjel, ukupna_placa AS placa 
FROM zaposlenik z 
JOIN odjel o ON z.id_odjel = o.id 
JOIN place p ON z.id = p.id_zaposlenik;


--  Zaposlenici koji su radili više od 15 sati prekovremeno u određenom mjesecu
SELECT z.id AS zaposlenik_id, CONCAT(ime, ' ', prezime) AS puno_ime, prekovremeni_sati 
FROM zaposlenik z 
JOIN place p ON z.id = p.id_zaposlenik 
WHERE godina_mjesec = '2025-01-01' AND prekovremeni_sati > 15;

-- Projekti s rokovima koji ističu u sljedećih 7 dana
SELECT naziv, opis, datum_zavrsetka 
FROM projekti 
WHERE status_projekta = 'aktivni' AND datum_zavrsetka BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);

-- Lista prekovremenih zahtjeva koji su odbijeni s razlozima
SELECT z.id AS zaposlenik_id, CONCAT(ime, ' ', prezime) AS puno_ime, datum_prekovremeni, sati, razlog 
FROM zaposlenik AS z 
JOIN zahtjev_prekovremeni AS zp ON z.id = zp.id_zaposlenik 
WHERE zp.status_pre = 'odbijen';

-- Ukupna plaća svih zaposlenika u određenom odjelu za zadani mjesec
SELECT o.naziv AS odjel, SUM(p.ukupna_placa) AS ukupna_placa_odjela
FROM zaposlenik z
JOIN odjel o ON z.id_odjel = o.id
JOIN place p ON z.id = p.id_zaposlenik
WHERE o.id = 1 AND godina_mjesec = '2025-01'
GROUP BY o.naziv;

-- Zaposlenici koji trenutno imaju bolovanje
SELECT CONCAT(z.ime, ' ', z.prezime) AS puno_ime, b.pocetni_datum, b.krajnji_datum
FROM zaposlenik z
JOIN bolovanje b ON z.id = b.id_zaposlenik
WHERE CURDATE() BETWEEN b.pocetni_datum AND b.krajnji_datum;

-- Ukupan broj sati rada po zaposleniku za zadani mjesec
SELECT CONCAT(z.ime, ' ', z.prezime) AS puno_ime, SUM(TIMESTAMPDIFF(HOUR, e.vrijeme_dolaska, e.vrijeme_odlaska)) AS ukupno_sati
FROM zaposlenik z
JOIN evidencija_rada e ON z.id = e.id_zaposlenik
WHERE DATE_FORMAT(e.datum, '%Y-%m') = '2025-01'
GROUP BY z.id
ORDER BY ukupno_sati DESC;

 -- Zaposlenici s najviše pozitivnih napomena

SELECT CONCAT(z.ime, ' ', z.prezime) AS puno_ime, COUNT(n.id) AS broj_pozitivnih_napomena
FROM zaposlenik z
JOIN napomene n ON z.id = n.id_zaposlenik
WHERE n.tip = 'pozitivna'
GROUP BY z.id
ORDER BY broj_pozitivnih_napomena DESC
LIMIT 5;

-- Ukupna plaća i broj prekovremenih sati po odjelu za određeni mjesec

SELECT 
    o.naziv AS odjel,
    SUM(p.prekovremeni_sati) AS ukupno_prekovremeni_sati,
    SUM(p.ukupna_placa) AS ukupna_isplacena_placa
FROM odjel o
JOIN zaposlenik z ON o.id = z.id_odjel
JOIN place p ON z.id = p.id_zaposlenik
WHERE p.godina_mjesec = '2025-01'
GROUP BY o.id
ORDER BY ukupna_isplacena_placa DESC;




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
/*----------------------------------------------------------------------------------*/
-- 2. View aktivni projekti
DROP VIEW IF EXISTS aktivni_projekti;

CREATE VIEW aktivni_projekti AS
SELECT *
FROM projekti
WHERE status_projekta = 'aktivni';

SELECT * FROM aktivni_projekti;
/*----------------------------------------------------------------------------------*/
-- 3. View
DROP VIEW IF EXISTS aktivni_zaposlenici;
CREATE VIEW aktivni_zaposlenici AS
SELECT z.id AS zaposlenik_id, CONCAT(z.ime, ' ', z.prezime) AS puno_ime, z.email, z.broj_telefona, o.naziv AS odjel, z.pozicija, z.satnica 
	FROM zaposlenik z JOIN odjel o ON z.id_odjel = o.id 
	WHERE z.status_zaposlenika = 'aktivan';

SELECT * FROM aktivni_zaposlenici;
/*----------------------------------------------------------------------------------*/
-- 4. View
DROP VIEW IF EXISTS mjesecne_place;
CREATE VIEW mjesecne_place AS 
SELECT p.id AS placa_id, CONCAT(z.ime, ' ', z.prezime) AS zaposlenik, p.godina_mjesec, p.radni_sati, p.prekovremeni_sati, p.ukupna_placa 
	FROM place p 
	JOIN zaposlenik z ON p.id_zaposlenik = z.id;

SELECT * FROM mjesecne_place;
/*----------------------------------------------------------------------------------*/
-- 5. View
DROP VIEW IF EXISTS troskovi_sluzbenih_putovanja;
CREATE VIEW troskovi_sluzbenih_putovanja AS 
SELECT sp.id AS putovanje_id, CONCAT(z.ime, ' ', z.prezime) AS zaposlenik, sp.odrediste, sp.svrha_putovanja, sp.pocetni_datum, sp.zavrsni_datum, sp.troskovi 
	FROM sluzbena_putovanja sp 
	JOIN zaposlenik z ON sp.id_zaposlenik = z.id;

SELECT * FROM troskovi_sluzbenih_putovanja;

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
/*----------------------------------------------------------------------------------*/
-- PROCEDURA BR.2 BRISI ZAPOSLENIKA
DROP PROCEDURE IF EXISTS brisi_zaposlenika;
DELIMITER //
CREATE PROCEDURE brisi_zaposlenika(IN zap_id INT)
BEGIN
	DELETE FROM zaposlenik
    WHERE id=zap_id;
END//
DELIMITER ;

/*----------------------------------------------------------------------------------*/

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
	INSERT INTO projekti (naziv, opis, datum_pocetka, datum_zavrsetka, status_projekta, odgovorna_osoba)
	VALUES(p_naziv, p_opis, p_datum_pocetka, p_datum_zavrsetka, p_status, p_odgovorna_osoba);
END //
DELIMITER ;
/*----------------------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------------------*/
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
                    WHERE status_god = 'odobren' 
                    AND (pocetni_datum BETWEEN pocetak AND kraj 
                        OR zavrsni_datum BETWEEN pocetak AND kraj))
            ) >= min_zaposlenika THEN
			
                UPDATE godisnji_odmori
                SET status_god = 'odobren'
                WHERE id = unesi_id;
            END IF;
        END IF;
    END LOOP;

    CLOSE izlazni_cur;
END //
DELIMITER ;
/*----------------------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------------------*/
-- PROCEDURA BR.10 Prerasporedi zaposlenike godisnji

DROP PROCEDURE IF EXISTS prerasporediZaposlenikeGodisnji;
DELIMITER //
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
        WHERE status_god = 'na čekanju'
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
                WHERE status_god = 'odobren' OR status_god = 'čeka prihvaćanje'
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
               SET status_god = 'odbijen'
             WHERE id = v_id;
        END IF;
    END LOOP main_loop;

    CLOSE c;
END//

DELIMITER ;
/*----------------------------------------------------------------------------------*/
-- PROCEDURA BR.11 Korisnik prihvaca godisnji

DROP PROCEDURE IF EXISTS korisnikPrihvacaGodisnji;
DELIMITER //
CREATE PROCEDURE korisnikPrihvacaGodisnji(IN status_prihvacanja BOOL, IN id_godisnji INT)
BEGIN
	IF status_prihvacanja THEN
		UPDATE godisnji_odmori SET status_god = 'odobren' WHERE id = id_godisnji AND status_god = 'čeka prihvaćanje';
	ELSE
		UPDATE godisnji_odmori SET status_god = 'odbijen' WHERE id = id_godisnji AND status_god = 'čeka prihvaćanje';
	END IF;
END//
DELIMITER ;

/*----------------------------------------------------------------------------------*/
-- PROCEDURA BR.12 Generiraj raspored

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
/*
CALL GenerirajRaspored('2025-05-01', '2025-05-31', 5);
SELECT * FROM raspored_rada ORDER BY datum;
select id_smjena from raspored_rada;
*/

/*----------------------------------------------------------------------------------*/
-- PROCEDURA BR.13 Dodaj prekovremene sate
DROP PROCEDURE IF EXISTS DodajPrekovremeneSate;

DELIMITER //

CREATE PROCEDURE DodajPrekovremeneSate (
    IN p_id_zahtjev INT
)
BEGIN
    DECLARE v_id_zaposlenik INT;
    DECLARE v_sati INT;

    SELECT id_zaposlenik, sati
    INTO v_id_zaposlenik, v_sati
    FROM zahtjev_prekovremeni
    WHERE id = p_id_zahtjev;

    UPDATE place
    SET prekovremeni_sati = prekovremeni_sati + v_sati
    WHERE id_zaposlenik = v_id_zaposlenik AND YEAR(godina_mjesec) = YEAR(CURDATE()) AND MONTH(godina_mjesec) = MONTH(CURDATE());

    UPDATE zahtjev_prekovremeni
    SET status_pre = 'odobren'
    WHERE id = p_id_zahtjev;
END//

DELIMITER ;
/*----------------------------------------------------------------------------------*/
-- FUNKCIJE

DROP FUNCTION IF EXISTS mjesecnaPlaca;
DELIMITER //
CREATE FUNCTION mjesecnaPlaca(zaposlenik_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE std_placa DECIMAL(10,2);
    DECLARE broj_sati DECIMAL(10,2);
    DECLARE prekovremeni DECIMAL(10,2);
    DECLARE bolovanje INT;
    DECLARE dopust_dani INT;
    DECLARE mjesecna DECIMAL(10,2);
    DECLARE godina_mjesec CHAR(7);
    DECLARE ukupan_broj_sati DECIMAL(10,2);

    -- Dohvati satnicu zaposlenika
    SELECT satnica INTO std_placa FROM zaposlenik WHERE id = zaposlenik_id;

    -- Izračunaj ukupne radne sate za mjesec
    SELECT SUM(TIMESTAMPDIFF(HOUR, vrijeme_dolaska, vrijeme_odlaska)) INTO broj_sati 
    FROM evidencija_rada 
    WHERE id_zaposlenik = zaposlenik_id AND YEAR(datum) = YEAR(CURDATE()) AND MONTH(datum) = MONTH(CURDATE());

    -- Izračunaj prekovremene sate
    SELECT SUM(GREATEST(0, TIMESTAMPDIFF(HOUR, vrijeme_dolaska, vrijeme_odlaska) - 8)) INTO prekovremeni
    FROM evidencija_rada 
    WHERE id_zaposlenik = zaposlenik_id AND YEAR(datum) = YEAR(CURDATE()) AND MONTH(datum) = MONTH(CURDATE());

    -- Izračunaj broj dana bolovanja
    SELECT IFNULL(SUM(DATEDIFF(krajnji_datum, pocetni_datum) + 1), 0) INTO bolovanje
		FROM bolovanje 
		WHERE id_zaposlenik = zaposlenik_id 
			AND YEAR(pocetni_datum) = YEAR(CURDATE()) 
			AND MONTH(pocetni_datum) = MONTH(CURDATE());
            
	-- Izračunaj broj dana dopusta
	
	SELECT IFNULL(SUM(DATEDIFF(zavrsni_datum, pocetni_datum) + 1), 0) INTO dopust_dani
		FROM dopust 
		WHERE id_zaposlenik = zaposlenik_id 
			AND YEAR(pocetni_datum) = YEAR(CURDATE()) 
			AND MONTH(pocetni_datum) = MONTH(CURDATE())
			AND tip_dopusta = 'neplaćeni';
            
    -- Izračunaj mjesec i godinu za unos u tablicu
    SET godina_mjesec = DATE_FORMAT(CURDATE(), '%Y-%m'); -- Formatira datum u 'YYYY-MM'
    
    -- ukupan broj odradenih sati
   SET ukupan_broj_sati = broj_sati - (dopust_dani * 8);

    -- Izračunaj ukupnu plaću
    SET mjesecna = ((ukupan_broj_sati  * std_placa) + (prekovremeni * std_placa * 2) - (bolovanje * 3 * std_placa));

    -- Upis u tablicu place
    INSERT INTO place (id_zaposlenik, godina_mjesec, radni_sati, prekovremeni_sati, bolovanje_dani, ukupna_placa)
    VALUES (zaposlenik_id, godina_mjesec, broj_sati, prekovremeni, bolovanje, mjesecna)
    ON DUPLICATE KEY UPDATE ukupna_placa = mjesecna;

    -- Vratiti ukupnu plaću
    RETURN mjesecna;
END //
DELIMITER ;


SELECT mjesecnaPlaca(1);
SELECT mjesecnaPlaca(2);
SELECT mjesecnaPlaca(3);
SELECT mjesecnaPlaca(4);
SELECT mjesecnaPlaca(5);
SELECT mjesecnaPlaca(6);
SELECT mjesecnaPlaca(7);
SELECT mjesecnaPlaca(30);
SELECT * FROM place;
/*----------------------------------------------------------------------------------*/
DELIMITER //
CREATE FUNCTION TroskoviPutovanjaPoOdjelu(OdjelID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE UkupniTroskovi DECIMAL(10,2);
    SELECT SUM(troskovi) INTO UkupniTroskovi
    FROM sluzbena_putovanja sp
    JOIN zaposlenik z ON sp.id_zaposlenik = z.id
    WHERE z.id_odjel = OdjelID;
    
    RETURN IFNULL(UkupniTroskovi, 0);
END //
DELIMITER ;
SELECT TroskoviPutovanjaPoOdjelu(1);
/*----------------------------------------------------------------------------------*/
DELIMITER //
CREATE FUNCTION provjera_dostupnosti(
    p_id_zaposlenik INT,
    p_datum DATE
) RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE zauzet BOOLEAN DEFAULT FALSE;
    DECLARE status VARCHAR(20);

    SELECT EXISTS (
        SELECT 1
        FROM bolovanje
        WHERE id_zaposlenik = p_id_zaposlenik 
          AND (p_datum = pocetni_datum OR p_datum = krajnji_datum OR (p_datum > pocetni_datum AND p_datum < krajnji_datum))
    ) INTO zauzet;

    IF NOT zauzet THEN
        SELECT EXISTS (
            SELECT 1
            FROM godisnji_odmori
            WHERE id_zaposlenik = p_id_zaposlenik 
              AND (p_datum = pocetni_datum OR p_datum = zavrsni_datum OR (p_datum > pocetni_datum AND p_datum < zavrsni_datum))
        ) INTO zauzet;
    END IF;

    IF NOT zauzet THEN
        SELECT EXISTS (
            SELECT 1
            FROM sluzbena_putovanja
            WHERE id_zaposlenik = p_id_zaposlenik 
              AND (p_datum = pocetni_datum OR p_datum = zavrsni_datum OR (p_datum > pocetni_datum AND p_datum < zavrsni_datum))
        ) INTO zauzet;
    END IF;

    IF NOT zauzet THEN
        SELECT EXISTS (
            SELECT 1
            FROM dopust
            WHERE id_zaposlenik = p_id_zaposlenik 
            AND (p_datum = pocetni_datum OR p_datum = zavrsni_datum OR (p_datum > pocetni_datum AND p_datum < zavrsni_datum))
            AND LOWER(TRIM(status_dopusta)) = 'odobren'  
        ) INTO zauzet;
    END IF;

    IF zauzet THEN
        SET status = 'Nedostupan';
    ELSE
        SET status = 'Dostupan';
    END IF;

    RETURN status;
END//
DELIMITER ;

USE bp_2_projekt;

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


-- PROCEDURA BR.5 DODAVANJE BILJESKE ZA ZAPOSLENIKA
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



-- PROCEDURA BR.6 DODAVANJE PREKOVREMENIH SATI ZAPOSLENIKU
DROP PROCEDURE IF EXISTS dodavanje_prekovremenih_sati_zaposleniku;
DELIMITER //
CREATE PROCEDURE dodaj_prekovremene_sate (
    IN p_id_zaposlenik INT,
    IN p_datum_prekovremeni DATE,
    IN p_sati INT,
    IN p_razlog VARCHAR(1000)
)
BEGIN 
	INSERT INTO zahtjev_prekovremeni (id_zaposlenik, datum_prekovremeni, sati, razlog, status_pre)
    VALUES (p_id_zaposlenik, p_datum_prekovremeni, p_sati, p_razlog, 'na čekanju');
END //

DELIMITER ;



-- PROCEDURA BR.7 IZRACUN UKUPNE PLACE ZAPOSLENIKA
DROP PROCEDURE IF EXISTS izracun_ukupne_place_zaposlenika;
DELIMITER //

CREATE PROCEDURE izracun_ukupne_place_zaposlenika (
    IN p_id_zaposlenik INT,
    IN p_godina_mjesec DATE
)
BEGIN 
	DECLARE zap_odradeni_sati INT DEFAULT 0;
    DECLARE zap_prekovremeni INT DEFAULT 0;
    DECLARE zap_bolovanje INT DEFAULT 0;
    DECLARE zap_ukupno_placa DECIMAL (10,2);
    DECLARE zap_satnica DECIMAL (10, 2);

SELECT radni_sati, prekovremeni_sati, bolovanje_dani
INTO zap_odradeni_sati, zap_prekovremeni, zap_bolovanje
FROM place
WHERE id_zaposlenik = p_id_zaposlenik AND godina_mjesec = p_godina_mjesec;

SELECT satnica 
INTO zap_satnica
FROM zaposlenik
WHERE id = p_id_zaposlenik;

SET zap_ukupno_placa = (zap_satnica * zap_odradeni_sati) + (zap_satnica * 1.5 * zap_prekovremeni);

IF EXISTS (SELECT 1 FROM place WHERE id_zaposlenik = p_id_zaposlenik AND godina_mjesec = p_godina_mjesec) THEN
        UPDATE place
        SET ukupna_placa = zap_ukupno_placa
        WHERE id_zaposlenik = p_id_zaposlenik AND godina_mjesec = p_godina_mjesec;
	ELSE 
		INSERT INTO place (id_zaposlenik, godina_mjesec, radni_sati, prekovremeni_sati, bolovanje_dani, ukupna_placa)
        VALUES (p_id_zaposlenik, p_godina_mjesec, zap_odradeni_sati, zap_prekovremeni, zap_bolovanje, zap_ukupno_placa);
	END IF;
END //
DELIMITER ;

CALL izracun_ukupne_place_zaposlenika(2, '2024-06-12');
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
CALL dodaj_zaposlenika(
    'Marko', 'Horvat', '12345678923', 'M', 'marko.horvat@email.com', '0911234567', '2025-01-10', 'Developer', 'aktivan', 50.00, 1
);
Select * from zaposlenik;

-- PROCEDURA BR.2 BRISI ZAPOSLENIKA
DROP PROCEDURE IF EXISTS brisi_zaposlenika;
DELIMITER //
CREATE PROCEDURE brisi_zaposlenika(IN zap_id INT)
BEGIN
	DELETE FROM zaposlenik
    WHERE id=zap_id;
END//
DELIMITER ;

CALL brisi_zaposlenika(31);

Select * from zaposlenik;

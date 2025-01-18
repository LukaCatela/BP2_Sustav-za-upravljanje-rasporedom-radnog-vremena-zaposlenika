-- 1 Funkcija za izračunavanje troškova putovanja po odjelu--
DELIMITER $$
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
END $$
DELIMITER ;
SELECT TroskoviPutovanjaPoOdjelu(1);

-- 2 Provjera dostupnosti zaposlenika na određeni datum --
DELIMITER $$
CREATE FUNCTION provjera_dostupnosti(
    p_id_zaposlenik INT,
    p_datum DATE
) RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE zauzet BOOLEAN DEFAULT FALSE;
    DECLARE status VARCHAR(20);

    -- Provjera bolovanja
    SELECT EXISTS (
        SELECT 1
        FROM bolovanje
        WHERE id_zaposlenik = p_id_zaposlenik 
          AND (p_datum = pocetni_datum OR p_datum = krajnji_datum OR (p_datum > pocetni_datum AND p_datum < krajnji_datum))
    ) INTO zauzet;

    -- Provjera godišnjeg odmora
    IF NOT zauzet THEN
        SELECT EXISTS (
            SELECT 1
            FROM godisnji_odmori
            WHERE id_zaposlenik = p_id_zaposlenik 
              AND (p_datum = pocetni_datum OR p_datum = zavrsni_datum OR (p_datum > pocetni_datum AND p_datum < zavrsni_datum))
        ) INTO zauzet;
    END IF;

    -- Provjera službenog putovanja
    IF NOT zauzet THEN
        SELECT EXISTS (
            SELECT 1
            FROM sluzbena_putovanja
            WHERE id_zaposlenik = p_id_zaposlenik 
              AND (p_datum = pocetni_datum OR p_datum = zavrsni_datum OR (p_datum > pocetni_datum AND p_datum < zavrsni_datum))
        ) INTO zauzet;
    END IF;

    -- Provjera dopusta
    IF NOT zauzet THEN
        SELECT EXISTS (
            SELECT 1
            FROM dopust
            WHERE id_zaposlenik = p_id_zaposlenik 
            AND (p_datum = pocetni_datum OR p_datum = zavrsni_datum OR (p_datum > pocetni_datum AND p_datum < zavrsni_datum))
            AND LOWER(TRIM(status_dopusta)) = 'odobren'  
        ) INTO zauzet;
    END IF;

    -- Postavljanje statusa
    IF zauzet THEN
        SET status = 'Nedostupan';
    ELSE
        SET status = 'Dostupan';
    END IF;

    RETURN status;
END$$
DELIMITER ;
-- 3 Azuriranje statusa projekta ako je unesem zavrsni datum --
DELIMITER $$

CREATE TRIGGER azuriranje_statusa_projekta
BEFORE UPDATE ON projekti
FOR EACH ROW
BEGIN
  IF NEW.datum_zavrsetka IS NOT NULL AND NEW.status_projekta != 'završeni' THEN
    SET NEW.status_projekta = 'završeni';
  END IF;
END$$

DELIMITER ;
-- 4 Pogled na koji zaposlenici imaju najduzu odsutnost
 CREATE VIEW zaposlenici_najduza_odsutnost AS
SELECT 
    z.id AS zaposlenik_id,
    z.ime,
    z.prezime,
    COALESCE(
        SUM(DATEDIFF(b.krajnji_datum, b.pocetni_datum) + 1) +
        SUM(DATEDIFF(go.zavrsni_datum, go.pocetni_datum) + 1) +
        SUM(DATEDIFF(d.zavrsni_datum, d.pocetni_datum) + 1) +
        SUM(DATEDIFF(sp.zavrsni_datum, sp.pocetni_datum) + 1),
        0
    ) AS ukupno_dani_odsutnosti
FROM zaposlenik z
LEFT JOIN bolovanje b ON z.id = b.id_zaposlenik
LEFT JOIN godisnji_odmori go ON z.id = go.id_zaposlenik AND LOWER(go.status) = 'odobren'
LEFT JOIN dopust d ON z.id = d.id_zaposlenik AND LOWER(d.status) = 'odobren'
LEFT JOIN sluzbena_putovanja sp ON z.id = sp.id_zaposlenik
GROUP BY z.id, z.ime, z.prezime
ORDER BY ukupno_dani_odsutnosti DESC;

-- 5 Procedura

DELIMITER $$

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
END$$

DELIMITER ;
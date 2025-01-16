DROP DATABASE IF EXISTS bp_2_projekt;
CREATE DATABASE bp_2_projekt;
USE bp_2_projekt;

-- Tablica odjela
CREATE TABLE odjel(
    id INT PRIMARY KEY AUTO_INCREMENT,
    naziv VARCHAR(50),
    opis TEXT,
    UNIQUE(naziv)
);

-- Tablica zaposlenika
CREATE TABLE zaposlenik(
    id INT PRIMARY KEY AUTO_INCREMENT,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(20) NOT NULL,
    oib CHAR(11) NOT NULL UNIQUE,
    spol ENUM('M', 'Ž') NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    broj_telefona VARCHAR(20) NOT NULL,
    datum_zaposljavanja DATE NOT NULL,
    pozicija VARCHAR(50),
    status_zaposlenika VARCHAR(30) NOT NULL,
    satnica DECIMAL(10,2) NOT NULL CHECK(satnica >= 0),
    id_odjel INTEGER NOT NULL, 
    CONSTRAINT provjera_oib CHECK(LENGTH(oib) = 11),
    FOREIGN KEY (id_odjel) REFERENCES odjel(id)
    
);

-- Tablica smjena
CREATE TABLE smjene(
    id INT PRIMARY KEY AUTO_INCREMENT,
    vrsta_smjene ENUM('jutarnja', 'popodnevna', 'nocna') NOT NULL,
    pocetak_smjene DATETIME NOT NULL,
    kraj_smjene DATETIME NOT NULL,
    min_broj_zaposlenika TINYINT UNSIGNED NOT NULL, 
    id_odjel INTEGER NOT NULL, 
    CONSTRAINT ck_datum CHECK(pocetak_smjene < kraj_smjene),
	FOREIGN KEY (id_odjel) REFERENCES odjel(id)

);

-- Tablica bolovanja
CREATE TABLE bolovanje(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    pocetni_datum DATE NOT NULL,
    krajnji_datum DATE NOT NULL,
    med_potvrda BOOL NOT NULL,
    CONSTRAINT ck_bolovanje CHECK(pocetni_datum < krajnji_datum)
    -- provjerit da se dva bolovanja istog zaposlenika ne preklapaju (nema smisla da ima dva bolovanja koji uključuju isti period)
	-- ovo su 2 triggera jer nemozemo slozeniji check INSERT i UPDATE
);

-- Tablica rasporeda rada 
CREATE TABLE raspored_rada(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    id_smjena INT NOT NULL,
    datum DATE NOT NULL,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    FOREIGN KEY (id_smjena) REFERENCES smjene(id),
    UNIQUE(id_zaposlenik, datum, id_smjena)
    -- dodat check za 1 smjena 1 datum -- UNIQUE(id_zaposlenik, datum) ili UNIQUE(id_zaposlenik, datum, id_smjena)
    -- implementirati (okidaci/procedure) da zaposlenik ne smije raditi jednu za drugom smjenom, npr. ne smije raditi "noćnu" jedan dan i drugi dan "jutarnju" da ne da otkaz zaposlenik ;)
);


CREATE TABLE evidencija_rada(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    datum DATE NOT NULL,
    vrijeme_dolaska TIME NOT NULL,
    vrijeme_odlaska TIME NOT NULL,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_vrijeme CHECK(vrijeme_dolaska < vrijeme_odlaska)
);

-- Tablica plaća 
CREATE TABLE place(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    godina_mjesec DATE NOT NULL,
    radni_sati INT NOT NULL CHECK(radni_sati >= 0),
    prekovremeni_sati INT NOT NULL CHECK(prekovremeni_sati >= 0),
    bolovanje_dani INT NOT NULL DEFAULT 0,
    ukupna_placa DECIMAL(10,2) NOT NULL CHECK(ukupna_placa >= 0),
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE
);

CREATE TABLE godisnji_odmori (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    pocetni_datum DATE NOT NULL,
    zavrsni_datum DATE NOT NULL,
    status ENUM('odobren', 'odbijen', 'na čekanju', 'iskorišten') DEFAULT 'na čekanju', 
    datum_podnosenja DATE, 
    godina INT NOT NULL, 
    broj_dana INT NOT NULL, 
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_datum2 CHECK(pocetni_datum <= zavrsni_datum),
    CONSTRAINT ck_godina CHECK(YEAR(pocetni_datum) = godina)
);


-- Tablica zahtjeva za prekovremene
CREATE TABLE zahtjev_prekovremeni(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    datum_prekovremeni DATE NOT NULL,
    sati INT NOT NULL,
    razlog VARCHAR(1000),
    status_pre VARCHAR(20), 
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);

-- Tablica preferencija zaposlenika za smjene
CREATE TABLE preferencije_smjena(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    vrsta_smjene ENUM('jutarnja', 'popodnevna', 'nocna') NOT NULL,
    datum DATETIME NOT NULL,
    prioritet TINYINT UNSIGNED NOT NULL,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_prioritet CHECK(prioritet > 0 AND prioritet <= 10)
);

-- Tablica sluzbena putovanja 
CREATE TABLE sluzbena_putovanja(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    pocetni_datum DATE NOT NULL,
    zavrsni_datum DATE NOT NULL,
    svrha_putovanja VARCHAR(100) NOT NULL,
    odrediste VARCHAR(100) NOT NULL,
    troskovi DECIMAL(10,2) NOT NULL CHECK(troskovi >= 0),
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_putovanje CHECK(pocetni_datum < zavrsni_datum)
);

-- implementirat proceduru koja će omogućiti da dva zaposlenika zamjene smjene

CREATE TABLE dopust (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    pocetni_datum DATE NOT NULL,
    zavrsni_datum DATE NOT NULL,
    tip_dopusta ENUM('plaćeni', 'neplaćeni') NOT NULL,
    status ENUM('odobren', 'odbijen', 'na čekanju') DEFAULT 'na čekanju',
    razlog VARCHAR(500), 
    datum_podnosenja DATE NOT NULL, 
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_dopust CHECK(pocetni_datum <= zavrsni_datum)
);


CREATE TABLE projekti (
    id INT PRIMARY KEY AUTO_INCREMENT,
    naziv VARCHAR(100) NOT NULL,
    opis TEXT,
    datum_pocetka DATE NOT NULL,
    datum_zavrsetka DATE,
    status ENUM('aktivni', 'završeni', 'odgođeni') DEFAULT 'aktivni',
    odgovorna_osoba INT, 
    FOREIGN KEY (odgovorna_osoba) REFERENCES zaposlenik(id),
    CONSTRAINT ck_datum3 CHECK(datum_pocetka <= datum_zavrsetka)
);

CREATE TABLE zadaci (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_projekt INT NOT NULL,
    id_zaposlenik INT NOT NULL,
    naziv VARCHAR(100) NOT NULL,
    opis TEXT,
    datum_pocetka DATE NOT NULL,
    datum_zavrsetka DATE,
    status ENUM('u tijeku', 'završeni', 'odgođeni') DEFAULT 'u tijeku',
    prioritet ENUM('nizak', 'srednji', 'visok') DEFAULT 'srednji', 
    FOREIGN KEY (id_projekt) REFERENCES projekti(id),
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_datum4 CHECK(datum_pocetka <= IFNULL(datum_zavrsetka, datum_pocetka)) 
);

CREATE TABLE napomene (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    datum DATETIME NOT NULL,
    napomena TEXT NOT NULL,
    tip ENUM('pozitivna', 'negativna') DEFAULT 'pozitivna',
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);


INSERT INTO odjel (naziv, opis) VALUES
('IT', 'Odljel za informatičku podršku i razvoj aplikacija'),
('Prodaja', 'Tim odgovoran za prodaju proizvoda i usluga'),
('Ljudski resursi', 'Odljel za upravljanje ljudskim resursima i zapošljavanje'),
('Marketing', 'Odjel odgovoran za marketing i promociju'),
('Financije', 'Odjel za financijsko planiranje i izvještavanje'),
('Skladište', 'Odljel koji se bavi skladištenjem i distribucijom proizvoda');

INSERT INTO zaposlenik (ime, prezime, oib, spol, email, broj_telefona, datum_zaposljavanja, pozicija, status_zaposlenika, satnica, id_odjel) VALUES
('Ivana', 'Horvat', '12345678901', 'Ž', 'ivana.horvat@example.com', '0912345678', '2022-03-15', 'Programer', 'Aktivan', 45.00, 1),
('Marko', 'Jurić', '23456789012', 'M', 'marko.juric@example.com', '0923456789', '2021-05-10', 'Prodajni menadžer', 'Aktivan', 50.00, 2),
('Ana', 'Marić', '34567890123', 'Ž', 'ana.maric@example.com', '0934567890', '2019-08-20', 'HR specijalist', 'Aktivan', 40.00, 3),
('Petar', 'Kovač', '45678901234', 'M', 'petar.kovac@example.com', '0945678901', '2020-02-05', 'Marketing koordinator', 'Aktivan', 55.00, 4),
('Lucija', 'Novak', '56789012345', 'Ž', 'lucija.novak@example.com', '0956789012', '2021-07-25', 'Računovođa', 'Aktivan', 50.00, 5),
('Tomislav', 'Babić', '67890123456', 'M', 'tomislav.babic@example.com', '0967890123', '2018-11-12', 'Skladištar', 'Aktivan', 35.00, 6),
('Marija', 'Kralj', '78901234567', 'Ž', 'marija.kralj@example.com', '0978901234', '2020-08-15', 'Asistent u ljudskim resursima', 'Aktivan', 38.00, 3),
('Jakov', 'Savić', '89012345678', 'M', 'jakov.savic@example.com', '0989012345', '2021-01-30', 'Specijalist za digitalni marketing', 'Aktivan', 50.00, 4),
('Jana', 'Lukić', '90123456789', 'Ž', 'jana.lukic@example.com', '0990123456', '2022-02-20', 'Administrator sustava', 'Aktivan', 47.00, 1),
('Davor', 'Vuković', '12345098765', 'M', 'davor.vukovic@example.com', '0912345679', '2022-04-25', 'Prodajni asistent', 'Aktivan', 42.00, 2),
('Martina', 'Petrović', '23456123456', 'Ž', 'martina.petrovic@example.com', '0923456780', '2020-10-10', 'Kreativni direktor', 'Aktivan', 60.00, 4),
('Jure', 'Matić', '34567234567', 'M', 'jure.matic@example.com', '0934567891', '2019-06-12', 'Zamjenik direktora', 'Aktivan', 65.00, 5),
('Nina', 'Zorić', '45678345678', 'Ž', 'nina.zoric@example.com', '0945678902', '2021-03-25', 'Pomoćnik za ljudske resurse', 'Aktivan', 40.00, 3),
('Igor', 'Kovačić', '56789456789', 'M', 'igor.kovacic@example.com', '0956789013', '2020-06-15', 'Prodajni menadžer', 'Aktivan', 55.00, 2),
('Tea', 'Horvat', '67890567890', 'Ž', 'tea.horvat@example.com', '0967890124', '2018-09-19', 'Interni auditor', 'Aktivan', 48.00, 5),
('Filip', 'Jovanović', '78901678901', 'M', 'filip.jovanovic@example.com', '0978901235', '2021-12-01', 'Specijalist za SEO', 'Aktivan', 45.00, 4),
('Maja', 'Petrić', '89012789012', 'Ž', 'maja.petric@example.com', '0989012346', '2022-06-05', 'Lektor', 'Aktivan', 30.00, 4),
('Marin', 'Balić', '90123890123', 'M', 'marin.balic@example.com', '0990123457', '2022-01-10', 'Web dizajner', 'Aktivan', 52.00, 1),
('Diana', 'Pavić', '12345987654', 'Ž', 'diana.pavic@example.com', '0912345680', '2019-03-15', 'Menadžer za ljudske resurse', 'Aktivan', 58.00, 3),
('Petar', 'Ladić', '23457098765', 'M', 'petar.ladic@example.com', '0923456781', '2020-07-22', 'Koordinator za prodaju', 'Aktivan', 50.00, 2),
('Nikolina', 'Zubić', '34568109876', 'Ž', 'nikolina.zubic@example.com', '0934567892', '2021-10-11', 'Menadžer za marketing', 'Aktivan', 56.00, 4),
('Damir', 'Knežević', '45679210987', 'M', 'damir.knezevic@example.com', '0945678903', '2021-09-05', 'Skladištar', 'Aktivan', 36.00, 6),
('Sanja', 'Uzelac', '56780321098', 'Ž', 'sanja.uzelac@example.com', '0956789014', '2021-11-10', 'Menadžer za IT podršku', 'Aktivan', 45.00, 1),
('Viktor', 'Kraljević', '67891432109', 'M', 'viktor.kraljevic@example.com', '0967890125', '2020-05-20', 'Marketing asistent', 'Aktivan', 42.00, 4),
('Anamarija', 'Tomić', '78902543210', 'Ž', 'anamarija.tomic@example.com', '0978901236', '2020-12-01', 'Prodajni asistent', 'Aktivan', 39.00, 2),
('Luka', 'Rajić', '89013654321', 'M', 'luka.rajic@example.com', '0989012347', '2021-08-25', 'Računovođa', 'Aktivan', 48.00, 5),
('Iva', 'Stojanović', '90124765432', 'Ž', 'iva.stojanovic@example.com', '0990123458', '2018-12-13', 'Programer', 'Aktivan', 45.00, 1),
('Luka', 'Zorić', '12346776543', 'M', 'luka.zoric@example.com', '0912345670', '2020-05-30', 'SEO stručnjak', 'Aktivan', 55.00, 4),
('Iva', 'Lucić', '23457887654', 'Ž', 'iva.lucic@example.com', '0923456782', '2019-07-25', 'Skladištar', 'Aktivan', 38.00, 6),
('Ivan', 'Bezić', '34568998765', 'M', 'ivan.bezic@example.com', '0934567893', '2021-02-01', 'IT stručnjak', 'Aktivan', 50.00, 1);

INSERT INTO bolovanje (id_zaposlenik, pocetni_datum, krajnji_datum, med_potvrda) VALUES
(1, '2024-11-10', '2024-11-15', TRUE),
(2, '2024-10-05', '2024-10-07', FALSE),
(3, '2024-12-01', '2024-12-10', TRUE),
(4, '2024-08-15', '2024-08-18', TRUE),
(5, '2024-07-20', '2024-07-22', FALSE);

INSERT INTO evidencija_rada (id_zaposlenik, datum, vrijeme_dolaska, vrijeme_odlaska) VALUES
(1, '2024-11-01', '08:00:00', '16:00:00'),
(2, '2024-11-02', '09:00:00', '17:00:00'),
(3, '2024-11-03', '08:30:00', '16:30:00'),
(4, '2024-11-04', '08:00:00', '16:00:00'),
(5, '2024-11-05', '09:00:00', '17:00:00'),
(6, '2024-11-06', '08:15:00', '16:15:00'),
(7, '2024-11-07', '09:00:00', '17:00:00'),
(8, '2024-11-08', '08:30:00', '16:30:00'),
(9, '2024-11-09', '08:00:00', '16:00:00'),
(10, '2024-11-10', '09:00:00', '17:00:00');

INSERT INTO godisnji_odmori (id_zaposlenik, pocetni_datum, zavrsni_datum, status, datum_podnosenja, godina, broj_dana) VALUES
(1, '2024-06-01', '2024-06-10', 'odobren', '2024-05-15', 2024, 10),
(2, '2024-07-05', '2024-07-10', 'na čekanju', '2024-06-15', 2024, 6),
(3, '2024-08-01', '2024-08-05', 'odobren', '2024-07-10', 2024, 5),
(4, '2024-09-01', '2024-09-07', 'odobren', '2024-08-10', 2024, 7),
(5, '2024-10-15', '2024-10-20', 'na čekanju', '2024-09-20', 2024, 6);

INSERT INTO zahtjev_prekovremeni (id_zaposlenik, datum_prekovremeni, sati, razlog, status_pre) VALUES
(1, '2024-11-02', 2, 'Povećani obim posla', 'odobren'),
(2, '2024-11-05', 3, 'Hitna isporuka projekta', 'na čekanju'),
(3, '2024-11-06', 4, 'Popravak sistema', 'odobren'),
(4, '2024-11-08', 2, 'Dodatne obaveze', 'na čekanju'),
(5, '2024-11-10', 5, 'Prebacivanje klijenta na novu platformu', 'odobren');

INSERT INTO preferencije_smjena (id_zaposlenik, vrsta_smjene, datum, prioritet) VALUES
(1, 'jutarnja', '2024-11-01 08:00:00', 5),
(2, 'popodnevna', '2024-11-02 16:00:00', 8),
(3, 'noćna', '2024-11-03 23:00:00', 3),
(4, 'jutarnja', '2024-11-04 08:00:00', 7),
(5, 'popodnevna', '2024-11-05 16:00:00', 6);

INSERT INTO sluzbena_putovanja (id_zaposlenik, pocetni_datum, zavrsni_datum, svrha_putovanja, odrediste, troskovi) VALUES
(1, '2024-06-01', '2024-06-03', 'Posjet klijentima', 'Zagreb', 150.00),
(2, '2024-07-05', '2024-07-07', 'Seminar', 'Split', 200.00),
(3, '2024-08-10', '2024-08-12', 'Sastanak s partnerima', 'Osijek', 250.00),
(4, '2024-09-20', '2024-09-22', 'Posjet klijentima', 'Rijeka', 180.00),
(5, '2024-10-25', '2024-10-27', 'Konferencija', 'Zadar', 220.00);

INSERT INTO dopust (id_zaposlenik, pocetni_datum, zavrsni_datum, tip_dopusta, status, razlog, datum_podnosenja) VALUES
(1, '2024-07-01', '2024-07-10', 'plaćeni', 'odobren', 'Ljetni odmor', '2024-06-01'),
(2, '2024-08-15', '2024-08-20', 'neplaćeni', 'na čekanju', 'Osobni razlog', '2024-07-15'),
(3, '2024-09-01', '2024-09-05', 'plaćeni', 'odobren', 'Obiteljske obveze', '2024-08-05'),
(4, '2024-10-10', '2024-10-15', 'neplaćeni', 'na čekanju', 'Studijski put', '2024-09-10'),
(5, '2024-11-05', '2024-11-10', 'plaćeni', 'odobren', 'Odmor', '2024-10-05');


INSERT INTO napomene (id_zaposlenik, datum, napomena, tip) VALUES
(1, '2024-11-01 09:00:00', 'Dobar rad, povećanje produktivnosti', 'pozitivna'),
(2, '2024-11-02 10:00:00', 'Potreban veći angažman na projektima', 'negativna'),
(3, '2024-11-03 11:00:00', 'Izvrsno obavljen zadatak', 'pozitivna'),
(4, '2024-11-04 12:00:00', 'Neispunjenje rokova za zadatak', 'negativna'),
(5, '2024-11-05 14:00:00', 'Redovito izvršavanje obveza', 'pozitivna');

-- funkcija koja racuna mjesecne place na temelju parametara i zapisuje rezultat u tablicu placa

DROP FUNCTION IF EXISTS mjesecnaPlaca;

DELIMITER //
CREATE FUNCTION mjesecnaPlaca(zaposlenik_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE std_placa DECIMAL(10,2);
    DECLARE broj_sati DECIMAL(10,2);
    DECLARE prekovremeni DECIMAL(10,2);
    DECLARE bolovanje INT;
    DECLARE mjesecna DECIMAL(10,2);

    SELECT satnica INTO std_placa FROM zaposlenik WHERE id = zaposlenik_id;

    SELECT SUM(TIMESTAMPDIFF(HOUR, vrijeme_dolaska, vrijeme_odlaska)) INTO broj_sati 
    FROM evidencija_rada WHERE id_zaposlenik = zaposlenik_id;

    SELECT SUM(GREATEST(0, TIMESTAMPDIFF(HOUR, vrijeme_dolaska, vrijeme_odlaska) - 8)) INTO prekovremeni
    FROM evidencija_rada WHERE id_zaposlenik = zaposlenik_id;

    SELECT COUNT(*) INTO bolovanje 
    FROM bolovanje WHERE id_zaposlenik = zaposlenik_id AND MONTH(pocetni_datum) = MONTH(CURDATE());

    SET mjesecna = (broj_sati * std_placa) + (prekovremeni * std_placa * 1.5) - (bolovanje * 8 * std_placa);

    INSERT INTO place (id_zaposlenik, godina_mjesec, radni_sati, prekovremeni_sati, bolovanje_dani, ukupna_placa)
    VALUES (zaposlenik_id, DATE(CURDATE()), broj_sati, prekovremeni, bolovanje, mjesecna)
    ON DUPLICATE KEY UPDATE ukupna_placa = mjesecna;

    RETURN mjesecna;
END //
DELIMITER ;

SELECT mjesecnaPlaca(4);


-- funkcija koja racuna ukupnu isplacenu placu za zaposlenike u odredenoj godini ukljucujuci obicne i prekovremene sate

DROP FUNCTION IF EXISTS izracunajGodisnjuPlacu;

DELIMITER //
CREATE FUNCTION izracunajGodisnjuPlacu(zaposlenik_id INT, godina INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE ukupna_placa DECIMAL(10,2) DEFAULT 0;
    DECLARE zadana_satnica DECIMAL(10,2);
    
    SELECT satnica INTO zadana_satnica
    FROM zaposlenik
    WHERE id = zaposlenik_id;
    
    SELECT SUM(
        CASE 
            WHEN TIMESTAMPDIFF(HOUR, pocetak_smjene, kraj_smjene) <= 8 THEN TIMESTAMPDIFF(HOUR, pocetak_smjene, kraj_smjene) * zadana_satnica
            ELSE (8 * zadana_satnica) + ((TIMESTAMPDIFF(HOUR, pocetak_smjene, kraj_smjene) - 8) * 1.5 * zadana_satnica)
        END
    ) INTO ukupna_placa
    FROM raspored_rada r
    JOIN smjene s ON r.id_smjena = s.id
    WHERE r.id_zaposlenik = zaposlenik_id AND YEAR(s.pocetak_smjene) = godina;
    
    RETURN ukupna_placa;
END //
DELIMITER ;

SELECT izracunajGodisnjuPlacu(1, 2024);


-- procedura koja odobrava zahtjeve za godisnji odmor ako nema preklapanja sa drugim zaposlenikom ili ako nema dovoljno osoblja u tom periodu

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

INSERT INTO godisnji_odmori (id_zaposlenik, pocetni_datum, zavrsni_datum, status, datum_podnosenja, godina, broj_dana) VALUES
	(7, '2024-2-15', '2024-2-20', 'na čekanju', '2024-09-20', 2024, 6);


-- procedura koja dodaje zaposlenike u smjene prema dostupnosti i zeljenim smjenama zaposlenika

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


INSERT INTO smjene (id, vrsta_smjene, pocetak_smjene, kraj_smjene, min_broj_zaposlenika, id_odjel) 
VALUES (3, 'jutarnja', '2025-01-10 08:00:00', '2025-01-10 16:00:00', 4, 2);

SELECT * FROM raspored_rada WHERE id_zaposlenik = 1;


CALL dodajZaposlenikeUSmjene();


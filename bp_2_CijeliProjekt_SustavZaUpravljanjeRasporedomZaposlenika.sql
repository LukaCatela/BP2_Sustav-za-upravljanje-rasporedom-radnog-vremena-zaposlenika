DROP DATABASE IF EXISTS bp_2_projekt;
CREATE DATABASE bp_2_projekt;
USE bp_2_projekt;

/*----------------------------------------------------------------------------------*/

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
-- Tablica vrsta smjene

CREATE TABLE vrsta_smjene (
    id INT PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL UNIQUE,
    pocetak_smjene TIME NOT NULL,
    kraj_smjene TIME NOT NULL
);

-- Tablica smjena
CREATE TABLE smjene (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_vrsta_smjene INT NOT NULL,
    min_broj_zaposlenika TINYINT UNSIGNED NOT NULL,
    id_odjel INT NOT NULL,
    FOREIGN KEY (id_odjel) REFERENCES odjel(id),
    FOREIGN KEY (id_vrsta_smjene) REFERENCES vrsta_smjene(id)
);

-- Tablica Bolovanja
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
    FOREIGN KEY (id_smjena) REFERENCES smjene(id) ON DELETE CASCADE,
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
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
    ukupna_placa DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK(ukupna_placa >= 0),
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
    CONSTRAINT ck_datum_godisnji CHECK(pocetni_datum <= zavrsni_datum),
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE
);

-- Tablica preferencija zaposlenika za smjene
CREATE TABLE preferencije_smjena(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
	id_vrsta_smjene INT NOT NULL,
    datum DATETIME NOT NULL,
    prioritet TINYINT UNSIGNED NOT NULL,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
	FOREIGN KEY (id_vrsta_smjene) REFERENCES vrsta_smjene(id),
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
    CONSTRAINT ck_putovanje CHECK(pocetni_datum < zavrsni_datum)
);

CREATE TABLE dopust (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    pocetni_datum DATE NOT NULL,
    zavrsni_datum DATE NOT NULL,
    tip_dopusta ENUM('plaćeni', 'neplaćeni') NOT NULL,
    status ENUM('odobren', 'odbijen', 'na čekanju') DEFAULT 'na čekanju',
    razlog VARCHAR(500), 
    datum_podnosenja DATE NOT NULL, 
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
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
    FOREIGN KEY (odgovorna_osoba) REFERENCES zaposlenik(id) ON DELETE CASCADE,
    CONSTRAINT ck_datum_projekt CHECK(datum_pocetka <= datum_zavrsetka)
    -- trigger datum zavrsetka not null, status zavrsen
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
    CONSTRAINT ck_datum_zadaci CHECK(datum_pocetka <= IFNULL(datum_zavrsetka, datum_pocetka)) 
);

CREATE TABLE napomene (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    datum DATETIME NOT NULL,
    napomena TEXT NOT NULL,
    tip ENUM('pozitivna', 'negativna') DEFAULT 'pozitivna',
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE
);
/*----------------------------------------------------------------------------------*/
-- Okidaci


/*----------------------------------------------------------------------------------*/
-- Ubacivanje podataka

INSERT INTO vrsta_smjene (id, naziv, pocetak_smjene, kraj_smjene) VALUES
(1,'jutarnja', '07:00', '15:00'),
(2,'popodnevna', '14:00', '22:00'),
(3,'nocna', '20:00', '24:00');

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
('Sanja', 'Kovačić', '56780321098', 'Ž', 'sanja.kovacic@example.com', '0956789014', '2021-11-10', 'Menadžer za IT podršku', 'Aktivan', 45.00, 1),
('Viktor', 'Kraljević', '67891432109', 'M', 'viktor.kraljevic@example.com', '0967890125', '2020-05-20', 'Marketing asistent', 'Aktivan', 42.00, 4),
('Anamarija', 'Tomić', '78902543210', 'Ž', 'anamarija.tomic@example.com', '0978901236', '2020-12-01', 'Prodajni asistent', 'Aktivan', 39.00, 2),
('Luka', 'Rajić', '89013654321', 'M', 'luka.rajic@example.com', '0989012347', '2021-08-25', 'Računovođa', 'Aktivan', 48.00, 5),
('Iva', 'Stojanović', '90124765432', 'Ž', 'iva.stojanovic@example.com', '0990123458', '2018-12-13', 'Programer', 'Aktivan', 45.00, 1),
('Luka', 'Zorić', '12346776543', 'M', 'luka.zoric@example.com', '0912345670', '2020-05-30', 'SEO stručnjak', 'Aktivan', 55.00, 4),
('Iva', 'Lucić', '23457887654', 'Ž', 'iva.lucic@example.com', '0923456782', '2019-07-25', 'Skladištar', 'Aktivan', 38.00, 6),
('Ivan', 'Bezić', '34568998765', 'M', 'ivan.bezic@example.com', '0934567893', '2021-02-01', 'IT stručnjak', 'Aktivan', 50.00, 1);

INSERT INTO bolovanje (id_zaposlenik, pocetni_datum, krajnji_datum, med_potvrda)
VALUES
(1, '2024-01-01', '2024-01-07', TRUE),
(2, '2024-01-10', '2024-01-15', TRUE),
(3, '2024-02-01', '2024-02-05', TRUE),
(4, '2024-02-10', '2024-02-14', TRUE),
(5, '2024-03-01', '2024-03-07', TRUE),
(6, '2024-03-15', '2024-03-20', TRUE),
(7, '2024-04-01', '2024-04-05', TRUE),
(8, '2024-04-10', '2024-04-15', TRUE),
(9, '2024-05-01', '2024-05-06', TRUE),
(10, '2024-05-10', '2024-05-17', TRUE),
(11, '2024-06-01', '2024-06-07', TRUE),
(12, '2024-06-15', '2024-06-20', TRUE),
(13, '2024-07-01', '2024-07-08', TRUE),
(14, '2024-07-15', '2024-07-22', TRUE),
(15, '2024-08-01', '2024-08-06', TRUE),
(16, '2024-08-10', '2024-08-15', TRUE),
(17, '2024-09-01', '2024-09-05', TRUE),
(18, '2024-09-10', '2024-09-15', FALSE),
(19, '2024-10-01', '2024-10-07', TRUE),
(20, '2024-11-01', '2024-11-06', FALSE);


INSERT INTO smjene (id_vrsta_smjene, min_broj_zaposlenika, id_odjel) VALUES
(1, 5, 1),  -- IT odjel, jutarnja smjena, minimalno 5 zaposlenika
(2, 3, 1),  -- IT odjel, popodnevna smjena, minimalno 3 zaposlenika
(1, 4, 2),  -- Prodaja odjel, jutarnja smjena, minimalno 4 zaposlenika
(2, 2, 2),  -- Prodaja odjel, popodnevna smjena, minimalno 2 zaposlenika
(1, 6, 3),  -- Ljudski resursi odjel, jutarnja smjena, minimalno 6 zaposlenika
(2, 3, 3),  -- Ljudski resursi odjel, popodnevna smjena, minimalno 3 zaposlenika
(1, 4, 4),  -- Marketing odjel, jutarnja smjena, minimalno 4 zaposlenika
(2, 2, 4),  -- Marketing odjel, popodnevna smjena, minimalno 2 zaposlenika
(1, 5, 5),  -- Financije odjel, jutarnja smjena, minimalno 5 zaposlenika
(2, 3, 5),  -- Financije odjel, popodnevna smjena, minimalno 3 zaposlenika
(1, 4, 6),  -- Skladište odjel, jutarnja smjena, minimalno 4 zaposlenika
(2, 2, 6);  -- Skladište odjel, popodnevna smjena, minimalno 2 zaposlenika


INSERT INTO raspored_rada (id_zaposlenik, id_smjena, datum)
VALUES
-- Prosinac 2024
(1, 1, '2024-12-02'), (1, 2, '2024-12-03'), (1, 1, '2024-12-04'), (1, 2, '2024-12-05'), (1, 1, '2024-12-06'),
(1, 2, '2024-12-09'), (1, 1, '2024-12-10'), (1, 2, '2024-12-11'), (1, 1, '2024-12-12'), (1, 2, '2024-12-13'),
(1, 1, '2024-12-16'), (1, 2, '2024-12-17'), (1, 1, '2024-12-18'), (1, 2, '2024-12-19'), (1, 1, '2024-12-20'),
(1, 2, '2024-12-23'), (1, 1, '2024-12-24'), (1, 2, '2024-12-27'), (1, 1, '2024-12-30'), (1, 2, '2024-12-31'),

(2, 1, '2024-12-02'), (2, 2, '2024-12-03'), (2, 1, '2024-12-04'), (2, 2, '2024-12-05'), (2, 1, '2024-12-06'),
(2, 2, '2024-12-09'), (2, 1, '2024-12-10'), (2, 2, '2024-12-11'), (2, 1, '2024-12-12'), (2, 2, '2024-12-13'),
(2, 1, '2024-12-16'), (2, 2, '2024-12-17'), (2, 1, '2024-12-18'), (2, 2, '2024-12-19'), (2, 1, '2024-12-20'),
(2, 2, '2024-12-23'), (2, 1, '2024-12-24'), (2, 2, '2024-12-27'), (2, 1, '2024-12-30'), (2, 2, '2024-12-31'),

(3, 1, '2024-12-02'), (3, 2, '2024-12-03'), (3, 1, '2024-12-04'), (3, 2, '2024-12-05'), (3, 1, '2024-12-06'),
(3, 2, '2024-12-09'), (3, 1, '2024-12-10'), (3, 2, '2024-12-11'), (3, 1, '2024-12-12'), (3, 2, '2024-12-13'),
(3, 1, '2024-12-16'), (3, 2, '2024-12-17'), (3, 1, '2024-12-18'), (3, 2, '2024-12-19'), (3, 1, '2024-12-20'),
(3, 2, '2024-12-23'), (3, 1, '2024-12-24'), (3, 2, '2024-12-27'), (3, 1, '2024-12-30'), (3, 2, '2024-12-31'),

(4, 1, '2024-12-02'), (4, 2, '2024-12-03'), (4, 1, '2024-12-04'), (4, 2, '2024-12-05'), (4, 1, '2024-12-06'),
(4, 2, '2024-12-09'), (4, 1, '2024-12-10'), (4, 2, '2024-12-11'), (4, 1, '2024-12-12'), (4, 2, '2024-12-13'),
(4, 1, '2024-12-16'), (4, 2, '2024-12-17'), (4, 1, '2024-12-18'), (4, 2, '2024-12-19'), (4, 1, '2024-12-20'),
(4, 2, '2024-12-23'), (4, 1, '2024-12-24'), (4, 2, '2024-12-27'), (4, 1, '2024-12-30'), (4, 2, '2024-12-31'),

(5, 1, '2024-12-02'), (5, 2, '2024-12-03'), (5, 1, '2024-12-04'), (5, 2, '2024-12-05'), (5, 1, '2024-12-06'),
(5, 2, '2024-12-09'), (5, 1, '2024-12-10'), (5, 2, '2024-12-11'), (5, 1, '2024-12-12'), (5, 2, '2024-12-13'),
(5, 1, '2024-12-16'), (5, 2, '2024-12-17'), (5, 1, '2024-12-18'), (5, 2, '2024-12-19'), (5, 1, '2024-12-20'),
(5, 2, '2024-12-23'), (5, 1, '2024-12-24'), (5, 2, '2024-12-27'), (5, 1, '2024-12-30'), (5, 2, '2024-12-31'),

(6, 1, '2024-12-02'), (6, 2, '2024-12-03'), (6, 1, '2024-12-04'), (6, 2, '2024-12-05'), (6, 1, '2024-12-06'),
(6, 2, '2024-12-09'), (6, 1, '2024-12-10'), (6, 2, '2024-12-11'), (6, 1, '2024-12-12'), (6, 2, '2024-12-13'),
(6, 1, '2024-12-16'), (6, 2, '2024-12-17'), (6, 1, '2024-12-18'), (6, 2, '2024-12-19'), (6, 1, '2024-12-20'),
(6, 2, '2024-12-23'), (6, 1, '2024-12-24'), (6, 2, '2024-12-27'), (6, 1, '2024-12-30'), (6, 2, '2024-12-31'),

(7, 1, '2024-12-02'), (7, 2, '2024-12-03'), (7, 1, '2024-12-04'), (7, 2, '2024-12-05'), (7, 1, '2024-12-06'),
(7, 2, '2024-12-09'), (7, 1, '2024-12-10'), (7, 2, '2024-12-11'), (7, 1, '2024-12-12'), (7, 2, '2024-12-13'),
(7, 1, '2024-12-16'), (7, 2, '2024-12-17'), (7, 1, '2024-12-18'), (7, 2, '2024-12-19'), (7, 1, '2024-12-20'),
(7, 2, '2024-12-23'), (7, 1, '2024-12-24'), (7, 2, '2024-12-27'), (7, 1, '2024-12-30'), (7, 2, '2024-12-31'),

(30, 2, '2024-12-03'), (30, 1, '2024-12-04'), (30, 2, '2024-12-05'), (30, 1, '2024-12-06'),
(30, 2, '2024-12-09'), (30, 1, '2024-12-10'), (30, 2, '2024-12-11'), (30, 1, '2024-12-12'), (30, 2, '2024-12-13'),
(30, 1, '2024-12-16'), (30, 2, '2024-12-17'), (30, 1, '2024-12-18'), (30, 2, '2024-12-19'), (30, 1, '2024-12-20'),
(30, 2, '2024-12-23'), (30, 1, '2024-12-24'), (30, 2, '2024-12-27'), (30, 1, '2024-12-30'), (30, 2, '2024-12-31');

select * from raspored_rada;

INSERT INTO evidencija_rada (id_zaposlenik, datum, vrijeme_dolaska, vrijeme_odlaska)
VALUES
-- Prosinac 2024
(1, '2024-12-01', '08:00:00', '16:00:00'), 
(2, '2024-12-01', '16:00:00', '23:59:59'),
(3, '2024-12-01', '08:00:00', '16:00:00'), 
(4, '2024-12-01', '16:00:00', '23:59:59'),
(5, '2024-12-01', '08:00:00', '16:00:00'), 
(6, '2024-12-02', '16:00:00', '23:59:59'),
(7, '2024-12-02', '08:00:00', '16:00:00'), 
(8, '2024-12-02', '16:00:00', '23:59:59'),
(9, '2024-12-02', '08:00:00', '16:00:00'), 
(10, '2024-12-02', '16:00:00', '23:59:59'),
(11, '2024-12-03', '08:00:00', '16:00:00'), 
(12, '2024-12-03', '16:00:00', '23:59:59'),
(13, '2024-12-03', '08:00:00', '16:00:00'), 
(14, '2024-12-03', '16:00:00', '23:59:59'),
(15, '2024-12-03', '08:00:00', '16:00:00'), 
(16, '2024-12-04', '16:00:00', '23:59:59'),
(17, '2024-12-04', '08:00:00', '16:00:00'), 
(18, '2024-12-04', '16:00:00', '23:59:59'),
(19, '2024-12-04', '08:00:00', '16:00:00'), 
(20, '2024-12-04', '16:00:00', '23:59:59'),
(21, '2024-12-05', '08:00:00', '16:00:00'), 
(22, '2024-12-05', '16:00:00', '23:59:59'),
(23, '2024-12-05', '08:00:00', '16:00:00'), 
(24, '2024-12-05', '16:00:00', '23:59:59'),
(25, '2024-12-05', '08:00:00', '16:00:00'),

-- Siječanj 2025
(1, '2025-01-01', '16:00:00', '23:59:59'), 
(2, '2025-01-01', '08:00:00', '16:00:00'),
(3, '2025-01-01', '16:00:00', '23:59:59'), 
(4, '2025-01-01', '08:00:00', '16:00:00'),
(5, '2025-01-01', '16:00:00', '23:59:59'), 
(6, '2025-01-02', '08:00:00', '16:00:00'),
(7, '2025-01-02', '16:00:00', '23:59:59'), 
(8, '2025-01-02', '08:00:00', '16:00:00'),
(9, '2025-01-02', '16:00:00', '23:59:59'), 
(10, '2025-01-02', '08:00:00', '16:00:00'),
(11, '2025-01-03', '16:00:00', '23:59:59'), 
(12, '2025-01-03', '08:00:00', '16:00:00'),
(13, '2025-01-03', '16:00:00', '23:59:59'), 
(14, '2025-01-03', '08:00:00', '16:00:00'),
(15, '2025-01-03', '16:00:00', '23:59:59');


INSERT INTO place (id_zaposlenik, godina_mjesec, radni_sati, prekovremeni_sati, bolovanje_dani, ukupna_placa)
VALUES
-- Studeni 2024
(1, '2024-11-01', 160, 10, 2, 2000.00),
(2, '2024-11-01', 150, 5, 0, 1900.00),
(3, '2024-11-01', 140, 12, 1, 2100.00),
(4, '2024-11-01', 160, 8, 0, 2050.00),
(5, '2024-11-01', 155, 15, 3, 2300.00),
(6, '2024-11-01', 150, 5, 0, 1900.00),
(7, '2024-11-01', 145, 7, 1, 2000.00),
(8, '2024-11-01', 160, 10, 0, 2100.00),
(9, '2024-11-01', 155, 20, 0, 2400.00),
(10, '2024-11-01', 150, 12, 0, 2200.00),
(11, '2024-11-01', 160, 10, 0, 2000.00),
(12, '2024-11-01', 140, 8, 0, 1800.00),
(13, '2024-11-01', 150, 5, 1, 1900.00),
(14, '2024-11-01', 145, 12, 0, 2100.00),
(15, '2024-11-01', 160, 10, 0, 2050.00),
(16, '2024-11-01', 155, 7, 0, 2000.00),
(17, '2024-11-01', 150, 5, 0, 1900.00),
(18, '2024-11-01', 160, 15, 0, 2250.00),
(19, '2024-11-01', 150, 8, 2, 2000.00),
(20, '2024-11-01', 145, 5, 0, 1850.00),
(21, '2024-11-01', 160, 10, 0, 2000.00),
(22, '2024-11-01', 155, 8, 1, 2050.00),
(23, '2024-11-01', 150, 7, 0, 1900.00),
(24, '2024-11-01', 140, 15, 0, 2200.00),
(25, '2024-11-01', 150, 12, 0, 2100.00),
(26, '2024-11-01', 155, 10, 0, 2000.00),
(27, '2024-11-01', 150, 5, 0, 1900.00),
(28, '2024-11-01', 160, 8, 0, 1950.00),
(29, '2024-11-01', 150, 7, 0, 1850.00),
(30, '2024-11-01', 160, 10, 0, 2000.00),

-- Prosinac 2024
(1, '2024-12-01', 140, 5, 0, 1800.00),
(2, '2024-12-01', 150, 8, 1, 1900.00),
(3, '2024-12-01', 155, 10, 0, 2000.00),
(4, '2024-12-01', 145, 15, 0, 2200.00),
(5, '2024-12-01', 160, 12, 0, 2100.00),
(6, '2024-12-01', 150, 8, 0, 2000.00),
(7, '2024-12-01', 160, 7, 0, 1900.00),
(8, '2024-12-01', 140, 10, 0, 2000.00),
(9, '2024-12-01', 150, 20, 2, 2400.00),
(10, '2024-12-01', 160, 15, 0, 2300.00),
(11, '2024-12-01', 150, 8, 0, 2000.00),
(12, '2024-12-01', 145, 7, 1, 1900.00),
(13, '2024-12-01', 155, 10, 0, 2000.00),
(14, '2024-12-01', 160, 12, 0, 2100.00),
(15, '2024-12-01', 150, 15, 0, 2200.00),
(16, '2024-12-01', 140, 8, 0, 1800.00),
(17, '2024-12-01', 160, 5, 0, 1900.00),
(18, '2024-12-01', 150, 10, 0, 2000.00),
(19, '2024-12-01', 160, 8, 1, 1950.00),
(20, '2024-12-01', 140, 5, 0, 1850.00),
(21, '2024-12-01', 150, 8, 0, 1900.00),
(22, '2024-12-01', 160, 12, 0, 2100.00),
(23, '2024-12-01', 150, 7, 0, 1900.00),
(24, '2024-12-01', 145, 10, 0, 2000.00),
(25, '2024-12-01', 140, 8, 0, 1900.00),
(26, '2024-12-01', 160, 12, 0, 2100.00),
(27, '2024-12-01', 150, 5, 1, 1900.00),
(28, '2024-12-01', 140, 8, 0, 1950.00),
(29, '2024-12-01', 155, 7, 0, 2000.00),
(30, '2024-12-01', 160, 10, 0, 2100.00),

-- Siječanj 2025
(1, '2025-01-01', 155, 5, 0, 1900.00),
(2, '2025-01-01', 150, 12, 1, 2000.00),
(3, '2025-01-01', 140, 8, 0, 1900.00),
(4, '2025-01-01', 160, 10, 0, 2000.00),
(5, '2025-01-01', 155, 12, 0, 2100.00),
(6, '2025-01-01', 160, 15, 0, 2300.00),
(7, '2025-01-01', 150, 8, 0, 2000.00),
(8, '2025-01-01', 140, 7, 1, 1800.00),
(9, '2025-01-01', 160, 10, 0, 2000.00),
(10, '2025-01-01', 155, 12, 0, 2100.00),
(11, '2025-01-01', 160, 15, 0, 2200.00),
(12, '2025-01-01', 140, 8, 0, 1900.00),
(13, '2025-01-01', 150, 10, 1, 2000.00),
(14, '2025-01-01', 160, 12, 0, 2100.00),
(15, '2025-01-01', 155, 15, 0, 2200.00),
(16, '2025-01-01', 140, 8, 0, 1800.00),
(17, '2025-01-01', 160, 5, 0, 1900.00),
(18, '2025-01-01', 150, 10, 0, 2000.00),
(19, '2025-01-01', 160, 8, 1, 1950.00),
(20, '2025-01-01', 140, 5, 0, 1850.00),
(21, '2025-01-01', 150, 8, 0, 1900.00),
(22, '2025-01-01', 160, 12, 0, 2100.00),
(23, '2025-01-01', 150, 7, 0, 1900.00),
(24, '2025-01-01', 145, 10, 0, 2000.00),
(25, '2025-01-01', 140, 8, 0, 1900.00),
(26, '2025-01-01', 160, 12, 0, 2100.00),
(27, '2025-01-01', 150, 5, 1, 1900.00),
(28, '2025-01-01', 140, 8, 0, 1950.00),
(29, '2025-01-01', 155, 7, 0, 2000.00),
(30, '2025-01-01', 160, 10, 0, 2100.00);


INSERT INTO godisnji_odmori (id_zaposlenik, pocetni_datum, zavrsni_datum, status, datum_podnosenja, godina, broj_dana) VALUES
(1, '2024-06-01', '2024-06-10', 'odobren', '2024-05-15', 2024, 10),
(2, '2024-07-05', '2024-07-10', 'na čekanju', '2024-06-15', 2024, 6),
(3, '2024-08-01', '2024-08-05', 'odobren', '2024-07-10', 2024, 5),
(4, '2024-09-01', '2024-09-07', 'odobren', '2024-08-10', 2024, 7),
(5, '2024-10-15', '2024-10-20', 'na čekanju', '2024-09-20', 2024, 6);

INSERT INTO zahtjev_prekovremeni (id_zaposlenik, datum_prekovremeni, sati, razlog, status_pre)
VALUES
(1, '2024-12-01', 4, 'Projektna faza završetka', 'odobren'),
(2, '2024-12-02', 2, 'Održavanje sustava', 'odobren'),
(3, '2024-12-03', 3, 'Priprema prezentacije', 'na čekanju'),
(4, '2024-12-04', 5, 'Hitna isporuka klijentu', 'odobren'),
(5, '2024-12-05', 4, 'Nedostatak osoblja', 'odbijen'),
(6, '2024-12-06', 2, 'Dovršetak izvještaja', 'odobren'),
(7, '2024-12-07', 6, 'Planiranje strategije', 'na čekanju'),
(8, '2024-12-08', 4, 'Testiranje aplikacije', 'odobren'),
(9, '2024-12-09', 3, 'Migracija podataka', 'odobren'),
(10, '2024-12-10', 4, 'Priprema materijala za edukaciju', 'odbijen'),
(11, '2024-12-11', 5, 'Organizacija eventa', 'odobren'),
(12, '2024-12-12', 6, 'Popravak hardvera', 'odobren'),
(13, '2024-12-13', 4, 'Optimizacija procesa', 'na čekanju'),
(14, '2024-12-14', 3, 'Sigurnosni pregled', 'odobren'),
(15, '2024-12-15', 7, 'Razvoj softverskog modula', 'odobren'),
(16, '2024-12-16', 4, 'Analiza financija', 'na čekanju'),
(17, '2024-12-17', 5, 'Edukacija novozaposlenih', 'odobren'),
(18, '2024-12-18', 4, 'Razvoj softverskog modula', 'odbijen'),
(19, '2024-12-19', 2, 'Planiranje događaja', 'odobren'),
(20, '2024-12-20', 5, 'Hitni zadatak klijenta', 'odobren'),
(21, '2024-12-21', 6, 'Ažuriranje sustava', 'odobren'),
(22, '2024-12-22', 3, 'Isporuka proizvoda', 'odobren'),
(23, '2024-12-23', 4, 'Dodatne analize', 'odobren'),
(24, '2024-12-24', 4, 'Priprema nove strategije', 'odobren'),
(25, '2024-12-25', 5, 'Tehnička podrška', 'odobren'),
(26, '2024-12-26', 4, 'Ispitivanje tržišta', 'odobren'),
(27, '2024-12-27', 2, 'Prezentacija upravi', 'na čekanju'),
(28, '2024-12-28', 3, 'Razvoj marketing plana', 'odobren'),
(29, '2024-12-29', 4, 'Priprema godišnjeg izvješća', 'na čekanju'),
(30, '2024-12-30', 5, 'Unapređenje sustava', 'odobren');

INSERT INTO preferencije_smjena (id_zaposlenik, id_vrsta_smjene, datum, prioritet)
VALUES
(1, 1, '2024-12-01 08:00:00', 5),
(2, 2, '2024-12-02 16:00:00', 7),
(3, 3, '2024-12-03 23:00:00', 6),
(4, 1, '2024-12-04 08:00:00', 8),
(5, 2, '2024-12-05 16:00:00', 3),
(6, 3, '2024-12-06 23:00:00', 4),
(7, 1, '2024-12-07 08:00:00', 9),
(8, 2, '2024-12-08 16:00:00', 5),
(9, 3, '2024-12-09 23:00:00', 2),
(10, 1, '2024-12-10 08:00:00', 10),
(11, 2, '2024-12-11 16:00:00', 6),
(12, 3, '2024-12-12 23:00:00', 7),
(13, 1, '2024-12-13 08:00:00', 5),
(14, 2, '2024-12-14 16:00:00', 4),
(15, 3, '2024-12-15 23:00:00', 8),
(16, 1, '2024-12-16 08:00:00', 9),
(17, 2, '2024-12-17 16:00:00', 5),
(18, 3, '2024-12-18 23:00:00', 6),
(19, 1, '2024-12-19 08:00:00', 7),
(20, 2, '2024-12-20 16:00:00', 8),
(21, 3, '2024-12-21 23:00:00', 3),
(22, 1, '2024-12-22 08:00:00', 4),
(23, 2, '2024-12-23 16:00:00', 6),
(24, 3, '2024-12-24 23:00:00', 9),
(25, 1, '2024-12-25 08:00:00', 10),
(26, 2, '2024-12-26 16:00:00', 6),
(27, 3, '2024-12-27 23:00:00', 4),
(28, 1, '2024-12-28 08:00:00', 7),
(29, 2, '2024-12-29 16:00:00', 5),
(30, 3, '2024-12-30 23:00:00', 8);



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

INSERT INTO projekti (naziv, opis, datum_pocetka, datum_zavrsetka, status, odgovorna_osoba)
VALUES
('Projekt Alfa', 'Razvoj novog softverskog sustava.', '2023-01-01', '2023-06-30', 'završeni', 1),
('Projekt Beta', 'Modernizacija postojećeg sustava.', '2023-05-01', '2024-01-15', 'aktivni', 2),
('Projekt Gamma', 'Istraživanje novih tehnologija.', '2023-02-15', NULL, 'aktivni', 3),
('Projekt Delta', 'Optimizacija procesa proizvodnje.', '2022-11-01', '2023-12-01', 'završeni', 4),
('Projekt Epsilon', 'Razvoj e-trgovine.', '2023-08-01', '2024-05-01', 'aktivni', 5),
('Projekt Zeta', 'Implementacija AI modela.', '2023-06-01', '2023-11-30', 'završeni', 6),
('Projekt Eta', 'Razvoj aplikacije za mobilne uređaje.', '2024-01-01', '2024-12-31', 'odgođeni', 7),
('Projekt Theta', 'Migracija podataka u cloud.', '2023-03-01', NULL, 'aktivni', 8),
('Projekt Iota', 'Testiranje sigurnosnih protokola.', '2023-09-01', NULL, 'odgođeni', 9),
('Projekt Kappa', 'Planiranje nove mrežne infrastrukture.', '2023-10-01', '2023-12-15', 'završeni', 10);

/*----------------------------------------------------------------------------------*/
-- Pogledi, Procedure, Funkcije, Slozeni upiti
-- Slozeni upiti




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

-- 3. View

-- 4. View

-- 5. View
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

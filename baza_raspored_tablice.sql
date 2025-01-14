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
    CONSTRAINT ck_datum_smjene CHECK(pocetak_smjene < kraj_smjene),
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
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
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
    vrsta_smjene ENUM('jutarnja', 'popodnevna', 'nocna') NOT NULL,
    datum DATETIME NOT NULL,
    prioritet TINYINT UNSIGNED NOT NULL,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id) ON DELETE CASCADE,
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

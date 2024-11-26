DROP DATABASE IF EXISTS bp_2_projekt;
CREATE DATABASE bp_2_projekt;
USE bp_2_projekt;

CREATE TABLE zaposlenik(
id INT PRIMARY KEY AUTO_INCREMENT,
ime VARCHAR(20) NOT NULL,
prezime VARCHAR(20) NOT NULL,
email VARCHAR(50) NOT NULL, 
broj_telefona VARCHAR(20) NOT NULL,
datum_zaposljavanja DATE NOT NULL,
pozicija VARCHAR(20) NOT NULL,
`status` ENUM('zaposlen', 'nezaposlen', 'penzija (segi)', 'pripravnik', 'student') NOT NULL
);
CREATE TABLE smjene(
id INT PRIMARY KEY AUTO_INCREMENT,
vrsta_smjene ENUM('jutarnja', 'popodnevna', 'nocna') NOT NULL,
pocetak_smjene DATETIME NOT NULL,
kraj_smjene DATETIME NOT NULL,
min_broj_zaposlenika TINYINT NOT NULL
);
CREATE TABLE zeljene_smjene(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
id_smjene INT NOT NULL,
mogucnost_ostvarivanja BOOL NOT NULL,
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
FOREIGN KEY (id_smjene) REFERENCES smjene(id)
);
CREATE TABLE bolovanje(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
pocetni_datum DATE NOT NULL,
krajnji_datum DATE NOT NULL,
med_potvrda BOOL NOT NULL
);
CREATE TABLE raspored_rada(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
id_smjena INT NOT NULL,
datum DATE NOT NULL,
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
FOREIGN KEY (id_smjena) REFERENCES smjene(id)
);
CREATE TABLE prisutnost(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
check_in DATETIME NOT NULL,
check_out DATETIME NOT NULL,
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);
CREATE TABLE place(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
godina_mjesec DATE NOT NULL,
radni_sati INT NOT NULL,
prekovremeni_sati INT NOT NULL,
id_bolovanje INT NOT NULL,
ukupna_placa INT NOT NULL,
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
FOREIGN KEY (id_bolovanje) REFERENCES bolovanje(id)
);
CREATE TABLE zahtjevni_godisnji_odmor(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
pocetni_datum DATE NOT NULL,
zavrsni_datum DATE NOT NULL,
status_god ENUM('odobren', 'odbijen', 'nedefinirano') DEFAULT ('nedefinirano'),
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);
CREATE TABLE kalendar_godisnjih_odmora(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
pocetak_godisnjeg DATE NOT NULL,
trajanje INT NOT NULL
);
CREATE TABLE ogranicenja_tvrtke(
id INT PRIMARY KEY AUTO_INCREMENT,
vrsta_ogranicenja VARCHAR(20) -- Kasnije dodati enum svake vrste
);
CREATE TABLE zahtjev_prekovremeni(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
datum_prekovremeni DATE NOT NULL,
sati INT NOT NULL,
status_pre VARCHAR(20), -- Kasnije dodati enum svake vrste
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);
CREATE TABLE radni_sati(
id INT PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INT NOT NULL,
datum_rada DATE NOT NULL,
broj_sati INT NOT NULL,
prekovremeni_sati INT NOT NULL,
FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);

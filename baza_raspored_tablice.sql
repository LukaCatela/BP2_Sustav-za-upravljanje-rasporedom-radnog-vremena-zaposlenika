DROP DATABASE IF EXISTS bp_2_projekt;
CREATE DATABASE bp_2_projekt;
USE bp_2_projekt;

-- Tablica odjela -> npr. "Podrška", "Razvoj", "Uprava" .... (dovoljno da imate samo ova 3 odjela u tablici, ne trebate dodavati više)
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
    min_broj_zaposlenika TINYINT UNSIGNED NOT NULL, -- UNSIGNED jer broj_zapo ne moze bit negativan
    id_odjel INTEGER NOT NULL, -- dodano da znate u kojem odjelu se kako radi koja smjena (npr. u podrški )
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

-- Tablica rasporeda rada -> prema ovoj tablici će zaposlenik moći vidjeti koje smjene mora raditi u budućnosti [popunjava algoritam]
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

-- Tablica evidencije dolazaka i odlazaka (inicijalno se zvala "prisutnost", ovo će se koristiti za obračun plaće, stvarno odrađeni sati)
-- tablica je djelomično vezana uz raspored_rada i ima smisla da je odvojena tablica zato jer zaposlenik može više puta doći na posao u istom danu (npr. otiđe na marendu pa se "odjavi", a kada dođe natrag se ponovno "prijavi")
-- nema id_raspored_rada u ovoj tablici jer zaposlenik može doći na posao čak i kada mu nije definirano u rasporedu (npr. desi se iznenada neki problem)
CREATE TABLE evidencija_rada(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    datum DATE NOT NULL,
    vrijeme_dolaska TIME NOT NULL,
    vrijeme_odlaska TIME NOT NULL,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT ck_vrijeme CHECK(vrijeme_dolaska < vrijeme_odlaska)
);

-- Tablica plaća -> ovu tablicu isključivo popunjava procedura (nikada ručno), predlažem da na kraju mjeseca procedura obračuna plaće za sve zaposlenike
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

-- Tablica zahtjeva za godišnji odmor
CREATE TABLE zahtjev_godisnji_odmor(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    pocetni_datum DATE NOT NULL,
    zavrsni_datum DATE NOT NULL,
    status_god ENUM('odobren', 'odbijen', 'nedefinirano') DEFAULT 'nedefinirano', -- ovaj status se može izmjeniti sa procedurom u odgovarajuću vrijednost nakon što izračunate konačni raspored godišnjih
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);

-- Tablica za izračunate (i konačne) periode godišnjih odmora (dorađena tablica "kalendar_godisnjih_odmora") [popunjava algoritam]
-- nije baš najbolje rješenje jer su tablice "zahtjev_godisnji_odmor" i "godisnji_odmori" slične pa bi ih u idealnom slučaju trebalo spojiti u jednu tablicu, ali ovako će vam bit lakše napraviti pa predlažem da ostavite ovako
CREATE TABLE godisnji_odmori(
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_zaposlenik INT NOT NULL,
  pocetni_datum DATE NOT NULL,
  zavrsni_datum DATE NOT NULL
  -- isto treba kroz okidac/proceduru provjeriti da zaposlenik nema više od 30 dana godišnjeg na godinu
);


-- Tablica zahtjeva za prekovremene --> ova tablica čak i ima smisla ako želite "opravdati" kada se zaposlenik "chekira" na posao izvan smjene koja mu je po rasporedu. To onda možete uzeti u obzir kod obračuna plaće gdje ćete obračunati samo "Odobrene" prekovremene
CREATE TABLE zahtjev_prekovremeni(
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INT NOT NULL,
    datum_prekovremeni DATE NOT NULL,
    sati INT NOT NULL,
    razlog VARCHAR(1000), -- dodan ovaj atribut da se može opisati zašto se traži odobrenje prekovremenih (npr. desio se problem u poslovanju pa je zaposlenik došao)
    status_pre VARCHAR(20), -- Kasnije dodati enum svake vrste
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

-- Tablica sluzbena putovanja -> ako je zaposlenik na službenom putovanju (npr. sastanak, edukacija, neka prezentacija, itd.) onda mu se može obračunati dodatna satnica kod obračuna plaće
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


-- još možete dodati tablicu za evidenciju "dopusta", možete napraviti tablicu gdje će se evidentirati "zahtjev" od strane zaposlenika za "dopust", pa onda poslodavac može odobriti ili odbiti taj dopust, te dopust može biti plaćeni ili neplaćeni (to isto ulazi u onaj obračun plaće)
-- ako nemate ideje za dodatne tablice možete malo izaći iz okvira projekta pa napraviti evidenciju projekata koji se rade u firmi, pa onda napraviti evidenciju radnih zadataka zaposleniku (npr. za određeni period mora napraviti neki određeni zadatak koji je vezan uz projekt)

USE bp_2_projekt;
-- View
Select * FROM zaposlenici_odjeli;
SELECT * FROM aktivni_projekti;
SELECT * FROM aktivni_zaposlenici;
SELECT * FROM mjesecne_place;
SELECT * FROM troskovi_sluzbenih_putovanja;

-- Procedure
/*CALL dodaj_zaposlenika(
    'Marko', 'Horvat', '12345678923', 'M', 'marko.horvat@email.com', '0911234567', '2025-01-10', 'Developer', 'aktivan', 50.00, 1
);*/
Select * from zaposlenik;

/*
CALL GenerirajRaspored('2025-05-01', '2025-05-31', 5);
SELECT * FROM raspored_rada ORDER BY datum;
select id_smjena from raspored_rada;
*/
CALL prijenos_projekta_drugom_zaposleniku(8, 12);
SELECT * FROM projekti WHERE id = 8;

CALL UkupniIzvjestajTroskovaMjesec('2025-01');

-- Funkcije
SELECT mjesecnaPlaca(1);
SELECT mjesecnaPlaca(2);
SELECT mjesecnaPlaca(3);
SELECT mjesecnaPlaca(4);
SELECT mjesecnaPlaca(5);
SELECT mjesecnaPlaca(6);
SELECT mjesecnaPlaca(7);
SELECT mjesecnaPlaca(30);
SELECT * FROM place;
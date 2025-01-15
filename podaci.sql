USE bp_2_projekt;

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

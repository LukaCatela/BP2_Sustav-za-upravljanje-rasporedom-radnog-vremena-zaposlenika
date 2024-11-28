INSERT INTO smjene (vrsta_smjene, pocetak_smjene, kraj_smjene, min_broj_zaposlenika) VALUES
('jutarnja', '2024-11-20 08:00:00', '2024-11-20 16:00:00', 3),
('jutarnja', '2024-11-21 08:00:00', '2024-11-21 16:00:00', 4),
('popodnevna', '2024-11-20 16:00:00', '2024-11-20 23:00:00', 2),
('popodnevna', '2024-11-21 16:00:00', '2024-11-21 23:00:00', 2),
('nocna', '2024-11-20 00:00:00', '2024-11-20 08:00:00', 1),
('nocna', '2024-11-21 00:00:00', '2024-11-21 08:00:00', 2),
('jutarnja', '2024-11-22 08:00:00', '2024-11-22 16:00:00', 3),
('popodnevna', '2024-11-22 16:00:00', '2024-11-22 23:00:00', 3),
('nocna', '2024-11-22 00:00:00', '2024-11-22 08:00:00', 1),
('jutarnja', '2024-11-23 08:00:00', '2024-11-23 16:00:00', 2),
('popodnevna', '2024-11-23 16:00:00', '2024-11-23 23:00:00', 1),
('nocna', '2024-11-23 00:00:00', '2024-11-23 08:00:00', 1),
('jutarnja', '2024-11-24 08:00:00', '2024-11-24 16:00:00', 4),
('popodnevna', '2024-11-24 16:00:00', '2024-11-24 23:00:00', 4),
('nocna', '2024-11-24 00:00:00', '2024-11-24 08:00:00', 3),
('jutarnja', '2024-11-25 08:00:00', '2024-11-25 16:00:00', 2),
('popodnevna', '2024-11-25 16:00:00', '2024-11-25 23:00:00', 3),
('nocna', '2024-11-25 00:00:00', '2024-11-25 08:00:00', 1),
('jutarnja', '2024-11-26 08:00:00', '2024-11-26 16:00:00', 3),
('nocna', '2024-11-26 00:00:00', '2024-11-26 08:00:00', 1);

INSERT INTO zeljene_smjene (id_zaposlenik, id_smjene, mogucnost_ostvarivanja) VALUES
(1, 1, TRUE), (2, 2, FALSE), (3, 3, TRUE), (4, 4, TRUE),
(5, 5, FALSE), (6, 6, TRUE), (7, 7, TRUE), (8, 8, TRUE),
(9, 9, FALSE), (10, 10, TRUE), (11, 11, TRUE), (12, 12, TRUE),
(13, 13, FALSE), (14, 14, TRUE), (15, 15, TRUE), (16, 16, TRUE),
(17, 17, TRUE), (18, 18, TRUE), (19, 19, FALSE), (20, 20, TRUE);

INSERT INTO bolovanje (id_zaposlenik, pocetni_datum, krajnji_datum, med_potvrda) VALUES
(1, '2024-10-01', '2024-10-05', TRUE), (2, '2024-09-15', '2024-09-18', TRUE),
(3, '2024-11-05', '2024-11-10', TRUE), (4, '2024-08-01', '2024-08-07', FALSE),
(5, '2024-07-20', '2024-07-24', TRUE), (6, '2024-06-10', '2024-06-15', FALSE),
(7, '2024-04-05', '2024-04-09', TRUE), (8, '2024-02-01', '2024-02-03', TRUE),
(9, '2024-01-15', '2024-01-20', FALSE), (10, '2024-05-10', '2024-05-13', TRUE),
(11, '2024-03-01', '2024-03-04', TRUE), (12, '2024-12-05', '2024-12-10', FALSE),
(13, '2024-10-20', '2024-10-25', TRUE), (14, '2024-09-05', '2024-09-10', TRUE),
(15, '2024-08-15', '2024-08-19', FALSE), (16, '2024-07-05', '2024-07-08', TRUE),
(17, '2024-06-20', '2024-06-23', TRUE), (18, '2024-05-01', '2024-05-06', FALSE),
(19, '2024-04-15', '2024-04-18', TRUE), (20, '2024-03-20', '2024-03-23', TRUE);

INSERT INTO raspored_rada (id_zaposlenik, id_smjena, datum) VALUES
(1, 1, '2024-11-01'), (2, 2, '2024-11-02'), (3, 3, '2024-11-03'), (4, 4, '2024-11-04'),
(5, 5, '2024-11-05'), (6, 6, '2024-11-06'), (7, 7, '2024-11-07'), (8, 8, '2024-11-08'),
(9, 9, '2024-11-09'), (10, 10, '2024-11-10'), (11, 11, '2024-11-11'), (12, 12, '2024-11-12'),
(13, 13, '2024-11-13'), (14, 14, '2024-11-14'), (15, 15, '2024-11-15'), (16, 16, '2024-11-16'),
(17, 17, '2024-11-17'), (18, 18, '2024-11-18'), (19, 19, '2024-11-19'), (20, 20, '2024-11-20');

INSERT INTO prisutnost (id_zaposlenik, check_in, check_out) VALUES
(1, '2024-11-01 08:00:00', '2024-11-01 16:00:00'), (2, '2024-11-02 16:00:00', '2024-11-02 23:00:00'),
(3, '2024-11-03 00:00:00', '2024-11-03 08:00:00'), (4, '2024-11-04 08:00:00', '2024-11-04 16:00:00'),
(5, '2024-11-05 16:00:00', '2024-11-05 23:00:00'), (6, '2024-11-06 00:00:00', '2024-11-06 08:00:00'),
(7, '2024-11-07 08:00:00', '2024-11-07 16:00:00'), (8, '2024-11-08 16:00:00', '2024-11-08 23:00:00'),
(9, '2024-11-09 00:00:00', '2024-11-09 08:00:00'), (10, '2024-11-10 08:00:00', '2024-11-10 16:00:00'),
(11, '2024-11-11 16:00:00', '2024-11-11 23:00:00'), (12, '2024-11-12 00:00:00', '2024-11-12 08:00:00'),
(13, '2024-11-13 08:00:00', '2024-11-13 16:00:00'), (14, '2024-11-14 16:00:00', '2024-11-14 23:00:00'),
(15, '2024-11-15 00:00:00', '2024-11-15 08:00:00'), (16, '2024-11-16 08:00:00', '2024-11-16 16:00:00'),
(17, '2024-11-17 16:00:00', '2024-11-17 23:00:00'), (18, '2024-11-18 00:00:00', '2024-11-18 08:00:00'),
(19, '2024-11-19 08:00:00', '2024-11-19 16:00:00'), (20, '2024-11-20 16:00:00', '2024-11-20 23:00:00');

INSERT INTO place (id_zaposlenik, godina_mjesec, radni_sati, prekovremeni_sati, id_bolovanje, ukupna_placa) VALUES
(1, '2024-10-01', 160, 20, 1, 1200), (2, '2024-10-01', 150, 10, 2, 1100),
(3, '2024-10-01', 140, 5, 3, 1000), (4, '2024-10-01', 170, 15, 4, 1300),
(5, '2024-10-01', 180, 25, 5, 1400), (6, '2024-10-01', 160, 0, 6, 1150),
(7, '2024-10-01', 155, 8, 7, 1120), (8, '2024-10-01', 165, 12, 8, 1180),
(9, '2024-10-01', 160, 10, 9, 1200), (10, '2024-10-01', 170, 18, 10, 1250),
(11, '2024-10-01', 180, 22, 11, 1350), (12, '2024-10-01', 150, 6, 12, 1100),
(13, '2024-10-01', 160, 8, 13, 1200), (14, '2024-10-01', 165, 10, 14, 1225),
(15, '2024-10-01', 170, 12, 15, 1275), (16, '2024-10-01', 155, 5, 16, 1130),
(17, '2024-10-01', 160, 8, 17, 1180), (18, '2024-10-01', 175, 15, 18, 1280),
(19, '2024-10-01', 180, 20, 19, 1350), (20, '2024-10-01', 150, 5, 20, 1100);

INSERT INTO zahtjevni_godisnji_odmor (id_zaposlenik, pocetni_datum, zavrsni_datum, status_god) VALUES
(1, '2024-12-01', '2024-12-10', 'odobren'), (2, '2024-11-15', '2024-11-20', 'odbijen'),
(3, '2024-10-05', '2024-10-15', 'odobren'), (4, '2024-09-01', '2024-09-07', 'odobren'),
(5, '2024-08-20', '2024-08-25', 'odbijen'), (6, '2024-07-10', '2024-07-15', 'odobren'),
(7, '2024-06-01', '2024-06-07', 'odobren'), (8, '2024-05-15', '2024-05-20', 'odobren'),
(9, '2024-04-01', '2024-04-10', 'odobren'), (10, '2024-03-20', '2024-03-25', 'odbijen'),
(11, '2024-02-15', '2024-02-20', 'odobren'), (12, '2024-01-01', '2024-01-07', 'odobren'),
(13, '2023-12-10', '2023-12-15', 'odobren'), (14, '2023-11-20', '2023-11-25', 'odbijen'),
(15, '2023-10-01', '2023-10-07', 'odobren'), (16, '2023-09-15', '2023-09-20', 'odobren'),
(17, '2023-08-01', '2023-08-10', 'odobren'), (18, '2023-07-10', '2023-07-15', 'odobren'),
(19, '2023-06-01', '2023-06-05', 'odobren'), (20, '2023-05-20', '2023-05-25', 'odobren');


INSERT INTO kalendar_godisnjih_odmora (id_zaposlenik, pocetak_godisnjeg, trajanje) VALUES
(1, '2024-12-01', 10), (2, '2024-11-15', 5), (3, '2024-10-05', 10), (4, '2024-09-01', 7),
(5, '2024-08-20', 5), (6, '2024-07-10', 5), (7, '2024-06-01', 7), (8, '2024-05-15', 5),
(9, '2024-04-01', 10), (10, '2024-03-20', 5), (11, '2024-02-15', 5), (12, '2024-01-01', 7),
(13, '2023-12-10', 5), (14, '2023-11-20', 5), (15, '2023-10-01', 7), (16, '2023-09-15', 5),
(17, '2023-08-01', 10), (18, '2023-07-10', 5), (19, '2023-06-01', 5), (20, '2023-05-20', 5);

INSERT INTO ogranicenja_tvrtke (vrsta_ogranicenja) VALUES
('min_broj_zaposlenika'), ('max_broj_prekovremenih'), ('dozvoljeni_godisnji'),
('radno_vrijeme_odmor'), ('sigurnosne_smjene'), ('bolovanja_limit'), 
('zabrana_prekovremenih'), ('obavezni_odmor'), ('tehnička_podrška'), 
('produženi_radni_sati'), ('maksimalni_radni_dani'), ('subotnji_rad'), 
('nedjeljni_odmor'), ('noćna_smjena'), ('rotacija_smjena'), 
('sezonski_rad'), ('dnevni_broj_sati'), ('periodični_odmor'), 
('naknade_putni_troškovi'), ('uvjeti_zaposlenja');

INSERT INTO zahtjev_prekovremeni (id_zaposlenik, datum_prekovremeni, sati, status_pre) VALUES
(1, '2024-11-05', 2, 'odobren'), (2, '2024-11-06', 3, 'odbijen'), 
(3, '2024-11-07', 1, 'odobren'), (4, '2024-11-08', 4, 'odobren'), 
(5, '2024-11-09', 5, 'odbijen'), (6, '2024-11-10', 2, 'odobren'), 
(7, '2024-11-11', 3, 'odobren'), (8, '2024-11-12', 2, 'odobren'), 
(9, '2024-11-13', 4, 'odbijen'), (10, '2024-11-14', 3, 'odobren'), 
(11, '2024-11-15', 5, 'odobren'), (12, '2024-11-16', 1, 'odbijen'), 
(13, '2024-11-17', 2, 'odobren'), (14, '2024-11-18', 4, 'odobren'), 
(15, '2024-11-19', 5, 'odbijen'), (16, '2024-11-20', 3, 'odobren');
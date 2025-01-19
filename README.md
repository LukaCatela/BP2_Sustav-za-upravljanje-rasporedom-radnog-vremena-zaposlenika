# BP2_Sustav-za-upravljanje-rasporedom-radnog-vremena-zaposlenika
Projekt za kolegija baze podataka 2. Članovi: Luka Catela, Luka Hušak, Mateo Šegon, Juraj Crljenko, Nikol Buzećan, Stjepan Srdarević
# Sustav za upravljanje rasporedom radnog vremena zaposlenika

**Projekt za kolegij Baze podataka 2**

---

## Opis projekta

Ovaj projekt predstavlja sustav za upravljanje rasporedom radnog vremena zaposlenika u organizaciji. Sustav omogućuje evidentiranje zaposlenika, smjena, godišnjih odmora, bolovanja, plaća, projekata, zadataka i drugih aspekata poslovanja vezanih uz upravljanje ljudskim resursima. Projekt je razvijen kao zadatak za kolegij **Baze podataka 2**.

## Članovi tima
- **Luka Catela**
- **Luka Hušak**
- **Mateo Šegon**
- **Juraj Crljenko**
- **Nikol Buzećan**
- **Stjepan Srdarević**
## Tehnologije
- **RDBMS:** MySQL
- **Jezik:** SQL za definiranje, upravljanje i manipulaciju podacima
- **Alati:** MySQL Workbench i VS Code

## Struktura projekta

### Tablice u sustavu
Projekt obuhvaća sljedeće tablice:

1. **odjel**
   - Sadrži informacije o odjelima unutar organizacije.

2. **zaposlenik**
   - Evidencija svih zaposlenika s detaljima poput osobnih podataka, statusa zaposlenja i povezanosti s odjelom.

3. **vrsta_smjene**
   - Definira vrste smjena u organizaciji.

4. **smjene**
   - Povezuje smjene s odjelima i minimalnim brojem potrebnih zaposlenika.

5. **bolovanje**
   - Evidencija bolovanja zaposlenika.

6. **raspored_rada**
   - Definira raspored rada zaposlenika po smjenama.

7. **evidencija_rada**
   - Sadrži podatke o vremenu dolaska i odlaska zaposlenika na posao.

8. **place**
   - Evidencija o plaćama zaposlenika, uključujući broj odrađenih sati, prekovremenih sati i bolovanja.

9. **godisnji_odmori**
   - Evidencija godišnjih odmora s mogućnošću odobravanja ili odbijanja.

10. **zahtjev_prekovremeni**
    - Sadrži zahtjeve zaposlenika za prekovremene sate.

11. **preferencije_smjena**
    - Zaposlenikove preferencije za smjene.

12. **sluzbena_putovanja**
    - Evidencija službenih putovanja zaposlenika.

13. **dopust**
    - Evidencija plaćenih i neplaćenih dopusta.

14. **projekti**
    - Informacije o projektima i njihov status.

15. **zadaci**
    - Zadaci vezani uz projekte, dodijeljeni zaposlenicima.

16. **napomene**
    - Pozitivne i negativne napomene o zaposlenicima.

### Ključne funkcionalnosti
- **Upravljanje zaposlenicima i odjelima**
- **Raspoređivanje smjena i praćenje rada**
- **Evidencija godišnjih odmora i bolovanja**
- **Izračun plaća i prekovremenih sati**
- **Praćenje projekata i zadataka**
- **Podrška za službena putovanja i dopuste**

### SQL upiti i procedure
Projekt uključuje složene SQL upite, procedure i trigere za:
- Automatizaciju promjena statusa projekata i zadataka
- Provjere valjanosti podataka (npr. nepreklapanje bolovanja)
- Generiranje izvještaja (npr. zaposlenici s najviše prekovremenih sati, projekti s najviše završenih zadataka)

## Instalacija i pokretanje

1. **Klonirajte repozitorij:**
   ```bash
   git clone https://github.com/korisnik/bp2_sustav_raspored.git
   ```

2. **Importirajte bazu podataka:**
   - Koristite MySQL Workbench ili CLI za izvršavanje SQL skripti u datoteci `schema.sql`.

3. **Pokrenite testne upite:**
   - Izvršite SQL upite iz datoteke `queries.sql` za provjeru funkcionalnosti sustava.

## Planovi za budućnost
- Implementacija korisničkog sučelja za rad s bazom
- Optimizacija upita za velike količine podataka
- Dodavanje podrške za višejezičnost u sustavu

## Licenca
Ovaj projekt je pod **MIT licencom**. Detalje potražite u datoteci `LICENSE`.

---

### Kontakt
Za sva pitanja, slobodno nas kontaktirajte putem e-maila: **primjer@email.com**.

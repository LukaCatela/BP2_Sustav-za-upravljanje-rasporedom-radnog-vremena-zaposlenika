# BP2_Sustav-za-upravljanje-rasporedom-radnog-vremena-zaposlenika
---

## Opis projekta

Poslovni proces upravljanja rasporedom radnog vremena zaposlenika obuhvaća planiranje, organizaciju i praćenje radnih smjena, godišnjih odmora, bolovanja, pauza, te evidenciju prisutnosti i odsutnosti unutar organizacije. Cilj ovog procesa je osigurati da se ljudski resursi koriste na najbolji mogući način, da se poštuju radni propisi te da se zadovolje potrebe zaposlenika i same tvrtke. 

Proces započinje prikupljanjem podataka o zaposlenicima, uključujući njihovo ime, prezime, kontakt podatke, poziciju u organizaciji, radne smjene te eventualne specifične zahtjeve poput preferencija za rad u određenim smjenama ili godišnjih odmora. Nakon što su svi potrebni podaci evidentirani, voditelji odjela ili odgovorne osobe koriste sustav za kreiranje inicijalnog rasporeda radnih smjena.  

Sustav omogućuje:   

- Planiranje: Unos i automatsko generiranje rasporeda prema poslovnim pravilima te prilagodbu smjena prema potrebama.   

- Organizaciju: Evidenciju odsutnosti i usklađivanje rasporeda s uvjetima zaposlenika.   

- Praćenje i ažuriranje: Evidenciju radnih sati i brze izmjene rasporeda  

Na kraju sustav omogućuje generiranje izvješća o radnim satima, prekovremenom radu i drugim ključnim informacijama. Implementacija ovog poslovnog procesa u sustavu donosi brojne koristi, uključujući povećanje učinkovitosti u planiranju, smanjenje administrativnog opterećenja te veću transparentnost i zadovoljstvo zaposlenika.

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
    - Pozitivne i negativne napomene/komentari o zaposlenicima.

### Ključne funkcionalnosti
- **Upravljanje zaposlenicima i odjelima**
- **Raspoređivanje smjena i praćenje rada**
- **Evidencija godišnjih odmora i bolovanja**
- **Izračun plaća i prekovremenih sati**
- **Praćenje projekata i zadataka**
- **Podrška za službena putovanja i dopuste**
- **Generiranje rasporeda za određeni mjesec**


### SQL upiti i procedure
Projekt uključuje složene SQL upite, procedure i trigere za:
- Automatizaciju promjena statusa projekata i zadataka
- Provjere valjanosti podataka (npr. nepreklapanje bolovanja)
- Generiranje izvještaja (npr. zaposlenici s najviše prekovremenih sati, projekti s najviše završenih zadataka)

## Instalacija i pokretanje

1. **Klonirajte repozitorij:**
   ```bash
   git clone https://github.com/LukaCatela/BP2_Sustav-za-upravljanje-rasporedom-radnog-vremena-zaposlenika.git
   ```


    1. Preuzmite repozitorij i raspakirajte ga
    2. Otvorite terminal u datoteci u kojoj se nalazi projekt
    3. Prvo kreiramo Python env: python -m venv myVenv
    4. Aktiviramo env: .\myVenv\Scripts\activate
    5. Instaliramo requirements-e: pip install -r requirements.txt

### Lokalno pokretanje web aplikacije

**Kreiranje baze podataka**

Prije pokretanja web aplikacije, trebamo kreirati bazu podataka.

Koraci za kreiranje baze podataka:

    Unutar MySQL Workbencha kreirati korisnika sa korisničkim imenom "root" i lozinkom "root"
    Onda pokrenemo : bp_2_CijeliProjekt_SustavZaUpravljanjeRasporedomZaposlenika.sql

    ili posebno file-ove tim redoslijedom:
    baza_raspored_tablice.sql,
    podaci.sql,
    pogledi_funkcije_procedure.sql

Pokretanje web aplikacije

    1. Otvorite terminal u datoteci u kojoj se nalazi projekt
    2. Kako bi aktivirali environment upišite: . \myVenv\Scripts\activate
    3. Kako bi pokrenuli web aplikaciju upišite: flask run
    4. Otvorite dobivenu lokalnu adresu u bilo kojem internet pregledniku

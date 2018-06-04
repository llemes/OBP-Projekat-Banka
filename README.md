# OBP Projekat: Banka
Oracle baza podataka za banku rađena u sklopu predmeta Osnove Baza Podataka. 

<!-- toc -->
- [Kreiranje baze](#kreiranje-baze)
- [Tabele](#tabele)
    * [Zaposleni](#zaposleni)
    * [Poslovnice](#poslovnice)
    * [Bankomati](#bankomati)
    * [Mušterije](#mušterije)
    * [Transakcije](#transakcije)
    * [Računi](#računi)
    * [Krediti](#krediti)
    * [Tipovi kredita](#tipovi-kredita)
    * [Tipovi kartica](#tipovi-kartica)
    * [Tipovi računa](#tipovi-računa)
- [Funkcije](#funkcije)
    * [Datum otplate](#datum-otplate)
    * [Može li korisnik dići kredit](#može-li-korisnik-dići-kredit)
    * [Broj rata kredita](#broj-rata-kredita)
    * [Broj radnika na odjelu](#broj-radnika-na-odjelu)
    * [Izvještaji o transakcijama](#izvještaji-o-transakcijama)
- [Procedure](#procedure)
    * [Dizanje kredita](#dizanje-kredita)
    * [Otplata rate kredita](#otplata-rate-kredita)
    * [Otvaranje tekućeg računa](#otvaranje-tekućeg-računa)
    * [Otvaranje štednog računa](#otvaranje-štednog-računa)
    * [Polaganje novca na račun](#polaganje-novca-na-račun)
    * [Podizanje novca s računa](#podizanje-novca-s-računa)
    * [Bankomat](#bankomat)
<!-- tocstop -->

## Kreiranje baze
Potrebno je pokrenuti queryje sljedećim redoslijedom:
- Tabele i viewovi: [tabele.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/tabele.sql)
- Ograničenja: [ogranicenja.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/ogranicenja.sql)
- Indeksi: [indeksi.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/indeksi.sql) 
- Funkcije: [funkcije.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/funkcije.sql)
- Procedure: [procedure.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/procedure.sql)
- Sekvence: [sekvence.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/sekvence.sql)
- Triggeri: [triggeri.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/triggeri.sql)
- Punjenje baze: [punjenjeBaze.sql](https://github.com/llemes/OBP-Projekat-Banka/tree/master/Baza/punjenjeBaze.sql)

## Korištenje baze
Ovo je uputstvo navedeno i u [dokumentaciji](https://github.com/llemes/OBP-Projekat-Banka/blob/master/dokumentacija.pdf).

## Tabele

### Zaposleni
Tabela zaposleni ima kolone:
```
zaposleni_id
ime
prezime
funkcija
odjel
poslovnica_id
plata
```
Kolone koje nisu nullable: zaposleni_id, ime, prezime, poslovnica_id i plata.
* zaposleni_id: primary key
* funkcija: funkcija koju zaposleni obavlja unutar odjela (i poslovnice)
* odjel: naziv odjela za koji zaposleni radi
* poslovnica_id: foreign key na poslovnicu kojoj pripada zaposlenik

### Poslovnice
Tabela poslovnice ima kolone:
```
poslovnica_id
tip_poslovnice
lokacija
stanje
nadlezna_poslovnica_id
```
Kolone koje nisu nullable: poslovnica_id, tip_poslovnice, lokacija i stanje.
* poslovnica_id: primary key
* lokacija: ime grada u kojem se poslovnica nalazi
* stanje: ukupan iznos novčanih sredstava koja se trenutno nalaze u poslovnici
* nadlezna_poslovnica_id: foreign key na nadležnu poslovnicu (odgovarajuća regionalna za lokalne, ili odgovarajuća centralna za regionalne poslovnice)

### Bankomati
Tabela bankomati ima kolone:
```
bankomat_id
stanje
poslovnica_id
```
Nijedna kolona nije nullable.
* bankomat_id: primary key
* stanje: ukupan iznos nočanih sredstava koji se nalaze na bankomatu
* poslovnica_id: foreign key na poslovnicu u kojoj se nalazi bankomat

### Mušterije
Tabela mušterije ima kolone:
```
musterija_id
ime
prezime
datum_rodjenja
zaposlenje
mjesecna_primanja
iznos_dugovanja
poslovnica_id
```
Kolone koje nisu nullable: musterija_id, ime, prezime, datum_rodjenja.
* musterija_id: primary key
* zaposlenje: zaposlen/nezaposlen
* mjesecna_primanja: plata korisnika, ovo polje se skupa sa iznosom dugovanja i datumom rođenja koristi kao kriterij da li je u stanju otplatiti kredit
* iznos_dugovanja: podaci o ukupnim dugovanjima banci, puni se triggerima
* poslovnica_id: foreign key na poslovnicu kojoj klijent pripada

### Transakcije
Ova tabela se ne bi trebala ni na koji način mijenjati od strane korisnika bez upotrebe funkcija i procedura.
Tabela transakcije ima kolone:
```
transakcija_id
vrijeme_transakcije
iznos_transakcije
uplata_racun_id
isplata_racun_id
uplata_poslovnica_id
isplata_poslovnica_id
uplata_kredit_id
isplata_kredit_id
bankomat_id
```
Kolone koje nisu nullable: transakcija_id, vrijeme_transakcije, iznos_transakcije.
* transakcija_id: primary key
* vrijeme_transakcije: datum transakcije
* uplata_racun_id: foreign key na račun sa kojeg se vrši uplata/transakcija
* isplata_racun_id: foreign key na račun na koji se vrši uplata/transakcija
* uplata_poslovnica_id: foreign key na poslovnicu sa koje se vrši transakcija
* isplata_poslovnica_id: foreign key na poslovnicu na koju se vrši transakcija
* bankomat_id: foreign key na bankomat - kada prima sredstva, prima ih od poslovnice; kada isplaćuje sredstva, isplaćuje ih u vidu keša

### Računi
Tabela računi ima kolone:
```
racun_id
tip_racuna
musterija_id
tip_kartice
balans
```
Kolone koje nisu nullable: racun_id, tip_racuna, mustrija_id, balans.
* racun_id: primary key
* tip_racuna: tekući ili štedni, odrređuje maksimalan iznos transakcija i mjesečni odbitak za održavanje
* musterija_id: foreign key na klijenta kome pripada račun
* tip_kartice: tip kartice koja je vezana na račun (ako je ima)
* balans: trenutno stanje računa; polje je fiktivnog tipa, sadrži informaciju o količini sredstava kojima klijent raspolaže ali se stvarna sredstva nalaze u poslovnici

### Krediti
Tabela krediti ima kolone:
```
kredit_id
musterija_id
zirant_id
tip_kredita
ukupan_iznos
placenih_rata
preostalih_rata
zadnja_uplata
datum_zaduzenja
```
Kolone koje nisu nullable: kredit_id, musterija_id, zirant_id, tip_kredita, ukupan_iznos, placenih_rata, preostalih_rata, datum_zaduzenja.
* kredit_id: primary key
* musterija_id: foreign key na klijenta koji je podigaokredit
* zirant_id: foreign key na žiranta
* tip_kredita: foreign key na tabelu tipovi_kredita, određuje vrijednosti polja vezane za određeni tip
* ukupan_iznos: iznos duga koji je klijent dužan poslovnici, update se vrši triggerom
* placenih_rata: broj plaćenih rata
* preostalih_rata: broj preostalih rata
* datum_zaduzenja: datum podizanja kredita

### Tipovi kredita
Tabela tipovi_kredita ima kolone:
```
tip_id
maksimalni_iznos
min_iznos_rate
min_period_otplate
max_period_otplate
puni_naziv
kamatna_stopa
```
Nijedna kolona nije nullable.
* tip_id: primary key
* maksimalni_iznos: maksimalni iznos kredita
* min_iznos_rate: iznos rate koja se otplaćuje u procedurama za rad sa kreditima
* min_period_otplate: najmanji period za otpltu kredita - broj godina
* max_period_otplate: najveći period za otplatu kredita - broj godina
* puni_naziv: puni naziv tipa kredita
* kamatna_stopa: kamatna stopa za dati tip kredita

### Tipovi kartica
Tabela tipovi_kartica ima kolone:
```
tip_id
puni_naziv
```
Nijedna kolona nije nullable.
* tip_id: primary key
* puni_naziv: puni naziv tipa kartice

### Tipovi računa
Tabela tipovi_racuna ima kolone:
```
tip_id
max_velicina_transakcija
mjesecni_odbitak
```
Nijedna kolona nije nullable.
* tip_id: primary key
* max_velicina_transakcija: maksimalna veličina transakcija
* mjesecni_odbitak: mjesečni odbitak za održavanje računa

## Funkcije

### Datum otplate
```
datum_otplate(id_kredita INTEGER)
```
Vraća datum otplate kredita.
* id_kredita: primarni ključ kredita čiji se datum otplate obračunava

```
max_datum_otplate(id_kredita INTEGER)
```
Vraća najkasniji datum otplate kredita.
* id_kredita: primarni ključ kredita čiji se najkasniji datum otplate obračunava

### Može li korisnik dići kredit
```
moze_dici_kredit(id_korisnika INTEGER)
```
Vraća VARCHAR2 'DA' ili 'NE'.
* id_korisnika: primarni ključ korisnika za kojeg se procjenjuje da li je validan kandidat za dizanje kredita

### Broj rata kredita
```
broj_rata_kredita(p_tp_kredita VARCHAR2,
    p_ukupni_iznos DECIMAL)
```
Vraća ukupan broj rata za odgovarajući tip kredita.
* p_tip_kredita: moguće vrijednosti 'HIPO', 'SRED', 'DUGO', 'MIKRO' za hipotekarni, srednjoročni, dugoročni i mikrokredit respektivno
* p_ukupni_iznos: ukupni iznos kredita čiji se broj rata izračunava

### Broj radnika na odjelu
```
broj_radnika_na_odjelu(p_naziv_odjela VARCHAR2)
```
Vraća broj radnika na odjelu.
* p_naziv_odjela: naziv odjela čija se hijerarhijska analiza zaposlenih vrši (rad s fizičkim licima, rad s pravnim licima, IT, menadžment, unutrašnji platni promet, pravni odjel, finansijsko tržište)

### Izvještaji o transakcijama
* p_poslovnica_id: primarni ključ poslovnice čiji se izvještaj računa

```
iznos_ulaznih_transakcija(p_poslovnica_id INTEGER)
```
Vraća sedmični izvještaj za poslovnicu - koliko je sredstava pristiglo u poslovnicu u toku sedmice.

```
iznos_izlaznih_transakcija(p_poslovnica_id INTEGER)
```
Vraća koliko je sredstava napustilo poslovnicu u toku sedmice.

```
m_iznos_ulaznih_transakcija(p_poslovnica_id INTEGER)
```
Vraća mjesečni izvještaj poslovnice, u izvještaj su uključeni i podaci lokalnih poslovnica koje su podređene datoj poslovnici - koliko je sredstava pristiglo u datu skupinu poslovnica.

```
m_iznos_izlaznih_transakcija(p_poslovnica_id INTEGER)
```
Vraća koliko je sredstava napustilo skupinu poslovnica.

## Procedure

### Dizanje kredita
```
digni_kredit(p_id_korisnika INTEGER,
    p_id_ziranta INTEGER,
    p_tip_kredita VARCHAR2,
    p_ukupan_iznos DECIMAL)
```
* p_id_korisnika: primary key korisnika koji diže kredit u svojoj matičnoj poslovnici
* p_id_ziranta: primary key korisnika koji će biti žirant
* p_tip_kredita: moguće vrijednosti 'HIPO', 'SRED', 'DUGO', 'MIKRO' za hipotekarni, srednjoročni, dugoročni i mikrokredit respektivno
* p_ukupan_iznos: ukupan iznos kredita
* p_broj_rata: broj rata kredita, potrebno da je izračunati (pomoću funkcije) na osnovu tipa kredita i ukupnog iznosa PRIJE nego što se pozove ova procedura

### Otplata rate kredita
```
otplata_rate_kredita(p_kredit_id INTEGER)
```
* p_kredit_id: primarni ključ kredita čiji se minimalni iznos rate otplaćuje

### Otvaranje tekućeg računa
```
otvaranje_tekuceg_racuna(p_musterija_id INTEGER)
```
* p_musterija_id: primarni ključ korisnika koji otvara tekući račun

```
otvaranje_tekuci_racun_kartica(p_musterija_id INTEGER,
    p_tip_kartice VARCHAR2)
```
* p_tip_kartice: moguće vrijednosti 'DEBK', 'KRED', 'STUD', 'STED' za debitnu, kreditnu, studentsku i štednu karticu respektivno

### Otvaranje štednog računa
```
otvaranje_stednog_racuna(p_musterija_id INTEGER)
```
* p_musterija_id: primarni ključ korisnika koji otvara štedni račun

```
otvaranje_stedni_racun_kartica(p_musterija_id INTEGER,
    p_tip_kartice VARCHAR2)
```
* p_tip_kartice: moguće vrijednosti 'DEBK', 'KRED', 'STUD', 'STED' za debitnu, kreditnu, studentsku i štednu karticu respektivno

### Polaganje novca na račun
```
polozi_pare_na_racun(p_kolicina DECIMAL,
    p_racun_id INTEGER)
```
* p_kolicina: količina sredstava koje se polažu na račun, ne smije prelaziti maksimalni iznos transakcija za odgovarajući tip računa
* p_racun_id: primarni ključ računa na koji se polažu sredstva

### Podizanje novca s računa
```
podigni_pare_sa_racuna(p_kolicina DECIMAL,
    p_racun_id INTEGER)
```
* p_kolicina: količina sredstava koja se preuzimaju sa šaltera poslovnice kojoj pripada korisnik - vlasnik računa, također ne smije prelaziti maksimalni iznos transakcija za odgovarajući tip računa
* p_racun_id: primarni ključ računa nad kojim se vrši transakcija

### Bankomat
```
podigni_pare_sa_bankomata(p_kolicina DECIMAL,
    p_racun_id INTEGER,
    p_bankomat_id INTEGER)
```
* p_kolicina: količina sredstava koja se podiže s bankomata, ne smije prelaziti limit
* p_racun_id: primarni ključ računa nad kojim se vrši transakcija
* p_bankomat_id: primarni ključ bankomata nad kojim se vrši transakcija

```
dopuni_bankomat(p_poslovnica_id INTEGER,
    p_bankomat_id INTEGER,
    p_kolicina DECIMAL)
```
* p_poslovnica_id: primary key poslovnice čija se sredstva prebacuju u bankomat
* p_bankomat_id: primary key bankomata nad kojim se vrši transakcija
* p_kolicina: količina sredstava koja se prebacuju na bankomat
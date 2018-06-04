-- 1: prikaz svih odjela u banci

SELECT DISTINCT odjel
FROM zaposleni;

-- 2: prikaz svih funkcija zaposlenih (job titles)

SELECT DISTINCT funkcija
FROM zaposleni;

-- 3: prikaz klijenata banke koji su digli kredit

SELECT *
FROM musterije
WHERE iznos_dugovanja IS NOT NULL;

-- 4: prikaz lokacija klijenata (prema poslovnici kojoj pripadaju)

SELECT m.ime, m.prezime, p.lokacija
FROM poslovnice p, musterije m
WHERE p.poslovnica_id = m.poslovnica_id;

-- 5: prikaz klijenata banke koji imaju slovo a u prezimenu

SELECT *
FROM musterije
WHERE Lower(prezime) LIKE '%a%';

-- 6: prikaz zaposlenih banke i klijenata banke koji imaju istu platu

SELECT m.ime || ' ' || m.prezime klijent, z.ime || ' ' || z.prezime uposleni, z.plata
FROM musterije m, zaposleni z
WHERE m.mjesecna_primanja = z.plata;

-- 7: prikaz klijenata koji imaju kartice

SELECT m.*
FROM racuni r, musterije m
WHERE r.musterija_id = m.musterija_id AND r.tip_kartice IS NOT NULL;

-- 8: prikaz klijenata koji su nekome ziranti

SELECT zirant.*
FROM musterije zirant, krediti k
WHERE k.zirant_id = zirant.musterija_id;

-- 9: prikaz klijenata koji su nekome ziranti i kome su ziranti

SELECT z.ime || ' ' || z.prezime zirant, m.ime || ' ' || m.prezime klijent
FROM musterije z, musterije m, krediti r
WHERE z.musterija_id = r.zirant_id AND m.musterija_id = r.musterija_id;

-- 10: prikaz regionalnih poslovnica (nemam više ideja)

SELECT *
FROM poslovnice
WHERE tip_poslovnice LIKE 'regionalna';

-- 11: ime, prezime klijenata cija imena sadrze slovo a, te ukupni iznos kredita za datog klijenta

SELECT m.ime, m.prezime, Sum(k.ukupan_iznos)
FROM musterije m, krediti k
WHERE k.musterija_id = m.musterija_id
HAVING Lower(m.ime) LIKE '%a%'
GROUP BY m.ime, m.prezime;

-- 12: ukupna kolicina novca koja je napustila centralnu poslovnicu, te najveci i najmanji iznos

SELECT Sum(iznos_transakcije), Max(iznos_transakcije), Min(iznos_transakcije)
FROM transakcije
HAVING uplata_poslovnica_id = 1
GROUP BY uplata_poslovnica_id;

-- 13: ukupna kolicina novca koja je napustila odgovarajuce poslovnice

SELECT p.lokacija, Sum(iznos_transakcije), Max(iznos_transakcije), Min(iznos_transakcije)
FROM transakcije t, poslovnice p
WHERE p.poslovnica_id = t.uplata_poslovnica_id
GROUP BY p.lokacija;

-- 14: ukupna kolicina novca koja je dosla u odgovarajuce poslovnice

SELECT p.lokacija, Sum(iznos_transakcije), Max(iznos_transakcije), Min(iznos_transakcije)
FROM transakcije t, poslovnice p
WHERE p.poslovnica_id = t.isplata_poslovnica_id
GROUP BY p.lokacija;

-- 15: racun sa najvecim balansom u banci

SELECT Max(r.balans)
FROM racuni r;

-- 16: prikaz klijenata koji imaju isto ime i prezime kao neki zaposlenik banke (nema takvih)

SELECT m.*
FROM musterije m
WHERE (m.ime, m.prezime) IN (SELECT z.ime, z.prezime
                             FROM zaposleni z);

-- 17: prikaz poslovnica koje su punile bankomate

SELECT p.*
FROM poslovnice p
WHERE p.poslovnica_id IN (SELECT uplata_poslovnica_id
                          FROM transakcije
                          WHERE bankomat_id IS NOT NULL);

-- 18: prikaz zaposlenika koji imaju platu vecu od prosjecne

SELECT *
FROM zaposleni
WHERE plata > (SELECT Avg(plata)
               FROM zaposleni);

-- 19: prikaz musterija koji imaju platu vecu od najvece plate zaposlenika koji rade s fizickim licima

SELECT *
FROM musterije
WHERE mjesecna_primanja > (SELECT Max(plata)
                           FROM zaposleni
                           WHERE odjel LIKE 'rad s fizickim licima');

-- 20: prikas iznosa uplata u lokalne poslovnice

SELECT iznos_transakcije
FROM transakcije
WHERE isplata_poslovnica_id IN (SELECT poslovnica_id
                               FROM poslovnice
                               WHERE tip_poslovnice LIKE 'lokalna');


-- 21: stedni racuni u lokalnim poslovnicama (because joins and views are too mainstream)

SELECT *
FROM racuni
WHERE musterija_id IN (SELECT musterija_id
                       FROM musterije
                       WHERE poslovnica_id IN (SELECT poslovnica_id
                                               FROM poslovnice
                                               WHERE tip_poslovnice LIKE 'lokalna'))
AND tip_racuna LIKE 'STEDNI';

-- 22: transakcije koje su obavljene nad poslovnicama koje imaju ispodprosjecno stanje (sve osim centralne haman)

SELECT t.*
FROM transakcije t, (SELECT poslovnica_id p
                     FROM poslovnice
                     WHERE stanje < (SELECT Avg(stanje)
                                     FROM poslovnice)) a
WHERE isplata_poslovnica_id IN a.p
OR uplata_poslovnica_id IN a.p
ORDER BY isplata_poslovnica_id;

-- 23: transakcije provedene nad poslovnicom sa najvecim stanjem

SELECT t.*
FROM transakcije t, (SELECT poslovnica_id p
                     FROM poslovnice
                     WHERE stanje = (SELECT Max(stanje)
                                     FROM poslovnice)) m
WHERE isplata_poslovnica_id IN m.p
OR uplata_poslovnica_id IN m.p
ORDER BY vrijeme_transakcije;

-- 24: tbh nisam ni ja sigurna šta se ovdje dešava

SELECT m.*
FROM musterije m
WHERE m.musterija_id IN (SELECT zirant_id
                         FROM krediti
                         WHERE ukupan_iznos > (SELECT Avg(mjesecna_primanja)
                                               FROM musterije
                                               WHERE ime LIKE 'Tim'));

SELECT * FROM krediti;

-- 25: ?_?

SELECT r.*
FROM racuni r, tipovi_racuna t
WHERE r.tip_racuna = t.tip_id
AND t.max_velicina_transakcija > (SELECT iznos_transakcije
                                  FROM transakcije
                                  WHERE uplata_kredit_id IN (SELECT kredit_id
                                                             FROM krediti
                                                             WHERE preostalih_rata < (SELECT Avg(placenih_rata)
                                                                                      FROM krediti)));

-- 26: nesto sa rollup xD

SELECT tip_racuna, musterija_id, Sum(balans)
FROM racuni
GROUP BY rollup(tip_racuna, musterija_id);

SELECT * FROM racuni;

-- 27: jos nesto sa rollup

SELECT transakcija_id, vrijeme_transakcije, Sum(iznos_transakcije)
FROM transakcije
GROUP BY cube(transakcija_id, vrijeme_transakcije);

-- 28: top down

SELECT lokacija || ' salje izvjestaj u ' || PRIOR lokacija
FROM poslovnice
START WITH lokacija = 'New York'
CONNECT BY PRIOR poslovnica_id = nadlezna_poslovnica_id;

-- [edit] ovo iznad nije top-N ;-;
-- 28.1: 10 zaposlenika sa najvecom platom

SELECT ROWNUM AS Rank, a.i, a.p, a.pp
FROM ( SELECT z.ime i, z.prezime p, z.plata pp
       FROM zaposleni z
       ORDER BY z.plata DESC) a
WHERE ROWNUM < 11;

-- 29: bottom up
-- stari upit
-- legacy :/

SELECT tip_poslovnice
FROM poslovnice
START WITH poslovnica_id = 15
CONNECT BY PRIOR nadlezna_poslovnica_id = poslovnica_id;

-- 29.1: 20 klijenata sa najnizom platom

SELECT ROWNUM AS Rank, a.i, a.p, a.m
FROM ( SELECT m.ime i, m.prezime p, m.mjesecna_primanja m
       FROM musterije m
       ORDER BY m.mjesecna_primanja ASC) a
WHERE ROWNUM < 21;

-- 30: union

SELECT m.ime, m.prezime, m.mjesecna_primanja
FROM musterije m
WHERE m.mjesecna_primanja > 2500

UNION

SELECT z.ime, z.prezime, z.plata
FROM zaposleni z
WHERE z.plata > 1200;

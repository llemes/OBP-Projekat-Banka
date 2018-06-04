-- dizanje kredita
-- nema pozivanja funkcije za provjeru moze li klijent dobiti kredit
-- to rade salteruse

CREATE OR REPLACE PROCEDURE digni_kredit (p_id_korisnika INTEGER,
                                          p_id_ziranta INTEGER,
                                          p_tip_kredita VARCHAR2,
                                          p_ukupan_iznos DECIMAL)
IS

p_max_iznos DECIMAL; p_stanje_poslovnice DECIMAL; p_poslovnica_id INTEGER; p_broj_rata INTEGER;

BEGIN

  SELECT poslovnica_id INTO p_poslovnica_id FROM musterije WHERE musterija_id LIKE p_id_korisnika;
  SELECT maksimalni_iznos INTO p_max_iznos FROM tipovi_kredita WHERE tip_id LIKE p_tip_kredita;
  SELECT stanje INTO p_stanje_poslovnice FROM poslovnice WHERE poslovnica_id LIKE p_poslovnica_id;
  SELECT broj_rata_kredita(p_tip_kredita, p_ukupan_iznos) INTO p_broj_rata FROM dual;

  IF p_ukupan_iznos > p_stanje_poslovnice
  THEN
  Raise_Application_Error('-20801', 'Nema dovoljno sredstava u poslovnici');
  END IF;

  IF p_ukupan_iznos > p_max_iznos
  THEN
  Raise_Application_Error('-20800', 'Prekoracen maksimalni iznos kredita');
  END IF;

  INSERT INTO krediti(musterija_id, zirant_id, tip_kredita, ukupan_iznos, placenih_rata, preostalih_rata, datum_zaduzenja)
  VALUES(p_id_korisnika, p_id_ziranta, p_tip_kredita, p_ukupan_iznos, 0, p_broj_rata, SYSDATE);

  UPDATE poslovnice
  SET stanje = stanje - p_ukupan_iznos
  WHERE poslovnica_id = p_poslovnica_id;

  INSERT INTO transakcije(vrijeme_transakcije, uplata_poslovnica_id, isplata_kredit_id, iznos_transakcije)
  VALUES(SYSDATE, p_poslovnica_id, kredit_id.CURRVAL, p_ukupan_iznos);

END;
/

-- otplacivanje rate kredita
-- uplacuje se minimalni iznos rate svaki put u poslovnicu kojoj pripada musterija
-- ako treba vise, nek uplati vise puta
-- kome ba mi da se prilagodjavamo

CREATE OR REPLACE PROCEDURE otplata_rate_kredita (p_kredit_id INTEGER)
IS

p_poslovnica_id INTEGER; p_rata_kredita DECIMAL;

BEGIN

  SELECT p.poslovnica_id INTO p_poslovnica_id
  FROM poslovnice p, musterije m, krediti k
  WHERE k.kredit_id = p_kredit_id AND k.musterija_id = m.musterija_id AND p.poslovnica_id = m.poslovnica_id;

  SELECT t.min_iznos_rate * (1 + kamatna_stopa) INTO p_rata_kredita
  FROM krediti k, tipovi_kredita t
  WHERE k.tip_kredita = t.tip_id AND k.kredit_id = p_kredit_id;

  UPDATE krediti
  SET placenih_rata = placenih_rata + 1, preostalih_rata = preostalih_rata - 1, zadnja_uplata = SYSDATE
  WHERE kredit_id = p_kredit_id;

  UPDATE poslovnice
  SET stanje = stanje + p_rata_kredita
  WHERE poslovnica_id = p_poslovnica_id;

  INSERT INTO transakcije(vrijeme_transakcije, uplata_kredit_id, isplata_poslovnica_id, iznos_transakcije)
  VALUES(SYSDATE, p_kredit_id, p_poslovnica_id, p_rata_kredita);

END;
/

-- otvaranje racuna

CREATE OR REPLACE PROCEDURE otvaranje_tekuceg_racuna(p_musterija_id INTEGER)
IS
BEGIN

  INSERT INTO racuni(tip_racuna, musterija_id, balans)
  VALUES('TEKUCI', p_musterija_id, 0);

END;
/

CREATE OR REPLACE PROCEDURE otvaranje_stednog_racuna(p_musterija_id INTEGER)
IS
BEGIN

  INSERT INTO racuni(tip_racuna, musterija_id, balans)
  VALUES('STEDNI', p_musterija_id, 0);

END;
/

CREATE OR REPLACE PROCEDURE otvaranje_tekuci_racun_kartica(p_musterija_id INTEGER,
                                                           p_tip_kartice VARCHAR2)
IS
BEGIN

  INSERT INTO racuni(tip_racuna, musterija_id, tip_kartice, balans)
  VALUES('TEKUCI', p_musterija_id, p_tip_kartice, 0);

END;
/

CREATE OR REPLACE PROCEDURE otvaranje_stedni_racun_kartica(p_musterija_id INTEGER,
                                                           p_tip_kartice VARCHAR2)
IS
BEGIN

  INSERT INTO racuni(tip_racuna, musterija_id, tip_kartice, balans)
  VALUES('STEDNI', p_musterija_id, p_tip_kartice, 0);

END;
/

-- rad s racunima

CREATE OR REPLACE PROCEDURE polozi_pare_na_racun (p_kolicina DECIMAL,
                                                  p_racun_id INTEGER)
IS

  p_max_velicina_transakcija DECIMAL; p_poslovnica_id INTEGER;

BEGIN

  SELECT max_velicina_transakcija INTO p_max_velicina_transakcija
  FROM tipovi_racuna t, racuni r
  WHERE r.tip_racuna = t.tip_id AND racun_id = p_racun_id;

  IF p_kolicina > p_max_velicina_transakcija
  THEN
  Raise_Application_Error('-20802', 'Prekoracen limit transakcija na racunu');
  END IF;

  SELECT m.poslovnica_id INTO p_poslovnica_id
  FROM musterije m, racuni r
  WHERE r.racun_id = p_racun_id AND r.musterija_id = m.musterija_id;

  UPDATE racuni
  SET balans = balans + p_kolicina
  WHERE racun_id = p_racun_id;

  UPDATE poslovnice
  SET stanje = stanje + p_kolicina
  WHERE poslovnica_id = p_poslovnica_id;

  INSERT INTO transakcije(vrijeme_transakcije, iznos_transakcije, uplata_racun_id, isplata_poslovnica_id)
  VALUES(SYSDATE, p_kolicina, p_racun_id, p_poslovnica_id);

END;
/

CREATE OR REPLACE PROCEDURE podigni_pare_sa_racuna (p_kolicina DECIMAL,
                                                    p_racun_id INTEGER)
IS

  p_max_velicina_transakcija DECIMAL; p_poslovnica_id INTEGER;

BEGIN

  SELECT max_velicina_transakcija INTO p_max_velicina_transakcija
  FROM tipovi_racuna t, racuni r
  WHERE r.tip_racuna = t.tip_id AND racun_id = p_racun_id;

  IF p_kolicina > p_max_velicina_transakcija
  THEN
  Raise_Application_Error('-20803', 'Prekoracen limit transakcija na racunu');
  END IF;

  SELECT m.poslovnica_id INTO p_poslovnica_id
  FROM musterije m, racuni r
  WHERE r.racun_id = p_racun_id AND r.musterija_id = m.musterija_id;

  UPDATE racuni
  SET balans = balans - p_kolicina
  WHERE racun_id = p_racun_id;

  UPDATE poslovnice
  SET stanje = stanje - p_kolicina
  WHERE poslovnica_id = p_poslovnica_id;

  INSERT INTO transakcije(vrijeme_transakcije, iznos_transakcije, isplata_racun_id, uplata_poslovnica_id)
  VALUES(SYSDATE, p_kolicina, p_racun_id, p_poslovnica_id);

END;
/

CREATE OR REPLACE PROCEDURE podigni_pare_sa_bankomata (p_kolicina DECIMAL,
                                                       p_racun_id INTEGER,
                                                       p_bankomat_id INTEGER)
IS

  p_max_velicina_transakcija DECIMAL; p_poslovnica_id INTEGER; p_kartica_id VARCHAR2(10); p_stanje_bankomata DECIMAL; p_stanje_racuna DECIMAL;

BEGIN

  SELECT stanje INTO p_stanje_bankomata
  FROM bankomati
  WHERE bankomat_id = p_bankomat_id;

  IF p_kolicina > p_stanje_bankomata
  THEN
  Raise_Application_Error('-20804', 'Nema dovoljno sredstava na bankomatu');
  END IF;

  SELECT balans INTO p_stanje_racuna
  FROM racuni
  WHERE racun_id = p_racun_id;

  IF p_stanje_racuna < p_kolicina
  THEN
  Raise_Application_Error('-20805', 'Nema dovoljno sredstava na racunu');
  END IF;

  -- ovo ce izazvati gresku ako korisnik nema karticu

  SELECT tip_kartice INTO p_kartica_id
  FROM racuni
  WHERE racun_id = p_racun_id;

  SELECT max_velicina_transakcija INTO p_max_velicina_transakcija
  FROM tipovi_racuna t, racuni r
  WHERE r.tip_racuna = t.tip_id AND racun_id = p_racun_id;

  IF p_kolicina > p_max_velicina_transakcija
  THEN
  Raise_Application_Error('-20803', 'Prekoracen limit transakcija na racunu');
  END IF;

  SELECT m.poslovnica_id INTO p_poslovnica_id
  FROM musterije m, racuni r
  WHERE r.racun_id = p_racun_id AND r.musterija_id = m.musterija_id;

  UPDATE racuni
  SET balans = balans - p_kolicina
  WHERE racun_id = p_racun_id;

  UPDATE bankomati
  SET stanje = stanje - p_kolicina
  WHERE bankomat_id = p_bankomat_id;

  INSERT INTO transakcije(vrijeme_transakcije, iznos_transakcije, uplata_poslovnica_id, isplata_racun_id)
  VALUES(SYSDATE, p_kolicina, p_poslovnica_id, p_racun_id);

END;
/

CREATE OR REPLACE PROCEDURE dopuni_bankomat(p_poslovnica_id INTEGER,
                                            p_bankomat_id INTEGER,
                                            p_kolicina DECIMAL)
IS

  p_stanje_poslovnice DECIMAL;

BEGIN

  SELECT stanje INTO p_stanje_poslovnice
  FROM poslovnice
  WHERE poslovnica_id = p_poslovnica_id;

  IF p_kolicina > p_stanje_poslovnice
  THEN
  Raise_Application_Error('-20807', 'Nema dovoljno sredstava u poslovnici');
  END IF;

  UPDATE bankomati
  SET stanje = stanje + p_kolicina
  WHERE bankomat_id = p_bankomat_id;

  UPDATE poslovnice
  SET stanje = stanje - p_kolicina
  WHERE poslovnica_id = p_poslovnica_id;

  INSERT INTO transakcije(vrijeme_transakcije, iznos_transakcije, uplata_poslovnica_id, bankomat_id)
  VALUES(SYSDATE, p_kolicina, p_poslovnica_id, p_bankomat_id);

END;
/

-- funkcija koja vraca najraniji datum otplate kredita za odredjenog korisnika

CREATE OR REPLACE FUNCTION datum_otplate(id_kredita IN INTEGER)
RETURN DATE
IS retn DATE;
BEGIN

  SELECT To_Date(To_Char(k.datum_zaduzenja, 'dd/mm') || '/' || To_Char(To_Number(To_Char(k.datum_zaduzenja, 'yyyy')) + t.min_period_otplate), 'dd/mm/yyyy')
  INTO retn
  FROM krediti k, tipovi_kredita t
  WHERE k.kredit_id = id_kredita AND k.tip_kredita = t.tip_id;
  RETURN(retn);

END;
/

-- funkcija koja vraca najkasniji datum otplate kredita

CREATE OR REPLACE FUNCTION max_datum_otplate(id_kredita IN INTEGER)
RETURN DATE
IS retn DATE;
BEGIN

  SELECT To_Date(To_Char(k.datum_zaduzenja, 'dd/mm') || '/' || To_Char(To_Number(To_Char(k.datum_zaduzenja, 'yyyy')) + t.max_period_otplate), 'dd/mm/yyyy')
  INTO retn
  FROM krediti k, tipovi_kredita t
  WHERE k.kredit_id = id_kredita AND k.tip_kredita = t.tip_id;
  RETURN(retn);

END;
/

-- funkcija koja odredjuje da li je musterija eligible za kredit

CREATE OR REPLACE FUNCTION moze_dici_kredit(id_korisnika IN INTEGER)
RETURN VARCHAR2
IS retn VARCHAR2(2);
i_dugovanja DECIMAL; i_zaposlenje VARCHAR2(45); i_mjesecna_primanja DECIMAL; i_datum_rodjenja DATE;
BEGIN

  SELECT iznos_dugovanja INTO i_dugovanja FROM musterije WHERE musterija_id = id_korisnika;
  SELECT zaposlenje INTO i_zaposlenje FROM musterije WHERE musterija_id = id_korisnika;
  SELECT mjesecna_primanja INTO i_mjesecna_primanja FROM musterije WHERE musterija_id = id_korisnika;
  SELECT datum_rodjenja INTO i_datum_rodjenja FROM musterije WHERE musterija_id = id_korisnika;

  IF Nvl(i_dugovanja, 0) < 10000 AND i_zaposlenje LIKE 'zaposlen' AND i_mjesecna_primanja > 500 AND To_Number(To_Char(i_datum_rodjenja, 'yyyy')) > 1940
  THEN
  SELECT 'DA' INTO retn FROM dual;

  ELSE
  SELECT 'NE' INTO retn FROM dual;

  END IF;

  RETURN(retn);

END;
/

CREATE OR REPLACE FUNCTION broj_rata_kredita(p_tip_kredita IN VARCHAR2,
                                             p_ukupni_iznos IN DECIMAL)
RETURN INTEGER
IS retn INTEGER;

  p_max_period_otplate INTEGER; p_min_iznos_rate DECIMAL;

BEGIN

  SELECT max_period_otplate INTO p_max_period_otplate
  FROM tipovi_kredita
  WHERE tip_id = p_tip_kredita;

  SELECT min_iznos_rate INTO p_min_iznos_rate
  FROM tipovi_kredita
  WHERE tip_id = p_tip_kredita;

  retn := p_ukupni_iznos / p_min_iznos_rate;

  IF retn > p_max_period_otplate * 12
  THEN
  Raise_Application_Error('-20808', 'Nemoguce izdati kredit'); -- bad design but it's too late now
  END IF;

  RETURN(retn);

END;
/

-- za hijerarhijsku nalizu uposlenih

CREATE OR REPLACE FUNCTION broj_radnika_na_odjelu(p_naziv_odjela VARCHAR2)
RETURN INTEGER IS retn INTEGER;

BEGIN

  SELECT Count(*) INTO retn
  FROM zaposleni
  WHERE odjel LIKE p_naziv_odjela;

  RETURN(retn);

END;
/

-- za sedmicne izvjestaje

CREATE OR REPLACE FUNCTION iznos_ulaznih_transakcija(p_poslovnica_id INTEGER)
RETURN DECIMAL IS retn DECIMAL;
BEGIN

  SELECT Sum(iznos_transakcije) INTO retn
  FROM transakcije
  WHERE To_Number(To_Char(vrijeme_transakcije, 'w')) = To_Number(To_Char(SYSDATE, 'w'))
  AND isplata_poslovnica_id = p_poslovnica_id;

  RETURN(retn);

END;
/

CREATE OR REPLACE FUNCTION iznos_izlaznih_transakcija(p_poslovnica_id INTEGER)
RETURN DECIMAL IS retn DECIMAL;
BEGIN

  SELECT Sum(iznos_transakcije) INTO retn
  FROM transakcije
  WHERE To_Number(To_Char(vrijeme_transakcije, 'w')) = To_Number(To_Char(SYSDATE, 'w'))
  AND uplata_poslovnica_id = p_poslovnica_id;

  RETURN(retn);

END;
/

-- za mjesecne izvjestaje

CREATE OR REPLACE FUNCTION m_iznos_ulaznih_transakcija(p_poslovnica_id INTEGER)
RETURN DECIMAL IS retn DECIMAL;

  pomocna DECIMAL;

BEGIN

  SELECT Sum(t.iznos_transakcije) INTO retn
  FROM transakcije t
  WHERE To_Number(To_Char(t.vrijeme_transakcije, 'mm')) = To_Number(To_Char(SYSDATE, 'mm'))
  AND t.isplata_poslovnica_id = p_poslovnica_id;

  SELECT Sum(t.iznos_transakcije) INTO pomocna
  FROM transakcije t, poslovnice p
  WHERE t.isplata_poslovnica_id = p.poslovnica_id
  AND p.nadlezna_poslovnica_id = p_poslovnica_id
  AND To_Number(To_Char(t.vrijeme_transakcije, 'mm')) = To_Number(To_Char(SYSDATE, 'mm'));

  retn := retn + pomocna;

  RETURN(retn);

END;
/

CREATE OR REPLACE FUNCTION m_iznos_izlaznih_transakcija(p_poslovnica_id INTEGER)
RETURN DECIMAL IS retn DECIMAL;

  pomocna DECIMAL;

BEGIN

  SELECT Sum(t.iznos_transakcije) INTO retn
  FROM transakcije t
  WHERE To_Number(To_Char(t.vrijeme_transakcije, 'mm')) = To_Number(To_Char(SYSDATE, 'mm'))
  AND t.uplata_poslovnica_id = p_poslovnica_id;

  SELECT Sum(t.iznos_transakcije) INTO pomocna
  FROM transakcije t, poslovnice p
  WHERE t.uplata_poslovnica_id = p.poslovnica_id
  AND p.nadlezna_poslovnica_id = p_poslovnica_id
  AND To_Number(To_Char(t.vrijeme_transakcije, 'mm')) = To_Number(To_Char(SYSDATE, 'mm'));

  retn := retn + pomocna;

  RETURN(retn);

END;
/

-- sumarni (godisnji) izvjestaj poslovanja centrale

CREATE OR REPLACE FUNCTION sumarni_izvjestaj
RETURN DECIMAL IS retn DECIMAL;

  pomocna DECIMAL;

BEGIN

  SELECT Sum(iznos_transakcije) INTO retn
  FROM transakcije
  WHERE uplata_poslovnica_id IS NOT NULL
  AND To_Number(To_Char(vrijeme_transakcije, 'yyyy')) = To_Number(To_Char(SYSDATE, 'yyyy'));

  SELECT Sum(iznos_transakcije) INTO pomocna
  FROM transakcije
  WHERE isplata_poslovnica_id IS NOT NULL
  AND To_Number(To_Char(vrijeme_transakcije, 'yyyy')) = To_Number(To_Char(SYSDATE, 'yyyy'));

  retn := pomocna - retn;

  RETURN(retn);

END;
/

COMMIT;

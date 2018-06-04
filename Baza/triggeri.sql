CREATE OR REPLACE TRIGGER zaposleni_pk_triger
BEFORE INSERT
ON zaposleni
FOR EACH ROW
BEGIN

SELECT zaposleni_id.NEXTVAL INTO :new.zaposleni_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER poslovnica_pk_triger
BEFORE INSERT
ON poslovnice
FOR EACH ROW
BEGIN

SELECT poslovnica_id.NEXTVAL INTO :new.poslovnica_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER bankomat_pk_triger
BEFORE INSERT
ON bankomati
FOR EACH ROW
BEGIN

SELECT bankomat_id.NEXTVAL INTO :new.bankomat_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER musterija_pk_triger
BEFORE INSERT
ON musterije
FOR EACH ROW
BEGIN

SELECT musterija_id.NEXTVAL INTO :new.musterija_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER transakcija_pk_triger
BEFORE INSERT
ON transakcije
FOR EACH ROW
BEGIN

SELECT transakcija_id.NEXTVAL INTO :new.transakcija_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER racun_pk_triger
BEFORE INSERT
ON racuni
FOR EACH ROW
BEGIN

SELECT racun_id.NEXTVAL INTO :new.racun_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER kredit_pk_triger
BEFORE INSERT
ON krediti
FOR EACH ROW
BEGIN

SELECT kredit_id.NEXTVAL INTO :new.kredit_id FROM dual;

END;
/

CREATE OR REPLACE TRIGGER korisnik_dugovanja
AFTER INSERT OR UPDATE OR DELETE
ON krediti
FOR EACH ROW
BEGIN

  UPDATE musterije
  SET iznos_dugovanja = Nvl(iznos_dugovanja, 0) + :new.ukupan_iznos
  WHERE musterija_id = :new.musterija_id;

END;
/

CREATE OR REPLACE TRIGGER otplacena_rata
BEFORE UPDATE
ON krediti
FOR EACH ROW
BEGIN

  SELECT :old.ukupan_iznos - min_iznos_rate INTO :new.ukupan_iznos
  FROM tipovi_kredita
  WHERE :old.tip_kredita = tip_id;

END;
/

CREATE OR REPLACE TRIGGER otplacen_kredit
AFTER UPDATE
ON krediti
FOR EACH ROW
BEGIN

  IF :new.preostalih_rata = 0
  THEN

    DELETE FROM krediti WHERE kredit_id = :new.kredit_id;

  END IF;

END;
/

CREATE OR REPLACE TRIGGER no_update_no_delete
BEFORE UPDATE OR DELETE
ON transakcije
BEGIN

  Raise_Application_Error('-20809','Zabranjena operacija');

END;
/

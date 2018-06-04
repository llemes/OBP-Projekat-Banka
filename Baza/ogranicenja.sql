ALTER TABLE zaposleni ADD CONSTRAINT cons_zap_pos_fk FOREIGN KEY (poslovnica_id) REFERENCES poslovnice (poslovnica_id);
ALTER TABLE poslovnice ADD CONSTRAINT cons_pos_pos_fk FOREIGN KEY (nadlezna_poslovnica_id) REFERENCES poslovnice (poslovnica_id);
ALTER TABLE bankomati ADD CONSTRAINT cons_ban_pod_fk FOREIGN KEY (poslovnica_id) REFERENCES poslovnice (poslovnica_id);
ALTER TABLE musterije ADD CONSTRAINT cons_mus_pos_fk FOREIGN KEY (poslovnica_id) REFERENCES poslovnice (poslovnica_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_rac_uplata_fk FOREIGN KEY (uplata_racun_id) REFERENCES racuni (racun_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_rac_isplata_fk FOREIGN KEY (isplata_racun_id) REFERENCES racuni (racun_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_pos_uplata_fk FOREIGN KEY (uplata_poslovnica_id) REFERENCES poslovnice (poslovnica_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_pos_isplata_fk FOREIGN KEY (isplata_poslovnica_id) REFERENCES poslovnice (poslovnica_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_kre_uplata_fk FOREIGN KEY (uplata_kredit_id) REFERENCES krediti (kredit_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_kre_isplata_fk FOREIGN KEY (isplata_kredit_id) REFERENCES krediti (kredit_id);
ALTER TABLE transakcije ADD CONSTRAINT cons_tra_ban_fk FOREIGN KEY (bankomat_id) REFERENCES bankomati (bankomat_id);
ALTER TABLE racuni ADD CONSTRAINT cons_rac_trac_fk FOREIGN KEY (tip_racuna) REFERENCES tipovi_racuna (tip_id);
ALTER TABLE racuni ADD CONSTRAINT cons_rac_mus_fk FOREIGN KEY (musterija_id) REFERENCES musterije (musterija_id);
ALTER TABLE racuni ADD CONSTRAINT cons_rac_tkar_fk FOREIGN KEY (tip_kartice) REFERENCES tipovi_kartica (tip_id);
ALTER TABLE krediti ADD CONSTRAINT cons_kre_mus_fk FOREIGN KEY (musterija_id) REFERENCES musterije (musterija_id);
ALTER TABLE krediti ADD CONSTRAINT cons_kre_zir_fk FOREIGN KEY (zirant_id) REFERENCES musterije (musterija_id);
ALTER TABLE krediti ADD CONSTRAINT cons_kre_tkre_fk FOREIGN KEY (tip_kredita) REFERENCES tipovi_kredita (tip_id);

-- nek se nadje:

ALTER TABLE zaposleni DROP CONSTRAINT cons_zap_pos_fk;
ALTER TABLE poslovnice DROP CONSTRAINT cons_pos_pos_fk;
ALTER TABLE bankomati DROP CONSTRAINT cons_ban_pod_fk;
ALTER TABLE musterije DROP CONSTRAINT cons_mus_pos_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_rac_uplata_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_rac_isplata_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_pos_uplata_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_pos_isplata_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_kre_uplata_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_kre_isplata_fk;
ALTER TABLE transakcije DROP CONSTRAINT cons_tra_ban_fk;
ALTER TABLE racuni DROP CONSTRAINT cons_rac_trac_fk;
ALTER TABLE racuni DROP CONSTRAINT cons_rac_mus_fk;
ALTER TABLE racuni DROP CONSTRAINT cons_rac_tkar_fk;
ALTER TABLE krediti DROP CONSTRAINT cons_kre_mus_fk;
ALTER TABLE krediti DROP CONSTRAINT cons_kre_zir_fk;
ALTER TABLE krediti DROP CONSTRAINT cons_kre_tkre_fk;

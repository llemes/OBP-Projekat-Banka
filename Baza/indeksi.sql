CREATE INDEX poslovnice_ind
ON poslovnice(tip_poslovnice);

CREATE INDEX musterije_ind
ON musterije(musterija_id, ime, prezime);

-- relativno cesto se koristi, nece se mijenjati

CREATE INDEX kartice_ind
ON tipovi_kartica(tip_id);

CREATE INDEX racuni_ind
ON tipovi_racuna(tip_id, max_velicina_transakcija, mjesecni_odbitak);

CREATE INDEX krediti_ind
ON tipovi_kredita(tip_id, maksimalni_iznos, kamatna_stopa);

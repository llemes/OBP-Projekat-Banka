CREATE TABLE zaposleni(zaposleni_id INTEGER NOT NULL,
                       ime VARCHAR2(45) NOT NULL,
                       prezime VARCHAR2(45) NOT NULL,
                       funkcija VARCHAR2(45),
                       odjel VARCHAR2(45),
                       poslovnica_id INTEGER NOT NULL,
                       plata INTEGER NOT NULL,
                       CONSTRAINT cons_zap_pk PRIMARY KEY (zaposleni_id));

CREATE TABLE poslovnice(poslovnica_id INTEGER NOT NULL,
                        tip_poslovnice VARCHAR2(45) NOT NULL,
                        lokacija VARCHAR2(45) NOT NULL,
                        stanje DECIMAL NOT NULL,
                        nadlezna_poslovnica_id INTEGER,
                        CONSTRAINT cons_pos_pk PRIMARY KEY (poslovnica_id));

CREATE TABLE bankomati(bankomat_id INTEGER NOT NULL,
                       stanje DECIMAL NOT NULL,
                       poslovnica_id INTEGER NOT NULL,
                       CONSTRAINT cons_ban_pk PRIMARY KEY (bankomat_id));

CREATE TABLE musterije(musterija_id INTEGER NOT NULL,
                       ime VARCHAR2(45) NOT NULL,
                       prezime VARCHAR2(45) NOT NULL,
                       datum_rodjenja DATE NOT NULL,
                       zaposlenje VARCHAR2(45),
                       mjesecna_primanja DECIMAL,
                       iznos_dugovanja DECIMAL,
                       poslovnica_id INTEGER NOT NULL,
                       CONSTRAINT cons_mus_pk PRIMARY KEY (musterija_id));

CREATE TABLE transakcije(transakcija_id INTEGER NOT NULL,
                         vrijeme_transakcije DATE NOT NULL,
                         iznos_transakcije DECIMAL NOT NULL,
                         uplata_racun_id INTEGER,
                         isplata_racun_id INTEGER,
                         uplata_poslovnica_id INTEGER,
                         isplata_poslovnica_id INTEGER,
                         uplata_kredit_id INTEGER,
                         isplata_kredit_id INTEGER,
                         bankomat_id INTEGER,
                         CONSTRAINT cons_tra_pk PRIMARY KEY (transakcija_id));

CREATE TABLE racuni(racun_id INTEGER NOT NULL,
                    tip_racuna VARCHAR2(10) NOT NULL,
                    musterija_id INTEGER NOT NULL,
                    tip_kartice VARCHAR2(10),
                    balans DECIMAL NOT NULL,
                    CONSTRAINT cons_rac_pk PRIMARY KEY (racun_id));

CREATE TABLE tipovi_racuna(tip_id VARCHAR2(10) NOT NULL,
                           max_velicina_transakcija DECIMAL NOT NULL,
                           mjesecni_odbitak DECIMAL NOT NULL,
                           CONSTRAINT cons_trac_pk PRIMARY KEY (tip_id));

CREATE TABLE tipovi_kartica(tip_id VARCHAR2(10) NOT NULL,
                            puni_naziv VARCHAR2(45) NOT NULL,
                            CONSTRAINT cons_tkar_pk PRIMARY KEY (tip_id));

CREATE TABLE krediti(kredit_id INTEGER NOT NULL,
                     musterija_id INTEGER NOT NULL,
                     zirant_id INTEGER NOT NULL,
                     tip_kredita VARCHAR2(10) NOT NULL,
                     ukupan_iznos DECIMAL NOT NULL,
                     placenih_rata INTEGER NOT NULL,
                     preostalih_rata INTEGER NOT NULL,
                     zadnja_uplata DATE,
                     datum_zaduzenja DATE NOT NULL,
                     CONSTRAINT cons_kre_pk PRIMARY KEY (kredit_id));

CREATE TABLE tipovi_kredita(tip_id VARCHAR2(10) NOT NULL,
                            maksimalni_iznos DECIMAL NOT NULL,
                            min_iznos_rate DECIMAL NOT NULL,
                            min_period_otplate INTEGER NOT NULL,
                            max_period_otplate INTEGER NOT NULL,
                            puni_naziv VARCHAR2(45) NOT NULL,
                            kamatna_stopa DECIMAL(3, 2) NOT NULL,
                            CONSTRAINT cons_tkre_pk PRIMARY KEY (tip_id));

COMMENT ON COLUMN tipovi_kredita.min_period_otplate IS 'Broj godina za koje treba otplatiti kredit';
COMMENT ON COLUMN tipovi_kredita.max_period_otplate IS 'Maksimalan broj godina za koje treba otplatiti kredit';

CREATE OR REPLACE VIEW musterije_sarajevo
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 7;

CREATE OR REPLACE VIEW musterije_zagreb
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 8;

CREATE OR REPLACE VIEW musterije_budapest
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 9;

CREATE OR REPLACE VIEW musterije_stockholm
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 10;

CREATE OR REPLACE VIEW musterije_reykjavik
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 11;

CREATE OR REPLACE VIEW musterije_copenhagen
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 12;

CREATE OR REPLACE VIEW musterije_toulouse
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 13;

CREATE OR REPLACE VIEW musterije_ottawa
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 14;

CREATE OR REPLACE VIEW musterije_vancouver
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 15;

CREATE OR REPLACE VIEW musterije_toronto
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 2;

CREATE OR REPLACE VIEW musterije_frankfurt
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 3;

CREATE OR REPLACE VIEW musterije_barcelona
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 4;

CREATE OR REPLACE VIEW musterije_oslo
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 5;

CREATE OR REPLACE VIEW musterije_ljubljana
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 6;

CREATE OR REPLACE VIEW musterije_nyc
AS
SELECT *
FROM musterije
WHERE poslovnica_id = 1;

COMMIT;

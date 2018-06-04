-- sedmicni izvjestaj za lokalne poslovnice

SELECT iznos_ulaznih_transakcija(poslovnica_id) AS "ulaz", iznos_izlaznih_transakcija(poslovnica_id) AS "izlaz"
FROM poslovnice
WHERE tip_poslovnice LIKE 'lokalna';

-- mjesecni izvjestaj za regionalne poslovnice

SELECT m_iznos_ulaznih_transakcija(poslovnica_id) AS ulaz, m_iznos_izlaznih_transakcija(poslovnica_id) AS izlaz
FROM poslovnice
WHERE tip_poslovnice LIKE 'regionalna';

-- godisnji izvjestaj centrale (razlika ulaza i izlaza za cijelu godinu)

SELECT sumarni_izvjestaj FROM dual;
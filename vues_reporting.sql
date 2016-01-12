CREATE SCHEMA reporting;

CREATE VIEW reporting.nb_ha_convention_mae AS
SELECT count(id_ug) as nb_ug, count(id_contrat) as nb_contrats, st_area2d(st_union(geometrie))::numeric/10000 as surf_tota_ha
  FROM compensation.unite_de_gestion JOIN compensation.contrat_de_gestion USING(id_contrat)
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date;

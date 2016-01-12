CREATE SCHEMA reporting;

CREATE VIEW reporting.nb_ha_convention_mae AS
SELECT now()::date as date, count(id_ug) as nb_ug, count(id_contrat) as nb_contrats, st_area2d(st_union(geometrie))::numeric/10000 as surf_tota_ha
  FROM compensation.unite_de_gestion JOIN compensation.contrat_de_gestion USING(id_contrat)
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date;
  
CREATE VIEW reporting.nb_exploitants_sous_convention AS
SELECT now()::date AS date, count(id_exploitant) as nb_exploitants, count(id_contrat) as nb_contrats
  FROM compensation.contrat_de_gestion
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date;

CREATE VIEW reporting.nb_ha_en_convention_pare_code_mesure AS
SELECT now()::date as date, code_mesure, st_area2d(st_union(geometrie))::numeric/10000 as surf_tota_ha
  FROM compensation.unite_de_gestion JOIN compensation.contrat_de_gestion USING(id_contrat)
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date
  GROUP By code_mesure;

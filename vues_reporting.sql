CREATE SCHEMA reporting;

CREATE OR REPLACE VIEW reporting.nb_ha_convention_mae AS
SELECT now()::date as date, count(id_ug) as nb_ug, count(id_contrat) as nb_contrats, st_area2d(st_union(geometrie))::numeric/10000 as surf_tota_ha
  FROM compensation.unite_de_gestion JOIN compensation.contrat_de_gestion USING(id_contrat)
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date;
  
CREATE OR REPLACE VIEW reporting.nb_exploitants_sous_convention AS
SELECT now()::date AS date, count(id_exploitant) as nb_exploitants, count(id_contrat) as nb_contrats
  FROM compensation.contrat_de_gestion
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date;

CREATE OR REPLACE VIEW reporting.nb_ha_en_convention_par_code_mesure AS
SELECT now()::date as date, code_mesure, st_area2d(st_union(geometrie))::numeric/10000 as surf_tota_ha
  FROM compensation.unite_de_gestion JOIN compensation.contrat_de_gestion USING(id_contrat)
  WHERE daterange(date_effet, date_expiration, '[]') @>now()::date
  GROUP By code_mesure;

CREATE OR REPLACE VIEW reporting.cout_total_euros_mae_signees AS
SELECT now()::date as date, sum(indemnite_exploitant_euros) as cout_total_mae_signees
  FROM compensation.unite_de_gestion JOIN compensation.contrat_de_gestion USING(id_contrat)
  WHERE COALESCE(contrat_de_gestion.date_effet,contrat_de_gestion.date_signature) <=now()::date;

CREATE OR REPLACE VIEW reporting.cout_moyen_ha_par_exploitant AS 
 SELECT now()::date AS date, exploitant.raison_sociale, round(avg(unite_de_gestion.indemnite_exploitant_euros_ha),2) AS cout_moyen_ha
   FROM compensation.unite_de_gestion
   JOIN compensation.contrat_de_gestion USING (id_contrat)
   JOIN compensation.exploitant USING (id_exploitant)
  WHERE COALESCE(contrat_de_gestion.date_effet,contrat_de_gestion.date_signature) <= now()::date
  GROUP BY exploitant.raison_sociale;

CREATE OR REPLACE VIEW reporting.nb_moyen_contrat_par_exploitant AS
SELECT now()::date as date, count(distinct id_contrat) as nb_contrats, count(distinct id_exploitant) as nb_exploitant, CASE WHEN count(id_exploitant)>0 THEN count(distinct id_contrat)::numeric/count(distinct id_exploitant)::numeric ELSE NULL END as nb_moyen_contrat_par_exploitant
  FROM compensation.contrat_de_gestion
  JOIN compensation.exploitant USING(id_exploitant)
  WHERE COALESCE(contrat_de_gestion.date_effet,contrat_de_gestion.date_signature) <=now()::date;
  
CREATE OR REPLACE VIEW reporting.duree_moyenne_convention AS 
 SELECT now()::date AS date, 
    count(DISTINCT contrat_de_gestion.id_contrat) AS nb_contrats, round(avg(contrat_de_gestion.duree_en_mois),2) AS duree_moyenne_mois
   FROM compensation.contrat_de_gestion
  WHERE COALESCE(contrat_de_gestion.date_effet,contrat_de_gestion.date_signature) <= now()::date;

CREATE OR REPLACE VIEW reporting.echeance_contrat AS 
 SELECT id_contrat, extract(day from(date_expiration::timestamp - now()::timestamp)) as echeance_en_jours
   FROM compensation.contrat_de_gestion
  ORDER BY 2 ASC;

CREATE OR REPLACE VIEW reporting.surface_moyenne_ug AS 
 SELECT now()::date AS date, count(id_ug) as nb_ug, round(sum(st_area2d(geometrie)/10000)::numeric,2) AS tot_surf_ha, round(avg(st_area2d(geometrie)/10000)::numeric,2) AS avg_surf_ha
   FROM compensation.unite_de_gestion
   JOIN compensation.contrat_de_gestion USING (id_contrat)
  WHERE COALESCE(contrat_de_gestion.date_effet,contrat_de_gestion.date_signature) <= now()::date;

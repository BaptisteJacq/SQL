/*
La table TA_FAMILLE_LIBELLE sert à faire la liaison entre les tables ta_libelle_long et ta_famille.
*/
-- 1. Création de la table
CREATE TABLE G_GEO.TA_FAMILLE_LIBELLE(
	objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
	fid_famille NUMBER(38,0),
	fid_libelle_long NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE G_GEO.TA_FAMILLE_LIBELLE IS 'Table contenant les identifiant des tables ta_libelle_long et ta_famille, permettant de joindre le libellé à sa famille de libellés.';
COMMENT ON COLUMN G_GEO.TA_FAMILLE_LIBELLE.objectid IS 'Identifiant de chaque ligne.';
COMMENT ON COLUMN G_GEO.TA_FAMILLE_LIBELLE.fid_famille IS 'Identifiant de chaque famille de libellés - FK de la table ta_famille.';
COMMENT ON COLUMN G_GEO.TA_FAMILLE_LIBELLE.fid_libelle_long IS 'Identifiant de chaque libellés - FK de la table ta_libelle_long.';

-- 3. Création de la clé primaire
ALTER TABLE G_GEO.TA_FAMILLE_LIBELLE
ADD CONSTRAINT TA_FAMILLE_LIBELLE_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_GEO.TA_FAMILLE_LIBELLE
ADD CONSTRAINT TA_FAMILLE_LIBELLE_FID_FAMILLE_FK
FOREIGN KEY("fid_famille")
REFERENCES G_GEO.TA_FAMILLE(objectid);

ALTER TABLE G_GEO.TA_FAMILLE_LIBELLE
ADD CONSTRAINT TA_FAMILLE_LIBELLE_FID_LIBELLE_LONG_FK
FOREIGN KEY("fid_libelle_long")
REFERENCES G_GEO.TA_LIBELLE_LONG(objectid);

-- 7. Création de l'index de la clé étrangère
CREATE INDEX TA_FAMILLE_LIBELLE_FID_FAMILLE_IDX ON TA_FAMILLE_LIBELLE(fid_famille)
TABLESPACE G_ADT_INDX;

CREATE INDEX TA_FAMILLE_LIBELLE_FID_LIBELLE_LONG_IDX ON TA_FAMILLE_LIBELLE(fid_libelle_long)
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_GEO.TA_FAMILLE_LIBELLE TO G_ADMIN_SIG;

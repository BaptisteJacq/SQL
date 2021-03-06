/*
La table TA_GG_PERMIS_CONSTRUIRE permet de regrouper tous les numéros et dates de permis de construire récupéré et utilisé par les photo-interprètes via GestionGeo.
*/
-- 1. Création de la table TA_GG_PERMIS_CONSTRUIRE ;
CREATE TABLE G_GEO.TA_GG_PERMIS_CONSTRUIRE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY, 
    numero VARCHAR2(100 BYTE) NOT NULL, 
    debut DATE NOT NULL, 
    fin DATE NOT NULL
);

-- 2. Création des commentaires sur la table et les champs ;
COMMENT ON TABLE G_GEO.TA_GG_PERMIS_CONSTRUIRE IS 'La table TA_GG_PERMIS_CONSTRUIRE permet de regrouper tous les numéros et dates de permis de construire récupéré et utilisé par les photo-interprètes via GestionGeo.' ;
COMMENT ON COLUMN G_GEO.TA_GG_PERMIS_CONSTRUIRE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_GEO.TA_GG_PERMIS_CONSTRUIRE.numero IS 'Numéro du permis de construire.';
COMMENT ON COLUMN G_GEO.TA_GG_PERMIS_CONSTRUIRE.debut IS 'Date de début de validité du permis de contruire';
COMMENT ON COLUMN G_GEO.TA_GG_PERMIS_CONSTRUIRE.fin IS 'Date de fin de validité du permis de construire';

-- 3. Création de la clé primaire ;
ALTER TABLE TA_GG_PERMIS_CONSTRUIRE 
ADD CONSTRAINT TA_GG_PERMIS_CONSTRUIRE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des indexes ;
CREATE INDEX TA_GG_PERMIS_CONSTRUIRE_NUMERO_IDX ON G_GEO.TA_GG_PERMIS_CONSTRUIRE(NUMERO)
    TABLESPACE G_ADT_INDX;
/*
Code permettant de vider le schéma G_GESTIONGEO de ses objets (code DDL)
*/
-- 1. TABLES FINALES
-- Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_GG_GEO';
COMMIT;
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_GG_POINT';
COMMIT;
-- Suppression de l'index spatial de la VM_GG_POINT
DROP INDEX VM_GG_POINT_SIDX;

-- Suppression des tables
DROP TABLE G_GESTIONGEO.TA_GG_GEO CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TA_GG_DOSSIER CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TA_GG_SOURCE CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TA_GG_ETAT CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TA_GG_FAMILLE CASCADE CONSTRAINTS;

-- Suppression de la VM
DROP MATERIALIZED VIEW G_GESTIONGEO.VM_GG_POINT;
------------------------------------------------------------

-- 2. TABLES TEMPORAIRES
-- Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TEMP_TA_GG_GEO';
COMMIT;

-- Suppression des tables
DROP TABLE G_GESTIONGEO.TEMP_TA_GG_GEO CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TEMP_TA_GG_DOSSIER CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TEMP_TA_GG_SOURCE CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TEMP_TA_GG_ETAT CASCADE CONSTRAINTS;
DROP TABLE G_GESTIONGEO.TEMP_TA_GG_FAMILLE CASCADE CONSTRAINTS;
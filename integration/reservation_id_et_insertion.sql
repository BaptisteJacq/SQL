/*
Code permettant la réservation d'une plage d'id.

Objectif :
- réserver une plage d'id et permettre une auto-incrémentation normale au-delà de cette plage afin qu'il n'y ait pas de tentative d'insertion de doublons 
(qui aboutirait sur une erreur due à la contrainte d'unicité) ;
- Permettre une insertion automatisée dans le champ objectid (le développeur ne doit pas écrire de valeurs à insérer dans ce champ) ;
- Donner une marge dans la réservation des ids, ainsi si un nombre d'insertions est plus grand que prévu, nous aurons toujours une suite de nombres pour un même thème dans le champ objectid ;

Enjeux :
- Permettre de faire des conditions sur une plage de valeurs de la PK, plutôt que des conditions d'égalité sur du varchar ; 
- Empêcher les erreurs dues à la casse (les conditions portant désormais sur du number et non sur du varchar, il n'y a plus de risque d'erreur due à la casse) ;

1. Code permettant de réserver une plage d'ids et d'insérer une liste de valeur dans la même transaction ;
2. Code permettant de réserver une plage d'ids pour une insertion ultérieure ;
*/


-- 1. Code permettant de réserver une plage d'id et d'insérer une liste de valeur dans la même transaction ;
SET SERVEROUTPUT ON
DECLARE
    v_id_max NUMBER(38,0);
    v_nb_id_reserve NUMBER(38,0);
    v_id_reserve NUMBER(38,0);
 
BEGIN
	SAVEPOINT POINT_SAUVERGARDE_RESERVATION_ID;
-- Sélection de l'identifiant maximal de la table d'insertion
    SELECT
        MAX(OBJECTID)
        INTO v_id_max
    FROM
        G_GEO.TEMP_LIBELLE_LONG;

-- Décompte du nombre d'objets à réserver (depuis une table d'import que l'on aurait insérée dans oracle via ogr2ogr)
    SELECT
        COUNT(OGR_FID)
        INTO v_nb_id_reserve
    FROM
        G_GEO.TEMP_LIBELLE_COMMUNE;

/* 
Création du nouveau numéro de départ de l'incrémentation (dans le code ci-dessous je fais recommencer l'incrémentation de la PK 
juste après l'insertion de mes valeurs via le "+1", mais on peut se donner une marge en modifiant ce chiffre). 
*/
    v_id_reserve := v_id_max + v_nb_id_reserve + 1;

-- Modification de la valeur de départ de la séquence d'auto-incrémentation via du SQL dynamique
EXECUTE IMMEDIATE 'ALTER TABLE G_GEO.TEMP_LIBELLE_LONG MODIFY OBJECTID GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_id_reserve || ')';

-- Insertion des valeurs dans la table. L'incrémentation de la PK se fait via une boucle, c'est-à-dire une structure séquentielle
    FOR i IN (SELECT valeur FROM G_GEO.TEMP_LIBELLE_COMMUNE) LOOP
        -- L'utilisation du merge permet d'éviter les doublons de valeurs dans les tables
        MERGE INTO G_GEO.TEMP_LIBELLE_LONG a
            USING(SELECT i.valeur FROM DUAL)
            ON (UPPER(a.valeur) = UPPER(i.valeur))
        WHEN NOT MATCHED THEN
            INSERT(objectid, valeur)
            VALUES(v_id_max+1, i.valeur);
        v_id_max:=v_id_max+1; -- incrémentation de 1 de la valeur à insérer dans objectid à chaque passage dans la boucle
    END LOOP;
-- Le code qui suit permet de connaître le nombre d'ids réservés et la valeur à partir de laquelle l'auto-incrémentation reprend
DBMS_OUTPUT.PUT_lINE('Nombre d''id à réserver : '|| v_nb_id_reserve || ' - id de reprise de l''incrémentation : ' || v_id_reserve);
-- En cas d'erreur un rollback est effectué, permettant de revenir à l'état de la table précédent la tentative d'insertion. Dans ce cas le LAST_NUMBER de la séquence d'auto-incrémentation n'est pas modifié.
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
    ROLLBACK TO POINT_SAUVERGARDE_RESERVATION_ID;
END;


-- 2. Code permettant de réserver une plage d'ids pour une insertion ultérieure ;
SET SERVEROUTPUT ON
DECLARE
    v_id_max NUMBER(38,0);
    v_nb_id_reserve NUMBER(38,0);
    v_id_reserve NUMBER(38,0);
 
BEGIN
	SAVEPOINT POINT_SAUVERGARDE_RESERVATION_ID;
-- Sélection de l'identifiant maximal de la table d'insertion
    SELECT
        MAX(OBJECTID)
        INTO v_id_max
    FROM
        G_GEO.TEMP_LIBELLE_LONG;

-- Déompte du nombre d'objets à réserver (depuis une table d'import que l'on aurait insérée dans oracle via ogr2ogr)
    SELECT
        COUNT(OGR_FID)
        INTO v_nb_id_reserve
    FROM
        G_GEO.TEMP_LIBELLE_COMMUNE;

/* 
Création du nouveau numéro de départ de l'incrémentation (dans le code ci-dessous je fais recommencer l'incrémentation de la PK 
juste après l'insertion de mes valeurs via le "+1", mais on peut se donner une marge en modifiant ce chiffre). 
*/
    v_id_reserve := v_id_max + v_nb_id_reserve + 1;

-- Modification de la valeur de départ de la séquence d'auto-incrémentation via du SQL dynamique
EXECUTE IMMEDIATE 'ALTER TABLE G_GEO.TEMP_LIBELLE_LONG MODIFY OBJECTID GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_id_reserve || ')';

-- Ce message est nécessaire pour connaître la valeur à partir de laquelle commencer l'insertion et la valeur à partir de laquelle l'auto-incrémentation reprend
DBMS_OUTPUT.PUT_lINE('Id à partir duquel l''insertion va commencer : ' || v_id_max || ' - Nombre d''id à réserver : '|| v_nb_id_reserve || ' - Id de reprise de l''incrémentation : ' || v_id_reserve);

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
    ROLLBACK TO POINT_SAUVERGARDE_RESERVATION_ID;
END;

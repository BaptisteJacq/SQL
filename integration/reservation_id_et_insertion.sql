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




-- Code permettant de réserver une plage d'ids pour une insertion ultérieure ;
SET SERVEROUTPUT ON
DECLARE
    v_id_max NUMBER(38,0);
    v_nb_id_reserve NUMBER(38,0);
    v_id_reserve NUMBER(38,0);
    v_nom_sequence VARCHAR2(50);
 
BEGIN
    SAVEPOINT POINT_SAUVERGARDE_RESERVATION_ID;
-- 1. Identification des libellés présents en base ou non
UPDATE G_GEO.TEMP_LIBELLE_POINT_VIGILANCE a
    SET a.EN_BASE = CASE
                        WHEN a.VALEUR IN(SELECT b.VALEUR FROM G_GEO.TEMP_LIBELLE_LONG b)
                            THEN 1 -- si la valeur est déjà en base alors 1
                        ELSE
                            0 -- si la valeur n'est pas en base alors 0
                    END;

-- 2. Suppression des valeurs déjà présentes en base
DELETE FROM G_GEO.TEMP_LIBELLE_POINT_VIGILANCE WHERE EN_BASE = 1;
COMMIT;

-- 3. Décompte du nombre d'objet/de valeurs à insérer en base
SELECT
    COUNT(OGR_FID)
    INTO v_nb_id_reserve
FROM
    G_GEO.TEMP_LIBELLE_POINT_VIGILANCE
WHERE
    EN_BASE = 0;

-- 4. Sélection de la prochaine valeur d'incrémentation de la PK de la table d'insertion
 SELECT
    LAST_NUMBER
    INTO v_id_max
FROM
    ALL_SEQUENCES
WHERE
    SEQUENCE_NAME = v_nom_sequence;

-- 5. Création des ids à insérer dans la table d'insertion
EXECUTE IMMEDIATE 'ALTER TABLE G_GEO.TEMP_LIBELLE_POINT_VIGILANCE ADD fid_objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_id_max || ' CACHE 20)';

-- 6. Réservation des ids dans la table d'insertion
-- 6.1. Sélection du nom de la séquence d'incrémentation
SELECT 
    SEQUENCE_NAME
    INTO v_nom_sequence
FROM user_tab_identity_cols
WHERE TABLE_NAME = 'TEMP_LIBELLE_LONG';

-- 6.2. Création du nouvel id à partir duquel faire repartir l'auto-incrémentation de la PK.
    v_id_reserve := v_nb_id_reserve + v_id_max;

-- 6.3. Modification de la valeur de départ de la séquence d'auto-incrémentation via du SQL dynamique
EXECUTE IMMEDIATE 'ALTER TABLE G_GEO.TEMP_LIBELLE_LONG MODIFY OBJECTID GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_id_reserve || ')';

-- Le code qui suit permet de connaître le nombre d'ids réservés et la valeur à partir de laquelle l'auto-incrémentation reprend
DBMS_OUTPUT.PUT_lINE('Nombre d''id à réserver : '|| v_nb_id_reserve || ' - id de reprise de l''incrémentation : ' || v_id_reserve);
-- En cas d'erreur un rollback est effectué, permettant de revenir à l'état de la table précédent la tentative d'insertion. Dans ce cas le LAST_NUMBER de la séquence d'auto-incrémentation n'est pas modifié.
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
    ROLLBACK TO POINT_SAUVERGARDE_RESERVATION_ID;
END;

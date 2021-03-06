-- Sélection des erreurs de géométrie des tables TOPO_G

SELECT
    'TA_LIG_TOPO_G' AS NOM_TABLE,
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005), 0, 5) AS ERREUR,
    COUNT(a.objectid) AS Nombre
FROM
    GEO.TA_LIG_TOPO_G a
WHERE
    SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005)<>'TRUE'
GROUP BY
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005), 0, 5),
    'TA_LIG_TOPO_G'
UNION ALL
SELECT
    'TA_SUR_TOPO_G' AS NOM_TABLE,
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005), 0, 5) AS ERREUR,
    COUNT(a.objectid) AS Nombre
FROM
    GEO.TA_SUR_TOPO_G a
WHERE
    SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005)<>'TRUE'
GROUP BY
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005), 0, 5),
    'TA_SUR_TOPO_G'
UNION ALL
SELECT
    'TA_POINT_TOPO_G' AS NOM_TABLE,
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005), 0, 5) AS ERREUR,
    COUNT(a.objectid) AS Nombre
FROM
    GEO.TA_POINT_TOPO_G a
WHERE
    SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005)<>'TRUE'
GROUP BY
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005), 0, 5),
    'TA_POINT_TOPO_G';
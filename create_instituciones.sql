\connect  udlafutbolappcompetencias;

INSERT INTO institucion (nombreinstitucion, institucionactiva)
SELECT v.nombre, v.activo
FROM (VALUES
  ('Escuela Politécnica Nacional', TRUE),
  ('Escuela Superior Politécnica del Litoral (ESPOL)', TRUE),
  ('Universidad de las Fuerzas Armadas (ESPE)', TRUE),
  ('Universidad Central del Ecuador', TRUE),
  ('Pontificia Universidad Católica del Ecuador (PUCE)', TRUE),
  ('Universidad San Francisco de Quito (USFQ)', TRUE),
  ('Universidad de Cuenca', TRUE),
  ('Universidad Técnica Particular de Loja (UTPL)', TRUE),
  ('Universidad Técnica de Ambato (UTA)', TRUE),
  ('Universidad de las Américas (UDLA)', TRUE),
  ('Universidad del Azuay (UDA)', TRUE),
  ('Universidad Católica de Santiago de Guayaquil (UCSG)', TRUE),
  ('Universidad Técnica del Norte (UTN)', TRUE),
  ('Universidad Técnica de Manabí (UTM)', TRUE),
  ('Universidad de Guayaquil', TRUE),
  ('Universidad Laica Vicente Rocafuerte de Guayaquil (ULVR)', TRUE),
  ('Universidad Internacional SEK (UISEK)', TRUE),
  ('Universidad Regional Autónoma de los Andes (UNIANDES)', TRUE),
  ('Universidad Estatal de Milagro (UNEMI)', TRUE),
  ('Universidad Estatal de Bolívar (UEB)', TRUE),
  ('Universidad Técnica de Machala (UTMACH)', TRUE),
  ('Universidad Técnica Estatal de Quevedo (UTEQ)', TRUE),
  ('Universidad Técnica de Cotopaxi (UTC)', TRUE),
  ('Universidad Nacional de Loja (UNL)', TRUE),
  ('Universidad Técnica Luis Vargas Torres de Esmeraldas (UTE-LVT)', TRUE),
  ('Universidad Técnica de Babahoyo (UTB)', TRUE),
  ('Universidad Estatal Amazónica (UEA)', TRUE),
  ('Universidad Politécnica Salesiana (UPS)', TRUE),
  ('Universidad Internacional del Ecuador (UIDE)', TRUE),
  ('Universidad Metropolitana del Ecuador (UMET)', TRUE)
) AS v(nombre, activo)
WHERE NOT EXISTS (SELECT 1 FROM institucion i WHERE i.nombreinstitucion = v.nombre);
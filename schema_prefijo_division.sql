-- Migración: agrega columna prefijo a divisiones para folios automáticos
-- Ejecutar en Neon una sola vez

ALTER TABLE divisiones
  ADD COLUMN IF NOT EXISTS prefijo VARCHAR(10);

-- Poblar prefijos de las divisiones existentes (ajusta si tu catálogo es diferente)
UPDATE divisiones SET prefijo = 'INM' WHERE LOWER(nombre) LIKE '%inmobil%' AND prefijo IS NULL;
UPDATE divisiones SET prefijo = 'AUT' WHERE LOWER(nombre) LIKE '%automo%'  AND prefijo IS NULL;
UPDATE divisiones SET prefijo = 'FIN' WHERE LOWER(nombre) LIKE '%financ%'  AND prefijo IS NULL;
UPDATE divisiones SET prefijo = 'COR' WHERE LOWER(nombre) LIKE '%corporat%' AND prefijo IS NULL;

-- Fallback: asignar primeras 3 letras del nombre para cualquier división sin prefijo
UPDATE divisiones SET prefijo = UPPER(LEFT(nombre, 3)) WHERE prefijo IS NULL;

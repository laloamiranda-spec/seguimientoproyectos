-- ============================================================
-- Seguimiento de horas + Cola por responsable
-- Ejecutar en Neon SQL Editor
-- ============================================================

-- 1. Registro de horas trabajadas por entregable
CREATE TABLE IF NOT EXISTS registros_trabajo (
    id               SERIAL PRIMARY KEY,
    entregable_id    INT NOT NULL REFERENCES entregables(id) ON DELETE CASCADE,
    fecha            DATE NOT NULL DEFAULT CURRENT_DATE,
    horas_trabajadas NUMERIC(5,2) NOT NULL CHECK (horas_trabajadas > 0),
    notas            TEXT,
    creado_en        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_registros_entregable ON registros_trabajo(entregable_id);

-- 2. Orden de prioridad por responsable (NULL = sin asignar)
ALTER TABLE entregables ADD COLUMN IF NOT EXISTS orden_responsable SMALLINT;

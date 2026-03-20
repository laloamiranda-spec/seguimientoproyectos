-- ============================================================
-- Módulo de Soporte Recurrente — Gestor de Entregables+
-- Ejecutar en Neon SQL Editor
-- ============================================================

-- 1. Temas recurrentes
CREATE TABLE IF NOT EXISTS temas_soporte (
    id           SERIAL PRIMARY KEY,
    titulo       VARCHAR(200) NOT NULL,
    descripcion  TEXT,
    tipo         VARCHAR(30) DEFAULT 'Sistema'
                 CHECK (tipo IN ('Sistema','SQL','Proceso','Integración','Otro')),
    url_proyecto VARCHAR(500),
    division_id  INT REFERENCES divisiones(id) ON DELETE SET NULL,
    activo       SMALLINT DEFAULT 1,
    creado_en    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Causas por tema
CREATE TABLE IF NOT EXISTS causas_soporte (
    id           SERIAL PRIMARY KEY,
    tema_id      INT NOT NULL REFERENCES temas_soporte(id) ON DELETE CASCADE,
    descripcion  TEXT NOT NULL,
    creado_en    TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Soluciones por causa
CREATE TABLE IF NOT EXISTS soluciones_soporte (
    id           SERIAL PRIMARY KEY,
    causa_id     INT NOT NULL REFERENCES causas_soporte(id) ON DELETE CASCADE,
    descripcion  TEXT NOT NULL,
    codigo_sql   TEXT,
    url_ref      VARCHAR(500),
    creado_en    TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Entregables hijos vinculados al tema (soluciones en desarrollo)
CREATE TABLE IF NOT EXISTS tema_entregable (
    tema_id       INT NOT NULL REFERENCES temas_soporte(id) ON DELETE CASCADE,
    entregable_id INT NOT NULL REFERENCES entregables(id)   ON DELETE CASCADE,
    PRIMARY KEY (tema_id, entregable_id)
);

CREATE INDEX IF NOT EXISTS idx_causas_tema      ON causas_soporte(tema_id);
CREATE INDEX IF NOT EXISTS idx_soluciones_causa  ON soluciones_soporte(causa_id);
CREATE INDEX IF NOT EXISTS idx_tema_entregable   ON tema_entregable(tema_id);

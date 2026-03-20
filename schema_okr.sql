-- ============================================================
-- Módulo OKR — Gestor de Entregables+
-- Ejecutar en Neon SQL Editor
-- ============================================================

-- 1. Ciclos (Q1 2026, Q2 2026, Anual 2026…)
CREATE TABLE IF NOT EXISTS ciclos_okr (
    id           SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE NOT NULL,
    activo       SMALLINT DEFAULT 0,
    creado_en    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Objetivos cualitativos y aspiracionales
CREATE TABLE IF NOT EXISTS objetivos (
    id             SERIAL PRIMARY KEY,
    ciclo_id       INT NOT NULL REFERENCES ciclos_okr(id) ON DELETE CASCADE,
    titulo         VARCHAR(200) NOT NULL,
    descripcion    TEXT,
    responsable_id INT REFERENCES responsables(id) ON DELETE SET NULL,
    color          VARCHAR(7) DEFAULT '#4F46E5',
    creado_en      TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Key Results medibles por objetivo
CREATE TABLE IF NOT EXISTS key_results (
    id            SERIAL PRIMARY KEY,
    objetivo_id   INT NOT NULL REFERENCES objetivos(id) ON DELETE CASCADE,
    descripcion   VARCHAR(300) NOT NULL,
    metrica       VARCHAR(100),
    valor_inicial NUMERIC(10,2) DEFAULT 0,
    valor_meta    NUMERIC(10,2) NOT NULL DEFAULT 100,
    valor_actual  NUMERIC(10,2) DEFAULT 0,
    unidad        VARCHAR(30)  DEFAULT '%',
    creado_en     TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Relación muchos-a-muchos entregable ↔ key_result
CREATE TABLE IF NOT EXISTS entregable_key_result (
    entregable_id    INT NOT NULL REFERENCES entregables(id) ON DELETE CASCADE,
    key_result_id    INT NOT NULL REFERENCES key_results(id) ON DELETE CASCADE,
    contribucion_pct SMALLINT DEFAULT 100
        CONSTRAINT contribucion_1_100 CHECK (contribucion_pct BETWEEN 1 AND 100),
    PRIMARY KEY (entregable_id, key_result_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_objetivos_ciclo  ON objetivos(ciclo_id);
CREATE INDEX IF NOT EXISTS idx_kr_objetivo       ON key_results(objetivo_id);
CREATE INDEX IF NOT EXISTS idx_ekr_entregable    ON entregable_key_result(entregable_id);
CREATE INDEX IF NOT EXISTS idx_ekr_kr            ON entregable_key_result(key_result_id);

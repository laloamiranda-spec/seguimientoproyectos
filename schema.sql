-- =============================================================================
--  Gestor de Entregables+ — Schema PostgreSQL (Neon)
--  Ejecutar en: Neon SQL Editor  |  psql  |  pgAdmin
--  Generado: 2026-03-17
-- =============================================================================


-- =============================================================================
--  SECCIÓN 1 — LIMPIEZA (solo en entorno dev / reset total)
--  Descomenta estas líneas si necesitas recrear todo desde cero.
-- =============================================================================

-- DROP TABLE IF EXISTS comentarios    CASCADE;
-- DROP TABLE IF EXISTS entregables    CASCADE;
-- DROP TABLE IF EXISTS key_users      CASCADE;
-- DROP TABLE IF EXISTS divisiones     CASCADE;
-- DROP TABLE IF EXISTS responsables   CASCADE;


-- =============================================================================
--  SECCIÓN 2 — CATÁLOGOS
-- =============================================================================

CREATE TABLE IF NOT EXISTS responsables (
    id                     SERIAL       PRIMARY KEY,
    nombre                 TEXT         NOT NULL,
    capacidad_horas_semana INTEGER      NOT NULL CHECK (capacidad_horas_semana > 0)
);

CREATE TABLE IF NOT EXISTS divisiones (
    id     SERIAL  PRIMARY KEY,
    nombre TEXT    NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS key_users (
    id     SERIAL  PRIMARY KEY,
    nombre TEXT    NOT NULL
);


-- =============================================================================
--  SECCIÓN 3 — TABLA PRINCIPAL: ENTREGABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS entregables (
    -- Identificación
    id                   SERIAL       PRIMARY KEY,
    folio                TEXT         NOT NULL,
    nombre               TEXT         NOT NULL,
    descripcion          TEXT,

    -- Fechas del ciclo de vida (ISO 8601: YYYY-MM-DD)
    fecha_inicio         DATE,
    fecha_fin_desarrollo DATE,
    fecha_entrega        DATE,
    fecha_publicacion    DATE,

    -- Flujo FRD
    frd_aplica           SMALLINT     NOT NULL DEFAULT 0 CHECK (frd_aplica    IN (0,1)),
    frd_url              TEXT,
    frd_firmado          SMALLINT     NOT NULL DEFAULT 0 CHECK (frd_firmado   IN (0,1)),
    frd_aceptacion       SMALLINT     NOT NULL DEFAULT 0 CHECK (frd_aceptacion IN (0,1)),

    -- Planificación
    responsable_id       INTEGER      REFERENCES responsables(id) ON DELETE SET NULL,
    horas_desarrollo     INTEGER      CHECK (horas_desarrollo IS NULL OR horas_desarrollo >= 0),
    porcentaje_avance    INTEGER      NOT NULL DEFAULT 0
                                      CHECK (porcentaje_avance BETWEEN 0 AND 100),
    necesita_devops      SMALLINT     NOT NULL DEFAULT 0 CHECK (necesita_devops IN (0,1)),

    -- Clasificación
    division_id          INTEGER      REFERENCES divisiones(id)  ON DELETE SET NULL,
    key_user_id          INTEGER      REFERENCES key_users(id)   ON DELETE SET NULL,

    -- Ciclo de vida
    estatus              TEXT         NOT NULL DEFAULT 'Borrador'
                                      CHECK (estatus IN (
                                          'Borrador','En progreso','En revisión',
                                          'Completado','Cancelado'
                                      )),

    -- Auditoría
    creado_en            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    actualizado_en       TIMESTAMPTZ
);

-- Reglas de integridad del flujo FRD
ALTER TABLE entregables
    DROP CONSTRAINT IF EXISTS chk_frd_firma;
ALTER TABLE entregables
    ADD  CONSTRAINT chk_frd_firma
    CHECK (frd_firmado = 0 OR (frd_url IS NOT NULL AND frd_url <> ''));

ALTER TABLE entregables
    DROP CONSTRAINT IF EXISTS chk_frd_aceptacion;
ALTER TABLE entregables
    ADD  CONSTRAINT chk_frd_aceptacion
    CHECK (frd_aceptacion = 0 OR frd_firmado = 1);

-- Trigger: actualiza `actualizado_en` en cada UPDATE
CREATE OR REPLACE FUNCTION fn_set_actualizado_en()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.actualizado_en := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_entregables_updated ON entregables;
CREATE TRIGGER trg_entregables_updated
    BEFORE UPDATE ON entregables
    FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();


-- =============================================================================
--  SECCIÓN 4 — COMENTARIOS
-- =============================================================================

CREATE TABLE IF NOT EXISTS comentarios (
    id             SERIAL       PRIMARY KEY,
    entregable_id  INTEGER      NOT NULL REFERENCES entregables(id) ON DELETE CASCADE,
    comentario     TEXT         NOT NULL,
    fecha          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- =============================================================================
--  SECCIÓN 5 — ÍNDICES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_entregables_folio          ON entregables (folio);
CREATE INDEX IF NOT EXISTS idx_entregables_nombre         ON entregables (nombre);
CREATE INDEX IF NOT EXISTS idx_entregables_fecha_entrega  ON entregables (fecha_entrega);
CREATE INDEX IF NOT EXISTS idx_entregables_estatus        ON entregables (estatus);
CREATE INDEX IF NOT EXISTS idx_entregables_division_id    ON entregables (division_id);
CREATE INDEX IF NOT EXISTS idx_entregables_responsable_id ON entregables (responsable_id);
CREATE INDEX IF NOT EXISTS idx_comentarios_entregable_id  ON comentarios (entregable_id);


-- =============================================================================
--  SECCIÓN 6 — DATOS SEMILLA
-- =============================================================================

INSERT INTO responsables (nombre, capacidad_horas_semana) VALUES
    ('Maria Perez',   40),
    ('Juan Ramirez',  35),
    ('Ana Gomez',     30)
ON CONFLICT DO NOTHING;

INSERT INTO divisiones (nombre) VALUES
    ('TI'), ('Finanzas'), ('Operaciones')
ON CONFLICT DO NOTHING;

INSERT INTO key_users (nombre) VALUES
    ('Karla Lopez'), ('Roberto Diaz'), ('Sofia Torres')
ON CONFLICT DO NOTHING;


-- =============================================================================
--  SECCIÓN 7 — DATOS DE EJEMPLO (comentar en producción)
-- =============================================================================

INSERT INTO entregables (
    folio, nombre, descripcion,
    fecha_inicio, fecha_fin_desarrollo, fecha_entrega, fecha_publicacion,
    frd_aplica, frd_url, frd_firmado, frd_aceptacion,
    responsable_id, horas_desarrollo, porcentaje_avance,
    necesita_devops, division_id, key_user_id, estatus
) VALUES
(
    'ENT-2024-001', 'Módulo de reportes financieros',
    'Generación de reportes PDF para el área de finanzas.',
    '2024-01-10', '2024-01-24', '2024-01-31', '2024-02-05',
    1, 'https://docs.example.com/frd-001', 1, 0,
    1, 80, 75, 0, 2, 2, 'En progreso'
),
(
    'ENT-2024-002', 'Integración API de pagos',
    'Conexión con proveedor externo de pasarela de pagos.',
    '2024-01-15', '2024-02-01', '2024-02-10', '2024-02-15',
    1, NULL, 0, 0,
    2, 60, 40, 1, 1, 1, 'En progreso'
),
(
    'ENT-2024-003', 'Dashboard de operaciones',
    'Panel de monitoreo en tiempo real para operaciones.',
    '2024-01-20', '2024-02-10', '2024-02-20', NULL,
    0, NULL, 0, 0,
    3, 48, 90, 0, 3, 3, 'En revisión'
),
(
    'ENT-2024-004', 'Migración base de datos legacy',
    'Migración de datos históricos al nuevo sistema.',
    '2024-02-01', '2024-02-15', '2024-02-28', '2024-03-05',
    1, 'https://docs.example.com/frd-004', 1, 1,
    1, 120, 100, 1, 1, 2, 'Completado'
),
(
    'ENT-2024-005', 'App móvil de aprobaciones',
    'Aplicación móvil para aprobaciones de gastos.',
    '2024-02-05', '2024-03-01', '2024-03-15', NULL,
    1, NULL, 0, 0,
    2, 200, 20, 0, 2, 3, 'Borrador'
)
ON CONFLICT DO NOTHING;

INSERT INTO comentarios (entregable_id, comentario) VALUES
    (1, 'Se completó el diseño del esquema de reportes. Pendiente revisión con el cliente.'),
    (1, 'El cliente solicitó agregar filtros por rango de fechas.'),
    (2, 'Credenciales de sandbox recibidas. Iniciando integración.'),
    (3, 'Primera versión lista para revisión del equipo de QA.')
ON CONFLICT DO NOTHING;


-- =============================================================================
--  SECCIÓN 8 — VISTAS
-- =============================================================================

CREATE OR REPLACE VIEW v_entregables_semaforo AS
SELECT
    e.id,
    e.folio,
    e.nombre,
    e.estatus,
    e.fecha_entrega,
    e.porcentaje_avance,
    r.nombre                                        AS responsable,
    d.nombre                                        AS division,
    k.nombre                                        AS key_user,
    CASE
        WHEN e.fecha_entrega < CURRENT_DATE          THEN 'rojo'
        WHEN e.porcentaje_avance < 40                THEN 'rojo'
        WHEN e.porcentaje_avance < 80                THEN 'amarillo'
        ELSE                                              'verde'
    END                                             AS semaforo,
    CASE
        WHEN e.fecha_entrega < CURRENT_DATE                          THEN 'Atrasado'
        WHEN e.porcentaje_avance >= 80                               THEN 'A tiempo'
        WHEN (e.fecha_entrega - CURRENT_DATE) <= 3                   THEN 'En riesgo'
        ELSE                                                              'A tiempo'
    END                                             AS va_a_tiempo,
    e.frd_aplica,
    e.frd_url,
    e.frd_firmado,
    e.frd_aceptacion,
    e.necesita_devops,
    e.creado_en,
    e.actualizado_en
FROM  entregables  e
LEFT  JOIN responsables r ON r.id = e.responsable_id
LEFT  JOIN divisiones   d ON d.id = e.division_id
LEFT  JOIN key_users    k ON k.id = e.key_user_id;

-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW v_frd_metricas AS
SELECT
    COUNT(*)                                                              AS total_con_frd,
    COUNT(*) FILTER (WHERE frd_url IS NULL OR frd_url = '')              AS sin_url,
    COUNT(*) FILTER (WHERE frd_url IS NOT NULL AND frd_url <> ''
                       AND frd_firmado = 0)                              AS sin_firma,
    COUNT(*) FILTER (WHERE frd_firmado = 1
                       AND porcentaje_avance >= 100
                       AND frd_aceptacion = 0)                           AS sin_aceptacion,
    COUNT(*) FILTER (WHERE frd_aceptacion = 1)                           AS completados,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE frd_aceptacion = 1)
              / NULLIF(COUNT(*), 0), 1
    )                                                                     AS pct_completado
FROM entregables
WHERE frd_aplica = 1;

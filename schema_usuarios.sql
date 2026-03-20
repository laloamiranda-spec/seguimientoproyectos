-- ============================================================
-- Módulo de usuarios — Gestor de Entregables+
-- Ejecutar en Neon SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id            SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(200) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    rol           VARCHAR(20)  DEFAULT 'usuario'
                  CHECK (rol IN ('admin', 'usuario')),
    activo        SMALLINT     DEFAULT 1,
    creado_en     TIMESTAMPTZ  DEFAULT NOW(),
    ultimo_acceso TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);

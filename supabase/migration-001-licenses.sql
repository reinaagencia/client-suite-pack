-- =============================================================================
-- Migration 001: Licenses + Installations
-- =============================================================================
-- Creado: 2026-07-13
-- 
-- Ejecutar en: Supabase SQL Editor
-- Dashboard: https://supabase.com/dashboard/project/rhaabimsiwbrpugaliah/sql/new
-- =============================================================================

-- ─── Tabla: licenses ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    client_name TEXT NOT NULL,
    active BOOLEAN DEFAULT true,
    max_installs INTEGER DEFAULT 1,
    expires_at DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    notes TEXT
);

-- ─── Tabla: installations ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS installations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_id UUID REFERENCES licenses(id) ON DELETE CASCADE,
    installed_at TIMESTAMPTZ DEFAULT now(),
    ip TEXT,
    version TEXT,
    hostname TEXT,
    os TEXT
);

-- ─── Row Level Security (service_role bypass) ───────────────────────────────
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE installations ENABLE ROW LEVEL SECURITY;

CREATE POLICY service_all_licenses ON licenses
    USING (true) WITH CHECK (true);
CREATE POLICY service_all_installations ON installations
    USING (true) WITH CHECK (true);

-- ─── Índices ─────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_licenses_key ON licenses(key);
CREATE INDEX IF NOT EXISTS idx_installations_license ON installations(license_id);

-- ═════════════════════════════════════════════════════════════════════════════
-- Datos iniciales: license key de prueba (opcional)
-- ═════════════════════════════════════════════════════════════════════════════
-- INSERT INTO licenses (key, client_name, active, expires_at)
-- VALUES ('REINA-TRIAL-2026', 'Cliente Trial', true, '2026-12-31');

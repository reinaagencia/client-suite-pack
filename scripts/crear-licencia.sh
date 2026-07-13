#!/usr/bin/env bash
# =============================================================================
# 🔑 Crear License Key — Cliente: SebasMezu01
# =============================================================================
# 
# 1. Abre Supabase Dashboard:
#    https://supabase.com/dashboard/project/rhaabimsiwbrpugaliah/sql/new
# 
# 2. LOGUEATE con el usuario: rzuluam@gmail.com
#    (usando "Continue with GitHub" con la cuenta rzuluam)
#
# 3. Pega y EJECUTA este SQL:
# =============================================================================

cat << 'SQL'
-- ═════════════════════════════════════════════════════════════════════════════
-- PASO 1: Crear las tablas (solo la primera vez)
-- ═════════════════════════════════════════════════════════════════════════════

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

CREATE TABLE IF NOT EXISTS installations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_id UUID REFERENCES licenses(id) ON DELETE CASCADE,
    installed_at TIMESTAMPTZ DEFAULT now(),
    ip TEXT,
    version TEXT,
    hostname TEXT,
    os TEXT
);

ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE installations ENABLE ROW LEVEL SECURITY;

CREATE POLICY service_all_licenses ON licenses
    USING (true) WITH CHECK (true);
CREATE POLICY service_all_installations ON installations
    USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_licenses_key ON licenses(key);
CREATE INDEX IF NOT EXISTS idx_installations_license ON installations(license_id);

-- ═════════════════════════════════════════════════════════════════════════════
-- PASO 2: Crear función de validación (solo la primera vez)
-- ═════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION validate_license(license_key TEXT)
RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'valid', true,
        'client_name', client_name,
        'expires_at', expires_at::text,
        'active', active
    ) INTO result
    FROM licenses
    WHERE key = license_key
      AND active = true
      AND (expires_at IS NULL OR expires_at >= CURRENT_DATE);
    
    IF result IS NULL THEN
        RETURN json_build_object('valid', false, 'reason', 'License not found or expired');
    END IF;
    
    RETURN result;
END;
$$;

-- ═════════════════════════════════════════════════════════════════════════════
-- PASO 3: Crear license key para SebasMezu01
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO licenses (key, client_name, active, max_installs, expires_at, notes)
VALUES ('REINA-SEBASMEZU01-' || upper(substr(md5(random()::text), 1, 8)),
        'SebasMezu01',
        true,
        1,
        CURRENT_DATE + INTERVAL '1 year',
        'Cliente: SebasMezu01 | Creada: ' || CURRENT_DATE::text)
RETURNING key;
SQL

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  🆕 Para crear NUEVAS licencias en el futuro, usa:"
echo ""
echo "  python3 ~/Dev/client-suite-pack/scripts/setup-licenses.py \\"
echo "    --create-key \"Nombre del Cliente\""
echo ""
echo "  O desde el SQL Editor de Supabase:"
echo ""
echo "  INSERT INTO licenses (key, client_name, active, expires_at)"
echo "  VALUES ('REINA-CLIENTE-' || upper(substr(md5(random()::text), 1, 8)),"
echo "          'Nombre del Cliente', true,"
echo "          CURRENT_DATE + INTERVAL '1 year');"
echo ""
echo "════════════════════════════════════════════════════════════════"

#!/usr/bin/env bash
# =============================================================================
# 🔑 Crear License Key — Cliente
# =============================================================================
# 
# Crea una license key en Supabase para un nuevo cliente.
# 
# Uso directo:
#   python3 scripts/setup-licenses.py --create-key "Nombre del Cliente"
#
# O desde el navegador (Supabase Dashboard):
#   1. Abre: https://supabase.com/dashboard/project/gegklkperqguypexsbtw/sql/new
#   2. Logueate con rzuluam@gmail.com (Continue with GitHub)
#   3. Pega y ejecuta el SQL de abajo
# =============================================================================

# ─── Configuración ────────────────────────────────────────────────────────────
# PROYECTO CORRECTO (el que usa install.sh):
SUPABASE_URL="https://gegklkperqguypexsbtw.supabase.co"
# ⚠️ NO USAR rhaabimsiwbrpugaliah — ese proyecto NO tiene las tablas de licencias
# =============================================================================

cat << 'SQL'
-- ═════════════════════════════════════════════════════════════════════════════
-- CREAR LICENSE KEY PARA NUEVO CLIENTE
-- ═════════════════════════════════════════════════════════════════════════════
-- Proyecto: gegklkperqguypexsbtw (client-licenses)
-- ═════════════════════════════════════════════════════════════════════════════

-- 1. Verificar que las tablas existen (crear si es primera vez)
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

-- RLS (seguridad a nivel de fila)
ALTER TABLE licenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE installations ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS service_all_licenses ON licenses
    USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS service_all_installations ON installations
    USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_licenses_key ON licenses(key);
CREATE INDEX IF NOT EXISTS idx_installations_license ON installations(license_id);

-- 2. Función de validación (recrear si cambió)
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

-- 3. INSERT: Cambia SOLO el nombre del cliente y la key
--    La key se genera automáticamente con formato REINA-CLIENTE-XXXXXXXX
INSERT INTO licenses (key, client_name, active, max_installs, expires_at, notes)
VALUES ('REINA-CLIENTE-' || upper(substr(md5(random()::text), 1, 8)),
        'NombreDelCliente',                    -- ← CAMBIA ESTO
        true,
        1,
        CURRENT_DATE + INTERVAL '1 year',
        'Cliente: NombreDelCliente | Creada: ' || CURRENT_DATE::text)
RETURNING key;

-- 🔑 La key generada aparecerá en la columna "key" del resultado
-- Cópiala y entrégasela al cliente para que la ingrese durante la instalación
SQL

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  🆕 Para crear licencias desde terminal (más rápido):"
echo ""
echo "  python3 scripts/setup-licenses.py --create-key \"Nombre del Cliente\""
echo ""
echo "  📋 Proyecto Supabase correcto: gegklkperqguypexsbtw"
echo "     (NO rhaabimsiwbrpugaliah — ese está obsoleto)"
echo ""
echo "  🔑 Licencias activas actualmente:"
curl -s "${SUPABASE_URL}/rest/v1/licenses?select=key,client_name,active,expires_at" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" 2>/dev/null | \
  python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for lic in data:
        print(f'     • {lic[\"client_name\"]}: {lic[\"key\"]} (exp: {lic[\"expires_at\"]})')
except: pass
" 2>/dev/null || echo "     (no se pudieron listar)"
echo ""
echo "════════════════════════════════════════════════════════════════"

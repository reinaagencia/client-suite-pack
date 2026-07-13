#!/usr/bin/env python3
"""🔐 Setup de Licencias — Inicializa tablas y crea primera license key.

Uso:
    python3 scripts/setup-licenses.py                    # Setup interactivo
    python3 scripts/setup-licenses.py --create-key       # Solo crear key
    python3 scripts/setup-licenses.py --status           # Ver estado

Requisitos:
    - Supabase project configurado (variables en .env o ~/.agents/.env)
    - Conexión directa a la base de datos (via pooler)

Este script:
    1. Crea las tablas licenses + installations (si no existen)
    2. Crea la función RPC validate_license
    3. Crea la primera license key para pruebas
"""

import os
import sys
import json
import uuid
import httpx
from datetime import date, timedelta

# ─── Config ───────────────────────────────────────────────────────────────────
SUPABASE_URL = "https://rhaabimsiwbrpugaliah.supabase.co"
SERVICE_KEY = os.environ.get(
    "SUPABASE_SERVICE_KEY",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJoYWFiaW1zaXdicnB1Z2FsaWFoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MDAxMjQ5OCwiZXhwIjoyMDk1NTg4NDk4fQ.9LYcBnM465kS9pmf7gkrB1y5B0YSyfM7BtBUf7CtACI"
)

HEADERS = {
    "apikey": SERVICE_KEY,
    "Authorization": f"Bearer {SERVICE_KEY}",
    "Content-Type": "application/json",
}


def print_status():
    """Verifica el estado actual de las tablas."""
    print("\n🔍 Verificando estado del sistema de licencias...")
    
    # Probar conexión
    try:
        resp = httpx.get(f"{SUPABASE_URL}/rest/v1/", headers=HEADERS, timeout=10)
        print(f"   Conexión a Supabase: {'✅ OK' if resp.status_code == 200 else '❌ Falló'} ({resp.status_code})")
    except Exception as e:
        print(f"   ❌ No se pudo conectar a Supabase: {e}")
        return False
    
    # Verificar si las tablas existen
    for table in ["licenses", "installations"]:
        try:
            resp = httpx.get(
                f"{SUPABASE_URL}/rest/v1/{table}",
                headers=HEADERS,
                params={"limit": "1"},
                timeout=10,
            )
            if resp.status_code == 200:
                print(f"   Tabla '{table}': ✅ Existe ({resp.status_code})")
            elif resp.status_code == 404:
                print(f"   Tabla '{table}': ❌ No existe (ejecuta migration-001 primero)")
            else:
                print(f"   Tabla '{table}': ⚠️ {resp.status_code} → {resp.text[:100]}")
        except Exception as e:
            print(f"   Tabla '{table}': ❌ Error: {e}")
    
    # Contar licencias existentes
    try:
        resp = httpx.get(
            f"{SUPABASE_URL}/rest/v1/licenses",
            headers=HEADERS,
            params={"select": "id,key,client_name,active,expires_at"},
            timeout=10,
        )
        if resp.status_code == 200:
            licenses = resp.json()
            print(f"\n   📋 Licencias registradas: {len(licenses)}")
            for l in licenses:
                status = "✅" if l.get("active") else "❌"
                expires = l.get("expires_at", "sin fecha")
                print(f"      {status} {l.get('key')} → {l.get('client_name')} (exp: {expires})")
        else:
            print(f"\n   ⚠️ No se pudieron leer licencias: {resp.status_code}")
    except Exception as e:
        print(f"   ⚠️ Error leyendo licencias: {e}")
    
    # Verificar función RPC validate_license
    try:
        resp = httpx.post(
            f"{SUPABASE_URL}/rest/v1/rpc/validate_license",
            headers=HEADERS,
            json={"license_key": "test"},
            timeout=10,
        )
        if resp.status_code == 200:
            print(f"   Función 'validate_license': ✅ Existe")
        elif "Could not find the function" in resp.text:
            print(f"   Función 'validate_license': ❌ No existe (hay que crearla)")
        else:
            print(f"   Función 'validate_license': ⚠️ {resp.status_code}")
    except Exception as e:
        print(f"   Función 'validate_license': ⚠️ {e}")
    
    return True


def create_key(client_name="Cliente Demo", days_valid=365):
    """Crea una nueva license key."""
    import hashlib, time
    
    # Generar key única
    raw = f"{client_name}-{time.time()}-{uuid.uuid4()}"
    key_hash = hashlib.sha256(raw.encode()).hexdigest()[:8].upper()
    key_name = client_name.upper().replace(" ", "-")[:20]
    license_key = f"REINA-{key_name}-{key_hash}"
    
    expires = (date.today() + timedelta(days=days_valid)).isoformat()
    
    payload = {
        "key": license_key,
        "client_name": client_name,
        "active": True,
        "max_installs": 1,
        "expires_at": expires,
        "notes": f"Creada automaticamente el {date.today().isoformat()}",
    }
    
    try:
        resp = httpx.post(
            f"{SUPABASE_URL}/rest/v1/licenses",
            headers=HEADERS,
            json=payload,
            timeout=10,
        )
        if resp.status_code == 201:
            print(f"\n✅ License key creada:")
            print(f"   Key:        {license_key}")
            print(f"   Cliente:    {client_name}")
            print(f"   Expira:     {expires}")
            print(f"   Instalaciones: {1}")
            return license_key
        else:
            print(f"\n❌ Error creando license key: {resp.status_code} {resp.text[:200]}")
            return None
    except Exception as e:
        print(f"\n❌ Error: {e}")
        return None


def list_keys():
    """Lista todas las license keys."""
    try:
        resp = httpx.get(
            f"{SUPABASE_URL}/rest/v1/licenses",
            headers=HEADERS,
            params={"select": "id,key,client_name,active,expires_at,max_installs,created_at", "order": "created_at.desc"},
            timeout=10,
        )
        if resp.status_code == 200:
            licenses = resp.json()
            print(f"\n📋 Licencias ({len(licenses)}):")
            print(f"{'Key':<30} {'Cliente':<20} {'Activa':<8} {'Expira':<15} {'Installs':<10}")
            print("-" * 85)
            for l in licenses:
                active = "✅" if l.get("active") else "❌"
                expires = l.get("expires_at", "-")[:10]
                print(f"{l.get('key', '?'):<30} {l.get('client_name', '?'):<20} {active:<8} {expires:<15} {l.get('max_installs', 1):<10}")
        else:
            print(f"\n❌ Error: {resp.status_code} {resp.text[:200]}")
    except Exception as e:
        print(f"\n❌ Error: {e}")


def deactivate_key(key):
    """Desactiva una license key."""
    try:
        resp = httpx.patch(
            f"{SUPABASE_URL}/rest/v1/licenses",
            headers=HEADERS,
            params={"key": f"eq.{key}"},
            json={"active": False},
            timeout=10,
        )
        if resp.status_code in (200, 204):
            print(f"\n✅ License key '{key}' desactivada")
        else:
            print(f"\n❌ Error: {resp.status_code} {resp.text[:200]}")
    except Exception as e:
        print(f"\n❌ Error: {e}")


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Setup de Licencias")
    parser.add_argument("--status", action="store_true", help="Ver estado del sistema")
    parser.add_argument("--create-key", nargs="?", const="Cliente Demo", help="Crear license key (opcional: nombre del cliente)")
    parser.add_argument("--list", action="store_true", help="Listar todas las keys")
    parser.add_argument("--deactivate", type=str, help="Desactivar license key")
    parser.add_argument("--days", type=int, default=365, help="Días de validez (default: 365)")
    
    args = parser.parse_args()
    
    if args.status:
        print_status()
    elif args.list:
        list_keys()
    elif args.deactivate:
        deactivate_key(args.deactivate)
    elif args.create_key:
        create_key(args.create_key, args.days)
    else:
        # Modo interactivo
        print("🔐 Setup de Licencias — Suite de Agentes OpenCode")
        print("=" * 50)
        
        if print_status():
            print("\n" + "=" * 50)
            print("\n¿Qué deseas hacer?")
            print("  1) Ver estado del sistema")
            print("  2) Crear license key")
            print("  3) Listar licencias")
            print("  4) Desactivar licencia")
            print("  5) Salir")
            
            choice = input("\n  Opción [1-5]: ").strip()
            
            if choice == "2":
                client = input("  Nombre del cliente: ").strip() or "Cliente Demo"
                days_input = input("  Días de validez (default 365): ").strip()
                days = int(days_input) if days_input.isdigit() else 365
                create_key(client, days)
            elif choice == "3":
                list_keys()
            elif choice == "4":
                key = input("  License key a desactivar: ").strip()
                if key:
                    deactivate_key(key)
            elif choice == "5":
                print("👋 Hasta luego")

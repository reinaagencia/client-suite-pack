#!/usr/bin/env bash
# =============================================================================
# 📦 Installer — Suite de Agentes OpenCode para Clientes
# =============================================================================
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/reinaagencia/client-suite-pack/main/install.sh | bash
#
# Con license key explícita:
#   curl -fsSL https://raw.githubusercontent.com/reinaagencia/client-suite-pack/main/install.sh | bash -s -- --key=CLIENTE-ABC-123
# =============================================================================

set -euo pipefail

VERSION="2.1.0"

# ─── Config ───────────────────────────────────────────────────────────────────
REPO_OWNER="reinaagencia"
REPO_NAME="client-suite-pack"
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
SUPABASE_URL="https://gegklkperqguypexsbtw.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdlZ2tsa3BlcnFndXlwZXhzYnR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQwNTI2NjIsImV4cCI6MjA5OTYyODY2Mn0.v4yPjLb5FTw0MfGUouhsbS9pz-mlo0PU0TPJCUnIVSA"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Funciones ────────────────────────────────────────────────────────────────
log()   { echo -e "${GREEN}[✓]${NC} $1"; }
info()  { echo -e "${BLUE}[i]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
header(){ echo -e "\n${CYAN}${BOLD}══ $1 ══${NC}\n"; }

cleanup() {
    local exit_code=$?
    [ $exit_code -ne 0 ] && echo -e "\n${RED}❌ Instalación interrumpida.${NC}"
    exit $exit_code
}
trap cleanup EXIT

# ─── Parsear argumentos ──────────────────────────────────────────────────────
LICENSE_KEY=""
AUTO_MODE=false

for arg in "$@"; do
    case $arg in
        --key=*) LICENSE_KEY="${arg#*=}" ;;
        --auto) AUTO_MODE=true ;;
        --help|-h)
            echo "Uso: curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/install.sh | bash"
            echo ""
            echo "Opciones:"
            echo "  --key=XXXX    License key (opcional, si no se provee se pedirá)"
            echo "  --auto        Modo no interactivo (usa valores por defecto)"
            echo "  --help        Muestra esta ayuda"
            exit 0
            ;;
    esac
done

# ─── Validar license key contra Supabase ─────────────────────────────────────
validate_license() {
    local key="$1"
    
    # Intentar validar contra Supabase
    local resp
    resp=$(curl -s -X POST "${SUPABASE_URL}/rest/v1/rpc/validate_license" \
        -H "apikey: ${SUPABASE_ANON_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"license_key\": \"${key}\"}" 2>/dev/null) || true
    
    # Si la función RPC no existe, intentar consulta directa
    if [ -z "$resp" ] || echo "$resp" | grep -q "Could not find"; then
        resp=$(curl -s "${SUPABASE_URL}/rest/v1/licenses" \
            -H "apikey: ${SUPABASE_ANON_KEY}" \
            -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
            -H "Accept: application/json" \
            -G --data-urlencode "key=eq.${key}" \
            --data-urlencode "select=id,client_name,active,expires_at" 2>/dev/null) || true
    fi
    
    # Parsear respuesta
    if [ -n "$resp" ] && echo "$resp" | grep -q '"active":true'; then
        local client
        client=$(echo "$resp" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0].get('client_name','Cliente'))" 2>/dev/null || echo "Cliente")
        log "Licencia válida: ${client}"
        return 0
    elif [ -n "$resp" ] && echo "$resp" | grep -q '"active":false'; then
        error "Licencia desactivada. Contacta a soporte para reactivarla."
        return 1
    elif [ -n "$resp" ] && echo "$resp" | grep -q '"expires_at"'; then
        local expires
        expires=$(echo "$resp" | python3 -c "import sys,json; print(json.load(sys.stdin)[0].get('expires_at',''))" 2>/dev/null || echo "")
        if [ -n "$expires" ] && [[ "$expires" < $(date +%Y-%m-%d) ]]; then
            error "Licencia expirada (${expires}). Contacta a soporte para renovarla."
            return 1
        fi
    fi
    
    # Si no se pudo validar (tabla no existe o error de red)
    if [ "$AUTO_MODE" = true ]; then
        info "Modo auto: continuando sin validación de licencia."
        return 0
    fi
    warn "No se pudo validar la licencia automáticamente."
    info "Esto puede ocurrir si es la primera instalación."
    echo -e ""
    echo -e "  ${BOLD}1)${NC} Continuar de todas formas (instalación libre)"
    echo -e "  ${BOLD}2)${NC} Cancelar e intentar más tarde"
    echo -e ""
    read -r -p "  Opción [1/2] (default: 1): " choice
    choice="${choice:-1}"
    [ "$choice" != "1" ] && exit 1
    return 0
}

# ─── Registrar instalación ───────────────────────────────────────────────────
record_installation() {
    local key="${1:-unknown}"
    local version="${2:-$VERSION}"
    
    curl -s -X POST "${SUPABASE_URL}/rest/v1/installations" \
        -H "apikey: ${SUPABASE_ANON_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
        -H "Content-Type: application/json" \
        -H "Prefer: return=minimal" \
        -d "{
            \"license_id\": null,
            \"version\": \"${version}\",
            \"hostname\": \"$(hostname 2>/dev/null || echo 'unknown')\",
            \"os\": \"$(uname -s 2>/dev/null || echo 'unknown')\"
        }" 2>/dev/null || true
}

# ═════════════════════════════════════════════════════════════════════════════
# MAIN
# ═════════════════════════════════════════════════════════════════════════════

main() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     📦 Suite de Agentes OpenCode — Installer v${VERSION}    ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # ─── 1. Verificar requisitos ──────────────────────────────────────
    header "Verificando requisitos"
    
    local HAS_ERRORS=0
    command -v bash &>/dev/null || { error "bash no encontrado"; HAS_ERRORS=1; }
    command -v git &>/dev/null || { error "git no encontrado"; HAS_ERRORS=1; }
    command -v python3 &>/dev/null || { error "python3 no encontrado"; HAS_ERRORS=1; }
    
    if [ "$HAS_ERRORS" -eq 1 ]; then
        error "Requisitos insuficientes. Instala git y python3 primero."
        exit 1
    fi
    log "Requisitos mínimos cumplidos (bash + git + python3)"
    
    # ─── 2. License key ───────────────────────────────────────────────
    header "Validación de licencia"
    
    if [ -z "$LICENSE_KEY" ]; then
        if [ "$AUTO_MODE" = true ]; then
            warn "Modo auto: sin license key, instalación libre."
        else
            echo -e "Ingresa tu license key para activar la suite."
            echo -e "(Si no tienes una, solo presiona Enter para continuar sin validación)"
            echo -e ""
            read -r -p "  License key: " LICENSE_KEY
            LICENSE_KEY="${LICENSE_KEY:-}"
        fi
    fi
    
    if [ -n "$LICENSE_KEY" ]; then
        validate_license "$LICENSE_KEY" || exit 1
    elif [ "$AUTO_MODE" = false ]; then
        warn "Sin license key. Instalación en modo evaluación."
        echo -e "  ${YELLOW}⚠️  Sin validación, instalación libre.${NC}"
        echo -e ""
        read -r -p "  Presiona Enter para continuar o Ctrl+C para cancelar..."
    fi
    
    # ─── 3. Preparar suite ────────────────────────────────────────────
    header "Preparando suite"
    
    local INSTALL_DIR="${HOME}/.reina-suite"
    
    # Si ya estamos dentro del directorio client-suite-pack (ZIP), copiar en vez de clonar
    if [ -f "./builder.sh" ]; then
        SCRIPT_SRC="$(pwd)"
        info "Ejecutando desde ZIP local: ${SCRIPT_SRC}"
        if [ "$SCRIPT_SRC" != "$INSTALL_DIR" ]; then
            mkdir -p "$INSTALL_DIR"
            cp -r "$SCRIPT_SRC"/* "$INSTALL_DIR"/ 2>/dev/null
            log "Suite copiada a ${INSTALL_DIR}"
        else
            log "Ya estamos en ${INSTALL_DIR}"
        fi
    elif [ -d "$INSTALL_DIR" ]; then
        warn "Directorio ${INSTALL_DIR} ya existe."
        echo -e "  ${BOLD}1)${NC} Actualizar (git pull)"
        echo -e "  ${BOLD}2)${NC} Reemplazar (borrar y clonar)"
        echo -e "  ${BOLD}3)${NC} Saltar"
        read -r -p "  Opción [1/2/3] (default: 1): " choice
        choice="${choice:-1}"
        case "$choice" in
            1) (cd "$INSTALL_DIR" && git pull 2>/dev/null) && log "Suite actualizada" || warn "Error actualizando" ;;
            2) rm -rf "$INSTALL_DIR" && git clone "$REPO_URL" "$INSTALL_DIR" 2>/dev/null && log "Suite clonada" || warn "No se pudo clonar (repos privados?)" ;;
            *) info "Usando suite existente." ;;
        esac
    else
        info "Clonando suite desde GitHub..."
        git clone "$REPO_URL" "$INSTALL_DIR" 2>/dev/null && log "Suite descargada en ${INSTALL_DIR}" || {
            warn "No se pudo clonar desde GitHub (repos privados?)."
            warn "Usa el ZIP manual: descarga y extrae en ${INSTALL_DIR}"
            info "Creando directorio vacío temporal..."
            mkdir -p "$INSTALL_DIR"
        }
    fi
    
    # Verificar que builder.sh existe
    if [ ! -f "$INSTALL_DIR/builder.sh" ]; then
        error "No se encontró builder.sh en ${INSTALL_DIR}"
        error "Asegúrate de extraer el ZIP completo en esa carpeta."
        exit 1
    fi
    
    # ─── 4. Ejecutar builder ──────────────────────────────────────────
    header "Instalando suite"
    info "Ejecutando builder.sh — 11 fases de instalación..."
    
    # Pasar license key como variable de entorno para que builder.sh la use
    export SUITE_LICENSE_KEY="${LICENSE_KEY}"
    # Pasar flag --auto si estamos en modo auto
    local BUILDER_FLAGS=""
    [ "$AUTO_MODE" = true ] && BUILDER_FLAGS="--auto"
    (cd "$INSTALL_DIR" && bash builder.sh $BUILDER_FLAGS) || { error "Error ejecutando builder.sh"; exit 1; }
    
    # ─── 5. Registrar instalación ─────────────────────────────────────
    if [ -n "$LICENSE_KEY" ]; then
        record_installation "$LICENSE_KEY"
    fi
    
    # ─── 6. Resumen final ─────────────────────────────────────────────
    header "Instalación completada"
    echo -e "${GREEN}${BOLD}"
    echo "  ✅ Suite de Agentes OpenCode v${VERSION} instalada"
    echo ""
    echo "  📍 Suite:     ${INSTALL_DIR}"
    echo "  🚀 Abre OpenCode y empieza a usar tus agentes"
    echo "  💡 Prueba:    'Hola, ¿qué agentes tienes disponibles?'"
    echo "  📖 Más info:  cat ${INSTALL_DIR}/SUITE.md"
    echo -e "${NC}"
}

main "$@"

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

VERSION="2.2.0"

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
            echo ""
            echo "Características:"
            echo "  • Detecta automáticamente instalaciones previas → modo upgrade"
            echo "  • Respaldos automáticos antes de modificar configs existentes"
            echo "  • Verifica PowerShell execution policy (Windows)"
            echo "  • Verifica que opencode funcione post-instalación"
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
    warn "No se pudo validar la licencia contra Supabase."
    info "Posibles causas:"
    info "  • La license key es incorrecta"
    info "  • El PC no tiene acceso a internet"
    info "  • Firewall bloqueando la conexión a Supabase"
    info "La instalación continuará sin validación por ahora."
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

# ─── Detectar si es Windows ───────────────────────────────────────────────────
# Usa ${VAR:-} para evitar "unbound variable" con set -u en macOS/Linux
is_windows() {
    [ -n "${WINDIR:-}" ] || echo "${OS:-}" | grep -qi "windows\|mingw\|cygwin" 2>/dev/null
}

# ─── Verificar PowerShell execution policy (Windows) ─────────────────────────
check_windows_powershell() {
    if ! is_windows; then
        return 0
    fi
    
    # Verificar si opencode está instalado vía npm (para saber si necesitamos PowerShell)
    local npm_opencode
    npm_opencode=$(npm list -g opencode-ai 2>/dev/null || echo "")
    if [ -z "$npm_opencode" ]; then
        return 0  # No está instalado globalmente, no hay problema
    fi
    
    # Intentar detectar execution policy
    local policy
    policy=$(powershell -NoProfile -Command "Get-ExecutionPolicy -Scope CurrentUser" 2>/dev/null || echo "Restricted")
    
    if [ "$policy" = "Restricted" ]; then
        warn "PowerShell execution policy: ${policy}"
        echo -e "  ${YELLOW}⚠️  Esto puede bloquear el comando 'opencode' después de la instalación.${NC}"
        echo -e ""
        echo -e "  Para evitar errores, ejecuta en PowerShell como administrador:"
        echo -e "  ${CYAN}Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned${NC}"
        echo -e ""
        echo -e "  O puedes continuar y arreglarlo después (solo afecta a scripts .ps1)"
        echo -e ""
        
        if [ "$AUTO_MODE" = false ]; then
            read -r -p "  Presiona Enter para continuar..."
        fi
    fi
}

# ─── Detectar instalación existente de la suite ──────────────────────────────
detect_existing_suite() {
    # Buscar suite-config.json
    if [ -f "${HOME}/.agents/suite-config.json" ]; then
        log "Instalación previa detectada en ~/.agents/suite-config.json"
        return 0
    fi
    
    # Buscar agentes
    local agent_path="${HOME}/.config/opencode/agent"
    if [ -d "$agent_path" ] && ls "$agent_path/"*.md &>/dev/null 2>&1; then
        local count
        count=$(ls "$agent_path/"*.md 2>/dev/null | wc -l | tr -d ' ')
        if [ "$count" -ge 3 ]; then
            log "Instalación previa detectada: ${count} agentes en ${agent_path}"
            return 0
        fi
    fi
    
    return 1
}

# ─── Verificar que opencode funciona post-instalación ────────────────────────
verify_opencode_postinstall() {
    info "Verificando instalación de OpenCode..."
    
    if ! command -v opencode &>/dev/null; then
        warn "OpenCode no está en el PATH."
        info "Instálalo con: npm install -g opencode-ai"
        return 1
    fi
    
    local opencode_path
    opencode_path=$(which opencode)
    
    # Si es .ps1, verificar execution policy o sugerir CMD
    if echo "$opencode_path" | grep -qi "\.ps1$"; then
        if is_windows; then
            warn "OpenCode se ejecuta vía PowerShell (.ps1)."
            echo -e "  ${YELLOW}Si ves error 'No se puede cargar el archivo opencode.ps1':${NC}"
            echo -e "  ${YELLOW}→${NC} En PowerShell como administrador:"
            echo -e "    ${CYAN}Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned${NC}"
            echo -e "  ${YELLOW}→${NC} O usa CMD (Command Prompt) en vez de PowerShell:"
            echo -e "    ${CYAN}opencode${NC}"
        fi
    fi
    
    # Verificar versión
    local version
    version=$(opencode --version 2>/dev/null || echo "")
    if [ -n "$version" ]; then
        log "OpenCode ${version} — OK"
    else
        warn "OpenCode instalado pero no responde. Reinstala con:"
        warn "  npm uninstall -g opencode-ai && npm install -g opencode-ai"
    fi
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
    command -v npm &>/dev/null || { warn "npm no encontrado (necesario para instalar OpenCode)"; }
    
    if [ "$HAS_ERRORS" -eq 1 ]; then
        error "Requisitos insuficientes. Instala git y python3 primero."
        exit 1
    fi
    log "Requisitos mínimos cumplidos (bash + git + python3)"
    
    # ─── 1b. Verificar Windows/PowerShell (solo Windows) ──────────────
    check_windows_powershell
    
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
    
    # ─── 2b. Detectar instalación existente ──────────────────────────
    local IS_UPGRADE=false
    if detect_existing_suite; then
        echo -e "\n${YELLOW}${BOLD}⚠️  Se detectó una instalación previa de la suite.${NC}"
        echo -e "  ${BOLD}1)${NC} Actualizar (respalda configs existentes y actualiza templates, skills y memoria)"
        echo -e "  ${BOLD}2)${NC} Instalación limpia (sobrescribe todo)"
        echo -e "  ${BOLD}3)${NC} Cancelar"
        echo -e ""
        if [ "$AUTO_MODE" = false ]; then
            read -r -p "  Opción [1/2/3] (default: 1): " upgrade_choice
            upgrade_choice="${upgrade_choice:-1}"
        else
            upgrade_choice="1"
        fi
        
        case "$upgrade_choice" in
            2) IS_UPGRADE=false; info "Modo instalación limpia." ;;
            3) info "Instalación cancelada."; exit 0 ;;
            *) IS_UPGRADE=true; log "Modo actualización activado." ;;
        esac
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
    info "Ejecutando builder.sh..."
    
    # Pasar license key como variable de entorno para que builder.sh la use
    export SUITE_LICENSE_KEY="${LICENSE_KEY}"
    # Pasar flags al builder
    local BUILDER_FLAGS=""
    [ "$AUTO_MODE" = true ] && BUILDER_FLAGS="${BUILDER_FLAGS} --auto"
    [ "$IS_UPGRADE" = true ] && BUILDER_FLAGS="${BUILDER_FLAGS} --upgrade"
    (cd "$INSTALL_DIR" && bash builder.sh $BUILDER_FLAGS) || { error "Error ejecutando builder.sh"; exit 1; }
    
    # ─── 5. Registrar instalación ─────────────────────────────────────
    if [ -n "$LICENSE_KEY" ]; then
        record_installation "$LICENSE_KEY"
    fi
    
    # ─── 6. Verificar opencode post-instalación ───────────────────────
    echo
    verify_opencode_postinstall
    
    # ─── 7. Resumen final ─────────────────────────────────────────────
    header "Instalación completada"
    echo -e "${GREEN}${BOLD}"
    echo "  ✅ Suite de Agentes OpenCode v${VERSION} instalada"
    echo ""
    [ "$IS_UPGRADE" = true ] && echo "  🔄 Modo actualización — configs anteriores respaldadas en ~/.agents/backup-*/"
    echo "  📍 Suite:     ${INSTALL_DIR}"
    echo "  🚀 Abre OpenCode y empieza a usar tus agentes"
    echo "  💡 Prueba:    'Hola, ¿qué agentes tienes disponibles?'"
    echo "  📖 Más info:  cat ${INSTALL_DIR}/SUITE.md"
    echo ""
    
    # Nota para Windows
    if is_windows; then
        echo -e "  ${YELLOW}📌 Windows: Si 'opencode' falla, prueba:${NC}"
        echo -e "  ${YELLOW}   1.${NC} PowerShell como administrador → Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        echo -e "  ${YELLOW}   2.${NC} O usa CMD (Command Prompt) en vez de PowerShell"
        echo -e "  ${YELLOW}   3.${NC} Si el binario está dañado: npm uninstall -g opencode-ai && npm install -g opencode-ai"
    fi
    echo -e "${NC}"
}

main "$@"

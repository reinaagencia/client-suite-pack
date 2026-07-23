#!/usr/bin/env bash
# =============================================================================
# 🚀 Instalador — Pack Lanzador (Agente de Lanzamientos Digitales)
# =============================================================================
# Añade el agente "Lanzador" y su skill de lanzamientos digitales
# a una instalación existente de la Suite de Agentes OpenCode.
#
# Uso:
#   bash scripts/install-lanzador.sh              # Interactivo
#   bash scripts/install-lanzador.sh --auto        # Automático (valores por defecto)
#   bash scripts/install-lanzador.sh --help        # Ayuda
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION="1.0.0"

# ─── Colores ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $1"; }
info()  { echo -e "${BLUE}[i]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
header(){ echo -e "\n${CYAN}${BOLD}══ $1 ══${NC}\n"; }

# ─── Config ───────────────────────────────────────────────────────────────────
AUTO_MODE=false

# ─── Parsear flags ────────────────────────────────────────────────────────────
for arg in "$@"; do
    case $arg in
        --auto) AUTO_MODE=true ;;
        --help|-h)
            echo "Uso: bash scripts/install-lanzador.sh [--auto]"
            echo ""
            echo "Añade el agente Lanzador + skill de lanzamientos digitales a una suite existente."
            echo ""
            echo "Opciones:"
            echo "  --auto       Modo no interactivo (usa valores por defecto)"
            echo "  --help       Muestra esta ayuda"
            exit 0
            ;;
    esac
done

# ─── Detectar configuración existente ─────────────────────────────────────────
detect_config() {
    local config_path="${HOME}/.agents/suite-config.json"
    local opencode_config="${HOME}/.config/opencode"
    
    # Intentar leer de suite-config.json
    if [ -f "$config_path" ]; then
        local cfg
        cfg=$(cat "$config_path")
        
        AGENTS_HOME=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('agents_home',''))" 2>/dev/null || echo "${HOME}/.agents")
        OPENCODE_CONFIG_PATH=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('opencode_config_path',''))" 2>/dev/null || echo "${opencode_config}")
        CLIENT_NAME=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('client_name','Cliente'))" 2>/dev/null || echo "Cliente")
        DEFAULT_MODEL=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('models',{}).get('default','opencode-go/deepseek-v4-flash'))" 2>/dev/null || echo "opencode-go/deepseek-v4-flash")
        
        log "Configuración cargada de suite-config.json"
        return 0
    fi
    
    # Fallback: valores por defecto
    AGENTS_HOME="${HOME}/.agents"
    OPENCODE_CONFIG_PATH="${opencode_config}"
    CLIENT_NAME="Cliente"
    DEFAULT_MODEL="opencode-go/deepseek-v4-flash"
    
    warn "No se encontró suite-config.json. Usando valores por defecto."
    return 1
}

# ─── Instalar agente Lanzador ─────────────────────────────────────────────────
install_lanzador_agent() {
    header "Instalando agente Lanzador"
    
    local agent_src="${SUITE_DIR}/template/agents/lanzador.md"
    local agent_dest="${OPENCODE_CONFIG_PATH}/agent/lanzador.md"
    
    if [ ! -f "$agent_src" ]; then
        error "No se encontró template: ${agent_src}"
        return 1
    fi
    
    # Copiar template
    cp "$agent_src" "$agent_dest"
    
    # Reemplazar placeholders
    sed -i '' "s|{{DEFAULT_MODEL}}|${DEFAULT_MODEL}|g" "$agent_dest" 2>/dev/null || \
    sed -i "s|{{DEFAULT_MODEL}}|${DEFAULT_MODEL}|g" "$agent_dest"
    
    sed -i '' "s|{{CLIENT_NAME}}|${CLIENT_NAME}|g" "$agent_dest" 2>/dev/null || \
    sed -i "s|{{CLIENT_NAME}}|${CLIENT_NAME}|g" "$agent_dest"
    
    log "Agente instalado: ${agent_dest}"
}

# ─── Instalar skill de lanzamientos digitales ─────────────────────────────────
install_lanzador_skill() {
    header "Instalando skill de Lanzamientos Digitales"
    
    local skill_src="${SUITE_DIR}/skills/domain/lanzamientos-digitales"
    local skill_dest="${AGENTS_HOME}/skills/domain/lanzamientos-digitales"
    
    if [ ! -d "$skill_src" ]; then
        error "No se encontró skill: ${skill_src}"
        return 1
    fi
    
    mkdir -p "$skill_dest"
    cp -r "$skill_src"/* "$skill_dest/" 2>/dev/null
    
    log "Skill instalada: ${skill_dest}/SKILL.md"
}

# ─── Verificar instalación ────────────────────────────────────────────────────
verify_installation() {
    header "Verificando instalación"
    
    local errors=0
    
    # Verificar agente
    if [ -f "${OPENCODE_CONFIG_PATH}/agent/lanzador.md" ]; then
        if grep -q "{{" "${OPENCODE_CONFIG_PATH}/agent/lanzador.md" 2>/dev/null; then
            warn "lanzador.md contiene placeholders sin reemplazar"
            errors=1
        else
            log "lanzador.md — OK"
        fi
    else
        error "lanzador.md no encontrado"
        errors=1
    fi
    
    # Verificar skill
    if [ -f "${AGENTS_HOME}/skills/domain/lanzamientos-digitales/SKILL.md" ]; then
        log "skill lanzamientos-digitales — OK ($(wc -l < "${AGENTS_HOME}/skills/domain/lanzamientos-digitales/SKILL.md") líneas)"
    else
        error "skill lanzamientos-digitales no encontrada"
        errors=1
    fi
    
    echo
    if [ "$errors" -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✅ Pack Lanzador instalado correctamente${NC}"
    else
        echo -e "${YELLOW}${BOLD}⚠️  Instalación con errores — revisa los mensajes arriba${NC}"
    fi
}

# ─── Mostrar resumen ──────────────────────────────────────────────────────────
show_summary() {
    echo
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║   🚀 Pack Lanzador v${VERSION} instalado           ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -e "  🤖  ${BOLD}Agente:${NC}        lanzador → ${OPENCODE_CONFIG_PATH}/agent/lanzador.md"
    echo -e "  📚  ${BOLD}Skill:${NC}         lanzamientos-digitales → ${AGENTS_HOME}/skills/domain/lanzamientos-digitales/"
    echo -e "  🧠  ${BOLD}Modelo:${NC}        ${DEFAULT_MODEL}"
    echo -e ""
    echo -e "  ${CYAN}💡 Prueba el agente:${NC}"
    echo -e "     'Diseña un lanzamiento para mi curso de [tema]'"
    echo -e "     'Crea la secuencia de emails para un lanzamiento'"
    echo -e "     'Necesito una estrategia de lanzamiento para [producto]'"
    echo -e ""
}

# ═════════════════════════════════════════════════════════════════════════════
# MAIN
# ═════════════════════════════════════════════════════════════════════════════

main() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     🚀 Pack Lanzador v${VERSION} — Instalador              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    detect_config
    
    echo -e "  Configuración detectada:"
    echo -e "  ${BOLD}Cliente:${NC}        ${CLIENT_NAME}"
    echo -e "  ${BOLD}Config OpenCode:${NC} ${OPENCODE_CONFIG_PATH}"
    echo -e "  ${BOLD}Agents home:${NC}     ${AGENTS_HOME}"
    echo -e "  ${BOLD}Modelo:${NC}          ${DEFAULT_MODEL}"
    echo
    
    if [ "$AUTO_MODE" = false ]; then
        read -r -p "$(echo -e "${BOLD}¿Instalar Pack Lanzador?${NC} (S/n): ")" confirm
        if [[ "$confirm" =~ ^[nN]$ ]]; then
            info "Instalación cancelada."
            exit 0
        fi
    fi
    
    install_lanzador_agent
    install_lanzador_skill
    verify_installation
    show_summary
}

main "$@"

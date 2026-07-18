#!/usr/bin/env bash
# =============================================================================
# 🏗️ Builder — Suite de Agentes OpenCode para Clientes
# =============================================================================
# Este script construye y despliega la suite completa de agentes OpenCode
# en el equipo del cliente. Lee las respuestas del usuario desde suite-config.json
# o interactivamente, reemplaza placeholders, y copia los archivos a las
# ubicaciones correctas.
#
# Uso:
#   bash builder.sh              # Modo interactivo (guía paso a paso)
#   bash builder.sh --auto       # Usa valores por defecto (no recomendado)
#   bash builder.sh --help       # Muestra ayuda
#
# Requisitos:
#   - bash 4.0+
#   - curl (para verificar conectividad)
#   - OpenCode instalado (opcional, se verifica al final)
# =============================================================================

set -euo pipefail

# ─── Configuración ───────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/template"
AGENTS_DIR="$TEMPLATES_DIR/agents"
SKILLS_SRC="$SCRIPT_DIR/skills"
VERSION="2.2.0"
LOG_FILE="/tmp/suite-builder-$(date +%Y%m%d-%H%M%S).log"

# ─── Colores (compatibles macOS/Linux) ───────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── Variables del usuario (se llenan durante la ejecución) ──────────────────
CLIENT_NAME=""
ORQUESTADOR=""
WORKSPACE_PATH=""
ADMIN_EMAIL=""
OPENCODE_CONFIG_PATH=""
AGENTS_HOME=""
DEFAULT_MODEL=""
PRO_MODEL=""
MULTIMODAL_MODEL=""

# ─── Auto mode (usar valores por defecto) ──
AUTO_MODE=false
UPGRADE_MODE=false   # --upgrade: actualizar instalación existente
EXISTING_CONFIG=""   # Ruta a configuración existente detectada

# ─── Funciones de utilidad ────────────────────────────────────────────────────

log()     { echo -e "${GREEN}[✓]${NC} $1"; echo "[$(date +%H:%M:%S)] [✓] $1" >> "$LOG_FILE"; }
info()    { echo -e "${BLUE}[i]${NC} $1"; echo "[$(date +%H:%M:%S)] [i] $1" >> "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; echo "[$(date +%H:%M:%S)] [!] $1" >> "$LOG_FILE"; }
error()   { echo -e "${RED}[✗]${NC} $1"; echo "[$(date +%H:%M:%S)] [✗] $1" >> "$LOG_FILE"; }
header()  { echo -e "\n${MAGENTA}${BOLD}═══ $1 ═══${NC}\n"; }
step()    { echo -e "\n${CYAN}${BOLD}▸ Paso $1:${NC} $2"; }

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${RED}${BOLD}❌ El builder se interrumpió.${NC}"
        echo -e "   Log guardado en: $LOG_FILE"
        echo -e "   Puedes revisar el log con: cat $LOG_FILE"
    fi
    exit $exit_code
}
trap cleanup EXIT

# ─── Detección de instalación existente ───────────────────────────────────────
# Busca si el cliente ya tiene una suite instalada previamente.
# Returns 0 si existe, 1 si no.
# Llena variables globales con la configuración existente.
detect_existing() {
    local config_paths=(
        "${HOME}/.config/opencode/opencode.json"
        "${HOME}/.config/opencode/agent"
        "${HOME}/.agents/memoria-reinicio.md"
        "${HOME}/.agents/suite-config.json"
    )
    
    # Buscar suite-config.json guardado (configuración de instalación anterior)
    if [ -f "${HOME}/.agents/suite-config.json" ]; then
        EXISTING_CONFIG="${HOME}/.agents/suite-config.json"
        info "Instalación previa detectada: ${EXISTING_CONFIG}"
        return 0
    fi
    
    # Buscar agentes instalados
    if [ -d "${HOME}/.config/opencode/agent" ] && ls "${HOME}/.config/opencode/agent/"*.md &>/dev/null 2>&1; then
        local count
        count=$(ls "${HOME}/.config/opencode/agent/"*.md 2>/dev/null | wc -l | tr -d ' ')
        if [ "$count" -ge 3 ]; then
            info "Instalación previa detectada: ${count} agentes en ~/.config/opencode/agent/"
            return 0
        fi
    fi
    
    # Buscar agentes en la ruta configurada del usuario
    local configured_path="${OPENCODE_CONFIG_PATH:-${HOME}/.config/opencode}"
    if [ -d "$configured_path/agent" ] && ls "$configured_path/agent/"*.md &>/dev/null 2>&1; then
        local count2
        count2=$(ls "$configured_path/agent/"*.md 2>/dev/null | wc -l | tr -d ' ')
        if [ "$count2" -ge 3 ]; then
            info "Instalación previa detectada en ${configured_path}/agent/"
            return 0
        fi
    fi
    
    return 1
}

# ─── Leer configuración existente desde suite-config.json ────────────────────
read_existing_config() {
    if [ ! -f "$EXISTING_CONFIG" ]; then
        return 1
    fi
    
    # Extraer valores del JSON
    local cfg
    cfg=$(cat "$EXISTING_CONFIG")
    
    CLIENT_NAME=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('client_name',''))" 2>/dev/null || echo "")
    ORQUESTADOR=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('orquestador',''))" 2>/dev/null || echo "")
    WORKSPACE_PATH=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('workspace_path',''))" 2>/dev/null || echo "")
    ADMIN_EMAIL=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('admin_email',''))" 2>/dev/null || echo "")
    OPENCODE_CONFIG_PATH=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('opencode_config_path',''))" 2>/dev/null || echo "")
    AGENTS_HOME=$(echo "$cfg" | python3 -c "import sys,json; print(json.load(sys.stdin).get('agents_home',''))" 2>/dev/null || echo "")
    DEFAULT_MODEL=$(echo "$cfg" | python3 "models" 2>/dev/null || echo "")
    
    # Si no se pudo leer, marcar upgrade manual
    if [ -z "$CLIENT_NAME" ]; then
        warn "No se pudieron leer todos los valores de la configuración existente."
        info "Se te pedirá la información necesaria durante la actualización."
        return 1
    fi
    
    log "Configuración existente cargada: ${CLIENT_NAME}"
    return 0
}

# ─── Respaldar instalación existente ─────────────────────────────────────────
backup_existing() {
    local backup_dir="${AGENTS_HOME}/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    info "Creando respaldo en: ${backup_dir}"
    
    # Respaldar configs de OpenCode
    if [ -f "$OPENCODE_CONFIG_PATH/opencode.json" ]; then
        cp "$OPENCODE_CONFIG_PATH/opencode.json" "$backup_dir/opencode.json"
        log "Respaldo: opencode.json"
    fi
    if [ -f "$OPENCODE_CONFIG_PATH/opencode.jsonc" ]; then
        cp "$OPENCODE_CONFIG_PATH/opencode.jsonc" "$backup_dir/opencode.jsonc"
        log "Respaldo: opencode.jsonc"
    fi
    
    # Respaldar agentes
    if [ -d "$OPENCODE_CONFIG_PATH/agent" ]; then
        cp -r "$OPENCODE_CONFIG_PATH/agent" "$backup_dir/agents"
        log "Respaldo: agent/ (todos los agentes)"
    fi
    
    # Respaldar skills (solo customized, no las del pack)
    if [ -d "$AGENTS_HOME/skills" ]; then
        cp -r "$AGENTS_HOME/skills" "$backup_dir/skills"
        log "Respaldo: skills/"
    fi
    
    # Respaldar memoria
    if [ -f "$AGENTS_HOME/memoria-reinicio.md" ]; then
        cp "$AGENTS_HOME/memoria-reinicio.md" "$backup_dir/"
        log "Respaldo: memoria-reinicio.md"
    fi
    if [ -d "$AGENTS_HOME/memoria-sessions" ]; then
        cp -r "$AGENTS_HOME/memoria-sessions" "$backup_dir/"
        log "Respaldo: memoria-sessions/"
    fi
    
    echo
    log "Respaldo completado en: ${backup_dir}"
    echo -e "  ${YELLOW}⚠️  Puedes restaurar manualmente desde: ${backup_dir}${NC}"
    echo
}

# ─── Verificar opencode binary después de instalar ───────────────────────────
verify_opencode_binary() {
    local has_error=false
    
    # Buscar opencode en PATH
    local opencode_path=""
    if command -v opencode &>/dev/null; then
        opencode_path=$(which opencode)
    fi
    
    if [ -n "$opencode_path" ]; then
        log "OpenCode encontrado en: ${opencode_path}"
        
        # Si es PowerShell script (.ps1), advertir sobre execution policy
        if echo "$opencode_path" | grep -qi "\.ps1$"; then
            warn "OpenCode se ejecuta vía PowerShell (.ps1)."
            warn "Si ves errores de 'execution policy', ejecuta en PowerShell como administrador:"
            echo -e "  ${CYAN}Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned${NC}"
        fi
        
        # En Windows, verificar que el .exe existe y no es 0 KB
        if echo "${OS:-}" | grep -qi "windows\|mingw\|cygwin" 2>/dev/null || [ -n "${WINDIR:-}" ]; then
            local exe_path=""
            exe_path=$(echo "$opencode_path" | sed 's/\.ps1$/.exe/' 2>/dev/null || echo "")
            if [ -n "$exe_path" ] && [ -f "$exe_path" ]; then
                local size
                size=$(stat -f%z "$exe_path" 2>/dev/null || wc -c < "$exe_path" 2>/dev/null || echo "0")
                if [ "$size" -gt 1000 ] 2>/dev/null; then
                    log "Binario opencode.exe verificado: $(numfmt --to=iec $size 2>/dev/null || echo "${size} bytes")"
                else
                    warn "opencode.exe parece corrupto (solo ${size} bytes). Reinstala con:"
                    echo -e "  ${CYAN}npm uninstall -g opencode-ai && npm install -g opencode-ai${NC}"
                    has_error=true
                fi
            fi
        fi
        
        # Verificar que responde (--version)
        local version
        version=$(opencode --version 2>/dev/null || echo "")
        if [ -n "$version" ]; then
            log "OpenCode versión: ${version}"
        else
            warn "No se pudo verificar la versión de OpenCode."
            warn "Si falla, reinstala con: npm uninstall -g opencode-ai && npm install -g opencode-ai"
        fi
    else
        warn "OpenCode no está instalado en el PATH."
        info "Instálalo con: npm install -g opencode-ai"
        info "O descárgalo desde: https://opencode.ai/"
        has_error=true
    fi
    
    if [ "$has_error" = true ]; then
        echo
        warn "Hay problemas con la instalación de OpenCode. Revisa los mensajes arriba."
    fi
}

# ─── Fase 1: Verificar prerequisitos ─────────────────────────────────────────

check_prereqs() {
    header "FASE 1/10 — Verificando requisitos"

    # Bash version (compatible macOS 3.2+)
    if [ "${BASH_VERSINFO[0]}" -lt 3 ]; then
        error "Se requiere bash 3.2+. Versión actual: ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
        HAS_ERRORS=1
    elif [ "${BASH_VERSINFO[0]}" -eq 3 ]; then
        warn "bash 3.x detectado. En macOS considera: brew install bash (para funcionalidad completa)"
        info "Continuando con bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} — funciones básicas OK"
    fi
    log "Bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} — OK"

    # curl
    if command -v curl &>/dev/null; then
        log "curl — OK"
    else
        warn "curl no instalado (se usará para verificaciones de red)"
    fi

    # Verificar que existe la estructura del paquete
    if [ ! -d "$AGENTS_DIR" ]; then
        error "No se encuentra el directorio de templates: $AGENTS_DIR"
        info "Asegúrate de ejecutar este script desde la carpeta client-suite-pack/"
        exit 1
    fi
    log "Templates encontrados en: $TEMPLATES_DIR"

    # Contar templates de agente
    AGENT_COUNT=$(find "$AGENTS_DIR" -name "*.md" | wc -l | tr -d ' ')
    log "Templates de agente disponibles: $AGENT_COUNT"

    # Skills
    SKILL_COUNT=$(find "$SKILLS_SRC" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SKILL_COUNT" -gt 0 ]; then
        log "Skills disponibles: $SKILL_COUNT"
    else
        warn "No se encontraron skills en $SKILLS_SRC (puedes agregarlas después)"
    fi

    echo
    info "Ubicación del log: $LOG_FILE"
}

# ─── Fase 2: Recoger configuración del usuario ───────────────────────────────

collect_config() {
    header "FASE 2/10 — Configuración de la Suite"

    if [ "$AUTO_MODE" = true ]; then
        info "Modo auto: usando valores por defecto"
        log "Cliente: $CLIENT_NAME"
        log "Orquestador: $ORQUESTADOR"
        log "Workspace: $WORKSPACE_PATH"
        log "Email: $ADMIN_EMAIL"
        log "Modelo default: $DEFAULT_MODEL"
        return
    fi

    echo -e "${CYAN}Vamos a configurar tu suite de agentes.${NC}"
    echo -e "${CYAN}Responde las siguientes preguntas. Puedes presionar Enter para usar el valor por defecto.${NC}\n"

    # ── Pregunta 1: Nombre del cliente ──
    while [ -z "$CLIENT_NAME" ]; do
        read -p "$(echo -e "${BOLD}🏢 Nombre del cliente o proyecto:${NC} ")" CLIENT_NAME
        if [ -z "$CLIENT_NAME" ]; then
            echo -e "${YELLOW}⚠️  Este campo es obligatorio.${NC}"
        fi
    done
    log "Cliente: $CLIENT_NAME"

    # ── Pregunta 2: Nombre del orquestador ──
    echo
    read -p "$(echo -e "${BOLD}🤖 Nombre del agente orquestador${NC} (Enter para usar '$CLIENT_NAME'): ")" ORQUESTADOR
    if [ -z "$ORQUESTADOR" ]; then
        ORQUESTADOR="$CLIENT_NAME"
    fi
    log "Orquestador: $ORQUESTADOR"

    # ── Pregunta 3: Workspace path ──
    echo
    while [ -z "$WORKSPACE_PATH" ]; do
        read -p "$(echo -e "${BOLD}📁 Ruta del workspace del proyecto${NC} (ej: /home/user/projects): ")" WORKSPACE_PATH
        if [ -z "$WORKSPACE_PATH" ]; then
            echo -e "${YELLOW}⚠️  Este campo es obligatorio.${NC}"
        elif [ ! -d "$WORKSPACE_PATH" ]; then
            echo -e "${YELLOW}⚠️  La ruta no existe. La crearemos después.${NC}"
            break
        fi
    done
    log "Workspace: $WORKSPACE_PATH"

    # ── Pregunta 4: Email ──
    echo
    while [ -z "$ADMIN_EMAIL" ]; do
        read -p "$(echo -e "${BOLD}📧 Email del administrador:${NC} ")" ADMIN_EMAIL
        if [ -z "$ADMIN_EMAIL" ]; then
            echo -e "${YELLOW}⚠️  Este campo es obligatorio.${NC}"
        elif [[ ! "$ADMIN_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            echo -e "${YELLOW}⚠️  Formato de email inválido (ej: usuario@dominio.com).${NC}"
            ADMIN_EMAIL=""
        fi
    done
    log "Email: $ADMIN_EMAIL"

    # ── Pregunta 5: OpenCode config path ──
    echo
    DEFAULT_OPENCODE_CONFIG="${HOME}/.config/opencode"
    read -p "$(echo -e "${BOLD}⚙️  Ruta de configuración de OpenCode${NC} (Enter para '$DEFAULT_OPENCODE_CONFIG'): ")" OPENCODE_CONFIG_PATH
    if [ -z "$OPENCODE_CONFIG_PATH" ]; then
        OPENCODE_CONFIG_PATH="$DEFAULT_OPENCODE_CONFIG"
    fi
    log "Config OpenCode: $OPENCODE_CONFIG_PATH"

    # ── Pregunta 6: Agents home ──
    echo
    DEFAULT_AGENTS_HOME="${HOME}/.agents"
    read -p "$(echo -e "${BOLD}📂 Directorio para agentes y skills${NC} (Enter para '$DEFAULT_AGENTS_HOME'): ")" AGENTS_HOME
    if [ -z "$AGENTS_HOME" ]; then
        AGENTS_HOME="$DEFAULT_AGENTS_HOME"
    fi
    log "Agents home: $AGENTS_HOME"

    # ── Pregunta 7: Modelo por defecto ──
    echo
    read -p "$(echo -e "${BOLD}🧠 Modelo por defecto${NC} (Enter para 'opencode-go/deepseek-v4-flash'): ")" DEFAULT_MODEL
    if [ -z "$DEFAULT_MODEL" ]; then
        DEFAULT_MODEL="opencode-go/deepseek-v4-flash"
    fi
    log "Modelo default: $DEFAULT_MODEL"

    # ── Pregunta 8: Modelo premium ──
    echo
    read -p "$(echo -e "${BOLD}⭐ Modelo premium (auditor)${NC} (Enter para 'opencode-go/deepseek-v4-pro'): ")" PRO_MODEL
    if [ -z "$PRO_MODEL" ]; then
        PRO_MODEL="opencode-go/deepseek-v4-pro"
    fi
    log "Modelo premium: $PRO_MODEL"

    # ── Pregunta 9: Modelo multimodal ──
    echo
    read -p "$(echo -e "${BOLD}🖼️  Modelo multimodal${NC} (Enter para 'opencode-go/mimo-v2.5'): ")" MULTIMODAL_MODEL
    if [ -z "$MULTIMODAL_MODEL" ]; then
        MULTIMODAL_MODEL="opencode-go/mimo-v2.5"
    fi
    log "Modelo multimodal: $MULTIMODAL_MODEL"

    # ── Resumen de configuración ──
    echo
    echo -e "${CYAN}${BOLD}═══ Resumen de configuración ═══${NC}"
    echo -e "  ${BOLD}Cliente:${NC}          $CLIENT_NAME"
    echo -e "  ${BOLD}Orquestador:${NC}      $ORQUESTADOR"
    echo -e "  ${BOLD}Workspace:${NC}        $WORKSPACE_PATH"
    echo -e "  ${BOLD}Email admin:${NC}      $ADMIN_EMAIL"
    echo -e "  ${BOLD}OpenCode config:${NC}  $OPENCODE_CONFIG_PATH"
    echo -e "  ${BOLD}Agents home:${NC}      $AGENTS_HOME"
    echo -e "  ${BOLD}Modelo default:${NC}   $DEFAULT_MODEL"
    echo -e "  ${BOLD}Modelo premium:${NC}   $PRO_MODEL"
    echo -e "  ${BOLD}Modelo multimodal:${NC} $MULTIMODAL_MODEL"
    echo

    # Confirmación
    read -p "$(echo -e "${BOLD}¿Es correcto?${NC} (s/N): ")" CONFIRM
    if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
        info "Reiniciando configuración..."
        # Reset variables
        CLIENT_NAME=""; ORQUESTADOR=""; WORKSPACE_PATH=""
        ADMIN_EMAIL=""; OPENCODE_CONFIG_PATH=""; AGENTS_HOME=""
        DEFAULT_MODEL=""; PRO_MODEL=""; MULTIMODAL_MODEL=""
        collect_config
        return
    fi
}

# ─── Fase 3: Crear directorios ───────────────────────────────────────────────

create_dirs() {
    header "FASE 3/10 — Creando directorios"

    mkdir -p "$OPENCODE_CONFIG_PATH/agent"
    log "Creado: $OPENCODE_CONFIG_PATH/agent/"

    mkdir -p "$AGENTS_HOME/skills"
    log "Creado: $AGENTS_HOME/skills/"

    # Crear directorio de memoria de sesiones
    mkdir -p "$AGENTS_HOME/memoria-sessions"
    log "Creado: $AGENTS_HOME/memoria-sessions/"

    if [ ! -d "$WORKSPACE_PATH" ]; then
        mkdir -p "$WORKSPACE_PATH"
        log "Creado workspace: $WORKSPACE_PATH"
    else
        log "Workspace ya existe: $WORKSPACE_PATH"
    fi

    # Crear .agents home
    mkdir -p "$AGENTS_HOME"
    log "Creado: $AGENTS_HOME/"
}

# ─── Fase 4: Instalar templates de agentes ───────────────────────────────────

install_agents() {
    header "FASE 4/10 — Instalando agentes"

    local TEMPLATE_FILE
    local DEST_FILE
    local COUNT=0

    for TEMPLATE_FILE in "$AGENTS_DIR"/*.md; do
        local BASENAME
        BASENAME=$(basename "$TEMPLATE_FILE")

        # Si es el template del orquestador, usar el nombre configurado
        if [ "$BASENAME" = "{{ORQUESTADOR}}.md" ]; then
            DEST_FILE="$OPENCODE_CONFIG_PATH/agent/${ORQUESTADOR}.md"
        else
            DEST_FILE="$OPENCODE_CONFIG_PATH/agent/$BASENAME"
        fi

        # Copiar y reemplazar placeholders
        cp "$TEMPLATE_FILE" "$DEST_FILE"

        # Reemplazar placeholders con sed (delimitador | para evitar conflictos con / en rutas y modelos)
        sed -i '' "s|{{CLIENT_NAME}}|$CLIENT_NAME|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{CLIENT_NAME}}|$CLIENT_NAME|g" "$DEST_FILE"

        sed -i '' "s|{{ORQUESTADOR}}|$ORQUESTADOR|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{ORQUESTADOR}}|$ORQUESTADOR|g" "$DEST_FILE"

        sed -i '' "s|{{WORKSPACE_PATH}}|$WORKSPACE_PATH|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{WORKSPACE_PATH}}|$WORKSPACE_PATH|g" "$DEST_FILE"

        sed -i '' "s|{{ADMIN_EMAIL}}|$ADMIN_EMAIL|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{ADMIN_EMAIL}}|$ADMIN_EMAIL|g" "$DEST_FILE"

        sed -i '' "s|{{OPENCODE_CONFIG_PATH}}|$OPENCODE_CONFIG_PATH|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{OPENCODE_CONFIG_PATH}}|$OPENCODE_CONFIG_PATH|g" "$DEST_FILE"

        sed -i '' "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" "$DEST_FILE"

        sed -i '' "s|{{DEFAULT_MODEL}}|$DEFAULT_MODEL|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{DEFAULT_MODEL}}|$DEFAULT_MODEL|g" "$DEST_FILE"

        sed -i '' "s|{{PRO_MODEL}}|$PRO_MODEL|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{PRO_MODEL}}|$PRO_MODEL|g" "$DEST_FILE"

        sed -i '' "s|{{MULTIMODAL_MODEL}}|$MULTIMODAL_MODEL|g" "$DEST_FILE" 2>/dev/null || \
        sed -i "s|{{MULTIMODAL_MODEL}}|$MULTIMODAL_MODEL|g" "$DEST_FILE"

        COUNT=$((COUNT + 1))
        log "Agente instalado: $(basename "$DEST_FILE")"
    done

    echo
    log "Total: $COUNT agentes instalados en $OPENCODE_CONFIG_PATH/agent/"
}

# ─── Fase 5: Instalar archivos de configuración ──────────────────────────────

install_configs() {
    header "FASE 5/12 — Instalando configuración de OpenCode"

    # opencode.json
    if [ -f "$OPENCODE_CONFIG_PATH/opencode.json" ]; then
        if [ "$UPGRADE_MODE" = true ]; then
            log "Actualizando opencode.json (respaldo guardado en backup/)"
        else
            warn "opencode.json ya existe. Se creará respaldo: opencode.json.bak"
            cp "$OPENCODE_CONFIG_PATH/opencode.json" "$OPENCODE_CONFIG_PATH/opencode.json.bak"
        fi
    fi

    cp "$TEMPLATES_DIR/opencode.json" "$OPENCODE_CONFIG_PATH/opencode.json"

    # Reemplazar placeholders (delimitador | para evitar conflictos con /)
    sed -i '' "s|{{DEFAULT_MODEL}}|$DEFAULT_MODEL|g" "$OPENCODE_CONFIG_PATH/opencode.json" 2>/dev/null || \
    sed -i "s|{{DEFAULT_MODEL}}|$DEFAULT_MODEL|g" "$OPENCODE_CONFIG_PATH/opencode.json"
    sed -i '' "s|{{ORQUESTADOR}}|$ORQUESTADOR|g" "$OPENCODE_CONFIG_PATH/opencode.json" 2>/dev/null || \
    sed -i "s|{{ORQUESTADOR}}|$ORQUESTADOR|g" "$OPENCODE_CONFIG_PATH/opencode.json"
    sed -i '' "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" "$OPENCODE_CONFIG_PATH/opencode.json" 2>/dev/null || \
    sed -i "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" "$OPENCODE_CONFIG_PATH/opencode.json"

    log "Configurado: $OPENCODE_CONFIG_PATH/opencode.json"

    # opencode.jsonc
    if [ -f "$OPENCODE_CONFIG_PATH/opencode.jsonc" ]; then
        if [ "$UPGRADE_MODE" = true ]; then
            log "Actualizando opencode.jsonc (respaldo guardado en backup/)"
        else
            warn "opencode.jsonc ya existe. Se creará respaldo: opencode.jsonc.bak"
            cp "$OPENCODE_CONFIG_PATH/opencode.jsonc" "$OPENCODE_CONFIG_PATH/opencode.jsonc.bak"
        fi
    fi

    cp "$TEMPLATES_DIR/opencode.jsonc" "$OPENCODE_CONFIG_PATH/opencode.jsonc"

    # Reemplazar placeholders en jsonc
    sed -i '' "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" "$OPENCODE_CONFIG_PATH/opencode.jsonc" 2>/dev/null || \
    sed -i "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" "$OPENCODE_CONFIG_PATH/opencode.jsonc"

    log "Configurado: $OPENCODE_CONFIG_PATH/opencode.jsonc"
}

# ─── Fase 6: Instalar skills ─────────────────────────────────────────────────

install_skills() {
    header "FASE 6/10 — Instalando skills"

    if [ ! -d "$SKILLS_SRC" ] || [ -z "$(ls -A "$SKILLS_SRC" 2>/dev/null)" ]; then
        warn "No hay skills para instalar en $SKILLS_SRC"
        info "Puedes agregar skills manualmente en $AGENTS_HOME/skills/"
        return
    fi

    local COUNT=0

    # Copiar skills principales
    for SKILL_DIR in "$SKILLS_SRC"/*/; do
        if [ -d "$SKILL_DIR" ]; then
            local SKILL_NAME
            SKILL_NAME=$(basename "$SKILL_DIR")
            local DEST_SKILL_DIR="$AGENTS_HOME/skills/$SKILL_NAME"

            mkdir -p "$DEST_SKILL_DIR"
            cp -r "$SKILL_DIR"/* "$DEST_SKILL_DIR/" 2>/dev/null

            # Reemplazar placeholders en skills
            find "$DEST_SKILL_DIR" -type f -exec sed -i '' "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" {} \; 2>/dev/null || \
            find "$DEST_SKILL_DIR" -type f -exec sed -i "s|{{AGENTS_HOME}}|$AGENTS_HOME|g" {} \; 2>/dev/null || true

            COUNT=$((COUNT + 1))
            log "Skill instalada: $SKILL_NAME"
        fi
    done

    # Copiar skills de desarrollo
    if [ -d "$SKILLS_SRC/dev" ]; then
        mkdir -p "$AGENTS_HOME/skills/dev"
        for SKILL_DIR in "$SKILLS_SRC/dev"/*/; do
            if [ -d "$SKILL_DIR" ]; then
                local SKILL_NAME
                SKILL_NAME=$(basename "$SKILL_DIR")
                local DEST_SKILL_DIR="$AGENTS_HOME/skills/dev/$SKILL_NAME"

                mkdir -p "$DEST_SKILL_DIR"
                cp -r "$SKILL_DIR"/* "$DEST_SKILL_DIR/" 2>/dev/null
                COUNT=$((COUNT + 1))
                log "Skill dev instalada: $SKILL_NAME"
            fi
        done
    fi

    # Copiar skills de dominio
    if [ -d "$SKILLS_SRC/domain" ]; then
        mkdir -p "$AGENTS_HOME/skills/domain"
        for SKILL_DIR in "$SKILLS_SRC/domain"/*/; do
            if [ -d "$SKILL_DIR" ]; then
                local SKILL_NAME
                SKILL_NAME=$(basename "$SKILL_DIR")
                local DEST_SKILL_DIR="$AGENTS_HOME/skills/domain/$SKILL_NAME"

                mkdir -p "$DEST_SKILL_DIR"
                cp -r "$SKILL_DIR"/* "$DEST_SKILL_DIR/" 2>/dev/null
                COUNT=$((COUNT + 1))
                log "Skill domain instalada: $SKILL_NAME"
            fi
        done
    fi

    echo
    log "Total: $COUNT skills instaladas en $AGENTS_HOME/skills/"
}

# ─── Fase 7: Inicializar memoria de reinicio ─────────────────────────────────

init_memory() {
    header "FASE 7/12 — Inicializando sistema de memoria"

    local MEMORIA_SESSIONS="$AGENTS_HOME/memoria-sessions"

    # En upgrade, preservar sesiones existentes
    if [ "$UPGRADE_MODE" = true ] && [ -f "$MEMORIA_SESSIONS/index.json" ]; then
        log "Sistema de memoria existente preservado (${MEMORIA_SESSIONS})"
        
        # Solo actualizar memoria-reinicio.md si no existe
        if [ ! -f "$AGENTS_HOME/memoria-reinicio.md" ]; then
            cat > "$AGENTS_HOME/memoria-reinicio.md" << EOF
# 🧠 Memoria de Reinicio — Sesiones Activas

> **Generado:** $(date '+%Y-%m-%dT%H:%M:%S%z')
> Este archivo se actualiza **automáticamente** en cada iteración del agente.
> Gestiona **0** sesiones independientes — cada una en su propio archivo.

---

## 📋 Sesiones abiertas

*No hay sesiones activas todavía. Crea tu primer proyecto y la memoria se poblará automáticamente.*

---
EOF
            log "Creado: memoria-reinicio.md (no existía)"
        fi
        
        # Actualizar schema si es más nuevo
        if [ -f "$TEMPLATES_DIR/memoria/memoria-sessions-schema.json" ]; then
            cp "$TEMPLATES_DIR/memoria/memoria-sessions-schema.json" "$MEMORIA_SESSIONS/"
            log "Schema de memoria actualizado"
        fi
        
        log "Sistema de memoria verificado correctamente"
        return
    fi

    # Instalación limpia — crear desde cero
    mkdir -p "$MEMORIA_SESSIONS"

    # 1. Crear session-actual.md
    echo "NINGUNA" > "$MEMORIA_SESSIONS/session-actual.md"
    log "Creado: session-actual.md"

    # 2. Crear index.json
    cat > "$MEMORIA_SESSIONS/index.json" << EOF
{
  "schema_version": "2.0",
  "sesiones": [],
  "ultima_actualizacion": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    log "Creado: index.json"

    # 3. Copiar schema de referencia
    if [ -f "$TEMPLATES_DIR/memoria/memoria-sessions-schema.json" ]; then
        cp "$TEMPLATES_DIR/memoria/memoria-sessions-schema.json" "$MEMORIA_SESSIONS/"
        log "Schema de memoria copiado"
    fi

    # 4. Generar memoria-reinicio.md
    cat > "$AGENTS_HOME/memoria-reinicio.md" << EOF
# 🧠 Memoria de Reinicio — Sesiones Activas

> **Generado:** $(date '+%Y-%m-%dT%H:%M:%S%z')
> Este archivo se actualiza **automáticamente** en cada iteración del agente.
> Gestiona **0** sesiones independientes — cada una en su propio archivo.

---

## 📋 Sesiones abiertas

*No hay sesiones activas todavía. Crea tu primer proyecto y la memoria se poblará automáticamente.*

---

## ▶️ Sesión activa (esta ventana)

- **ID:** *(ninguna)*
- **Proyecto:** *(ninguno)*

---

## 💡 Para iniciar una sesión

Cuando trabajes en un proyecto, el orquestador creará automáticamente una sesión de memoria.
En tu próxima sesión, di **"continuar"** para ver tus proyectos pendientes.
EOF
    log "Creado: memoria-reinicio.md"

    echo
    log "Sistema de memoria multi-sesión inicializado correctamente"
}

# ─── Fase 8: Inicializar diario de proyecto ──────────────────────────────────

init_diary() {
    header "FASE 8/10 — Inicializando diario de proyecto"

    local DIARIO_DIR="$WORKSPACE_PATH"

    # Crear diario del proyecto si no existe
    if [ ! -f "$DIARIO_DIR/diario-construccion.md" ]; then
        cat > "$DIARIO_DIR/diario-construccion.md" << EOF
# 📓 Diario de Construcción — ${CLIENT_NAME}

> **Iniciado:** $(date '+%Y-%m-%d')
> **Suite:** Client Agent Suite v${VERSION}
> **Orquestador:** ${ORQUESTADOR}

---

## 🌱 Sesión 1 — Instalación de la Suite

### Fecha: $(date '+%Y-%m-%d')

### Logros
- Suite de agentes instalada con builder.sh
- 11 agentes configurados en \`${OPENCODE_CONFIG_PATH}/agent/\`
- 20+ skills instaladas en \`${AGENTS_HOME}/skills/\`
- Sistema de memoria multi-sesión inicializado
- Diario de proyecto creado

### Pendientes
- [ ] Configurar API key de OpenCode
- [ ] Configurar MCP servers (Playwright, etc.)
- [ ] Primer proyecto de prueba

---

## 📝 Cómo registrar avances

Cada vez que trabajes con la suite, crea una nueva entrada aquí.
El orquestador también guarda progreso automáticamente en \`${AGENTS_HOME}/memoria-sessions/\`.
EOF
        log "Creado: diario-construccion.md en el workspace"
    else
        log "El diario ya existe en el workspace"
    fi
}

# ─── Fase 9: Instalar pipeline agent-swarm ──────────────────────────────

install_pipeline() {
    header "FASE 9/11 — Instalando pipeline de desarrollo (agent-swarm)"
    
    local pipeline_dir="${OPENCODE_CONFIG_PATH%/opencode}/agent-swarm"
    local repo_url="https://github.com/reinaagencia/agent-swarm.git"
    
    # Preguntar si instalar el pipeline
    echo -e "\n${CYAN}¿Deseas instalar el pipeline de desarrollo agent-swarm?${NC}"
    echo -e "  (Esto permite a los agentes ejecutar el pipeline completo de generación de código"
    echo -e "   con MoA, Bash-Native y memoria en línea. Sin él, los agentes funcionan"
    echo -e "   pero sin el pipeline automatizado.)"
    echo -e ""
    echo -e "  ${BOLD}1)${NC} Sí, instalar pipeline (recomendado)"
    echo -e "  ${BOLD}2)${NC} No, solo los agentes OpenCode"
    echo -e ""
    
    if [ -n "${SUITE_PIPELINE_INSTALL:-}" ]; then
        local choice="$SUITE_PIPELINE_INSTALL"
        echo -e "  → Usando valor preconfigurado: $choice"
    else
        read -r -p "  Opción [1/2] (default: 1): " choice
        choice="${choice:-1}"
    fi
    
    if [ "$choice" != "1" ]; then
        info "Pipeline agent-swarm no instalado. Los agentes funcionan sin él."
        return 0
    fi
    
    # Elegir método de instalación
    echo -e "\n${CYAN}Método de instalación:${NC}"
    echo -e "  ${BOLD}1)${NC} Clonar desde GitHub (requiere git)"
    echo -e "  ${BOLD}2)${NC} Copiar desde origen local (si ya tienes agent-swarm)"
    echo -e ""
    
    if [ -n "${SUITE_PIPELINE_METHOD:-}" ]; then
        local method="$SUITE_PIPELINE_METHOD"
    else
        read -r -p "  Opción [1/2] (default: 1): " method
        method="${method:-1}"
    fi
    
    if [ "$method" = "1" ]; then
        # Clonar desde GitHub
        if command -v git &>/dev/null; then
            if [ -d "$pipeline_dir" ]; then
                warn "El directorio $pipeline_dir ya existe."
                echo -e "  ${BOLD}1)${NC} Actualizar (git pull)"
                echo -e "  ${BOLD}2)${NC} Reemplazar (git clone fresco)"
                echo -e "  ${BOLD}3)${NC} Saltar"
                if [ -n "${SUITE_PIPELINE_EXISTS:-}" ]; then
                    local exist_action="$SUITE_PIPELINE_EXISTS"
                else
                    read -r -p "  Opción [1/2/3] (default: 1): " exist_action
                    exist_action="${exist_action:-1}"
                fi
                
                case "$exist_action" in
                    1)
                        info "Actualizando pipeline existente..."
                        (cd "$pipeline_dir" && git pull) && log "Pipeline actualizado" || warn "Error en git pull"
                        ;;
                    2)
                        info "Reemplazando pipeline..."
                        rm -rf "$pipeline_dir"
                        git clone "$repo_url" "$pipeline_dir" && log "Pipeline clonado en $pipeline_dir" || error "Error clonando"
                        ;;
                    *)
                        info "Usando pipeline existente."
                        ;;
                esac
            else
                info "Clonando pipeline agent-swarm desde GitHub..."
                git clone "$repo_url" "$pipeline_dir" && log "Pipeline clonado en $pipeline_dir" || error "Error clonando"
            fi
        else
            error "git no está instalado. Instala git o usa la opción de copia local."
            warn "Puedes clonar manualmente: git clone $repo_url $pipeline_dir"
        fi
    else
        # Copiar local
        local local_src="${SCRIPT_DIR}/../agent-swarm"
        if [ -d "$local_src" ]; then
            info "Copiando pipeline desde $local_src..."
            cp -r "$local_src" "$pipeline_dir" && log "Pipeline copiado desde origen local" || error "Error copiando"
        else
            error "No se encontró agent-swarm en $local_src"
            warn "Clona manualmente: git clone $repo_url $pipeline_dir"
        fi
    fi
    
    # Verificar instalación
    if [ -f "$pipeline_dir/main.py" ]; then
        log "Pipeline instalado correctamente en $pipeline_dir"
        
        # Crear alias en .zshrc para facilitar uso
        local alias_line="alias enjambre='cd $pipeline_dir && python3 main.py'"
        local zshrc="$HOME/.zshrc"
        if [ -f "$zshrc" ] && ! grep -q "alias enjambre=" "$zshrc" 2>/dev/null; then
            echo "$alias_line" >> "$zshrc"
            log "Alias 'enjambre' creado en .zshrc"
        fi
    else
        warn "Pipeline no verificado. Puedes instalarlo manualmente."
    fi
}


# ─── Fase 10: Verificar instalación ───────────────────────────────────────────

verify_installation() {
    header "FASE 10/11 — Verificando instalación"

    local HAS_ERRORS=0

    # 1. Verificar que los archivos de agente existen (11 = 1 orquestador + 10 subagentes)
    local AGENT_FILES
    AGENT_FILES=$(ls "$OPENCODE_CONFIG_PATH/agent/"*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$AGENT_FILES" -ge 11 ]; then
        log "Archivos de agente: $AGENT_FILES (OK)"
    elif [ "$AGENT_FILES" -ge 8 ]; then
        warn "Archivos de agente: $AGENT_FILES (puede faltar alguno, se esperaban 11)"
    else
        error "Archivos de agente: $AGENT_FILES (se esperaban 11)"
        HAS_ERRORS=1
    fi

    # 2. Verificar que el orquestador principal existe
    if [ -f "$OPENCODE_CONFIG_PATH/agent/${ORQUESTADOR}.md" ]; then
        log "Orquestador '${ORQUESTADOR}' encontrado"
    else
        error "Orquestador '${ORQUESTADOR}' NO encontrado en $OPENCODE_CONFIG_PATH/agent/"
        HAS_ERRORS=1
    fi

    # 3. Verificar opencode.json
    if [ -f "$OPENCODE_CONFIG_PATH/opencode.json" ]; then
        if grep -q "{{" "$OPENCODE_CONFIG_PATH/opencode.json" 2>/dev/null; then
            warn "opencode.json contiene placeholders sin reemplazar"
            HAS_ERRORS=1
        else
            log "opencode.json configurado correctamente"
        fi
    else
        error "opencode.json no encontrado"
        HAS_ERRORS=1
    fi

    # 4. Verificar que NO queden placeholders sin reemplazar en agentes
    local UNREPLACED
    UNREPLACED=$(grep -r '{{' "$OPENCODE_CONFIG_PATH/agent/" 2>/dev/null || true)
    if [ -n "$UNREPLACED" ]; then
        warn "Se encontraron placeholders sin reemplazar en los agentes:"
        echo "$UNREPLACED" | head -20
        HAS_ERRORS=1
    else
        log "Todos los placeholders reemplazados correctamente"
    fi

    # 5. Verificar skills
    local SKILL_COUNT_CHECK
    SKILL_COUNT_CHECK=$(find "$AGENTS_HOME/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SKILL_COUNT_CHECK" -gt 0 ]; then
        log "Skills instaladas: $SKILL_COUNT_CHECK"
    else
        warn "No se encontraron skills en $AGENTS_HOME/skills/"
    fi

    # 6. Verificar memoria de reinicio
    if [ -f "$AGENTS_HOME/memoria-reinicio.md" ]; then
        log "Memoria de reinicio: encontrada"
    else
        error "Memoria de reinicio NO encontrada en $AGENTS_HOME/"
        HAS_ERRORS=1
    fi

    # 7. Verificar memoria-sessions
    if [ -f "$AGENTS_HOME/memoria-sessions/index.json" ]; then
        log "Índice de sesiones: encontrado"
    else
        warn "Índice de sesiones no encontrado (se creará automáticamente al primer uso)"
    fi

    # 8. Verificar pipeline agent-swarm
    local pipeline_dir="${OPENCODE_CONFIG_PATH%/opencode}/agent-swarm"
    if [ -f "$pipeline_dir/main.py" ]; then
        log "Pipeline agent-swarm: encontrado ($pipeline_dir)"
        if [ -f "$pipeline_dir/src/moa_engine.py" ]; then
            log "  → MoA Engine: presente"
        fi
        if grep -q "_run_local_tests" "$pipeline_dir/src/nodes/programmer.py" 2>/dev/null; then
            log "  → Bash-Native pytest: presente"
        fi
        if grep -q "get_heuristics_context" "$pipeline_dir/src/nodes/programmer.py" 2>/dev/null; then
            log "  → Memoria episódica en línea: presente"
        fi
    else
        info "Pipeline agent-swarm no instalado (opcional — los agentes funcionan sin él)"
    fi

    # 9. Verificar OpenCode instalado
    if command -v opencode &>/dev/null; then
        log "OpenCode detectado: $(which opencode)"
    else
        warn "OpenCode no está instalado en el PATH. Instálalo desde https://opencode.ai/"
    fi

    echo
    if [ "$HAS_ERRORS" -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✅ Verificación completada — sin errores.${NC}"
    else
        echo -e "${YELLOW}${BOLD}⚠️  Verificación completada — con advertencias/errores.${NC}"
        echo -e "${YELLOW}Revisa los mensajes arriba para más detalles.${NC}"
    fi
}

# ─── Fase 10: Mostrar resumen final ──────────────────────────────────────────

show_summary() {
    header "FASE 11/11 — Resumen final"

    echo -e "${GREEN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     ✅ Suite ${CLIENT_NAME} instalada correctamente       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${BOLD}📋 Resumen de instalación:${NC}"
    echo -e "  🤖  ${BOLD}Orquestador:${NC}    ${ORQUESTADOR}"
    echo -e "  👥  ${BOLD}Agentes:${NC}         11 (10 subagentes + orquestador)"
    echo -e "  📁  ${BOLD}Agentes en:${NC}      $OPENCODE_CONFIG_PATH/agent/"
    echo -e "  📚  ${BOLD}Skills en:${NC}       $AGENTS_HOME/skills/"
    echo -e "  🧠  ${BOLD}Memoria en:${NC}      $AGENTS_HOME/memoria-sessions/"
    echo -e "  📓  ${BOLD}Diario en:${NC}       $WORKSPACE_PATH/diario-construccion.md"
    echo -e "  ⚙️   ${BOLD}Config en:${NC}       $OPENCODE_CONFIG_PATH/opencode.json"
    echo

    echo -e "${YELLOW}${BOLD}⚡ Configuración pendiente (manual):${NC}"
    echo -e "  ${YELLOW}1.${NC} Obtener API key en https://opencode.ai y configurarla"
    echo -e "     export OPENCODE_API_KEY=\"sk-tu-key-aqui\""
    echo -e "     export OPENCODE_BASE_URL=\"https://opencode.ai/zen/v1\""
    echo
    echo -e "  ${YELLOW}2.${NC} Configurar MCP servers según necesites:"
    echo -e "     - Playwright: npx @playwright/mcp (navegador web)"
    echo -e "     - Google: OAuth 2.0 (Calendar, Gmail — opcional)"
    echo
    echo -e "  ${YELLOW}3.${NC} Revisar CONFIGURATION.md para la guía completa"
    echo
    echo -e "${CYAN}${BOLD}🧠 Tu suite tiene superinteligencia continua:${NC}"
    echo -e "  Cada tarea que resuelvas → genera lecciones → mejora las siguientes."
    echo -e "  El sistema se vuelve más inteligente con cada uso."
    echo

    # Guardar configuración para referencia
    local CONFIG_SAVE_PATH="$AGENTS_HOME/suite-config.json"
    cat > "$CONFIG_SAVE_PATH" << EOF
{
  "version": "$VERSION",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "client_name": "$CLIENT_NAME",
  "orquestador": "$ORQUESTADOR",
  "workspace_path": "$WORKSPACE_PATH",
  "admin_email": "$ADMIN_EMAIL",
  "opencode_config_path": "$OPENCODE_CONFIG_PATH",
  "agents_home": "$AGENTS_HOME",
  "models": {
    "default": "$DEFAULT_MODEL",
    "pro": "$PRO_MODEL",
    "multimodal": "$MULTIMODAL_MODEL"
  }
}
EOF
    log "Configuración guardada en: $CONFIG_SAVE_PATH"

    echo -e "${GREEN}${BOLD}🎉 ¡Todo listo! Abre OpenCode y empieza a trabajar.${NC}"
    echo -e "${GREEN}   cd $WORKSPACE_PATH${NC}"
    echo -e "${GREEN}   opencode${NC}"
    echo

    # Mostrar ruta del log
    info "Log completo: $LOG_FILE"

    # Preguntar si quiere abrir CONFIGURATION.md
    read -p "$(echo -e "${BOLD}¿Quieres abrir la guía de configuración?${NC} (s/N): ")" SHOW_GUIDE
    if [[ "$SHOW_GUIDE" =~ ^[sS]$ ]]; then
        if command -v cat &>/dev/null; then
            echo -e "\n${CYAN}═══ CONFIGURATION.md ═══${NC}\n"
            cat "$SCRIPT_DIR/CONFIGURATION.md" 2>/dev/null | head -80
            echo -e "\n${CYAN}... (continúa en el archivo completo)${NC}"
        fi
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    # ─── Parsear flags ───
    for arg in "$@"; do
        case $arg in
            --auto) AUTO_MODE=true ;;
            --upgrade|--update) UPGRADE_MODE=true ;;
            --help|-h)
                echo "Uso: bash builder.sh [--auto] [--upgrade]"
                echo ""
                echo "Opciones:"
                echo "  --auto       Usa valores por defecto"
                echo "  --upgrade    Actualiza instalación existente (detecta + respalda + sobrescribe)"
                echo "  --help       Muestra esta ayuda"
                exit 0
                ;;
        esac
    done
    
    # ─── Detectar instalación existente ───
    detect_existing
    if [ $? -eq 0 ] && [ "$UPGRADE_MODE" = false ]; then
        echo -e "\n${YELLOW}${BOLD}⚠️  Se detectó una instalación previa de la suite.${NC}"
        echo -e "  ${BOLD}1)${NC} Actualizar instalación existente (recomendado — respalda y sobrescribe)"
        echo -e "  ${BOLD}2)${NC} Instalación limpia (sobrescribe todo)"
        echo -e "  ${BOLD}3)${NC} Cancelar"
        echo ""
        read -r -p "  Opción [1/2/3] (default: 1): " upgrade_choice
        upgrade_choice="${upgrade_choice:-1}"
        
        case "$upgrade_choice" in
            2) UPGRADE_MODE=false; info "Modo instalación limpia." ;;
            3) info "Instalación cancelada."; exit 0 ;;
            *) UPGRADE_MODE=true ;;
        esac
    fi

    # ─── Auto mode: valores por defecto ───
    if [ "$AUTO_MODE" = true ]; then
        CLIENT_NAME="${CLIENT_NAME:-Cliente}"
        ORQUESTADOR="${ORQUESTADOR:-$CLIENT_NAME}"
        WORKSPACE_PATH="${WORKSPACE_PATH:-$HOME/Dev}"
        ADMIN_EMAIL="${ADMIN_EMAIL:-admin@${CLIENT_NAME,,}.com}"
        OPENCODE_CONFIG_PATH="${OPENCODE_CONFIG_PATH:-$HOME/.config/opencode}"
        AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
        DEFAULT_MODEL="${DEFAULT_MODEL:-opencode-go/deepseek-v4-flash}"
        PRO_MODEL="${PRO_MODEL:-opencode-go/deepseek-v4-pro}"
        MULTIMODAL_MODEL="${MULTIMODAL_MODEL:-opencode-go/mimo-v2.5}"
    fi

    # Limpiar pantalla
    clear

    echo -e "${MAGENTA}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     🏗️  Builder — Suite de Agentes OpenCode v${VERSION}    ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # ─── Modo upgrade ───
    if [ "$UPGRADE_MODE" = true ]; then
        header "🔄 MODO ACTUALIZACIÓN — Instalación existente detectada"
        
        # Cargar configuración existente
        read_existing_config
        if [ $? -ne 0 ] && [ "$AUTO_MODE" = false ]; then
            # Si falla la lectura, preguntar datos manualmente
            warn "No se pudo cargar la configuración. Ingresa los datos manualmente."
            collect_config
        fi
        
        # Mostrar resumen de la configuración detectada
        echo -e "  ${BOLD}Cliente:${NC}          ${CLIENT_NAME:-$(whoami)}"
        echo -e "  ${BOLD}Orquestador:${NC}      ${ORQUESTADOR:-$CLIENT_NAME}"
        echo -e "  ${BOLD}Workspace:${NC}        ${WORKSPACE_PATH:-$HOME/Dev}"
        echo -e "  ${BOLD}Config OpenCode:${NC}  ${OPENCODE_CONFIG_PATH:-$HOME/.config/opencode}"
        echo -e "  ${BOLD}Agents home:${NC}      ${AGENTS_HOME:-$HOME/.agents}\n"
        
        # Confirmar antes de respaldar y actualizar
        if [ "$AUTO_MODE" = false ]; then
            read -r -p "$(echo -e "${BOLD}¿Actualizar con esta configuración?${NC} (s/N): ")" confirm_upgrade
            if [[ ! "$confirm_upgrade" =~ ^[sS]$ ]]; then
                info "Actualización cancelada."
                exit 0
            fi
        fi
        
        # RESPALDAR antes de modificar
        backup_existing
    fi
    
    # ─── Ejecutar fases (11-12 fases) ───
    check_prereqs
    
    # Saltar collect_config si estamos en upgrade y ya cargamos la config
    if [ "$UPGRADE_MODE" = false ]; then
        collect_config
    else
        # En upgrade, mostrar que preservamos la config existente
        header "FASE 2/12 — Configuración preservada"
        log "Usando configuración existente de: ${CLIENT_NAME}"
        log "Orquestador: ${ORQUESTADOR}"
        log "Workspace: ${WORKSPACE_PATH}"
        log "Modelo default: ${DEFAULT_MODEL:-opencode-go/deepseek-v4-flash}"
    fi
    
    create_dirs
    install_agents
    install_configs
    install_skills
    init_memory
    init_diary
    install_pipeline
    verify_installation
    verify_opencode_binary    # 🆕 Verificación del binario opencode
    show_summary

    # ─── Crear archivo de finalización para AGENTS.md ───
    echo "done" > "/tmp/suite-builder-complete"
}

main "$@"

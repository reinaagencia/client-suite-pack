# 📓 Diario — Client Suite Pack

> **Iniciado:** 2026-07-05
> **Propósito:** Paquete de instalación y despliegue de la suite de agentes OpenCode para clientes
> **Repositorio:** `~/Dev/client-suite-pack/`

---

## 🌱 Sesión 1 — 5 Julio 2026

### Commit: `45f605d` — feat: v2.0 — Superinteligencia Continua + Memoria Multi-Sesión

### Contexto

Este proyecto nace de la necesidad de empaquetar la suite de agentes OpenCode (enjambre 4.0) para que los clientes puedan instalarla y usarla en sus propios equipos. La v1.0 existía pero tenía **3 problemas críticos** identificados tras un primer despliegue real en un cliente:

1. **No incluía superinteligencia**: faltaban las skills `moa-intelligence-amplifier`, `auto-superinteligencia-continua`, `aprendizaje-refuerzo` y `knowledge-acquisition-engine`. El cliente tenía agentes funcionales pero sin capacidad de auto-mejora.

2. **No tenía memoria de sesiones**: el cliente no podía retomar proyectos donde los dejó. No existían `reinicio-memoria`, `conversation-saver`, ni la infraestructura `memoria-sessions/`.

3. **No tenía diario de proyecto**: no se creaba automáticamente un diario para registrar avances.

### Problemas reportados por Isa (feedback directo)

> *"La instalación del cliente no incluía la creación ni el manejo de los diarios de los proyectos ni la memoria de reinicio, que es clave para el óptimo funcionamiento de la suite."*
>
> *"No estoy seguro de si el pack de instalación y despliegue de la suite hace que los agentes del cliente también tengan la arquitectura de superinteligencia, autoaprendizaje y aprendizaje continuo que tiene la nuestra."*

### Solución implementada

Se realizó una auditoría completa del pack vs el enjambre original, identificando todas las brechas:

**Skills faltantes identificadas y copiadas (10):**
- Core: `reinicio-memoria`, `conversation-saver`
- Superinteligencia (nueva categoría): `moa-intelligence-amplifier`, `auto-superinteligencia-continua`, `aprendizaje-refuerzo`, `knowledge-acquisition-engine`
- Desarrollo: `code-review-checklist`, `deployment-checklist`, `langgraph-unified-pattern`, `ecosistema-digital`, `knowledge-tagging-std`

**Infraestructura de memoria creada:**
- `template/memoria/` con 4 archivos: `memoria-reinicio.md`, `session-actual.md`, `MEMORIA-TEMPLATE.md`, `memoria-sessions-schema.json`
- `template/diario/` con plantilla de diario de proyecto

**Agentes redefinidos:**
- Se eliminaron `lanzador` y `trader` del pack (tendrán sus propios packs individuales)
- Quedan 11 agentes: 1 orquestador + 5 desarrollo + 2 operaciones + 3 especializados
- Templates actualizados con referencias a superinteligencia y memoria

**builder.sh mejorado (v2.0):**
- De 8 a 10 fases
- Nueva FASE 7: `init_memory()` — crea `memoria-sessions/`, `memoria-reinicio.md`, `index.json`
- Nueva FASE 8: `init_diary()` — crea `diario-construccion.md` en el workspace
- FASE 9 (verificación): ahora verifica memoria y cuenta 11 agentes
- FASE 10 (resumen): muestra información de superinteligencia y memoria

**Documentación actualizada:**
- `SUITE.md` — nueva sección de superinteligencia, memoria, pipeline mejorado
- `SKILLS.md` — catálogo completo con 31 skills organizadas en 5 categorías
- `CONFIGURATION.md` — pasos de memoria + superinteligencia
- `AGENTS.md` — 11 agentes + skills destacadas

### Archivos modificados/creados

| Archivo | Cambio |
|---------|--------|
| `builder.sh` | 613→~800 líneas. 10 fases, init_memory, init_diary |
| `SUITE.md` | Reescribito: 11 agentes, superinteligencia, memoria |
| `SKILLS.md` | Reescribito: 31 skills en 5 categorías |
| `CONFIGURATION.md` | Actualizado: memoria, superinteligencia, 11 agentes |
| `AGENTS.md` | Actualizado: 11 agentes, skills v2.0 |
| `suite-config.json` | Post-instalación actualizado |
| `template/agents/{{ORQUESTADOR}}.md` | Superinteligencia + MoA + RL + memoria + auto-save |
| `template/agents/estratega, auditor, etc` | Skills mejoradas en cada template |
| `template/memoria/` | 4 archivos nuevos (infraestructura de sesiones) |
| `template/diario/` | 1 archivo nuevo (plantilla de diario) |
| `skills/` | 10 skills nuevas copiadas del enjambre original |

### Pendientes post-sesión

- [ ] Probar `bash builder.sh` con un cliente de prueba (entorno limpio)
- [ ] Corregir bugs si los hay
- [ ] Configurar remote de git (GitHub) para push
- [ ] Crear pack individual de trader
- [ ] Crear pack individual de lanzador

### Notas técnicas

- El builder.sh tiene sintaxis verificada (`bash -n` pasa OK)
- Todos los templates de agente tienen placeholders `{{...}}` que el builder reemplaza
- Las skills se copian completas con sus subdirectorios (training, templates)
- El sistema de memoria está diseñado para multi-ventana: cada ventana de OpenCode puede tener su propia sesión activa

---

## 🚀 Sesión 2 — 13 Julio 2026

### Commit: `5c47930` → `0498961` — Operación Auto-Rediseño Cuántico

### Contexto

Se completó la **Operación Auto-Rediseño Cuántico** del enjambre, implementando 3 mejoras estructurales en el pipeline agent-swarm. Era crítico integrar estas mejoras en el Client Suite Pack para que los clientes también se beneficien.

### Cambios realizados en el pack

**builder.sh actualizado a v2.1 (11 fases):**
- Nueva **FASE 9: `install_pipeline()`** — instala el pipeline agent-swarm completo (git clone o copia local)
- Crea alias `enjambre` en `.zshrc` para acceso rápido
- Verifica componentes MoA, Bash-Native y memoria en línea
- Versión bump: `2.0.0` → `2.1.0`

**SUITE.md actualizado:**
- Nueva sección "Pipeline de Desarrollo v2.1 Turbo" con MoA, Bash-Native, memoria en línea
- Tabla de "Novedades v2.1" con impacto medido
- Versión bump

**Templates de agentes mejorados:**
- `arquitecto.md`: documenta el MoA Ensemble (3 proposers + aggregator Pro)
- `programador.md`: documenta el Bash-Native pytest loop + memoria en línea
- `{{ORQUESTADOR}}.md`: description actualizada con capacidades v2.1

**Documentación:**
- `SKILLS.md` y `SUITE.md` actualizados con nuevas capacidades

### Lo que NO cambió
- No se agregaron nuevas skills (las 31 existentes ya cubren todo)
- No se agregaron nuevos agentes (siguen siendo 11)

### Pendientes
- [x] Probar `bash builder.sh` de extremo a extremo con cliente real (Sebastián)
- [x] Pipeline agent-swarm instalado vía git clone correctamente
- [ ] Verificar que los alias y paths funcionan en macOS

### Archivos modificados/creados
| Archivo | Cambio |
|---------|--------|
| `builder.sh` | Nueva FASE 9 (install_pipeline), bump v2.1, verificación de componentes |
| `SUITE.md` | Pipeline v2.1 Turbo, novedades, bump versión |
| `template/agents/arquitecto.md` | Documentación MoA Ensemble |
| `template/agents/programador.md` | Documentación Bash-Native + memoria en línea |
| `template/agents/{{ORQUESTADOR}}.md` | Description v2.1 |
| `diario.md` | Esta entrada |

---

## 🐛 Sesión 3 — 16 Julio 2026 — Fix instalación Sebastián

### Commits: `8142537` — Fix opencode.jsonc

### Contexto

Sebastián (SebasMezu01) instaló la suite desde el ZIP y al ejecutar `opencode` recibió:

```
Configuration is invalid at C:\Users\sebas\.config\opencode\opencode.jsonc
↳ Unrecognized key: //
```

### Causa raíz

El archivo `template/opencode.jsonc` contenía una pseudo-clave `"//"` usada como comentario JSON:

```json
"//": "Ver CONFIGURATION.md para guía de configuración de cada MCP server"
```

OpenCode no reconoce `//` como clave válida en su schema, lo que hace fallar la validación del archivo de configuración.

### Fix aplicado
1. Eliminada la línea `"//"` del template (causaba el error)
2. Eliminada coma colgante (trailing comma) que quedó tras la eliminación
3. Commit + push a `origin/master`
4. Template validado con `python3 -c "import json"` — JSON correcto ✅

### Lección aprendida
No usar pseudo-comentarios con claves no estándar (`"//"`, `"_notes"`) en archivos de configuración de OpenCode. El validador JSON del cliente rechaza cualquier clave no reconocida por el schema.

### Pendientes
- [x] Re-empaquetar el ZIP (`client-suite-pack.zip`) — ✅ hecho
- [x] Notificar a Sebastián que edite manualmente su `opencode.jsonc` — ✅ PowerShell command dado

---

## 🚀 Sesión 4 — 17 Julio 2026 — v2.2.0: Upgrade Mode + Lecciones Sebastián

### Commits: *(pendiente)*

### Contexto

Sebastián completó la instalación exitosamente. Durante el proceso surgieron varios incidentes que sirvieron como lecciones para mejorar el pack instalador:

### Lecciones aprendidas (de la instalación de Sebastián)

| # | Problema | Solución aplicada en v2.2 |
|---|---|---|
| 1 | `opencode.jsonc` con llave `"//"` inválida | Template corregido + fix validación JSON |
| 2 | PowerShell execution policy bloquea scripts `.ps1` | Nuevo `check_windows_powershell()` en install.sh |
| 3 | `opencode.exe` corrupto (>0 KB), comando falla | Nueva `verify_opencode_binary()` post-instalación |
| 4 | Cliente con instalación previa (Javi Arce) | Nuevo modo `--upgrade` con detección + respaldo |
| 5 | Cliente no sabe qué responder en preguntas del builder | Mejores prompts y detección de entorno |
| 6 | Error de sintaxis npm (faltó package name) | Mejores mensajes de error en verify |

### Mejoras implementadas en v2.2

**builder.sh:**
- Nuevo flag `--upgrade` / `--update` para actualizar instalaciones existentes
- Nueva función `detect_existing()` — busca instalaciones previas
- Nueva función `backup_existing()` — respaldo completo (agents, configs, skills, memoria)
- Nueva función `read_existing_config()` — lee `suite-config.json` de instalación anterior
- Nueva función `verify_opencode_binary()` — verifica binario post-instalación
- `init_memory()` — ahora preserva sesiones existentes en modo upgrade
- Fase expandida de 11 a 12 fases (con verify_opencode_binary)

**install.sh:**
- Nueva función `is_windows()` — detección multiplataforma
- Nueva función `check_windows_powershell()` — advierte sobre execution policy
- Nueva función `detect_existing_suite()` — detecta suite v1 previa
- Nueva función `verify_opencode_postinstall()` — verifica opencode funcional
- Ahora pasa `--upgrade` al builder automáticamente si detecta instalación previa
- Bump v2.1.0 → v2.2.0

**SUITE.md:**
- Tabla de novedades v2.2 añadida

**ZIP:**
- Re-empaquetado `client-suite-pack.zip` con todo incluido

### Archivos modificados

| Archivo | Cambios |
|---------|---------|
| `builder.sh` | +250 líneas: upgrade mode, detección, backup, verify binary |
| `install.sh` | +90 líneas: Windows checks, detección suite, verify post-install, bump v2.2 |
| `SUITE.md` | Novedades v2.2 |
| `template/opencode.jsonc` | (ya corregido en Sesión 3) |
| `diario.md` | Esta entrada |

### Pendientes
- [ ] Instalar v2.2 en equipo de Javi Arce (modo upgrade desde v1)

---

## 🐛 Sesión 4b — 17 Julio 2026 — Hotfix: WINDIR unbound variable

### Commit: `48a3d39`

### Contexto
Al ejecutar `bash install.sh` en el MacBook Air de Javi, el script falló inmediatamente con:
```
install.sh: line 153: WINDIR: unbound variable
```

### Causa raíz
La función `is_windows()` recién agregada usaba `$WINDIR` y `$OS` (variables de Windows) sin valor por defecto. El script tiene `set -u` habilitado, que causa que bash termine con error cuando se referencia una variable no definida.

### Fix aplicado
```bash
# Antes (roto en macOS/Linux):
[ -n "$WINDIR" ] || echo "$OS" | grep -qi "windows"

# Después (funciona en todos lados):
[ -n "${WINDIR:-}" ] || echo "${OS:-}" | grep -qi "windows"
```

### Archivos modificados
| Archivo | Línea | Cambio |
|---------|-------|--------|
| `install.sh` | 153 | `$WINDIR` → `${WINDIR:-}`, `$OS` → `${OS:-}` |
| `builder.sh` | 214 | Mismo fix en `verify_opencode_binary()` |

### Verificación
✅ `bash -n install.sh` — sintaxis OK
✅ `bash -n builder.sh` — sintaxis OK
✅ `is_windows()` simulado devuelve `false` en macOS
✅ ZIP re-empaquetado con el fix

### Lección aprendida
⚠️ **Siempre** usar `${VAR:-}` en lugar de `$VAR` en scripts con `set -u` cuando la variable podría no existir en todos los SO.

---

## 🐛 Sesión 4c — 17 Julio 2026 — Hotfix: model null en agents

### Commit: `1bec002`

### Contexto
Después de que el WINDIR fix permitió la instalación, Javi ejecutó `opencode` y recibió:
```
Configuration is invalid at /Users/javiarce/.config/opencode/agent/investigador.md
[✗] Expected string | undefined, got null model
```

### Causa raíz
La función `read_existing_config()` en builder.sh tenía un bug en la línea 136:
```bash
# ANTES (roto):
DEFAULT_MODEL=$(echo "$cfg" | python3 "models" 2>/dev/null || echo "")
```
Esto ejecutaba `python3 "models"` como si fuera un archivo, no como código Python. Siempre fallaba y DEFAULT_MODEL quedaba vacío.

Además, el modelo en el JSON guardado está anidado como `models.default`, no como `default_model` plano.

Al quedar DEFAULT_MODEL="" el sed hacía: `s|{{DEFAULT_MODEL}}||g` → `model: {{DEFAULT_MODEL}}` → `model: ` → YAML interpreta como `null`.

### Fix aplicado
1. Corregida la extracción del modelo: `json.load().get('models',{}).get('default','')`
2. Agregadas las mismas líneas para PRO_MODEL y MULTIMODAL_MODEL
3. Agregados fallbacks: si modelo vacío → valores por defecto (`deepseek-v4-flash`, etc.)

### Verificación
✅ Extracción de modelo probada con Python directo
✅ Fallbacks asignados correctamente
✅ ZIP re-empaquetado

---

## 🧹 Sesión 4d — 17 Julio 2026 — --clean mode + fix doble pregunta

### Commit: `57691ea`

### Contexto
Javi encontró el mismo `model: null` en `tester.md`. En lugar de arreglar archivo por archivo, mejor: **opción de limpieza total** que borre todo e instale desde cero.

### Cambios implementados

**builder.sh:**
- Nuevo flag `--clean` / `--fresh`
- Nueva función `clean_installation()` que elimina:
  - Todos los agentes en `~/.config/opencode/agent/*.md`
  - `opencode.json` y `opencode.jsonc`
  - Respaldos `.bak`
  - `suite-config.json`
  - `memoria-reinicio.md`
  - Skills (con confirmación — pregunta si borrar)
  - `session-actual.md` (se recrea automáticamente)
- **Preserva** `memoria-sessions/` (datos del cliente)
- La detección existente ya no pregunta si vino flag explícito

**install.sh:**
- Opción 2 "Instalación limpia" ahora pasa `--clean` al builder
- Eliminada redundancia: ya no pregunta dos veces

### Flujo corregido

| Opción | Antes (roto) | Ahora |
|--------|-------------|-------|
| 1 (Actualizar) | `--upgrade` → ok | `--upgrade` → ok |
| 2 (Limpiar) | sin flag → builder preguntaba otra vez | `--clean` → borra todo e instala |
| 3 (Cancelar) | exit | exit |

### Archivos modificados
| Archivo | Cambio |
|---------|--------|
| `builder.sh` | +clean_installation(), +--clean flag, detect_existing no pregunta con flag |
| `install.sh` | IS_CLEAN flag, pasa --clean al builder, mensajes actualizados |

### Verificación
✅ `bash -n install.sh` — sintaxis OK
✅ `bash -n builder.sh` — sintaxis OK
✅ ZIP re-empaquetado

---

## 🚀 Sesión 5 — 23 Julio 2026 — Pack Lanzador v1.0

### Commit: `e0ac6e3`

### Contexto
Después de instalar la suite v2.2 en el equipo de Javi (con --clean mode), se necesita añadir el agente **Lanzador** con su base de conocimiento de lanzamientos digitales.

### Qué se creó

**template/agents/lanzador.md** (201 líneas):
- Agente especializado en lanzamientos digitales
- Domina 4 frameworks: PLF (Jeff Walker), TPL (Álvaro Luque), TWM (Santi Padilla), Funnel Mindset (Russell Brunson)
- Capacidades: estrategia de lanzamiento, copywriting, gestión de tráfico, optimización
- Deliverables: plan de lanzamiento, secuencias de email, guión de sales page, anuncios
- Placeholders: `{{DEFAULT_MODEL}}`, `{{CLIENT_NAME}}`

**skills/domain/lanzamientos-digitales/SKILL.md** (770 líneas):
- 9 secciones con conocimiento integral
- Frameworks detallados (PLF, TPL, TWM, Funnel Mindset)
- Estructura de embudos (lead magnet, webinar, challenge, evergreen)
- Copywriting: fórmulas de headlines, estructura de sales page, guiones de email
- Secuencias completas (prelanzamiento, venta, post-compra, no-compradores)
- Tráfico pagado y orgánico con benchmarks
- Métricas y KPIs con fórmulas
- Plataformas y herramientas (Hotmart, Kiwify, Kajabi, etc.)
- Checklists (pre, durante, post lanzamiento)
- Glosario de 35+ términos

**scripts/install-lanzador.sh** (210 líneas):
- Instalador autónomo para añadir el pack a una suite existente
- Detecta suite-config.json y reemplaza placeholders
- Verifica que no queden `{{...}}` sin reemplazar

### Archivos creados
| Archivo | Líneas |
|---------|--------|
| `template/agents/lanzador.md` | 201 |
| `skills/domain/lanzamientos-digitales/SKILL.md` | 770 |
| `scripts/install-lanzador.sh` | 210 |
| `SUITE.md` (modificado) | Pack Lanzador marcado como disponible |

### Pendientes
- [ ] **Instalar suite base v2.2 en Javi** → `bash install.sh` → opción 2 (limpia)
- [ ] **Instalar Pack Lanzador en Javi** → `bash scripts/install-lanzador.sh`

# 🏗️ Suite de Agentes OpenCode para Clientes

> **Versión:** 2.2 | **Builder:** builder.sh (12 fases) | **Agentes:** 11 | **Skills:** 31 | **Pipeline:** agent-swarm con MoA + Bash-Native | **Upgrade:** detección + respaldo automático

---

## ¿Qué es esta Suite?

Es un **enjambre de desarrollo** con **superinteligencia continua**: 11 agentes de IA que trabajan en equipo dentro de OpenCode para potenciar el desarrollo de software, operaciones y más. Cada agente tiene un rol específico, puede delegar tareas a otros, y el sistema completo se **auto-mejora con cada uso**.

---

## 🧬 Arquitectura General con Superinteligencia

```
                     ┌─────────────────────────────────────┐
                     │       SUPERINTELIGENCIA v2.0         │
                     │  (MoA + Aprendizaje por Refuerzo)    │
                     └─────────────────────────────────────┘
                                    │
Usuario → {{ORQUESTADOR}} (orquestador)
               │
               ├── 🎯 Desarrollo
               │   ├── estratega → Planifica tareas complejas (MoA)
               │   ├── investigador → Busca conocimiento previo
               │   ├── arquitecto → Diseña sistemas
               │   ├── programador → Escribe y verifica código
               │   └── tester → QA y detección de errores
               │
               ├── 🚀 Operaciones
               │   ├── desplegador → DevOps, deploy a producción
               │   └── instalador → Bootstrap de entornos
               │
               ├── 🌟 Especializados
               │   ├── auditor → Supervisión crítica (modelo premium)
               │   ├── visor-multimodal → Análisis visual/auditivo
               │   └── transcriptor → Transcripción audio/video
               │
               ├── 🧠 Memoria (reinicio-memoria)
               │   └── Sesiones persistentes + auto-save
               │
               └── 📚 Skills (28+ skills multipropósito)
                   ├── Core 🛡️
                   ├── Superinteligencia 🧬 ← NUEVO
                   ├── Desarrollo 💻
                   ├── Herramientas 🔧
                   └── Dominio 🏢
```

---

## 🤖 Los 11 Agentes

### Orquestador Principal (`{{ORQUESTADOR}}`)

El cerebro de la operación. Recibe las peticiones del usuario, las analiza y decide qué agente o combinación necesita.

**Modelo:** `{{DEFAULT_MODEL}}`
**Rol:** Orquestar, delegar, coordinar y supervisar
**Capacidades:**
- Delegar tareas a 10 subagentes mediante `task()`
- Ejecutar el pipeline de desarrollo completo con superinteligencia
- Gestionar memoria de sesiones con skill `reinicio-memoria` (auto-save)
- Activar MoA, aprendizaje por refuerzo y auto-mejora continua
- Orquestar agentes especializados (visor, transcriptor)

---

### 🏗️ Desarrollo

#### Estratega (`estratega`)
Planificador maestro con **MoA (Mixture-of-Agents)**. Descompone tareas complejas usando 3 perspectivas (MINIMALISTA, ROBUSTO, ARRIESGADO) y asigna el agente óptimo para cada paso.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** Planificación multi-paso

#### Investigador (`investigador`)
Memoria de largo plazo del sistema. Busca conocimiento previo, proyectos similares y lecciones aprendidas.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** Búsqueda y recuperación de conocimiento

#### Arquitecto (`arquitecto`)
Diseñador de sistemas. Convierte requerimientos en blueprints JSON detallados con 3 enfoques: MINIMALISTA, ROBUSTO, TESTING-FIRST.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** Diseño de arquitectura de software

#### Programador (`programador`)
Genera código limpio con type hints, verifica sintaxis localmente y auto-corrige errores.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** Generación de código con verificación

#### Tester (`tester`)
QA con herramientas reales + análisis LLM en paralelo. Clasifica errores en 6 categorías con causa raíz y fix concreto.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** QA y testing

---

### 🚀 Operaciones

#### Desplegador (`desplegador`)
DevOps del equipo. Deploy a Railway, Docker, health check post-deploy, verificación pre-deploy.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** DevOps y despliegues

#### Instalador (`instalador`)
Bootstrap de proyectos desde cero. Configura entornos, dependencias y .env.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** Bootstrap y configuración

---

### 🌟 Especializados

#### Auditor (`auditor`) ⭐
Supervisor de precisión con **modelo premium**. Solo interviene en puntos críticos. Gate 1 (viabilidad), Gate 2 (arquitectura), Gate 3 (desbloqueo de loops).

**Modelo:** `{{PRO_MODEL}}` (premium) | **Rol:** Validación crítica

#### Visor Multimodal (`visor-multimodal`)
Traductor visual/auditivo. Analiza imágenes, capturas, videos, PDFs visuales con protocolo de 3 pasadas.

**Modelo:** `{{MULTIMODAL_MODEL}}` | **Rol:** Análisis visual y auditivo

#### Transcriptor (`transcriptor`)
Transcripción de audio/video a texto con Whisper local. 100% gratuito, privado, sin límites de tamaño.

**Modelo:** `{{DEFAULT_MODEL}}` | **Rol:** Transcripción audio/video

---

## 🧬 Superinteligencia Continua

La suite incluye un **sistema auto-mejorante de 4 capas** que la hace más inteligente con cada uso:

| Capa | Skill | Qué hace |
|------|-------|----------|
| **MoA** 🎯 | `moa-intelligence-amplifier` | Razonamiento multi-vía con 3 perspectivas + consenso |
| **Auto-mejora** 🔄 | `auto-superinteligencia-continua` | Reflexión verbal, self-play, benchmark automático |
| **Aprendizaje por Refuerzo** 📈 | `aprendizaje-refuerzo` | Post-ejecución: extrae lecciones y mejora la siguiente |
| **Adquisición de Conocimiento** 📚 | `knowledge-acquisition-engine` | Investigación multi-fuente + síntesis + curriculum |

**El ciclo:** Cada tarea → genera lecciones → mejora las siguientes → el sistema se vuelve más inteligente solo.

---

## 🧠 Memoria y Continuidad

La suite incluye un **sistema multi-sesión** para nunca perder el progreso:

| Componente | Propósito |
|------------|-----------|
| `reinicio-memoria` (skill) | Gestiona múltiples proyectos simultáneos con auto-save |
| `conversation-saver` (skill) | Guarda resúmenes completos en diario + sesiones |
| `~/.agents/memoria-reinicio.md` | Tracker multi-sesión (se regenera automáticamente) |
| `~/.agents/memoria-sessions/` | Archivos individuales por proyecto |
| `diario-construccion.md` | Diario del proyecto en el workspace |

**Flujo:** Trabajas → auto-save al final de cada respuesta → al reiniciar dices "continuar" → retomas exactamente donde lo dejaste.

---

## 🔄 Pipeline de Desarrollo (v2.1 Turbo)

```
Usuario → {{ORQUESTADOR}}
               │
      ┌────────┴────────┐
      ▼                  ▼
   Tarea simple     Tarea compleja
      │                  │
      ▼                  ▼
   task() directo    Pipeline agent-swarm con INTELIGENCIA x5:
   a un agente       1. [MoA] 3 arquitectos en paralelo
                       │      (MINIMALISTA, ROBUSTO, TESTING-FIRST)
                       │      + Aggregator Pro elige el mejor
                       │      + Lite mode si está en plan free
                      2. programador → genera + ejecuta pytest local
                       │      [Bash-Native] auto-corrección instantánea
                      3. tester → QA (pytest real + análisis LLM)
                      4. [Si bloqueos] auditor (Pro) → desbloquea
                      5. extractor → guarda en memoria vectorial
                      6. reflexión → APRENDE + memoria episódica
                       │      [Memoria en línea] heurísticas → próximo ciclo
                      7. auto-save en memoria de sesiones
```

### 🆕 Novedades v2.2

| Mejora | Descripción | Impacto |
|--------|-------------|---------|
| **Modo Upgrade** | Detecta instalación previa, respalda configs, actualiza en limpio | Transición sin pérdida de datos |
| **Respaldo automático** | `backup-{timestamp}/` con agents, configs, skills, memoria | Rollback manual posible |
| **Verificación post-instalación** | Verifica que opencode binario existe y responde | Detecta binarios corruptos |
| **Compatibilidad Windows** | Detecta PowerShell execution policy, guía al usuario | Primer `opencode` siempre funciona |
| **Fix opencode.jsonc** | Eliminada llave `//` que causaba `Unrecognized key` | Error de configuración eliminado |

### 🆕 Novedades v2.1

| Mejora | Descripción | Impacto |
|--------|-------------|---------|
| **MoA Intelligence Amplifier** | 3 proposers paralelos + aggregator Pro | +40% calidad decisiones arquitectónicas |
| **Bash-Native pytest** | Programador ejecuta tests locales y se auto-corrige | -40% iteraciones Programador↔Tester |
| **Memoria episódica en línea** | Heurísticas aprendidas se inyectan en el prompt del programador | -30% errores reintroducidos |
| **Modos FULL/LITE/LOCAL** | MoA se adapta: Pro (pago), auto-score (free), Ollama (local) | $0 extra en modo eficiente |
| **Soporte modelos locales** | Ollama: Gemma 4, Qwen3, DeepSeek R1 locales | Privacidad total, $0 |

### Ejemplos de flujo

| Si dices... | El orquestador hace... |
|-------------|------------------------|
| "Crea una API REST en Flask" | Pipeline completo con superinteligencia |
| "Analiza esta captura de pantalla" | task() al visor-multimodal |
| "Transcribe este audio" | task() al transcriptor |
| "Continúa con el proyecto anterior" | Carga reinicio-memoria → muestra sesiones |
| "Aprende a usar Docker" | Carga autoaprendizaje → investiga → entrena |

---

## 📚 Skills Incluidas (28+)

| Categoría | Skills |
|-----------|--------|
| **Core** 🛡️ | model-router, find-skills, autoaprendizaje, **reinicio-memoria**, **conversation-saver** |
| **Superinteligencia** 🧬 | **moa-intelligence-amplifier**, **auto-superinteligencia-continua**, **aprendizaje-refuerzo**, **knowledge-acquisition-engine** |
| **Desarrollo** 💻 | mcp-server-blueprint, ecosystem-python-std, testing-checklist, cli-tool-pattern, api-integration-pattern, data-pipeline-pattern, error-handling-std, **code-review-checklist**, **deployment-checklist**, **langgraph-unified-pattern** |
| **Herramientas** 🔧 | visor-multimodal (delegación), ffmpeg-video-editing, playwright-web-scraping, langgraph-advanced, document-ocr-reader |
| **Dominio** 🏢 | senior-accounting-assistant, organizational-culture, instagram-cx-best-practices, whatsapp-agent |

Ver `SKILLS.md` para el catálogo completo.

---

## 🚀 Próximos Pasos

1. ✅ Ejecuta `bash builder.sh` para instalar la suite (10 fases automatizadas)
2. ⚡ Configura API keys y cuentas (ver `CONFIGURATION.md`)
3. 🎯 Abre OpenCode y empieza a delegar tareas a tus agentes
4. 📚 Explora las skills para ampliar capacidades
5. 🔄 El sistema aprenderá y mejorará con cada uso

---

## 📦 Paquetes Complementarios

| Pack | Contenido | Disponible |
|------|-----------|------------|
| **Client Suite Pack** (este) | 11 agentes: desarrollo + ops + especializados + **Lanzador** | ✅ Ahora |
| **Lanzador Pack** | Agente lanzador + skill lanzamientos-digitales (770 líneas de conocimiento) | ✅ Ahora — `bash scripts/install-lanzador.sh` |
| **Trader Pack** | Agente trader + análisis financiero | Próximamente |

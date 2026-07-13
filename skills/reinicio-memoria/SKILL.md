# Skill: reinicio-memoria (v2 — Multi-Sesión)

> **Versión:** 2.0
> **Actualizada:** 30 de junio de 2026
> **Propósito:** Gestión multi-sesión de memoria de reinicio. Soporta N proyectos/sesiones simultáneas sin que una sobrescriba a otra.

---

## ⚠️ ¿Cuándo se activa esta skill?

- **Siempre** que `~/.agents/memoria-reinicio.md` exista → Smith DEBE cargar esta skill
- **PERO** el protocolo completo solo se ejecuta si el usuario menciona **"continuar"**, **"seguir"**, **"retomar"**, **"reanudar"** o similar
- Si el usuario no menciona continuar → Smith ignora la memoria y opera con proyecto nuevo

---

## 📁 Estructura de archivos

| Archivo | Rol |
|---------|-----|
| `~/.agents/memoria-reinicio.md` | **Tracker multi-sesión** — resumen de TODAS las sesiones abiertas. Es el archivo centinela que detona la skill. |
| `~/.agents/memoria-sessions/index.json` | **Índice maestro** — metadatos de todas las sesiones (id, proyecto, prioridad, estado, tareas) |
| `~/.agents/memoria-sessions/MEMORIA-{ID}.md` | **Sesión individual** — plan detallado, checklist, commits, estado de UN proyecto |
| `~/.agents/memoria-sessions/session-actual.md` | **Sesión activa** — contiene solo el ID de la sesión que se está trabajando en esta ventana |

---

## 🔄 Protocolo completo (5 fases)

### FASE 0: Activación condicional

```javascript
// Se ejecuta siempre que memoria-reinicio.md exista
FASE_0: {
  1. Cargar skill reinicio-memoria ✅ (automático al detectar el archivo)
  2. Leer la instrucción del usuario
  3. ANALIZAR: ¿La instrucción contiene "continuar", "seguir", "retomar", "reanudar", "continuemos", "retomamos"?
     ├── SÍ → EJECUTAR FASE_1 (mostrar sesiones pendientes)
     └── NO → 
         ├── ¿Es un proyecto/tarea NUEVA? 
         │   ├── Verificar en index.json si existe sesión relacionada por nombre
         │   ├── ¿Está relacionada? → Preguntar al usuario: "¿Quieres continuar la sesión existente o crear una nueva?"
         │   └── No relacionada → EJECUTAR FASE_2 (crear nueva sesión automáticamente)
         └── Continuar normalmente con la tarea (la FASE_2 creará la sesión en background)
}
```

### FASE 1: Mostrar sesiones pendientes y seleccionar

```
1. Leer ~/.agents/memoria-sessions/index.json
2. Filtrar sesiones con estado "pendiente" o "en_curso"
3. Mostrar al usuario:

   ┌─────────────────────────────────────────────────────────────┐
   │  🧠 Sesiones con trabajo pendiente:                         │
   │                                                             │
   │  [1] 🔴 CRÍTICO — QueenChat (queenchat-agent)              │
   │      Tareas pendientes: 4  |  Última act: 2026-06-03       │
   │                                                             │
   │  [2] 🟡 ALTA   — Agent Swarm (agent-swarm)                 │
   │      Tareas pendientes: 2  |  Última act: 2026-06-03       │
   │                                                             │
   │  [3] 🟢 MEDIA  — Gicela Ospina (gicela-ospina)             │
   │      Tareas pendientes: 5  |  Última act: 2026-06-30       │
   │                                                             │
   │  ¿Cuál deseas continuar? (1-3 o 'ninguna')                  │
   └─────────────────────────────────────────────────────────────┘

4. Al seleccionar una:
   a. Leer ~/.agents/memoria-sessions/MEMORIA-{ID}.md
   b. Cargar el plan de trabajo en contexto
   c. Actualizar session-actual.md con el ID seleccionado
   d. Iniciar ejecución del plan
   e. Marcar estado como "en_curso" en index.json
```

### FASE 2: Crear nueva sesión

```
1. Generar ID único: MEMORIA-{PROYECTO_EN_MAYUSCULAS}
   - Ej: proyecto "gicela-ospina" → MEMORIA-GICELA-OSPINA
   - Ej: proyecto "queenchat-agent" → MEMORIA-QC (si ya existe, usar variante)

2. Crear archivo ~/.agents/memoria-sessions/MEMORIA-{ID}.md:

   # [PRIORIDAD] MEMORIA-{ID} — {Nombre del Proyecto}
   
   **Proyecto**: {ruta o nombre}
   **Prioridad**: 🟢 MEDIA (default, ajustable)
   **Creada**: {fecha}
   **Última actividad**: {fecha}
   **Estado**: en_curso
   
   ---
   
   ## 📋 Resumen General
   
   {Breve descripción del proyecto basada en la conversación}
   
   ---
   
   ## ✅ Tareas Completadas
   
   - [x] {primeras tareas que ya se hicieron en esta sesión}
   
   ## 🔲 Plan de Trabajo
   
   - [ ] {tarea 1 detectada}
   - [ ] {tarea 2 detectada}
   
   ---
   
   ## 📁 Archivos Clave
   
   | Archivo | Propósito |
   |---------|-----------|
   
   ---
   
   ## ⚙️ Comandos útiles
   
   ```
   {comandos relevantes al proyecto}
   ```

3. Agregar entrada en index.json:
   ```json
   {
     "id": "MEMORIA-{ID}",
     "label": "{Nombre del Proyecto}",
     "prioridad": "🟢 MEDIA",
     "proyecto": "{nombre-del-proyecto}",
     "tareas": {número de tareas},
     "ultima_actividad": "{fecha}",
     "estado": "en_curso",
     "owner": "enjambre-dev"
   }
   ```

4. Actualizar session-actual.md con el ID
5. Regenerar memoria-reinicio.md (FASE 4)
```

### FASE 3: Auto-Save (OBLIGATORIO — cada iteración)

**AL FINAL DE CADA RESPUESTA**, Smith DEBE ejecutar auto-save:

```
1. ¿Hay una sesión activa? (leer session-actual.md)
   ├── No → Saltar auto-save (no hay nada que guardar)
   └── Sí → Continuar

2. Actualizar ~/.agents/memoria-sessions/MEMORIA-{ID}.md:
   - Estado actual del proyecto
   - Checklist: marcar tareas completadas como [x]
   - Agregar nuevas tareas si se descubrieron
   - Último commit (si hubo) con hash y mensaje
   - Actualizar fecha de última actividad

3. Actualizar ~/.agents/memoria-sessions/index.json:
   - last_updated → timestamp actual
   - tareas → recuento actualizado
   - estado → "en_curso" si hay actividad, "pendiente" si se pausó

4. Regenerar ~/.agents/memoria-reinicio.md (FASE 4)
```

### FASE 4: Regenerar tracker multi-sesión

Cada vez que se modifica una sesión, se regenera `~/.agents/memoria-reinicio.md`:

```
1. Leer index.json completo
2. Generar archivo con este formato:

   # 🧠 Memoria de Reinicio — Sesiones Activas
   
   > Generado: {timestamp}
   > Este archivo se actualiza automáticamente en cada iteración.
   > Gestiona {N} sesiones independientes — cada una en su propio archivo.
   
   ## 📋 Sesiones abiertas
   
   | # | ID | Proyecto | Prioridad | Pendientes | Estado | Última Act. |
   |---|----|----------|-----------|------------|--------|-------------|
   | 1 | MEMORIA-QC | QueenChat Agent | 🔴 CRÍTICO | 4 | pendiente | 2026-06-03 |
   | 2 | MEMORIA-ENJAMBRE | Agent Swarm | 🟡 ALTA | 2 | pendiente | 2026-06-03 |
   | 3 | MEMORIA-GICELA | Gicela Ospina | 🟢 MEDIA | 5 | en_curso | 2026-06-30 |
   
   ## ▶️ Sesión activa (esta ventana)
   
   - **ID:** {session-actual}
   - **Proyecto:** {...}
   - **Último commit:** {hash} — {mensaje}
   - **Archivo:** ~/.agents/memoria-sessions/MEMORIA-{ID}.md
   
   ## 💡 Para continuar una sesión
   
   En tu próxima sesión, di "continuemos con [proyecto]" o simplemente "continuar"
   para que Smith te muestre las sesiones pendientes.

3. Sobrescribir ~/.agents/memoria-reinicio.md
```

### FASE 5: Finalización

```
1. Cuando se completa una sesión (checklist completado):
   a. Marcar estado como "completada" en index.json
   b. Preguntar al usuario si desea continuar otra sesión pendiente
   c. Si sí → volver a FASE 1 (mostrar pendientes)
   d. Si no → actualizar memoria-reinicio.md sin esa sesión

2. Cuando NO hay más sesiones pendientes:
   a. Preguntar al usuario si desea archivar la memoria
   b. Si confirma:
      - Respaldar ~/.agents/memoria-reinicio.md en ~/Dev/agentes-opencode/diario/
      - Mover el archivo a memoria-{fecha}.md
      - Eliminar ~/.agents/memoria-reinicio.md (el centinela)
   c. Si no confirma → dejar todo intacto

3. NOTA: Una sesión completada NO se elimina del índice, solo se marca.
   Se puede reactivar si es necesario.
```

---

## 🪟 Comportamiento multi-ventana

El sistema está diseñado para que N ventanas de OpenCode puedan operar en paralelo:

| Escenario | Qué pasa |
|-----------|----------|
| Ventana A trabaja en "Gicela" y hace auto-save | Solo se actualiza MEMORIA-GICELA.md |
| Ventana B trabaja en "QueenChat" y hace auto-save | Solo se actualiza MEMORIA-QC.md |
| Ventana A se cierra inesperadamente | MEMORIA-GICELA.md tiene el último estado guardado |
| Ventana B abre nueva sesión y dice "continuar" | Ve TODAS las sesiones pendientes, incluyendo Gicela |
| session-actual.md se sobrescribe entre ventanas | Cada ventana apunta a su propia sesión activa. El index.json es la fuente de verdad. |

**Regla de oro**: El index.json es la fuente de verdad. session-actual.md es solo un atajo para la ventana actual. Si hay conflicto, index.json gana.

---

## 📝 Formato estándar de MEMORIA-{ID}.md

Toda sesión individual DEBE seguir esta plantilla:

```markdown
# [PRIORIDAD] MEMORIA-{ID} — {Nombre del Proyecto}

**Proyecto**: {ruta o nombre}
**Prioridad**: {🔴 CRÍTICO | 🟡 ALTA | 🟢 MEDIA}
**Creada**: {fecha}
**Última actividad**: {fecha}
**Estado**: {pendiente | en_curso | completada}

---

## 📋 Resumen General

{2-3 líneas describiendo el proyecto y su estado actual}

---

## ✅ Tareas Completadas

- [x] {tarea completada 1}
- [x] {tarea completada 2}

## 🔲 Plan de Trabajo

- [ ] {tarea pendiente 1}
- [ ] {tarea pendiente 2}

---

## 📁 Archivos Clave

| Archivo | Propósito |
|---------|-----------|

---

## ⚙️ Comandos útiles

```
{comandos}
```
```

---

## 🔗 Integración con Commit-Push Protocol

Cuando se ejecuta el Commit-Push Protocol (descrito en AGENTS.md), en lugar de sobrescribir `memoria-reinicio.md`:

```
En lugar de:
   Actualizar ~/.agents/memoria-reinicio.md  ← ANTIGUO (una sola sesión)

Hacer:
   1. Actualizar ~/.agents/memoria-sessions/MEMORIA-{ID}.md  ← Añadir commit al plan
   2. Actualizar ~/.agents/memoria-sessions/index.json        ← Actualizar metadata
   3. Regenerar ~/.agents/memoria-reinicio.md                 ← FASE 4 (reflejar cambios)
```

---

## 🧪 Verificación rápida

```bash
# Verificar que existe el índice
cat ~/.agents/memoria-sessions/index.json | python3 -m json.tool

# Listar sesiones pendientes
python3 -c "
import json
with open('$HOME/.agents/memoria-sessions/index.json') as f:
    data = json.load(f)
for s in data['sesiones']:
    if s['estado'] in ('pendiente', 'en_curso'):
        print(f\"[{s['prioridad']}] {s['label']} — {s['tareas']} tareas\")
"

# Ver sesión activa
cat ~/.agents/memoria-sessions/session-actual.md
```

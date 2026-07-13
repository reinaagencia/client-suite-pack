# Skill: conversation-saver

# Conversation Saver v2

Save comprehensive conversation summaries to local diary files, restart memories, and optionally to Google NotebookLM. Includes a **pending queue** for sessions where the user prefers to upload to NotebookLM later, with batch upload capability.

## When to Trigger

Activate this skill when the user says ANY of these or similar:
- "guarda la conversación"
- "guarda el avance"
- "save this chat"
- "save progress"
- "guarda esto en el cuaderno"
- "update the notebook"
- "save to notebooklm"
- "haz un resumen y guárdalo"
- "guarda el avance y sube lo pendiente"
- "sube las sesiones pendientes a notebook"
- "sube todo lo que falta"

Also triggered automatically by the **Commit-Push Protocol** (see `AGENTS.md` section ⚠️ Commit-Push Protocol) after every `git commit` + `git push`.

## What Gets Saved

Create a COMPREHENSIVE summary including:
1. **Session metadata**: Date, time, duration, accounts used
2. **Objective**: What the user asked to accomplish
3. **Actions taken**: All major steps, commands, edits, decisions
4. **Results achieved**: What was completed, built, configured
5. **State changes**: Files created/modified, configs changed, new connections
6. **Errors encountered**: What failed and how it was resolved
7. **Lessons learned**: Patterns, insights, gotchas
8. **Current ecosystem state**: What's working, what's pending
9. **Next steps**: Priority-ordered todo for next session

## Output Destinations (New Flow)

```
Summarize → Save to Diary + Memoria → Ask user: "¿Subo a NotebookLM ahora o lo dejo pendiente?"
                                              ├── "Ahora" → Upload to NotebookLM inmediatamente
                                              └── "Después / Pendiente" → Add to pending queue
                                                       └── Later: "sube las sesiones pendientes" → Batch upload all
```

### 1. Local Diary (ALWAYS)
Append the summary to the project's development diary file.

**Determinar el diario correcto** según la tabla del Commit-Push Protocol:

| Proyecto | Ruta del Diario |
|---|---|
| `agentes-opencode/` | `~/Dev/agentes-opencode/diario-construccion-agentes.md` |
| `queenchat-agent/` | `~/Dev/agentes-opencode/diario-construccion-agentes.md` (mismo ecosistema) |
| `agent-swarm/` | `~/Dev/agentes-opencode/diario-construccion-agentes.md` (mismo ecosistema) |
| `agentes-ui/` | `~/Dev/agentes-opencode/diario-construccion-agentes.md` (mismo ecosistema) |
| `domina-tu-closet-evergreen/` | Ver `AGENTS.md` en su raíz |
| Otro proyecto | Buscar `AGENTS.md` en su raíz o usar `~/Dev/<proyecto>/diario.md` |

Format: New section `## Sesión N — [date]` with `### N+1. [Topic]` numbered subsections.

### 2. Memoria de Reinicio (ALWAYS)
Update `~/.agents/memoria-reinicio.md` with the latest session state so the agent can resume after restart.

Use the template from the Commit-Push Protocol:
```markdown
# Memoria de Sesión — [Proyecto]

**Fecha:** [fecha]
**Último commit:** [hash] — [mensaje] (si aplica)
**Estado:** 🟢 Avance guardado

## Último avance
- Propósito: [descripción]
- Archivos/sesiones: [resumen]

## Estado actual
[resumen de qué está funcionando, qué está pendiente]

## Plan de continuación
- [ ] [próximos pasos]

## Sesiones pendientes de NotebookLM
- [ ] Sesión N — [fecha]: [título] (pendiente desde [fecha])
```

### 3. NotebookLM (CONDITIONAL — user decides)
The user chooses whether to upload NOW or LATER. See "User Decision Flow" below.

---

## Pending Queue System

### Queue file
**Location**: `~/.agents/pending-notebooklm.json`
**Format**:
```json
{
  "sessions": [
    {
      "id": "sesion-26",
      "title": "Sesión 26 — 3 junio 2026: Actualización conversation-saver v2",
      "date": "2026-06-03",
      "summary_path": "/tmp/summary-2026-06-03.md",
      "summary_text": "Sesión 26 — ...\n\n## Sesión 26\n\n...",
      "notebook_target": "Agentes OpenCode",
      "added_at": "2026-06-03T15:30:00Z"
    }
  ]
}
```

### Adding to the queue
When user says "después" / "pendiente" / "espera":
1. Save the full summary text in the JSON (embedded, NOT file reference — survives cleanup)
2. Add a clear entry in the queue
3. Confirm to user: "✅ Guardado en diario y memoria local. 📝 **Anotado como pendiente para NotebookLM.** Te aviso cuando quieras subirlo todo junto."

### Batch upload trigger
When user says "sube las sesiones pendientes", "sube todo lo que falta", "sincroniza con notebook":
1. Load the queue
2. For each session in the queue, execute the NotebookLM upload flow (Step 5)
3. Mark each as uploaded (or failed with reason)
4. Summarize results to user:
   ```
   📤 Sincronización completada:
   ✅ Sesión 26 — 3 junio: Subida correctamente
   ✅ Sesión 25 — 2 junio: Subida correctamente
   ❌ Sesión 24 — 1 junio: Falló (Playwright MCP no conectado)
   ```
5. Remove successfully uploaded sessions from queue
6. Keep failed ones for retry

### Checking queue status
When user asks "qué sesiones faltan" or "cómo va la cola":
- Read the queue file
- Show pending count + list with dates and titles

---

## User Decision Flow

This is the critical NEW flow that replaces the old "always upload" approach.

### After Step 2 (Save to Diary + Memoria):

```markdown
✅ Avance guardado localmente:
  📓 Diario actualizado: [path al diario]
  🔄 Memoria de reinicio actualizada

¿Quieres que lo suba también a NotebookLM ahora,
o prefieres que lo deje pendiente para subir
todas las sesiones acumuladas de una vez después?

Responde: "ahora" / "sube" / "sí" → sube ahora
         "después" / "pendiente" / "espera" → agrega a la cola
         "no" → solo local
```

### If user chooses NOW:
→ Execute Step 5 (NotebookLM upload flow) immediately

### If user chooses LATER/PENDING:
→ Execute Step 4 (Add to pending queue)

### If user chooses NO:
→ Done. Only local save.

---

## Multi-Account Notebook Discovery (NUEVO v3)

ANTES de guardar en NotebookLM, el agente DEBE determinar qué notebook y cuenta usar:

### Protocolo de descubrimiento (5 pasos)

```
1. IDENTIFICAR PROYECTO: Determinar el proyecto actual
   (agentes-opencode, queenchat-agent, agent-swarm, trading, etc.)

2. CONSULTAR REGISTRY: Leer ~/.agents/known_notebooks.json
   → project_to_notebook[proyecto] → nombre del notebook
   → notebooks[nombre] → cuenta, URL, ID

3. VERIFICAR SESIÓN ACTIVA: Tomar snapshot del navegador
   ¿Qué cuenta de Google está activa en NotebookLM?
   ¿Es la misma cuenta del notebook objetivo?

4. SI CUENTA INCORRECTA:
   → Usar AccountChooser para cambiar a la cuenta correcta
   → https://accounts.google.com/AccountChooser?continue={URL}&Email={EMAIL}

5. SI NO HAY NOTEBOOK REGISTRADO:
   → Buscar en ambas cuentas (reinaagenciacol y rzuluam) con snapshot
   → Si se encuentra: registrar en known_notebooks.json
   → Si no se encuentra: preguntar a Isa "¿creo un notebook nuevo?"
```

### Registry de notebooks conocidos

**Archivo**: `~/.agents/known_notebooks.json`

Este archivo es la fuente de verdad. El agente DEBE consultarlo siempre antes de decidir dónde guardar.

```json
{
  "notebooks": [
    {
      "name": "Agentes OpenCode",
      "id": "cb1a99a0-...",
      "account": "reinaagenciacol",
      "projects": ["agentes-opencode", "queenchat-agent", "agent-swarm"],
      "url": "https://notebooklm.google.com/notebook/{ID}"
    }
  ],
  "project_to_notebook": {
    "agentes-opencode": "Agentes OpenCode",
    "queenchat-agent": "Agentes OpenCode",
    "agent-swarm": "Agentes OpenCode",
    "trading": "Trading Master v3"
  }
}
```

### Actualización automática del registry

Si durante la ejecución se descubre un notebook NO registrado:
1. Registrar automáticamente en `known_notebooks.json`
2. Asignar al/los proyectos correspondientes
3. Usar para el guardado actual

---

## Step-by-Step Execution

### Step 1: Summarize
Write a comprehensive summary of the current conversation. Structure it as:

**IMPORTANTE**: La primera línea DEBE ser el título en el formato de fuente de NotebookLM:
```
Sesión N — DD mes AAAA: Breve resumen de lo logrado
```

Luego el contenido:

```markdown
Sesión N — DD mes AAAA: Resumen breve de hitos principales

## Sesión N — [fecha]

### N. [Topic 1]

[Content with details, code references, results]

### N+1. [Topic 2]

[Content]
```

Save the summary to a temp file:
```bash
cat > /tmp/summary-$(date +%Y-%m-%d).md << 'SUMMARY_EOF'
[full summary content]
SUMMARY_EOF
```

### Step 2: Save Locally (ALWAYS)

**2a. Append to Diary**
Use the `edit` tool to append the full summary to the diary file. Follow the diary's existing format (numbered sections).

**2b. Update Memoria de Reinicio**
Write/update `~/.agents/memoria-reinicio.md` with:
- Current session metadata
- What was accomplished
- Current state
- Next steps
- List of pending NotebookLM sessions (if any exist in the queue)

**2c. Also apply Commit-Push Protocol if applicable**
If this save was triggered by a commit+push, also add the commit-specific information:
```
### N.M. Commit: [hash] — [message]
- **Archivos**: [diff stat]
- **Qué hizo**: [description]
```

### Step 3: Ask User About NotebookLM

Present the decision prompt (see "User Decision Flow" above).
- Wait for user's response
- Route accordingly

### Step 4: Add to Pending Queue

Only executed if user chose "después"/"pendiente"/"espera":

**4a. Read existing queue**
```bash
cat ~/.agents/pending-notebooklm.json 2>/dev/null || echo '{"sessions":[]}'
```

**4b. Create/update queue file**
Write the updated JSON with the new session appended.

**4c. Confirm to user**
```
✅ Avance guardado localmente.
📝 **Añadido a la cola de NotebookLM.** Cuando quieras, dime "sube las sesiones pendientes" y lo subo todo junto.
```

### Step 5: Save to NotebookLM (NOW or BATCH)

**Only executed when:**
- User chose "ahora" in the decision flow, OR
- User triggers batch upload with "sube las sesiones pendientes"

**PASO OBLIGATORIO: Cambiar a la cuenta correcta con AccountChooser.**
NotebookLM suele abrir con la cuenta `rzuluam`. El cuaderno "Agentes OpenCode" está en `reinaagenciacol`.
SIEMPRE ejecutar el AccountChooser antes de cualquier operación:

```
playwright_browser_navigate("https://accounts.google.com/AccountChooser?continue=https://notebooklm.google.com/notebook/cb1a99a0-9f69-4ed9-a66d-d7b804137817&Email=reinaagenciacol%40gmail.com")
```

Esto redirige al cuaderno con la cuenta correcta (`authuser=2`). Verificar que el snapshot muestre "Reina Agencia (reinaagenciacol@gmail.com)".

**⚠️ REGLA DE ORO: Usar `run_code_unsafe` SIEMPRE para clicks en NotebookLM.**

NotebookLM tiene 3 problemas que obligan a usar `playwright_browser_run_code_unsafe` para interactuar:

| # | Problema | Síntoma | Solución |
|---|----------|---------|----------|
| 1 | **Acentos en UI**: botones como "Agregar fuente", "Texto copiado", "Insertar" tienen letras acentuadas | `Unexpected token ""` en `playwright_browser_click` | Usar `run_code_unsafe` con JS para buscar el botón por `textContent` |
| 2 | **Angular CDK overlays**: diálogos modales crean `cdk-overlay-backdrop` que intercepta clicks | "subtree intercepts pointer events" | `run_code_unsafe` evita la validación de Playwright |
| 3 | **Elementos dinámicos**: NotebookLM renderiza elementos bajo demanda (stretched-button, etc.) | Selector no encuentra el elemento | `run_code_unsafe` permite encontrar por texto contenido |

**Patrón universal para clicks en NotebookLM** (usar SIEMPRE, nunca `playwright_browser_click`):

```javascript
async (page) => {
  const buttons = await page.locator('button').all();
  for (const btn of buttons) {
    const t = await btn.textContent();
    if (t && t.includes('TEXTO_DEL_BOTON')) {
      await btn.click();
      return 'Clicked TEXTO_DEL_BOTON';
    }
  }
  return 'Button not found';
}
```

#### 5a. Copy summary to clipboard

```bash
cat /tmp/summary-YYYY-MM-DD.md | pbcopy
```

For batch upload, do this for each pending session.

#### 5b. Navigate to the notebook (already redirected from AccountChooser)

The notebook URL should already be loaded from the AccountChooser step.
Verify: tomar snapshot y confirmar cuenta `reinaagenciacol` en el header.

#### 5c. Add source (flujo completo probado y funcional)

1. **Click "Agregar fuente"** — usar `run_code_unsafe` con `include('Agregar fuente')`
2. **Esperar 1s** a que se abra el diálogo
3. **Click "Texto copiado"** — usar `run_code_unsafe` con `include('Texto copiado')`
4. **Esperar 500ms** a que aparezca el textarea
5. **Hacer focus al textarea**: `playwright_browser_click` en `textarea[placeholder="Pega texto aquí"]`
6. **Pegar texto**: `playwright_browser_press_key("Meta+v")`
7. **Esperar 1s** a que se procese el pegado
8. **Click "Insertar"** — usar `run_code_unsafe` con `include('Insertar')`
9. **Verificar**: el URL pierde el parámetro `&addSource=true` y el contador de fuentes aumentó

**For new notebook (different account)**:
1. Navigate to `https://notebooklm.google.com`
2. Wait 3 seconds
3. Click "Crear nuevo" — usar `run_code_unsafe`
4. Click "Texto copiado"
5. Paste and insert

#### 5d. For batch upload: repeat for each pending session

After each session:
- Confirm success/failure
- Track counts: N uploaded, M failed

#### 5e. Confirm

- Single upload: "✅ Fuente añadida al cuaderno '[nombre]' — ahora tiene N fuentes"
- Batch: "📤 Sincronización completada: X subidas, Y fallidas. Z pendientes aún."

### Step 6: Clean Up (batch only)

After successful batch upload:
1. Remove uploaded sessions from the queue
2. Save updated `pending-notebooklm.json`
3. Archive any temp summary files if needed

---

## Source naming (CRÍTICO)

La primera línea del texto pegado se convierte en el título de la fuente en NotebookLM.
DEBE ser un título descriptivo con este formato exacto:

```
Sesión N — DD mes AAAA: Resumen breve de lo logrado
```

Ejemplos:
```
Sesión 7 — 18 mayo 2026: Subagentes nivel 3, MCP servers Meta, Dashboard GUI
Sesión 6 — 17 mayo 2026: Google OAuth, credenciales, modelos por tier
Sesión 5 — 17 mayo 2026: Reevaluación de modelos, 4 tiers de agentes
```

El título debe ser una sola línea, descriptivo, con los 2-3 hitos principales de la sesión.
NUNCA uses títulos genéricos como "Avance" o "Resumen".

---

## NotebookLM Access Details

Use the **notebooklm-fast-auth** approach:
1. Navigate via Playwright MCP to the notebook
2. If authenticated, access is immediate
3. If redirected to login, guide user to log in once
4. Add source using the dialog flow

**Critical**: Never use `auth_manager.py` or `update_source.py` scripts for this. Use Playwright MCP browser tools directly.

## Text Pasting for Large Summaries

Since summaries can be 5K-15K chars:
1. Use `bash` to run `cat /tmp/summary.md | pbcopy`
2. Click the NotebookLM textarea for pasted text
3. Press `Meta+v` (Cmd+V) in the Playwright browser
4. Alternatively, use `playwright_browser_run_code_unsafe` with fill

## Patrón completo para agregar fuente (resistente a overlays)

```javascript
async (page) => {
  try {
    // 1. Click "Agregar fuente"
    const addBtn = page.locator('button.add-source-button');
    await addBtn.waitFor({ state: 'visible', timeout: 5000 });
    await addBtn.click();
    await page.waitForTimeout(2000);

    // 2. Click "Texto copiado"
    const tcBtn = page.locator('button:has-text("Texto copiado")').last();
    await tcBtn.waitFor({ state: 'visible', timeout: 5000 });
    await tcBtn.click();
    await page.waitForTimeout(2000);

    // 3. Verificar textarea
    const textarea = page.locator('textarea[placeholder="Pega texto aquí"]');
    await textarea.waitFor({ state: 'visible', timeout: 3000 });

    // 4. Pegar contenido (texto ya en clipboard via pbcopy)
    await textarea.click();
    await page.keyboard.press('Meta+v');
    await page.waitForTimeout(1000);

    // 5. Verificar pegado
    const value = await textarea.inputValue();
    if (value.length < 5000) throw new Error('Paste failed: only ' + value.length + ' chars');

    // 6. Click Insertar
    const insertBtn = page.locator('button:has-text("Insertar")');
    await insertBtn.click();
    await page.waitForTimeout(2000);

    return 'Source added';
  } catch (err) {
    console.error('Failed to add source:', err.message);
    throw err;
  }
}
```

Si `Meta+v` no pega todo el contenido, usar `fill()` o `evaluate` como fallback (ver troubleshooting en notebooklm-fast-auth skill).

---

## Troubleshooting: Fallas comunes de conversation-saver

| Síntoma | Causa raíz | Solución |
|---------|-----------|----------|
| ❌ "No se pudo añadir la fuente" | Cuenta incorrecta (rzuluam en vez de reinaagenciacol) | **Siempre** ejecutar AccountChooser primero con `Email=reinaagenciacol%40gmail.com` |
| ❌ `Unexpected token ""` | Selector de Playwright tiene acento (í, ó, á) | **Siempre** usar `run_code_unsafe` para clicks, no `playwright_browser_click` |
| ❌ "subtree intercepts pointer events" | Angular CDK overlay backdrop intercepta el click | Usar `run_code_unsafe` con `btn.click()` directo |
| ❌ "Source not added" sin error visible | El pegado no copió suficiente texto | Verificar con `textarea.inputValue()` que tenga >500 chars antes de Insertar |
| ❌ `Meta+v` no pega nada | El textarea no tenía foco | Hacer click explícito en el textarea antes de `press_key("Meta+v")` |
| ❌ Se añadió "Texto pegado" como título | La primera línea del contenido no era un título descriptivo | La primera línea del summary DEBE ser `Sesión N — DD mes AAAA: ...` |

### Lecciones aprendidas (10 Jun 2026)

Se diagnosticó y reparó el flujo completo:
1. AccountChooser con `Email=reinaagenciacol` redirige al notebook correcto ✅
2. `run_code_unsafe` para clicks con acento funciona ✅
3. `pbcopy` + `Meta+v` para pegar texto funciona ✅
4. El contador de fuentes se incrementó de 48→49 exitosamente ✅

**Regla**: NO usar `playwright_browser_click` para NADA en NotebookLM. Usar SIEMPRE `run_code_unsafe`.

---

## Reference

| Resource | Path / URL |
|---|---|
| Local diary (general) | `~/Dev/DIARIO.md` |
| Local diary (agentes) | `~/Dev/agentes-opencode/diario-construccion-agentes.md` |
| Trader diary | `~/Dev/agentes-opencode/diario-trader.md` |
| QueenChat diary | `~/Dev/queenchat-agent/DIARIO.md` |
| Memoria de reinicio | `~/.agents/memoria-reinicio.md` |
| Pending queue | `~/.agents/pending-notebooklm.json` |
| Pending queue | `~/.agents/pending-notebooklm.json` |
| Notebook registry | `~/.agents/known_notebooks.json` — fuente de verdad de notebooks |
| NotebookLM notebook (reinaagenciacol) | `https://notebooklm.google.com/notebook/cb1a99a0-9f69-4ed9-a66d-d7b804137817` |
| Notebook name | "Agentes OpenCode" |
| Cuenta principal | `reinaagenciacol@gmail.com` |
| Cuenta secundaria | `rzuluam@gmail.com` (sin notebook por defecto) |
| Related skill | `notebooklm-fast-auth` — NotebookLM access via Playwright |
| Related protocol | `AGENTS.md` ⚠️ Commit-Push Protocol |
| Temp summaries | `/tmp/summary-YYYY-MM-DD.md` |

## Notes

- The diary uses numbered sections sequentially (check the last number used and continue)
- The NotebookLM notebook has a 300-source limit. Old sources can be deleted if needed.
- Summaries should be COMPREHENSIVE, not brief. Include code paths, file names, error messages.
- If Playwright MCP is not available, save locally only and add to pending queue with note "Playwright no disponible".
- The local diary and NotebookLM are independent — one can succeed even if the other fails.
- The pending queue survives reboots (persistent JSON file).
- When doing batch upload, process sessions in FIFO order (oldest first).

---
name: find-skills
description: Descubrimiento e instalación de skills del catálogo. Úsala cuando el usuario pregunte "¿cómo hago X?", "¿hay una skill para...?", "busca una skill que...", o exprese interés en extender las capacidades de los agentes.
---

# Find Skills — Descubridor de Skills

Esta skill permite a los agentes **descubrir, evaluar e instalar** nuevas skills del catálogo incluido en la suite o de fuentes externas. Es la puerta de entrada para ampliar las capacidades del enjambre bajo demanda.

---

## 📋 Catálogo de Skills Incluidas

La suite incluye un catálogo de skills preinstaladas. Consulta `SKILLS.md` (raíz del paquete) para el catálogo completo. Las skills se organizan en estas categorías:

| Categoría | Propósito | Skills incluidas |
|-----------|-----------|------------------|
| **Core** 🛡️ | Skills fundacionales | `model-router`, `find-skills`, `autoaprendizaje` |
| **Desarrollo** 💻 | Desarrollo de software | `mcp-server-blueprint`, `ecosystem-python-std`, `testing-checklist`, `cli-tool-pattern`, `api-integration-pattern`, `data-pipeline-pattern`, `error-handling-std` |
| **Herramientas** 🔧 | Tareas con herramientas específicas | `ffmpeg-video-editing`, `playwright-web-scraping`, `langgraph-advanced`, `document-ocr-reader` |
| **Dominio** 🏢 | Especialización por industria | `senior-accounting-assistant`, `organizational-culture`, `queenchat-cx-excellence`, `instagram-cx-best-practices`, `whatsapp-agent` |

> **Ubicación en disco:** Las skills residen en `{{AGENTS_HOME}}/skills/`, organizadas en subdirectorios `dev/` y `domain/`.

---

## 🔍 Cómo Buscar Skills

### Por nombre

Cuando el usuario pide algo específico, busca coincidencias en el catálogo:

| Si el usuario dice... | Busca skills con... |
|---|---|
| "¿cómo hago web scraping?" | `playwright-web-scraping`, `autoaprendizaje` |
| "necesito contabilidad" | `senior-accounting-assistant` |
| "¿hay una skill para testing?" | `testing-checklist` |
| "quiero editar un video" | `ffmpeg-video-editing` |
| "ayuda con cultura organizacional" | `organizational-culture` |
| "quiero un agente de WhatsApp" | `whatsapp-agent` |
| "necesito OCR para documentos" | `document-ocr-reader` |
| "cómo estructurar una API" | `api-integration-pattern`, `mcp-server-blueprint` |

### Por categoría

Si la búsqueda por nombre no es clara, agrupa por categoría:

```yaml
Desarrollo:
  - mcp-server-blueprint: Patrón canónico para servidores MCP
  - ecosystem-python-std: Convenciones Python (type hints, logging, errores)
  - testing-checklist: Checklist exhaustivo de testing con pytest
  - cli-tool-pattern: Patrón para herramientas CLI con argparse
  - api-integration-pattern: Integración con APIs REST
  - data-pipeline-pattern: Pipelines de datos (CSV, JSON, Excel, ETL)
  - error-handling-std: Manejo estándar de errores y logging

Herramientas:
  - ffmpeg-video-editing: Edición de video desde CLI
  - playwright-web-scraping: Web scraping con Playwright + Python
  - langgraph-advanced: LangGraph avanzado (subgraphs, streaming, HITL)
  - document-ocr-reader: OCR para documentos escaneados

Dominio:
  - senior-accounting-assistant: Auxiliar contable (normativa colombiana)
  - organizational-culture: Consultoría en cultura organizacional
  - queenchat-cx-excellence: CX omnicanal y ventas conversacionales
  - instagram-cx-best-practices: Mejores prácticas de CX para Instagram
  - whatsapp-agent: Blueprint para construir agentes de WhatsApp
```

### Búsqueda en disco

Si el catálogo documentado no es suficiente, se puede inspeccionar directamente el sistema de archivos:

```bash
# Listar todas las skills instaladas
ls {{AGENTS_HOME}}/skills/

# Ver skills de desarrollo
ls {{AGENTS_HOME}}/skills/dev/

# Ver skills de dominio
ls {{AGENTS_HOME}}/skills/domain/
```

---

## 📦 Cómo Instalar Skills Nuevas

### Skills del catálogo incluido

Las skills del catálogo ya vienen incluidas en el paquete `client-suite-pack`. El `builder.sh` las copia automáticamente a `{{AGENTS_HOME}}/skills/` durante la instalación. No requieren instalación adicional.

### Skills externas (no incluidas)

Para instalar una skill que no está en el catálogo incluido:

1. **Descargar o clonar** la skill desde su fuente (GitHub, repositorio interno, etc.)
2. **Copiar al directorio de skills:**

```bash
# Copiar una skill externa al directorio de skills
cp -r /ruta/a/la/nueva-skill {{AGENTS_HOME}}/skills/
```

3. **Verificar que el archivo `SKILL.md` existe** dentro del directorio de la skill, con el frontmatter YAML correcto:

```yaml
---
name: nombre-de-la-skill
description: Descripción breve de lo que hace
---
```

### Skills creadas por el usuario

Si no existe una skill para lo que el usuario necesita, puedes ofrecer crear una:

1. El agente `autoaprendizaje` puede investigar y generar skills nuevas bajo demanda
2. La skill generada se guarda en `{{AGENTS_HOME}}/skills/` y queda disponible inmediatamente

> **Importante:** Las skills nuevas se cargan dinámicamente. No es necesario reiniciar OpenCode para que un agente las use —basta con que el orquestador las referencie con `skill("nombre-de-skill")`.

---

## ✅ Cómo Saber Qué Skills Están Instaladas

Hay tres formas de conocer las skills disponibles:

### 1. Consultar el catálogo documentado

El archivo `SKILLS.md` en la raíz del paquete contiene el catálogo completo con descripciones y cuándo usar cada skill.

### 2. Inspeccionar el sistema de archivos

```bash
# Listar skills instaladas (solo directorios de primer nivel)
ls -d {{AGENTS_HOME}}/skills/*/

# Contar skills instaladas
ls -d {{AGENTS_HOME}}/skills/*/ | wc -l

# Ver estructura completa
find {{AGENTS_HOME}}/skills/ -maxdepth 2 -name "SKILL.md" | sort
```

### 3. Consultar al orquestador

El orquestador tiene acceso a la configuración de skills y puede listar las disponibles:

```
Usuario: "¿Qué skills tienes instaladas?"
→ El orquestador lista las skills disponibles con una breve descripción de cada una
```

---

## 🔄 Ciclo de Vida de una Skill

```
1. Usuario expresa necesidad → "¿hay una skill para X?"
2. find-skills busca en el catálogo local
3. Si existe → Se informa al usuario y se carga con skill("nombre")
4. Si no existe → Se ofrece:
   a. Buscar en fuentes externas (GitHub, comunidades)
   b. Crear una nueva skill con autoaprendizaje
   c. Resolver la tarea directamente sin skill
5. La skill se carga en contexto y el agente ejecuta la tarea
```

---

## ⚠️ Reglas de Uso

1. **Siempre prefiere skills del catálogo incluido** antes de buscar externas
2. **Verifica que una skill existe en disco** antes de recomendarla
3. **Si el usuario pide "aprende a usar X"**, deriva a la skill `autoaprendizaje` en lugar de buscar manualmente
4. **No instales skills de fuentes no verificadas** sin advertir al usuario
5. **Mantén el catálogo actualizado**: si agregas skills externas, documentalas en `SKILLS.md`
6. **Las skills se cargan bajo demanda**: usa `skill("nombre-de-skill")` cuando la tarea lo requiera, no al inicio

---

## 📎 Referencias

- `SKILLS.md` — Catálogo completo de skills incluidas
- `SUITE.md` — Arquitectura general de la suite
- `{{AGENTS_HOME}}/skills/` — Directorio físico de skills
- `{{AGENTS_HOME}}/skills/dev/` — Skills de desarrollo y herramientas
- `{{AGENTS_HOME}}/skills/domain/` — Skills de dominio específico
- Skill `autoaprendizaje` — Para crear skills nuevas bajo demanda

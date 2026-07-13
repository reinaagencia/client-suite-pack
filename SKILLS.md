# 📚 Catálogo de Skills Incluidas (28+)

> **Skills multipropósito** para potenciar a tus agentes. Cada skill es un conjunto de instrucciones y conocimientos especializados que los agentes pueden cargar bajo demanda.
>
> **Nuevo en v2.0:** Superinteligencia Continua + Memoria de Sesiones + Calidad de Código

**Para cargar una skill:** El orquestador usa `skill("nombre-de-skill")` cuando la tarea lo requiere.

---

## 🛡️ Core (5 skills)

Skills fundacionales que todo agente debe conocer.

| Skill | Propósito | Cuándo usarla |
|-------|-----------|---------------|
| **model-router** | Gestión de modelos, planes, fallback automático y API keys | Siempre que haya dudas sobre modelos, autenticación, o errores de API |
| **find-skills** | Descubrimiento e instalación de skills del catálogo | Cuando el usuario pregunte "¿cómo hago X?" o "¿hay una skill para...?" |
| **autoaprendizaje** | Meta-skill: enseña al enjambre a usar nuevas herramientas y técnicas | Cuando el usuario diga "aprende a usar X", "investiga y aprende Y" |
| **reinicio-memoria** 🆕 | Gestión multi-sesión de memoria de reinicio. Soporta N proyectos simultáneos | Cuando el usuario diga "continuar", "retomar", "reanudar" |
| **conversation-saver** 🆕 | Guarda resúmenes completos en diario local + memoria, con cola para NotebookLM | Después de commit+push, o cuando el usuario pida "guarda el avance" |

---

## 🧬 Superinteligencia (4 skills) 🆕

Skills que hacen que la suite se vuelva más inteligente con cada uso.

| Skill | Propósito | Cuándo usarla |
|-------|-----------|---------------|
| **moa-intelligence-amplifier** | Amplificador exponencial de inteligencia mediante Mixture-of-Agents, razonamiento multi-vía (CoT, ToT, GoT) y consenso | Tareas complejas que requieren razonamiento profundo, análisis multi-perspectiva |
| **auto-superinteligencia-continua** | Sistema de superinteligencia agéntica auto-mejorante con meta-cognición, reflexión verbal, self-play y benchmark | Cuando el usuario pida mejorar la inteligencia del sistema o implementar auto-mejora |
| **aprendizaje-refuerzo** | Ciclo de aprendizaje por refuerzo continuo: reflexión post-ejecución, extracción de lecciones, evolución de prompts | Al finalizar cada ejecución del pipeline. Automático, no requiere invocación manual |
| **knowledge-acquisition-engine** | Motor de adquisición de conocimiento ultra-rápida con pipeline multi-fuente | Cuando necesites investigación profunda, síntesis de múltiples fuentes, curriculum |

---

## 💻 Desarrollo (10 skills)

Skills para desarrollo de software de calidad.

| Skill | Propósito | Cuándo usarla |
|-------|-----------|---------------|
| **mcp-server-blueprint** | Patrón canónico para construir servidores MCP | Cuando el requerimiento diga "MCP server", "conector", "integración con API" |
| **ecosystem-python-std** | Convenciones Python: type hints, logging, errores, pathlib | Siempre que se genere código Python |
| **testing-checklist** | Checklist exhaustivo de testing con pytest | Cuando el requerimiento diga "incluye tests", "con pruebas", "QA" |
| **code-review-checklist** 🆕 | Revisión de calidad pre-entrega: seguridad, rendimiento, mantenibilidad | Antes de finalizar una feature, hacer deploy o entregar código |
| **deployment-checklist** 🆕 | Preparación para producción: variables de entorno, tests, build, health check | Antes de cada deploy a producción |
| **cli-tool-pattern** | Patrón para herramientas CLI con argparse | Cuando se necesite crear una herramienta de línea de comandos |
| **api-integration-pattern** | Patrón para integración con APIs REST | Cuando se necesite consumir o crear APIs |
| **data-pipeline-pattern** | Patrón para pipelines de datos (CSV, JSON, Excel, ETL) | Cuando se necesite procesar datos, reportes, transformaciones |
| **error-handling-std** | Manejo estándar de errores, logging y excepciones | Cuando se genere código que necesite robustez |
| **langgraph-unified-pattern** 🆕 | Patrón unificado de LangGraph para sistemas multi-agente | Cuando construyas sistemas con LangGraph en Python o TypeScript |

---

## 🔧 Herramientas (5 skills)

Skills para tareas específicas con herramientas populares.

| Skill | Propósito | Cuándo usarla |
|-------|-----------|---------------|
| **visor-multimodal** | Delegación de análisis visual/auditivo al agente visor-multimodal | Cuando el usuario comparta imágenes, capturas, PDFs visuales, videos o audios |
| **ffmpeg-video-editing** | Edición de video desde CLI con ffmpeg | Cuando necesites cortar, concatenar, convertir o editar videos |
| **playwright-web-scraping** | Web scraping con Playwright y Python | Cuando necesites extraer datos de sitios web |
| **langgraph-advanced** | LangGraph avanzado: state management, subgraphs, streaming | Cuando construyas sistemas multi-agente avanzados con LangGraph |
| **document-ocr-reader** | OCR y lectura de documentos escaneados | Cuando necesites extraer texto de documentos escaneados o PDFs con imágenes |

---

## 🏢 Dominio (4 skills)

Skills especializadas por industria.

| Skill | Propósito | Cuándo usarla |
|-------|-----------|---------------|
| **senior-accounting-assistant** | Auxiliar contable senior (normativa colombiana) | Cuando necesites contabilidad, impuestos, conciliaciones, NIIF |
| **organizational-culture** | Consultoría en cultura organizacional | Cuando necesites diagnóstico, diseño o transformación cultural |
| **instagram-cx-best-practices** | Mejores prácticas de CX para Instagram (DMs + comentarios) | Cuando gestiones respuestas comerciales en Instagram |
| **whatsapp-agent** | Blueprint para construir agentes de WhatsApp con IA | Cuando necesites crear o configurar un agente de WhatsApp |

---

## 📖 Cómo Usar las Skills

### Desde el orquestador

Cuando el orquestador recibe una tarea que coincide con una skill, la carga automáticamente:

```
Usuario: "Necesito que aprendas a usar pandas para análisis de datos"
→ El orquestador detecta "aprende a usar" → carga skill("autoaprendizaje")
```

### Desde cualquier agente

Cualquier agente puede cargar una skill explícitamente:

```
// Un agente necesita el patrón de testing
skill("testing-checklist")

// El orquestador necesita el model-router
skill("model-router")
```

### Skills auto-activadas

Algunas skills se activan automáticamente sin intervención del usuario:

- `aprendizaje-refuerzo` → después de cada pipeline
- `reinicio-memoria` → al detectar `~/.agents/memoria-reinicio.md` + palabra "continuar"
- `model-router` → al encontrar errores 429, 401, 402

---

## 📂 Ubicación de las Skills

Las skills se instalan en `{{AGENTS_HOME}}/skills/`:

```
{{AGENTS_HOME}}/skills/
├── model-router/                 # Core
├── find-skills/
├── autoaprendizaje/
├── reinicio-memoria/             ← NUEVO
├── conversation-saver/           ← NUEVO
├── visor-multimodal/
├── dev/                          # Superinteligencia + Desarrollo + Herramientas
│   ├── moa-intelligence-amplifier/    ← NUEVO
│   ├── auto-superinteligencia-continua/  ← NUEVO
│   ├── aprendizaje-refuerzo/          ← NUEVO
│   ├── knowledge-acquisition-engine/  ← NUEVO
│   ├── mcp-server-blueprint/
│   ├── ecosystem-python-std/
│   ├── testing-checklist/
│   ├── code-review-checklist/         ← NUEVO
│   ├── deployment-checklist/          ← NUEVO
│   ├── cli-tool-pattern/
│   ├── api-integration-pattern/
│   ├── data-pipeline-pattern/
│   ├── error-handling-std/
│   ├── langgraph-advanced/
│   ├── langgraph-unified-pattern/     ← NUEVO
│   ├── ffmpeg-video-editing/
│   ├── playwright-web-scraping/
│   └── document-ocr-reader/
└── domain/                       # Dominio
    ├── senior-accounting-assistant/
    ├── organizational-culture/
    ├── instagram-cx-best-practices/
    └── whatsapp-agent/
```

---

## 🔄 Ciclo de Vida de una Skill

```
1. El orquestador detecta que una tarea necesita una skill
2. Carga la skill con skill("nombre-de-skill")
3. Las instrucciones de la skill se inyectan en el contexto
4. El agente ejecuta la tarea siguiendo las instrucciones
5. La skill se puede recargar en futuras tareas similares
6. [NUEVO] aprendizaje-refuerzo extrae lecciones post-ejecución
```

---

*¿Quieres más skills? Pídele a tu orquestador: "Busca una skill para hacer [lo que necesites]"*

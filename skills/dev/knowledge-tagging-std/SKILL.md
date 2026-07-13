# Knowledge Tagging Standard — Etiquetado de Memoria para RAG

## metadata
- **id**: `knowledge-tagging-std`
- **version**: 1.0.0
- **domain**: meta
- **priority**: medium
- **phase**: meta

## triggers
```yaml
keywords:
  - "memoria"
  - "conocimiento"
  - "aprendizaje"
  - "extraer"
  - "lección"
  - "guardar"
  - "recordar"
  - "tag"
  - "etiqueta"
  - "clasificar"
  - "categorizar"
  - "dominio"
  - "tipo de tarea"
patterns:
  - "guarda el conocimiento"
  - "extrae lecciones"
  - "aprende de"
  - "memory tagging"
  - "clasifica por dominio"
  - "etiqueta la memoria"
exclude:
  - "test"
  - "debug"
```

## rules
```yaml
business_rules:
  - "TODAS las memorias guardadas DEBEN tener un task_type que refleje el dominio del problema"
  - "Los task_type DEBEN seguir el formato: <dominio>_<resultado> (ej: mcp_server_exitoso, data_pipeline_error)"
  - "Dominios permitidos: mcp_server, cli_tool, data_pipeline, api_integration, web_service, automation, general"
  - "Resultados permitidos: exitoso, con_errores, parcial, fallido"
  - "La metadata DEBE incluir: archivos, lenguaje, skills usadas, resultado"
  - "El contenido de la memoria DEBE ser un resumen estructurado con: problema, solución, lecciones, código clave"
  - "NO guardar memorias triviales (< 100 caracteres) o mensajes de error del pipeline"
  - "Las lecciones aprendidas DEBEN ser accionables (que un agente futuro pueda aplicar)"
  - "Incluir SIEMPRE los nombres de skills que se activaron durante el proyecto"
  - "El embedding se genera automáticamente — NO incluir vectores manualmente"
```

## blueprint
```yaml
architecture:
  description: >
    Estandariza cómo se etiquetan y almacenan las memorias en Supabase (agent_memory).
    Cada memoria es un registro con task_type, content, embedding, keywords, metadata.
    El task_type determina qué skills se activarán en el futuro para problemas similares.
  
  file_structure:
    - path: "src/nodes/knowledge_extractor.py"
      purpose: "Genera y guarda la memoria al finalizar un proyecto exitoso"
    - path: "src/supabase_utils.py"
      purpose: "Funciones hybrid_search y save_to_memory"
    - path: "supabase_schema.sql"
      purpose: "Schema de la tabla agent_memory con pgvector"

  data_flow: >
    Proyecto exitoso → extractor genera resumen → clasifica dominio →
    asigna task_type → guarda en agent_memory → futuro RAG puede recuperarlo

  tech_decisions:
    - "task_type compuesto: dominio_resultado (único por combinación)"
    - "keywords generado automáticamente por trigger SQL (to_tsvector)"
    - "metadata en JSONB para flexibilidad sin cambiar schema"
    - "embedding: text-embedding-3-small (1536 dimensiones)"
```

## code
```yaml
templates:
  - name: "memory_entry"
    description: "Formato estándar de entrada de memoria"

libraries:
  preferred: []
  avoid: []

snippets:
  - name: "task_type_format"
    description: "Formato estándar de task_type"
    code: |
      # Formato: <dominio>_<resultado>
      # Dominio: mcp_server | cli_tool | data_pipeline | api_integration | web_service | automation | general
      # Resultado: exitoso | con_errores | parcial | fallido
      
      task_type = f"{dominio}_{resultado}"
      # Ejemplos:
      # "mcp_server_exitoso"      — Servidor MCP completado con éxito
      # "data_pipeline_parcial"   — Pipeline de datos incompleto
      # "cli_tool_con_errores"    — CLI con bugs conocidos
      # "api_integration_fallido" — Integración API que no funcionó

  - name: "memory_content_structure"
    description: "Estructura del contenido de la memoria"
    code: |
      # El contenido debe seguir esta estructura:
      contenido = f"""
      ## Problema
      {descripcion_del_problema}
      
      ## Solución
      {descripcion_de_la_solucion}
      
      ## Arquitectura
      {archivos_y_estructura}
      
      ## Lecciones aprendidas
      - {leccion_1}
      - {leccion_2}
      
      ## Código clave
      ```python
      {fragmento_de_codigo_relevante}
      ```
      
      ## Skills activadas
      - {skill_1}
      - {skill_2}
      """

  - name: "metadata_standard"
    description: "Metadatos estándar para cada memoria"
    code: |
      metadata = {
          "archivos": ["main.py", "core.py"],
          "lenguaje": "Python",
          "exito": True,
          "skills_activadas": ["mcp-server-blueprint", "ecosystem-python-std"],
          "task_type": "mcp_server_exitoso",
          "iteraciones": 3,
          "lineas_codigo": 840,
      }
```

## checks
```yaml
validation_checks:
  - category: "task_type"
    checks:
      - "[ ] task_type sigue formato <dominio>_<resultado>"
      - "[ ] Dominio es uno de los permitidos"
      - "[ ] Resultado es uno de los permitidos"
  - category: "contenido"
    checks:
      - "[ ] Memoria tiene al menos 100 caracteres"
      - "[ ] Incluye problema, solución y lecciones"
      - "[ ] Incluye skills activadas"
      - "[ ] No contiene errores del pipeline"
  - category: "metadata"
    checks:
      - "[ ] metadata incluye archivos y lenguaje"
      - "[ ] metadata incluye skills_activadas"
      - "[ ] metadata incluye exito (bool)"
  - category: "utilidad"
    checks:
      - "[ ] Lecciones son accionables para futuros agentes"
      - "[ ] Código clave es relevante y reutilizable"
      - "[ ] El resumen es auto-contenido (no requiere contexto externo)"
```

## examples
```yaml
examples:
  - input: "Extrae las lecciones aprendidas de este proyecto"
    skills_activated: ["knowledge-tagging-std"]
    expected_output: >
      Memoria estructurada con task_type adecuado, metadata completa,
      lecciones accionables, código clave, y skills activadas

  - input: "Guarda el conocimiento de este MCP server para futuros proyectos"
    skills_activated: ["mcp-server-blueprint", "knowledge-tagging-std"]
    expected_output: >
      Memoria con task_type="mcp_server_exitoso", metadata con archivos del MCP server,
      lecciones sobre el patrón dispatch dict y errores encontrados
```

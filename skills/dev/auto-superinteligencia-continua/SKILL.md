---
name: auto-superinteligencia-continua
description: "Sistema de superinteligencia agéntica auto-mejorante con meta-cognición, reflexión verbal, ejecución bash-native, benchmark automático, self-play y replicación de agentes."
---

# 🧠 Auto-Superinteligencia Continua

> Meta-skill de transformación agéntica: convierte al enjambre-dev en un sistema de superinteligencia auto-mejorante con capacidades de frontera.
> 
> Inspirado en: Reflexion (Shinn et al. 2023), SWE-agent (Yang et al. 2024), mini-SWE-agent, CrewAI
> Entrenamiento: 5 módulos, 15 ejercicios, verificado el 2026-06-02

## metadata

- **id**: `auto-superinteligencia-continua`
- **version**: 2.0.0
- **domain**: agentic_ai, meta_cognition, self_improvement
- **priority**: critical
- **phase**: meta

## triggers

```yaml
keywords:
  - "superinteligencia"
  - "auto-mejora"
  - "reflexión verbal"
  - "aprendizaje continuo"
  - "self-play"
  - "replicación de agentes"
  - "bash-native"
  - "benchmark suite"
  - "memoria episódica"
  - "agente inteligente"
  - "mejorar enjambre"
  - "hacer más inteligente"
patterns:
  - "quiero que el enjambre sea más inteligente"
  - "necesitamos mejorar las capacidades del agente"
  - "cómo podemos hacer que aprenda de sus errores"
  - "implementa auto-mejora continua"
  - "queremos un sistema superinteligente"
  - "replica este agente a otro dominio"
exclude:
  - "solo análisis"
  - "solo investiga"
  - "no implementes"
```

## architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 ENJAMBRE SUPERINTELIGENTE v2.0               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                 │
│  │ Pipeline │──▶│Episodic  │──▶│Verbal RL │                 │
│  │ Clásico  │   │Memory    │   │Reflection│                 │
│  └──────────┘   └──────────┘   └─────┬────┘                 │
│                                       │                      │
│                 ┌─────────────────────┼──────────────┐       │
│                 ▼                     ▼              ▼       │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                 │
│  │Bash-     │   │Benchmark │   │Self-Play │                 │
│  │Native    │   │Suite     │   │Pipeline  │                 │
│  └──────────┘   └──────────┘   └─────┬────┘                 │
│                                       │                      │
│                 ┌─────────────────────┘                      │
│                 ▼                                            │
│  ┌──────────────────────────────────────┐                   │
│  │      Agent Replication Engine        │                   │
│  │  (Extraer → Adaptar → Generar)      │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## rules

```yaml
business_rules:
  # META-COGNICIÓN
  - "Siempre archivar episodio completo en memoria episódica después de cada ejecución"
  - "Generar auto-crítica (reflective text) en cada episodio, identificando qué salió mal y por qué"
  - "Extraer al menos 1 heurística por episodio: regla 'si → entonces' generalizable"
  - "Inyectar heurísticas aprendidas en prompts de futuras ejecuciones del mismo dominio"
  
  # BASH-NATIVE
  - "El Programador DEBE ejecutar su código para verificar que funciona antes de entregarlo"
  - "Si hay errores de sintaxis, auto-corregir con el feedback de ejecución"
  - "Usar subprocess.run con timeout para todas las ejecuciones"
  - "Capturar stdout + stderr completos para análisis"
  
  # BENCHMARKS
  - "Registrar cada ejecución en el benchmark con timestamp, éxito/fallo, iteraciones"
  - "Generar reporte de tendencias cada 10+ ejecuciones"
  - "Comparar rendimiento contra estándares de la industria periódicamente"
  
  # SELF-PLAY
  - "Cada ejecución exitosa produce un par (requerimiento → código) para entrenamiento"
  - "Cada ejecución fallida produce un par (requerimiento → error) como ejemplo negativo"
  - "Acumular pares para fine-tuning futuro del modelo"
  
  # REPLICACIÓN
  - "Agentes con 3+ ejecuciones exitosas en un dominio son candidatos a replicación"
  - "La receta incluye: prompts, thresholds, patrones de éxito y tecnologías"
  - "El agente replicado debe validarse con una tarea de prueba del dominio destino"
  - "Registrar cada replicación en el catálogo de agentes"
```

## components

```yaml
modules:
  - id: "episodic_memory"
    file: "src/episodic_memory.py"
    description: "Memoria episódica con reflexión verbal (Reflexion-style)"
    api:
      - "archive_episode(state) → episode"
      - "generate_self_reflection(...) → str"
      - "extract_heuristics(episode) → list[str]"
      - "get_heuristics_context(domain) → str"
      - "process_episode(state) → dict"
      - "show_status() → str"
  
  - id: "bash_executor"
    file: "src/bash_executor.py"
    description: "Ejecución segura de comandos bash para auto-verificación"
    api:
      - "execute_command(command, workdir, timeout) → ExecutionResult"
      - "execute_python_code(path, args) → ExecutionResult"
      - "run_pytest(test_path) → ExecutionResult"
      - "format_output_for_llm(result) → str"
  
  - id: "benchmark_suite"
    file: "src/benchmark_suite.py"
    description: "Benchmark automático con tracking temporal"
    api:
      - "record_run(state, start_time) → record"
      - "generate_report() → dict"
      - "get_report_text() → str"
      - "compare_to_standards() → str"
  
  - id: "selfplay_data"
    file: "src/selfplay_data.py"
    description: "Generación de datos de entrenamiento desde ejecuciones"
    api:
      - "record_training_pair(state, success)"
      - "get_stats() → dict"
      - "export_for_finetuning(path) → Path"
  
  - id: "agent_replicator"
    file: "src/agent_replicator.py"
    description: "Replicación de capacidades a nuevos agentes/dominios"
    api:
      - "extract_recipe(state) → recipe"
      - "adapt_recipe(recipe, target_domain) → recipe"
      - "generate_subagent(recipe) → files"
      - "replicate_agent(state, target_domain) → result"
      - "get_catalog_text() → str"
```

## workflow

```yaml
ciclo_superinteligencia:
  description: "Ciclo completo de superinteligencia continua"
  steps:
    - "1. Ejecutar pipeline estándar (Investigador → Orquestador → ... → Tester)"
    - "2. [Reflection] LessonsEngine extrae lecciones genéricas"
    - "3. [Reflection] EpisodicMemory archiva episodio completo + auto-crítica"
    - "4. [Reflection] Extraer heurísticas del episodio"
    - "5. [Reflection] Analizar tendencias de mejora/empeoramiento"
    - "6. [Reflection] Inyectar heurísticas en contexto para próxima ejecución"
    - "7. [Benchmark] Registrar métricas de rendimiento"
    - "8. [Self-Play] Registrar par de entrenamiento (éxito/fallo)"
    - "9. [Programador] Ejecutar código localmente para verificación"
    - "10. [Programador] Auto-corregir si hay errores de ejecución"
  
  replication:
    description: "Replicar agente exitoso a nuevo dominio"
    steps:
      - "1. Identificar agente con 3+ ejecuciones exitosas en dominio A"
      - "2. Extraer receta (prompts, thresholds, patrones)"
      - "3. Adaptar receta al dominio B"
      - "4. Generar archivos del nuevo subagente"
      - "5. Registrar en catálogo"
      - "6. Validar con tarea de prueba"
```

## checks

```yaml
validation_checks:
  - category: "Episodic Memory"
    checks:
      - "[ ] process_episode() archiva y retorna episode_id"
      - "[ ] generate_self_reflection() produce texto de auto-crítica"
      - "[ ] extract_heuristics() retorna al menos 1 heurística"
      - "[ ] get_heuristics_context() genera texto inyectable"
  
  - category: "Bash Executor"
    checks:
      - "[ ] execute_command() captura stdout/stderr correctamente"
      - "[ ] Timeout funciona (comando lento se cancela)"
      - "[ ] Comandos peligrosos son rechazados"
      - "[ ] format_output_for_llm() produce texto legible"
  
  - category: "Benchmarks"
    checks:
      - "[ ] record_run() almacena sin errores"
      - "[ ] generate_report() produce métricas con 10+ runs"
      - "[ ] compare_to_standards() muestra comparativa"
  
  - category: "Self-Play"
    checks:
      - "[ ] record_training_pair() produce archivos JSONL válidos"
      - "[ ] export_for_finetuning() genera dataset utilizable"
  
  - category: "Replication"
    checks:
      - "[ ] extract_recipe() captura todos los componentes"
      - "[ ] adapt_recipe() modifica para dominio destino"
      - "[ ] generate_subagent() produce archivos ejecutables"
      - "[ ] register_agent() persiste en catálogo"
```

## examples

```bash
# Verificar estado de la memoria episódica
python3 main.py --episodic

# Ver reporte de benchmark
python3 main.py --report

# Ver estadísticas de self-play
python3 main.py --selfplay

# Ver catálogo de agentes replicados
python3 main.py --catalog

# Comparar con estándares de la industria
python3 main.py --compare

# Ejecutar pipeline con superinteligencia activa
python3 main.py "Crea una API REST en Flask"

# Verificar configuración completa
python3 main.py --verify
```

---

*Skill generada por autoaprendizaje | 5 módulos, 15 ejercicios | 2026-06-02*
*Transformación: Enjambre Clásico → Superinteligencia Continua v2.0*

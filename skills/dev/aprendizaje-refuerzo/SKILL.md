---
name: aprendizaje-refuerzo
description: Ciclo de aprendizaje por refuerzo continuo del enjambre. Reflexión automática post-ejecución, extracción de lecciones, inyección en futuras tareas, evolución de prompts y mejora continua de parámetros.
---

# Aprendizaje por Refuerzo Continuo

> Skill de meta-aprendizaje que cierra el ciclo: cada ejecución del pipeline
> genera lecciones que mejoran la siguiente ejecución.
> Fecha: 2026-06-02

## metadata
- **id**: `aprendizaje-refuerzo`
- **version**: 1.0.0
- **domain**: meta_aprendizaje
- **priority**: high
- **phase**: meta

## triggers
```yaml
keywords:
  - "aprendizaje por refuerzo"
  - "rl"
  - "refuerzo continuo"
  - "aprender de errores"
  - "lecciones aprendidas"
  - "mejora continua"
  - "post-task reflection"
  - "auto-mejora"
  - "ciclo rl"
  - "reinforcement learning swarm"
  - "reflexión automática"
  - "lessons learned"
  - "evolución de prompts"
  - "prompt evolution"
  - "rules engine"
patterns:
  - "el enjambre aprenda automáticamente"
  - "aprenda de sus mismos flujos de trabajo"
  - "aprendizaje por refuerzo"
  - "mejorar el autoaprendizaje"
  - "cierre el ciclo de aprendizaje"
  - "cada tarea que deje enseñanza"
exclude:
  - "aprende a usar"
  - "aprende a hacer"
  - "certifícate"
```

## rules

```yaml
business_rules:
  - "REGLAS DEL CICLO RL:"
  - "1. REFLEXIÓN UNIVERSAL: Toda ejecución del pipeline (PASS o FAIL) debe pasar por el nodo de reflexión."
  - "2. EXTRACCIÓN ESTRUCTURADA: Cada reflexión extrae lecciones en 4 categorías: pattern, anti-pattern, pitfall, optimization."
  - "3. UMBRAL DE ACTIVACIÓN: Una lección repetida 2+ veces genera una regla de negocio automática."
  - "4. INYECCIÓN EN FUTURAS TAREAS: Las reglas aprendidas se inyectan como business_rules en el ParallelPrep de la siguiente ejecución."
  - "5. EVOLUCIÓN DE PROMPTS: Los prompts de agentes se refinan con cada lección confirmada."
  - "6. SEÑAL DE REFUERZO REAL: router.aprender() debe recibir calidad, errores, iteraciones y ajustar thresholds dinámicamente."
  - "7. PERSISTENCIA: Las lecciones se almacenan en ~/.agents/lessons/*.json y en Supabase (agent_memory con task_type='leccion')."
  - "8. NO SOBREESCRIBIR: Las lecciones se acumulan, no se reemplazan. Cada nueva lección se agrega al historial."
  - "9. AUTO-LIMPIAR: Lecciones con más de 30 días sin uso se archivan automáticamente."
  - "10. TRAZABILIDAD: Cada lección registra qué tarea la originó, en qué iteración, y si se ha aplicado con éxito."
```

## blueprint

```yaml
description: >
  Sistema completo de aprendizaje por refuerzo continuo para el enjambre.
  
  ARQUITECTURA:
  
  1. REFLECTION NODE (reflection.py)
     - Se ejecuta DESPUÉS de cada tarea (knowledge_extractor o fail_diagnosis)
     - Recibe el estado completo de la ejecución
     - Extrae lecciones en 4 categorías
     - Calcula señal de refuerzo (0.0 a 1.0)
     - Delega a lessons_engine y prompt_evolution
  
  2. LESSONS ENGINE (lessons_engine.py)
     - Almacén central de lecciones aprendidas
     - Detecta patrones repetidos (2+ ocurrencias → regla)
     - Genera business_rules dinámicas para inyección
     - Scoreboard de rendimiento por tipo de tarea
  
  3. PROMPT EVOLUTION (prompt_evolution.py)
     - Refina prompts de agentes basado en lecciones
     - Agrega/actualiza reglas aprendidas
     - Ajusta thresholds y parámetros
  
  4. MODEL ROUTER APRENDER() REAL
     - Recibe señal de refuerzo con métricas
     - Ajusta max_pro dinámicamente
     - Aprende qué nodos realmente necesitan pro
  
  FLUJO:
  
  Tarea termina (PASS/FAIL)
         │
         ▼
  ┌──────────────────────┐
  │  Reflection Node      │
  │  - Analiza ejecución  │
  │  - Extrae lecciones   │
  │  - Calcula refuerzo   │
  └──────┬───────────────┘
         │
    ┌────┴────┐
    ▼         ▼
  Lessons   Prompt
  Engine    Evolution
    │         │
    └────┬────┘
         ▼
  Model Router.aprender()
  (ajusta thresholds)
         │
         ▼
  Próxima tarea empieza con
  todo lo aprendido inyectado
         │
         ▼
  ┌──────────────────────┐
  │  ParallelPrep         │
  │  - Carga lecciones    │
  │  como business_rules  │
  │  - Inyecta en prompt  │
  └──────────────────────┘

tech_decisions:
  - "Usar archivos JSON locales en ~/.agents/lessons/ como almacén primario (rápido, sin dependencias)"
  - "Supabase como almacén secundario para persistencia y búsqueda vectorial"
  - "Las lecciones se cargan en ParallelPrep vía retrieved_memory y business_rules"
  - "Categorías de lecciones: pattern (éxito repetible), anti-pattern (error a evitar), pitfall (error común), optimization (mejora de eficiencia)"
  - "Señal de refuerzo compuesta: éxito * 0.4 + (1 - iteraciones/max_iter) * 0.3 + calidad_codigo * 0.3"
```

## code

```yaml
templates:
  - name: "reflection_cycle"
    description: "Ciclo completo de reflexión y aprendizaje"
    code: |
      from src.lessons_engine import LessonsEngine
      from src.prompt_evolution import PromptEvolution
      
      # 1. Extraer lecciones de la ejecución
      lessons = LessonsEngine.extract_lessons(
          requirement=state["user_requirement"],
          source_code=state["source_code"],
          test_report=state["test_report"],
          blueprint=state["architecture_blueprint"],
          audit_trail=state["audit_trail"],
          iterations=state["iteration_count"],
          success=(state["test_report"]["status"] == "PASS"),
      )
      
      # 2. Guardar lecciones
      for lesson in lessons:
          LessonsEngine.store_lesson(lesson)
      
      # 3. Detectar patrones y generar reglas
      new_rules = LessonsEngine.detect_patterns()
      if new_rules:
          PromptEvolution.add_rules(new_rules)
      
      # 4. Señal de refuerzo al router
      signal = LessonsEngine.compute_reinforcement_signal(state)
      router.aprender(
          ejecucion_exitosa=signal["success"],
          calidad=signal["quality"],
          iteraciones=signal["iterations"],
          errores=signal["errors"],
          complexity=signal["complexity"],
      )

libraries:
  - "json (stdlib)"
  - "pathlib (stdlib)"
  - "datetime (stdlib)"
  - "from collections import defaultdict (stdlib)"
  - "No requiere paquetes pip externos"
```

## checks

```yaml
validation_checks:
  - category: "Reflection Node"
    checks:
      - "[ ] El nodo reflection.py se ejecuta después de knowledge_extractor en PASS"
      - "[ ] El nodo reflection.py se ejecuta después de fail_diagnosis en FAIL"
      - "[ ] Extrae al menos 1 lección por ejecución"
      - "[ ] Las lecciones se categorizan correctamente (pattern/anti-pattern/pitfall/optimization)"
  - category: "Lessons Engine"
    checks:
      - "[ ] lessons_engine.load_lessons() retorna lista no vacía después de guardar"
      - "[ ] Detecta patrones repetidos con 2+ ocurrencias"
      - "[ ] Genera reglas de negocio dinámicas"
      - "[ ] Inyecta reglas en ParallelPrep vía business_rules"
  - category: "Prompt Evolution"
    checks:
      - "[ ] prompt_evolution.evolve() produce cambios en los prompts"
      - "[ ] Las reglas no se duplican"
      - "[ ] Los cambios son acumulativos (no destructivos)"
  - category: "Model Router"
    checks:
      - "[ ] router.aprender() actualiza thresholds reales"
      - "[ ] max_pro se ajusta según tasa de éxito histórica"
      - "[ ] Las decisiones mejoran con el tiempo"
  - category: "Ciclo Completo"
    checks:
      - "[ ] Tras N ejecuciones, el enjambre comete menos errores repetidos"
      - "[ ] Las lecciones de tasks previas aparecen como contexto en nuevas tasks"
      - "[ ] El performance scoreboard muestra mejora sostenida"
```

---

## ⭐ Cross-Refinamiento: Lecciones de Uso de Skills (NUEVO)

### Extensión del ciclo RL para skills

El sistema de aprendizaje por refuerzo ahora captura lecciones NO SOLO del pipeline agent-swarm,
sino también del **uso de cada skill del catálogo**. Cada vez que un agente usa una skill y
encuentra un problema o mejora, se registra como lección.

### Nueva categoría: "skill_improvement"

```yaml
lesson_categories:
  - pattern:        "Éxito repetible en el uso de una skill"
  - anti-pattern:    "Error a evitar al usar una skill"
  - pitfall:         "Error común en una skill específica"
  - optimization:    "Mejora de eficiencia en el flujo de una skill"
  - skill_improvement:  # NUEVA
      desc: "Mejora potencial identificada en el contenido de una skill"
      ejemplo: "La skill X usa un approach Y que la skill Z reemplazó con un approach W más robusto"
      accion: "Registrar en skill_cross_refinement_log para revisión en el próximo ciclo"
```

### Protocolo de captura de lecciones de skills

```
Cuando ejecutes una skill y notes algo mejorable:

1. IDENTIFICAR si el problema es de:
   ├── ⚙️ Sintaxis/API (comando incorrecto, flag obsoleto)
   │   → Categoría: skill_improvement, sub: syntax
   │   → Acción: Corregir en la skill inmediatamente
   │
   ├── 🔄 Flujo (pasos ineficientes, redundantes)
   │   → Categoría: skill_improvement, sub: workflow
   │   → Acción: Registrar para refinamiento
   │
   ├── 🧩 Dependencia (la skill usa un approach reemplazado)
   │   → Categoría: skill_improvement, sub: dependency
   │   → Acción: Registrar para refinamiento cruzado
   │
   └── 📝 Documentación (ambiguo, incompleto)
       → Categoría: skill_improvement, sub: docs
       → Acción: Corregir en la skill inmediatamente

2. REGISTRAR la lección:
   - Formato: JSON en ~/.agents/lessons/skill_improvements.json
   - Incluir: skill_name, categoría, descripción, fecha, contexto
   - Si es crítica: registrar también en supabase agent_memory

3. NOTIFICAR al ciclo de refinamiento:
   - Si hay 2+ lecciones sobre la misma skill → marcar para refinamiento
   - Si hay una skill más nueva que resuelve mejor el mismo problema
     → marcar para refinamiento cruzado (como el que acabamos de hacer)
```

### Formato de registro

```json
{
  "skill_name": "deepseek-web",
  "category": "skill_improvement",
  "sub_category": "dependency",
  "description": "La sección Auth no aprovecha el perfil persistente de Playwright MCP",
  "improved_by": "Perfil persistente multi-cuenta (playwright-profile)",
  "impact": "Cada login requiere password manual, aunque la sesión ya está guardada",
  "date": "2026-06-03",
  "context": "Refinamiento cruzado de skills",
  "resolved": true,
  "resolution": "Se actualizó la skill para usar AccountChooser y perfil persistente"
}
```

### Integración con el ciclo de refinamiento de skills

```yaml
Cada N ejecuciones o cada semana:
  1. LessonsEngine.scan_skill_improvements()
     → Escanea ~/.agents/lessons/skill_improvements.json
     → Agrupa por skill_name
     → Identifica skills con 2+ mejoras pendientes

  2. CrossRefinementEngine.analyze()
     → Para cada skill con mejoras pendientes:
       a. Busca skills nuevas que puedan mejorar su flujo
       b. Genera propuesta de refinamiento
       c. Aplica cambios (con backup automático)

  3. BackupEngine.create_checkpoint()
     → Antes de modificar: backup en ~/.agents/backups/<fecha>/
     → Si algo se rompe: restaurar desde backup

  4. Registry.update()
     → Actualiza backup_index.json
     → Registra el refinamiento en el diario
```

### Checks de validación (nuevos)

```yaml
- category: "Skill Improvements"
  checks:
    - "[ ] Cada skill usada en una tarea revisa si hay skills más nuevas que mejoren su flujo"
    - "[ ] skill_improvements.json existe y tiene registros válidos"
    - "[ ] Las mejoras detectadas se resuelven en el mismo ciclo o se registran como pendientes"
    - "[ ] Las skills modificadas tienen backup antes del cambio"
    - "[ ] Después del refinamiento, la skill sigue siendo funcional"
```

## examples

```yaml
uso_tipico:
  - "El pipeline completa una tarea exitosamente → reflection_node extrae patterns → lessons_engine guarda → próxima tarea similar encuentra el patrón como contexto"
  - "El pipeline falla 3 veces seguidas por el mismo error → reflection_node detecta anti-pattern → lessons_engine genera regla → prompt_evolution agrega advertencia al Programador → 4ta iteración corrige el error"
  - "Tareas CSV consistentemente exitosas en 1 iteración → tuner reduce budgets → router aprende que CSV no necesita pro → todo flash, más barato y rápido"
  - "Tareas de API consistentemente fallan en iter 6+ → router escala Programador a PRO desde iter 4 → menos iteraciones, más éxito"
```

---

*Skill generada para el sistema de aprendizaje por refuerzo continuo del enjambre | 2026-06-02*

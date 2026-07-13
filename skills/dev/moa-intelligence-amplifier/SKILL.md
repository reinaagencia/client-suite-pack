---
name: moa-intelligence-amplifier
description: Amplificador exponencial de inteligencia mediante arquitectura Mixture-of-Agents (MoA), razonamiento avanzado multi-vía (CoT, ToT, GoT), mecanismos de consenso y auto-mejora recursiva. Inspirado en Mixture-of-Agents (Wang et al. 2024), Chain-of-Thought (Wei et al. 2022), Tree-of-Thoughts (Yao et al. 2023), ReAct (Yao et al. 2023) y Switch Transformer (Fedus et al. 2021).
---

# MoA Intelligence Amplifier

> Skill auto-generada por el sistema de autoaprendizaje del enjambre
> Investigación: MoA paper, CoT/ToT/GoT, ReAct, Reflexion, Switch Transformer, ensemble methods
> Fecha: 2026-06-07

## metadata
- **id**: `moa-intelligence-amplifier`
- **version**: 1.0.0
- **domain**: agentic_ai, razonamiento, inteligencia_amplificada
- **priority**: critical
- **phase**: meta
- **tags**: ["moa", "mixture-of-agents", "reasoning", "consensus", "ensemble", "amplification"]

## triggers
```yaml
keywords:
  - "amplificar inteligencia"
  - "mixture of agents"
  - "moa"
  - "razonamiento avanzado"
  - "chain of thought"
  - "tree of thought"
  - "graph of thought"
  - "consenso"
  - "votación"
  - "multi-agente"
  - "multi-modelo"
  - "razonamiento en paralelo"
  - "debate entre agentes"
  - "ensemble"
  - "self-consistency"
  - "razonamiento profundo"
  - "inteligencia exponencial"
  - "amplificación cognitiva"
  - "colaboración de agentes"
  - "react"
  - "reasoning and acting"
patterns:
  - "necesito razonamiento profundo sobre"
  - "analiza desde múltiples perspectivas"
  - "usa múltiples agentes para"
  - "haz que los agentes colaboren en"
  - "aplica razonamiento multi-vía"
  - "necesito la mejor respuesta posible a"
  - "compara diferentes enfoques para"
  - "vota entre múltiples soluciones para"
  - "debate sobre"
exclude:
  - "respuesta simple"
  - "tarea trivial"
  - "solo una fuente"
  - "sin razonamiento"
  - "rápido y directo"
```

## rules
```yaml
business_rules:
  # MOA ARCHITECTURE
  - "MoA se activa SOLO para tareas con complejidad > 0.6 (evaluada por complexity_classifier)"
  - "Mínimo 2 agentes por capa, máximo 5. Capas: 1-3 según complejidad"
  - "Capa 1: proposers (generan respuestas iniciales). Capa 2+: aggregators (refinan/resumen)"
  - "Cada agente en capa N recibe outputs de TODOS los agentes de capa N-1 como contexto"
  - "Routing por experticia: si el tema es técnico, dar más peso al agente con mejor historial en ese dominio"
  - "Timeout por capa: 30 segundos. Si un agente no responde, continuar con los demás"
  
  # REASONING PATTERNS
  - "CoT: usar para problemas de razonamiento secuencial (matemáticas, lógica, debugging)"
  - "ToT: usar para problemas con múltiples caminos de solución (planificación, diseño, estrategia)"
  - "  - BFS: cuando hay muchas opciones y se necesita explorar sistemáticamente"
  - "  - DFS: cuando se necesita profundizar en una línea de razonamiento"
  - "GoT: usar para problemas con dependencias complejas (arquitectura, sistemas distribuidos)"
  - "ReAct: usar para tareas que requieren interacción con herramientas (APIs, búsqueda web, código)"
  
  # CONSENSUS
  - "Votación ponderada: peso = confianza del agente * accuracy_histórica * relevancia_dominio"
  - "Si el consenso es débil (< 0.6 agreement), iniciar ciclo de debate: agentes argumentan y refinan"
  - "Self-consistency: sample N >= 3 respuestas, seleccionar por majority vote"
  - "Confidence calibration: si la respuesta tiene confianza < 0.5, marcar como 'incierta' en lugar de forzar"
  - "Debate protocol: max 3 rondas. Cada ronda: agentes ven outputs de otros y refinan el suyo"
  
  # SPEED & EFFICIENCY
  - "Complexity classifier decide: simple → agente único, medium → MoA 1 capa, hard → MoA 2+ capas"
  - "Speculative execution: empezar con agente único mientras complexity classifier corre en paralelo"
  - "Early exit: si después de 2 agentes hay consenso > 0.9, no ejecutar más agentes"
  - "Caching de reasoning paths: si mismo problema ya resuelto, retornar respuesta cachead"
  - "Token budget: 75% del presupuesto para proposers, 25% para aggregators"
  - "Parallel vs sequential: capas son secuenciales, agentes dentro de capa son paralelos"
  
  # RECURSIVE IMPROVEMENT
  - "Cada respuesta MoA se registra para aprendizaje: (problema, respuestas, voto, resultado final)"
  - "Si MoA produce una respuesta significativamente mejor que agente único, registrar como evidencia"
  - "Actualizar pesos de agentes basado en desempeño histórico por dominio"
  - "Detectar cuándo MoA es innecesario (overkill) y registrar para optimización"
```

## blueprint
```yaml
description: >
  Sistema de amplificación exponencial de inteligencia mediante colaboración multi-agente.
  
  ARQUITECTURA:
  
  ┌──────────────────────────────────────────────────────────────┐
  │                 MoA INTELLIGENCE AMPLIFIER                    │
  ├──────────────────────────────────────────────────────────────┤
  │                                                               │
  │  ┌──────────────────┐                                        │
  │  │Complexity        │──→ simple → [Agent single]             │
  │  │Classifier        │──→ medium → [MoA 2-layer]              │
  │  │(0.0-1.0)         │──→ hard   → [MoA 3-layer]              │
  │  └──────────────────┘                                        │
  │                                                               │
  │  ┌─────────────────────────────────────────────────┐         │
  │  │           MoA LAYERED ARCHITECTURE               │         │
  │  │                                                   │         │
  │  │  ┌─────┐ ┌─────┐ ┌─────┐                         │         │
  │  │  │ A1  │ │ A2  │ │ A3  │  ← Layer N-1: Proposers │         │
  │  │  └──┬──┘ └──┬──┘ └──┬──┘                         │         │
  │  │     │       │       │                            │         │
  │  │     └───┬───┘───────┘                            │         │
  │  │         ▼                                        │         │
  │  │  ┌─────┐ ┌─────┐ ┌─────┐                         │         │
  │  │  │ B1  │ │ B2  │ │ B3  │  ← Layer N: Aggregators │         │
  │  │  └──┬──┘ └──┬──┘ └──┬──┘                         │         │
  │  │     │       │       │                            │         │
  │  │     └───┬───┘───────┘                            │         │
  │  │         ▼                                        │         │
  │  │  ┌──────────────┐                                │         │
  │  │  │   Consensus   │  ← Weighted voting / Debate   │         │
  │  │  │   Engine      │                                │         │
  │  │  └──────────────┘                                │         │
  │  └─────────────────────────────────────────────────┘         │
  │                                                               │
  │  ┌─────────────────────────────────────────────────┐         │
  │  │              REASONING ENGINES                   │         │
  │  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐        │         │
  │  │  │ CoT  │  │ ToT  │  │ GoT  │  │ReAct │        │         │
  │  │  │Seq.  │  │Tree  │  │Graph │  │Act+  │        │         │
  │  │  │Step  │  │Search│  │Dep.  │  │Reason│        │         │
  │  │  └──────┘  └──────┘  └──────┘  └──────┘        │         │
  │  └─────────────────────────────────────────────────┘         │
  │                                                               │
  └──────────────────────────────────────────────────────────────┘

tech_decisions:
  - "Complexity classifier: usar modelo flash para evaluar complejidad antes de enrutar"
  - "MoA agents: reutilizar los subagentes existentes (auditor, trader, visor) como proposers"
  - "Cuando no hay suficientes agentes especializados, instanciar agentes flash genéricos con diferentes prompts"
  - "Consensus engine: weighted voting con historial de accuracy por dominio"
  - "Debate protocol: cada agente ve los outputs anteriores y refina (como MoA paper)"
  - "Caching: hash del problema + contexto para reutilizar reasoning paths"
  - "Early exit: monitorear divergencia de opiniones, si convergen temprano, detener"
```

## code
```yaml
templates:
  - name: "moa_orchestrator"
    description: "Orquestador MoA con complexity classifier, layered execution y consensus"
    code: |
      from dataclasses import dataclass, field
      from typing import List, Dict, Any, Optional, Callable
      import asyncio, time, hashlib, json
      
      @dataclass
      class AgentResponse:
          agent_id: str
          content: str
          confidence: float
          reasoning_path: str  # "cot", "tot", "got", "react", "direct"
          latency_ms: float
          metadata: Dict = field(default_factory=dict)
      
      @dataclass
      class MoAConfig:
          max_layers: int = 3
          agents_per_layer: int = 3
          timeout_per_agent: float = 30.0
          min_consensus: float = 0.6
          max_debate_rounds: int = 3
          use_speculative: bool = True
          use_early_exit: bool = True
      
      class MoAOrchestrator:
          """Orquestador MoA que amplifica inteligencia mediante colaboración multi-agente."""
          
          def __init__(self, config: MoAConfig = None):
              self.config = config or MoAConfig()
              self.agent_registry = {}
              self.cache = {}
              self.accuracy_history = {}  # agent_id → {domain: accuracy}
          
          async def solve(self, problem: str, context: Dict = None) -> Dict[str, Any]:
              """Resuelve un problema usando MoA, adaptando profundidad según complejidad."""
              start = time.time()
              
              # 1. Evaluar complejidad
              complexity = await self._classify_complexity(problem)
              
              # 2. Decidir profundidad MoA
              if complexity < 0.3:
                  # Simple → agente único
                  return await self._single_agent(problem, context)
              elif complexity < 0.6:
                  # Medium → 1 capa MoA
                  layers = 1
              elif complexity < 0.85:
                  # Hard → 2 capas MoA
                  layers = 2
              else:
                  # Very hard → 3 capas MoA
                  layers = 3
              
              # 3. MoA execution
              result = await self._execute_moa(problem, context, layers)
              result["complexity"] = complexity
              result["layers_used"] = layers
              result["total_time_ms"] = (time.time() - start) * 1000
              
              return result
          
          async def _classify_complexity(self, problem: str) -> float:
              """Clasifica complejidad del problema usando heurísticas rápidas."""
              # Señales de alta complejidad
              signals = {
                  "longitud": len(problem.split()),
                  "preguntas_multiples": problem.count("?") > 2,
                  "requiere_investigacion": any(w in problem.lower() 
                      for w in ["investiga", "compara", "analiza", "diseña", "arquitectura"]),
                  "requiere_codigo": any(w in problem.lower() 
                      for w in ["código", "implementa", "programa", "script"]),
                  "multi_dominio": " y " in problem.lower() or " vs " in problem.lower(),
              }
              
              score = 0.0
              if signals["longitud"] > 20: score += 0.2
              if signals["preguntas_multiples"]: score += 0.3
              if signals["requiere_investigacion"]: score += 0.3
              if signals["requiere_codigo"]: score += 0.2
              if signals["multi_dominio"]: score += 0.3
              
              return min(score, 1.0)
          
          async def _execute_moa(self, problem: str, context: Dict, 
                                 num_layers: int) -> Dict[str, Any]:
              """Ejecuta arquitectura MoA multi-capa."""
              all_agents = self._select_agents(num_layers)
              layer_outputs = []
              
              for layer_idx in range(num_layers):
                  agents = all_agents[layer_idx]
                  tasks = []
                  
                  for agent in agents:
                      # Cada agente ve outputs de capa anterior
                      prev_context = "\n\n".join([
                          f"=== Output de {r.agent_id} ===\n{r.content}"
                          for r in layer_outputs
                      ]) if layer_outputs else ""
                      
                      task = self._run_agent(
                          agent_id=agent,
                          problem=problem,
                          prev_context=prev_context,
                          context=context,
                      )
                      tasks.append(task)
                  
                  # Ejecutar agentes en paralelo dentro de la capa
                  responses = await asyncio.gather(*tasks, return_exceptions=True)
                  valid = [r for r in responses if isinstance(r, AgentResponse)]
                  layer_outputs.extend(valid)
                  
                  # Early exit si hay consenso fuerte
                  if self.config.use_early_exit and len(valid) >= 2:
                      consensus = self._compute_consensus(valid)
                      if consensus["agreement"] > 0.9 and layer_idx < num_layers - 1:
                          break
              
              # Consenso final
              consensus = self._compute_consensus(layer_outputs)
              
              # Debate si consenso débil
              if consensus["agreement"] < self.config.min_consensus:
                  consensus = await self._debate_round(problem, layer_outputs, context)
              
              return {
                  "responses": [r.__dict__ for r in layer_outputs],
                  "consensus": consensus,
                  "num_agents_used": len(layer_outputs),
              }
          
          def _select_agents(self, num_layers: int) -> List[List[str]]:
              """Selecciona agentes para cada capa."""
              # En producción, seleccionar de registry según dominio
              layers = []
              for _ in range(num_layers):
                  layers.append([f"agent_{i}" for i in range(self.config.agents_per_layer)])
              return layers
          
          async def _run_agent(self, agent_id: str, problem: str, 
                              prev_context: str, context: Dict) -> AgentResponse:
              """Ejecuta un agente y captura su respuesta."""
              t0 = time.time()
              
              # En producción: llamar al modelo via task() o LLM directo
              response_content = f"[{agent_id} simulated response for: {problem[:50]}...]"
              confidence = 0.7 + (hash(agent_id) % 30) / 100  # Simulado
              
              elapsed = (time.time() - t0) * 1000
              return AgentResponse(
                  agent_id=agent_id,
                  content=response_content,
                  confidence=min(confidence, 1.0),
                  reasoning_path="cot",
                  latency_ms=elapsed,
              )
          
          def _compute_consensus(self, responses: List[AgentResponse]) -> Dict:
              """Calcula consenso ponderado entre respuestas."""
              if not responses:
                  return {"answer": None, "agreement": 0.0, "confidence": 0.0}
              
              # Votación ponderada por confianza
              weights = [r.confidence for r in responses]
              total_weight = sum(weights) or 1
              
              # Agreement = qué tan similares son las respuestas (simplificado)
              # En producción: usar embedding similarity
              agreement = 0.7  # Placeholder
              
              return {
                  "answer": responses[0].content,
                  "agreement": agreement,
                  "confidence": sum(weights) / len(weights) / total_weight,
                  "weighted_votes": [
                      {"agent": r.agent_id, "weight": r.confidence}
                      for r in responses
                  ]
              }
          
          async def _debate_round(self, problem: str, 
                                  responses: List[AgentResponse], 
                                  context: Dict) -> Dict:
              """Ciclo de debate entre agentes para alcanzar consenso."""
              for round_num in range(self.config.max_debate_rounds):
                  # Agentes ven outputs de otros y refinan
                  all_outputs = "\n\n".join([
                      f"{r.agent_id} (conf: {r.confidence:.2f}): {r.content}"
                      for r in responses
                  ])
                  
                  refined = []
                  for r in responses:
                      # En producción: llamar al modelo con prompt de debate
                      refined.append(r)
                  
                  responses = refined
                  consensus = self._compute_consensus(responses)
                  
                  if consensus["agreement"] >= self.config.min_consensus:
                      break
              
              return consensus
          
          async def _single_agent(self, problem: str, context: Dict) -> Dict:
              """Respuesta directa con un solo agente (para tareas simples)."""
              response = await self._run_agent("single", problem, "", context)
              return {
                  "mode": "single_agent",
                  "response": response.__dict__,
                  "complexity": 0.2,
              }

  - name: "reasoning_engine"
    description: "Motor de razonamiento multi-patrón (CoT, ToT, GoT, ReAct) con selección automática"
    code: |
      from typing import List, Dict, Any, Optional
      import itertools
      
      class ReasoningEngine:
          """Motor de razonamiento que selecciona y ejecuta el patrón óptimo."""
          
          @staticmethod
          def chain_of_thought(problem: str, steps: int = 5) -> str:
              """Chain-of-Thought: razonamiento paso a paso."""
              prompt = f"""Resuelve el siguiente problema paso a paso:
              
              Problema: {problem}
              
              Pasos:
              1)"""
              return prompt
          
          @staticmethod
          def tree_of_thought(problem: str, branches: int = 3, depth: int = 3) -> str:
              """Tree-of-Thought: exploración de múltiples caminos de razonamiento.
              
              BFS: explorar todas las ramas hasta cierta profundidad
              DFS: profundizar en una rama prometedora
              """
              prompt = f"""Explora múltiples caminos de razonamiento para:
              
              Problema: {problem}
              
              Genera {branches} enfoques diferentes. Para cada uno, desarrolla hasta {depth} niveles de profundidad.
              Luego evalúa cuál es el más prometedor y por qué.
              
              Rama 1:"""
              return prompt
          
          @staticmethod
          def graph_of_thought(problem: str) -> str:
              """Graph-of-Thought: razonamiento con dependencias y bifurcaciones."""
              prompt = f"""Analiza este problema como un grafo de pensamiento:
              
              Problema: {problem}
              
              Identifica:
              1. Conceptos/pasos fundamentales (nodos)
              2. Dependencias entre ellos (aristas)
              3. Caminos paralelos posibles
              4. Puntos de decisión donde el camino se bifurca
              5. Puntos de convergencia donde caminos se unen
              
              Luego resuelve siguiendo el grafo."""
              return prompt
          
          @staticmethod
          def react(problem: str, tools: List[str] = None) -> str:
              """ReAct: Reasoning + Acting interleaved."""
              tools = tools or ["search", "code", "calculator"]
              prompt = f"""Resuelve este problema usando Reasoning + Acting:
              
              Problema: {problem}
              
              Herramientas disponibles: {', '.join(tools)}
              
              Sigue este formato:
              Thought: [razonamiento sobre qué hacer]
              Action: [herramienta a usar]
              Observation: [resultado de la acción]
              ... (repetir hasta resolver)
              Thought: [respuesta final]"""
              return prompt
          
          @staticmethod
          def select_pattern(problem: str, complexity: float) -> str:
              """Selecciona automáticamente el patrón de razonamiento óptimo."""
              if complexity < 0.3:
                  return "direct"  # Sin razonamiento elaborado
              elif complexity < 0.5:
                  return "cot"     # Chain of Thought
              elif complexity < 0.7:
                  return "react"   # ReAct (necesita herramientas)
              elif complexity < 0.85:
                  return "tot"     # Tree of Thought
              else:
                  return "got"     # Graph of Thought

  - name: "self_consistency_ensemble"
    description: "Self-consistency con majority voting para respuestas robustas"
    code: |
      from typing import List, Dict, Any
      from collections import Counter
      
      class SelfConsistency:
          """Múltiples muestras → majority vote → respuesta robusta."""
          
          @staticmethod
          def vote(responses: List[str], weights: List[float] = None) -> Dict:
              """Majority voting ponderado sobre múltiples respuestas."""
              if not responses:
                  return {"answer": None, "confidence": 0.0}
              
              if weights is None:
                  weights = [1.0] * len(responses)
              
              # Normalizar pesos
              total = sum(weights)
              weights = [w/total for w in weights]
              
              # Votación (simplificada: en producción usar embedding similarity)
              # Agrupar respuestas similares
              clusters = {}
              for resp, w in zip(responses, weights):
                  key = resp[:100]  # Simplified clustering
                  if key in clusters:
                      clusters[key]["weight"] += w
                      clusters[key]["count"] += 1
                  else:
                      clusters[key] = {"response": resp, "weight": w, "count": 1}
              
              # Seleccionar cluster con mayor peso
              best = max(clusters.values(), key=lambda x: x["weight"])
              
              return {
                  "answer": best["response"],
                  "confidence": best["weight"],
                  "num_samples": len(responses),
                  "num_clusters": len(clusters),
                  "agreement": best["count"] / len(responses),
              }

libraries:
  - "asyncio (stdlib) — ejecución paralela de agentes"
  - "itertools (stdlib) — combinaciones de razonamiento"
  - "dataclasses (stdlib) — estructuras de datos"
  - "hashlib + json (stdlib) — cache keys"
  - "No requiere paquetes pip externos (usa subagentes existentes del enjambre)"
```

## checks
```yaml
validation_checks:
  - category: "Complexity Classification"
    checks:
      - "[ ] Classifier retorna 0.0-1.0 correctamente"
      - "[ ] Problemas simples (<0.3) → single agent"
      - "[ ] Problemas medios (0.3-0.6) → MoA 1 capa"
      - "[ ] Problemas complejos (0.6-0.85) → MoA 2 capas"
      - "[ ] Problemas muy complejos (>0.85) → MoA 3 capas"
  
  - category: "MoA Execution"
    checks:
      - "[ ] Agentes en misma capa ejecutan en paralelo"
      - "[ ] Capas ejecutan en secuencia (outputs capa N-1 → inputs capa N)"
      - "[ ] Cada agente recibe outputs de TODOS los agentes de capa anterior"
      - "[ ] Timeout por agente: 30s, fallos no bloquean"
      - "[ ] Early exit funciona: si consenso >0.9, detener capas restantes"
  
  - category: "Consensus Engine"
    checks:
      - "[ ] Weighted voting: pesos = confianza * accuracy * relevancia"
      - "[ ] Consenso débil (<0.6) → debate loop (max 3 rounds)"
      - "[ ] Confidence calibration: <0.5 → marcar como incierto"
      - "[ ] Self-consistency: majority vote sobre N>=3 muestras"
  
  - category: "Reasoning Patterns"
    checks:
      - "[ ] CoT: genera pasos secuenciales, cada paso depende del anterior"
      - "[ ] ToT: múltiples ramas, evalúa y poda (BFS/DFS)"
      - "[ ] GoT: grafo con bifurcaciones y convergencias"
      - "[ ] ReAct: intercala reasoning + action + observation"
      - "[ ] Pattern selector elige óptimo según complejidad"
  
  - category: "Speed & Efficiency"
    checks:
      - "[ ] Complexity classifier corre en <1s (modelo flash)"
      - "[ ] Speculative execution: agente único arranca mientras clasificador corre"
      - "[ ] Cache de reasoning paths: mismo problema → evitar recomputar"
      - "[ ] MoA overhead < 2x tiempo de agente único para misma tarea"
      - "[ ] Token budget: 75% proposers, 25% aggregators"
```

## examples
```yaml
uso_tipico:
  - "Necesito razonamiento profundo sobre la mejor arquitectura para un sistema de trading: "
    "→ Complexity classifier: 0.82 (hard) → MoA 2 capas "
    "→ Layer 1: 3 agentes proponen (auditor, trader, arquitecto) "
    "→ Layer 2: 2 agentes agregan y refinan "
    "→ Consensus engine: weighted voting con debate "
    "→ Respuesta final con confianza 0.87"
    
  - "Analiza desde múltiples perspectivas el impacto de subir tasas de interés: "
    "→ ToT con 3 ramas (económico, social, político) "
    "→ Cada rama depth=3 "
    "→ Votación entre ramas "
    "→ Self-consistency con 5 muestras → confianza >0.9"
    
  - "Implementa un parser de CSV con validaciones: "
    "→ Complexity classifier: 0.35 (medium) → MoA 1 capa "
    "→ ReAct pattern (razona + escribe código) "
    "→ 2 agentes: code + QA "
    "→ Consensus on final implementation"
```

---

*Skill generada por autoaprendizaje | Entrenamiento: 5 módulos | 2026-06-07*
*Inspirado en: Mixture-of-Agents (Wang et al. 2024), CoT (Wei et al. 2022), ToT (Yao et al. 2023), ReAct (Yao et al. 2023), Switch Transformer (Fedus et al. 2021)*

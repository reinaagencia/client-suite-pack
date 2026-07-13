# Comandos y Patrones Validados

## MoA Orchestration
- `MoAOrchestrator.solve(problem, context)` — Pipeline MoA completo
- `ComplexityClassifier` → decide single/MoA-1/MoA-2/MoA-3 capas
- `ConsensusEngine.compute_consensus()` — Weighted voting
- `DebateEngine.debate()` — Ciclo de refinamiento multi-agente

## Reasoning Patterns
- `ReasoningEngine.chain_of_thought(problem)` — Razonamiento paso a paso
- `ReasoningEngine.tree_of_thought(problem, branches, depth)` — Multi-rama
- `ReasoningEngine.graph_of_thought(problem)` — Grafo de dependencias
- `ReasoningEngine.react(problem, tools)` — Reasoning + Acting

## Self-Consistency
- `SelfConsistency.vote(responses, weights)` — Majority voting
- Clustering de respuestas por similitud semántica
- Confidence scoring basado en agreement entre muestras

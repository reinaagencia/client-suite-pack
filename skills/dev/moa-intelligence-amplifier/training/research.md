# Research: MoA Intelligence Amplifier

## Fuentes consultadas
1. Mixture-of-Agents (Wang et al. 2024) — Layered MoA architecture, SOTA on AlpacaEval
2. Chain-of-Thought (Wei et al. 2022) — Step-by-step reasoning
3. Tree-of-Thoughts (Yao et al. 2023) — Multi-path reasoning with BFS/DFS
4. Graph-of-Thoughts (Besta et al. 2023) — Reasoning as graph with branching + merging
5. ReAct (Yao et al. 2023) — Synergizing reasoning and acting
6. Reflexion (Shinn et al. 2023) — Self-reflection for improvement
7. Switch Transformer (Fedus et al. 2021) — Mixture-of-Experts routing
8. Self-Consistency (Wang et al. 2022) — Majority voting over multiple samples
9. Algorithm Distillation (Laskin et al. 2023) — In-context RL from history

## Técnicas clave identificadas
- MoA layered: proposers → aggregators con refinamiento progresivo
- CoT/ToT/GoT: selección automática según tipo de problema
- Weighted consensus por confianza + accuracy histórica
- Debate protocol entre agentes para alcanzar consenso
- Self-consistency con majority voting
- Complexity classifier para decidir profundidad MoA
- Speculative execution + early exit para eficiencia

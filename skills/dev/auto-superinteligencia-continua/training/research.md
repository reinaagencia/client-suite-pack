# Investigación: Superinteligencia Agéntica Auto-mejorante

## Fuentes consultadas
1. SWE-agent paper (NeurIPS 2024) - Agent-Computer Interfaces
2. mini-SWE-agent - 100-line agent, 74% SWE-bench verified
3. Reflexion (Shinn et al. 2023) - Verbal Reinforcement Learning
4. CrewAI - Multi-agent orchestration framework
5. SWE-bench - Benchmark for software engineering agents
6. LangGraph Advanced - State management patterns

## Hallazgos clave
- La simplicidad (mini-SWE-agent) supera a la complejidad (SWE-agent original)
- La reflexión verbal sin weight updates es suficiente para aprendizaje continuo
- Bash como única herramienta elimina complejidad innecesaria
- Los benchmarks objetivos son el único camino para mejora medible
- La replicación de agentes requiere extracción de recetas, no copia de código

## Arquitecturas estudiadas
- ACI (Agent-Computer Interface): interfaces diseñadas para agentes, no humanos
- Episodic Memory: buffer de experiencias completas con auto-crítica
- Verbal RL: feedback lingüístico como señal de refuerzo
- Self-Play: generación de datos de entrenamiento desde ejecuciones naturales
- Recipe Extraction: prompts + thresholds + patterns como unidad de clonación

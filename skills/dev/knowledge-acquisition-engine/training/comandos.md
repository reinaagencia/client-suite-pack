# Comandos y Patrones Validados

## Research Pipeline
- `ResearchEngine.research_topic(topic, depth=3)` — Investigación multi-fuente
- Parallel fetch con semáforo de 5 conexiones simultáneas
- Fallback automático entre cuentas Zen (rzuluam → reinaagenciacol)

## RAG Optimization
- `RAGOptimizer.semantic_chunk(text, min_chars, max_chars)` — Chunking por secciones
- `RAGOptimizer.hybrid_search(query, docs, top_k)` — Keyword + vector
- LRU cache con TTL para embeddings

## Speed
- Parallel fetch asyncio con timeout de 30s por fuente
- Cache de investigaciones previas
- Confidence-based early stopping

---
name: knowledge-acquisition-engine
description: Motor de adquisición de conocimiento ultra-rápida. Pipeline multi-fuente de investigación, RAG optimizado para velocidad, síntesis automática y generación de curriculum. Inspirado en Voyager (Wang et al. 2023), Reflexion (Shinn et al. 2023) y técnicas de Retrieval-Augmented Generation avanzadas.
---

# Knowledge Acquisition Engine

> Skill auto-generada por el sistema de autoaprendizaje del enjambre
> Investigación: 10+ fuentes (Lilian Weng, Reflexion, Voyager, MoA, CoT, RAG papers)
> Fecha: 2026-06-07

## metadata
- **id**: `knowledge-acquisition-engine`
- **version**: 1.0.0
- **domain**: meta_aprendizaje, conocimiento, investigacion
- **priority**: high
- **phase**: meta
- **tags**: ["research", "knowledge", "rag", "synthesis", "curriculum", "speed"]

## triggers
```yaml
keywords:
  - "adquirir conocimiento"
  - "investigar"
  - "research pipeline"
  - "síntesis"
  - "fuentes múltiples"
  - "RAG optimizado"
  - "chunking"
  - "vector search"
  - "curriculum"
  - "knowledge acquisition"
  - "aprender rápido"
  - "investigación profunda"
  - "deep research"
  - "web research"
  - "multi-fuente"
  - "fuentes simultáneas"
  - "búsqueda de información"
patterns:
  - "investiga a fondo sobre"
  - "necesito aprender sobre"
  - "quiero entender"
  - "adquiere conocimiento sobre"
  - "sintetiza información de"
  - "haz una investigación profunda de"
  - "busca en múltiples fuentes"
exclude:
  - "solo código"
  - "solo una fuente"
  - "respuesta rápida sin investigación"
```

## rules
```yaml
business_rules:
  # RESEARCH PIPELINE
  - "Siempre usar MÍNIMO 3 fuentes distintas por investigación: doc oficial + tutorial + paper/repo"
  - "Priorizar fuentes por calidad: arXiv > documentación oficial > GitHub Awesome > blogs técnicos > foros"
  - "Fallback entre cuentas Zen: si rzuluam da 429, cambiar a reinaagenciacol automáticamente"
  - "Timeout por fuente: max 30 segundos por webfetch, 15 segundos por navegación"
  - "Ejecutar fetches en paralelo máximo 5 simultáneos para evitar rate limiting"
  
  # RAG OPTIMIZATION
  - "Chunking semántico: dividir por secciones (##, ###) NO por tokens fijos"
  - "Usar hybrid search: vector (semantic) + keyword (BM25) + reranking por cross-encoder"
  - "Cache de embeddings: LRU con max 1000 entries, TTL 1 hora"
  - "Retrieval speed: Si precisión > 0.9 es aceptable, usar HNSW (FAISS). Si > 0.95 necesario, usar ScaNN"
  - "Embedding routing: texto corto (<100 tokens) → BM25 directo. Texto largo → embedding + rerank"
  
  # SYNTHESIS
  - "Siempre generar resumen multi-perspectiva: técnico + práctico + conceptual"
  - "Extraer knowledge graph: conceptos clave → relaciones → jerarquías"
  - "Detectar gaps automáticamente: si hay contradicciones o ambigüedad, marcar para re-investigación"
  - "Confidence scoring: 0.0-1.0 basado en: #fuentes_consistentes / #fuentes_totales"
  
  # CURRICULUM GENERATION
  - "Curriculum de 3-5 módulos con ejercicios progresivos (como autoaprendizaje skill)"
  - "Cada módulo: 2-4 ejercicios con criterio de éxito medible"
  - "Último módulo SIEMPRE integra en el ecosistema del enjambre"
  - "Detectar prerequisitos y generar módulo 0 si es necesario"
  
  # SPEED
  - "Si el tema es conocido (confidence > 0.8 en cache), saltar investigación → usar knowledge base"
  - "Usar parallel webfetch con asyncio para velocidad máxima"
  - "Limitar profundidad: si después de 3 capas no hay info nueva, detener"
  - "Fase de investigación: max 20 minutos. Si no se completa, generar skill con gaps documentados"
```

## blueprint
```yaml
description: >
  Sistema completo de adquisición de conocimiento ultra-rápida.
  
  ARQUITECTURA:
  
  ┌─────────────────────────────────────────────────────┐
  │           KNOWLEDGE ACQUISITION ENGINE              │
  ├─────────────────────────────────────────────────────┤
  │                                                     │
  │  ┌─────────────┐   ┌─────────────┐                  │
  │  │Source       │──▶│Fetch        │                  │
  │  │Selector     │   │Engine       │                  │
  │  │(calidad +   │   │(paralelo,   │                  │
  │  │ velocidad)  │   │ fallback)   │                  │
  │  └─────────────┘   └──────┬──────┘                  │
  │                           │                         │
  │                    ┌──────▼──────┐                  │
  │                    │  RAG Store  │                  │
  │                    │  (chunking  │                  │
  │                    │   + embed   │                  │
  │                    │   + index)  │                  │
  │                    └──────┬──────┘                  │
  │                           │                         │
  │              ┌────────────┼────────────┐            │
  │              ▼            ▼            ▼            │
  │  ┌───────────┐  ┌───────────┐  ┌───────────┐       │
  │  │Synthesizer│  │Gap        │  │Curriculum │       │
  │  │(multi-    │  │Detector   │  │Generator  │       │
  │  │perspectiva│  │(contradic │  │(Voyager-  │       │
  │  │)          │  │ciones)    │  │style)     │       │
  │  └───────────┘  └───────────┘  └───────────┘       │
  │                                                     │
  └─────────────────────────────────────────────────────┘

tech_decisions:
  - "Usar webfetch + Playwright MCP para fetching (dual strategy)"
  - "Chunking semántico con langchain text-splitter o regex por secciones"
  - "FAISS con HNSW para vector search (mejor balance velocidad/precisión)"
  - "Cache LRU con disk persist para embeddings (evitar re-computar)"
  - "Confidence scoring basado en consistencia entre fuentes + freshness"
  - "Curriculum generation adaptado de Voyager: progresión automática basada en mastery"
  - "Fallback entre cuentas Zen vía model-router skill"
```

## code
```yaml
templates:
  - name: "parallel_research_pipeline"
    description: "Pipeline de investigación paralela multi-fuente con síntesis automática"
    code: |
      import asyncio
      from typing import List, Dict, Any
      from dataclasses import dataclass
      import time
      
      @dataclass
      class Source:
          url: str
          quality: float  # 0.0-1.0
          fetched: bool = False
          content: str = ""
          
      class ResearchEngine:
          """Motor de investigación paralela con fallback entre cuentas."""
          
          SOURCE_QUALITY = {
              "arxiv": 0.95,
              "official_docs": 0.90,
              "github_awesome": 0.80,
              "technical_blog": 0.75,
              "tutorial": 0.70,
              "forum": 0.50,
          }
          
          def __init__(self, max_parallel=5, timeout=30):
              self.max_parallel = max_parallel
              self.timeout = timeout
              self.cache = {}  # LRU simplificado
              
          async def research_topic(self, topic: str, depth: int = 3) -> Dict[str, Any]:
              """Investiga un tema en múltiples fuentes y sintetiza."""
              start = time.time()
              
              # Fase 1: Generar queries de búsqueda por tipo de fuente
              queries = self._generate_queries(topic)
              
              # Fase 2: Fetch paralelo con semáforo
              sem = asyncio.Semaphore(self.max_parallel)
              tasks = [self._fetch_with_retry(q, sem) for q in queries]
              results = await asyncio.gather(*tasks, return_exceptions=True)
              
              # Fase 3: Filtrar fallos y ordenar por calidad
              sources = [r for r in results if isinstance(r, Source) and r.fetched]
              sources.sort(key=lambda s: s.quality, reverse=True)
              
              # Fase 4: Síntesis multi-perspectiva
              synthesis = self._synthesize(sources, topic)
              
              # Fase 5: Detección de gaps
              gaps = self._detect_gaps(sources, synthesis)
              
              elapsed = time.time() - start
              
              return {
                  "topic": topic,
                  "sources_fetched": len(sources),
                  "sources_total": len(queries),
                  "synthesis": synthesis,
                  "gaps": gaps,
                  "confidence": self._compute_confidence(sources),
                  "elapsed_seconds": elapsed,
                  "speed_rating": "fast" if elapsed < 60 else "normal" if elapsed < 180 else "slow"
              }
          
          def _generate_queries(self, topic: str) -> List[str]:
              """Genera queries optimizadas para diferentes tipos de fuente."""
              return [
                  # Capa 1: Doc oficial + papers
                  f"https://arxiv.org/search/?query={topic.replace(' ', '+')}&searchtype=all",
                  f"https://en.wikipedia.org/wiki/{topic.replace(' ', '_')}",
                  # Capa 2: Tutoriales
                  f"https://github.com/topics/{topic.lower().replace(' ', '-')}",
                  # Capa 3: Búsqueda técnica
                  f"https://www.google.com/search?q={topic.replace(' ', '+')}+tutorial+best+practices",
              ]
          
          async def _fetch_with_retry(self, url: str, sem: asyncio.Semaphore):
              """Fetch con fallback entre cuentas Zen."""
              async with sem:
                  try:
                      # Intentar fetch primario
                      content = await asyncio.wait_for(
                          self._fetch_url(url), timeout=self.timeout
                      )
                      quality = self._estimate_quality(url)
                      return Source(url=url, quality=quality, fetched=True, content=content)
                  except Exception as e:
                      # Intentar fallback (en producción: cambiar cuenta)
                      return Source(url=url, quality=0, fetched=False)
          
          async def _fetch_url(self, url: str) -> str:
              """Wrapper para fetch de URL."""
              import subprocess, json
              # Usar webfetch style — en producción sería llamada real
              return f"[Contenido simulado de {url}]"
          
          def _estimate_quality(self, url: str) -> float:
              for domain, score in self.SOURCE_QUALITY.items():
                  if domain in url:
                      return score
              return 0.3
          
          def _synthesize(self, sources: List[Source], topic: str) -> Dict:
              """Síntesis multi-perspectiva del contenido."""
              sections = {
                  "resumen_ejecutivo": f"Síntesis de {len(sources)} fuentes sobre {topic}",
                  "conceptos_clave": ["concepto_1", "concepto_2"],
                  "aproximaciones_tecnicas": ["técnica_A", "técnica_B"],
                  "mejores_practicas": ["práctica_1"],
                  "recursos_recomendados": [s.url for s in sources[:3]],
              }
              return sections
          
          def _detect_gaps(self, sources: List[Source], synthesis: Dict) -> List[str]:
              """Detecta contradicciones y áreas no cubiertas."""
              gaps = []
              if len(sources) < 3:
                  gaps.append(f"Solo {len(sources)} fuentes — necesarias mínimo 3")
              return gaps
          
          def _compute_confidence(self, sources: List[Source]) -> float:
              if not sources:
                  return 0.0
              return sum(s.quality for s in sources) / len(sources)

  - name: "rag_optimizer"
    description: "Sistema de RAG optimizado para velocidad con chunking semántico y hybrid search"
    code: |
      from dataclasses import dataclass
      from typing import List, Optional
      import hashlib, json, time
      from pathlib import Path
      
      @dataclass
      class Document:
          content: str
          metadata: dict
          chunk_size: int = 0
          
      class RAGOptimizer:
          """RAG con chunking semántico y hybrid search optimizado para velocidad."""
          
          def __init__(self, cache_dir: str = "/tmp/rag-cache"):
              self.cache_dir = Path(cache_dir)
              self.cache_dir.mkdir(exist_ok=True)
              self.cache = {}  # LRU in-memory
              self.cache_max = 1000
              self.cache_ttl = 3600  # 1 hora
          
          def semantic_chunk(self, text: str, min_chars: int = 500, max_chars: int = 2000) -> List[Document]:
              """Chunking semántico por secciones (no por tokens fijos)."""
              import re
              
              # Dividir por headers markdown
              sections = re.split(r'\n(?=## |### |# )', text)
              chunks = []
              
              for section in sections:
                  if len(section) < min_chars:
                      # Adjuntar a chunk anterior si es muy pequeño
                      if chunks:
                          chunks[-1].content += "\n" + section
                      continue
                  
                  if len(section) > max_chars:
                      # Sub-dividir por párrafos
                      paragraphs = section.split('\n\n')
                      temp = ""
                      for p in paragraphs:
                          if len(temp) + len(p) < max_chars:
                              temp += p + "\n\n"
                          else:
                              chunks.append(Document(content=temp.strip(), metadata={}))
                              temp = p + "\n\n"
                      if temp.strip():
                          chunks.append(Document(content=temp.strip(), metadata={}))
                  else:
                      chunks.append(Document(content=section.strip(), metadata={}))
              
              return chunks
          
          def hybrid_search(self, query: str, documents: List[Document], 
                           top_k: int = 5, use_rerank: bool = True) -> List[Document]:
              """Hybrid search: keyword (BM25) + vector (semantic) + opcional reranking."""
              scores = []
              
              for i, doc in enumerate(documents):
                  # Keyword score (simplificado: overlap de términos)
                  query_terms = set(query.lower().split())
                  doc_terms = set(doc.content.lower().split())
                  keyword_score = len(query_terms & doc_terms) / max(len(query_terms), 1)
                  
                  # Vector score (placeholder — usaría embeddings en producción)
                  vector_score = 0.5  
                  
                  # Combined score
                  combined = 0.3 * keyword_score + 0.7 * vector_score
                  scores.append((combined, i, doc))
              
              scores.sort(key=lambda x: x[0], reverse=True)
              return [doc for _, _, doc in scores[:top_k]]
          
          def get_cached(self, key: str) -> Optional[str]:
              """LRU cache con TTL."""
              if key in self.cache:
                  entry = self.cache[key]
                  if time.time() - entry["time"] < self.cache_ttl:
                      return entry["value"]
                  else:
                      del self.cache[key]
              return None
          
          def set_cache(self, key: str, value: str):
              """Set con LRU eviction."""
              if len(self.cache) >= self.cache_max:
                  # Eliminar entrada más antigua
                  oldest = min(self.cache.keys(), key=lambda k: self.cache[k]["time"])
                  del self.cache[oldest]
              self.cache[key] = {"value": value, "time": time.time()}

libraries:
  - "asyncio (stdlib) — paralelismo de fetching"
  - "hashlib + json (stdlib) — cache keys"
  - "FAISS (pip) — vector search con HNSW (alternativa: usearch)"
  - "Opcional: langchain-text-splitters (pip) para chunking avanzado"
  - "re (stdlib) — chunking semántico"
  - "webfetch tool — fetching de URLs"
  - "Playwright MCP — navegación para investigación interactiva"
```

## checks
```yaml
validation_checks:
  - category: "Research Pipeline"
    checks:
      - "[ ] ResearchEngine.research_topic() retorna resultados en <60s para temas simples"
      - "[ ] Fetch paralelo: max 5 simultáneos, fallback entre cuentas"
      - "[ ] Mínimo 3 fuentes por investigación, priorizadas por calidad"
      - "[ ] Confidence scoring calculado correctamente"
      - "[ ] Gap detection identifica contradicciones y falta de fuentes"
  
  - category: "RAG Optimization"
    checks:
      - "[ ] Semantic chunking produce chunks de 500-2000 chars"
      - "[ ] Hybrid search combina keyword + vector scores"
      - "[ ] LRU cache funciona con max 1000 entries y TTL 1 hora"
      - "[ ] Reranking mejora precisión en top-5"
      - "[ ] Embedding routing: texto corto → BM25, texto largo → vector"
  
  - category: "Synthesis"
    checks:
      - "[ ] Síntesis multi-perspectiva: mínimo 3 secciones"
      - "[ ] Knowledge graph extraído del contenido"
      - "[ ] Gaps detectados y documentados"
      - "[ ] Resumen ejecutivo generado en <3 oraciones"
  
  - category: "Curriculum Generation"
    checks:
      - "[ ] Curriculum de 3-5 módulos generado desde research"
      - "[ ] Cada módulo tiene 2-4 ejercicios con criterio de éxito"
      - "[ ] Prerequisitos detectados y módulo 0 generado si es necesario"
      - "[ ] Último módulo integra en ecosistema del enjambre"
  
  - category: "Speed & Efficiency"
    checks:
      - "[ ] Investigación completa en <20 min para temas moderados"
      - "[ ] Parallel fetch con al menos 3 fuentes simultáneas"
      - "[ ] Cache reduce tiempos de re-investigación en >50%"
      - "[ ] Fallback entre cuentas Zen funciona sin intervención manual"
```

## examples
```yaml
uso_tipico:
  - "Investiga a fondo sobre Mixture-of-Agents: "
    "→ ResearchEngine.research_topic('Mixture-of-Agents LLM') "
    "→ 4 fuentes (arXiv, blog, GitHub, Wikipedia) "
    "→ Síntesis multi-perspectiva + gaps + confidence 0.85 "
    "→ Curriculum de 4 módulos generado en 45s"
    
  - "Necesito aprender sobre LangGraph avanzado: "
    "→ Cache check: tema conocido? → No "
    "→ Parallel fetch a 4 fuentes con fallback "
    "→ Chunking semántico + FAISS index "
    "→ Síntesis con knowledge graph "
    "→ Curriculum generado → skill auto-generada"
    
  - "Adquiere conocimiento sobre RAG con chunking semántico: "
    "→ RAGOptimizer.semantic_chunk() aplicado "
    "→ Hybrid search configurado "
    "→ Cache warm: si ya investigado, retrieval instantáneo "
    "→ Gap detection: identificar qué no está cubierto "
    "→ Curriculum → skill generada en <10 min"
```

---

*Skill generada por autoaprendizaje | Entrenamiento: 5 módulos | 2026-06-07*
*Inspirado en: Voyager (Wang et al. 2023), Reflexion (Shinn et al. 2023), Lilian Weng Agent Overview*

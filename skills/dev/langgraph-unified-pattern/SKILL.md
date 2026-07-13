---
name: langgraph-unified-pattern
description: Patrón unificado de LangGraph para todo el ecosistema. Documenta el diseño compartido entre agent-swarm (Python) y queenchat-agent (TypeScript). Generada por revisión estratégica del enjambre el 2026-06-04.
---

# LangGraph Unified Pattern

> Skill auto-generada por la revisión estratégica del ecosistema (4 Jun 2026)
> Unifica los patrones de LangGraph entre agent-swarm (Python) y queenchat-agent (TypeScript)

## metadata
- **id**: `langgraph-unified-pattern`
- **version**: 1.0.0
- **domain**: architecture
- **priority**: high
- **phase**: pattern

## triggers
```yaml
keywords:
  - "langgraph"
  - "state graph"
  - "state machine"
  - "pipeline de agentes"
  - "agent pipeline"
  - "graph state"
  - "StateGraph"
  - "nodo langgraph"
  - "conditional edge"
  - "checkpointer"
patterns:
  - "crea un pipeline de agentes con"
  - "implementa un grafo de estado para"
  - "diseña la arquitectura del grafo"
  - "unifica los grafos de"
exclude:
  - "solo react"
  - "sin langgraph"
  - "graphql"
```

## rules
```yaml
business_rules:
  - "TODO pipeline LangGraph DEBE tener un TypedDict/interface de estado canónico"
  - "TODO nodo DEBE ser una función pura: state → dict (partial update)"
  - "Los nodos NO deben mutar el state directamente — siempre retornar dict parcial"
  - "Las conditional edges DEBEN usar lambdas, no funciones con side-effects"
  - "El entry point DEBE ser un router (nunca un nodo de ejecución directa)"
  - "El checkpointer DEBE ser MemorySaver para desarrollo, SupabaseCheckpointer para producción (si es estable)"
  - "TODO grafo DEBE tener un nodo de clasificación/ruteo inicial"
  - "Los Human-in-the-loop (interrupts) solo para acciones sensibles (calendar_cancel, calendar_create, daemon_execute)"
  - "Los tool calls DEBEN tener parseTextToolCalls como fallback para modelos que no generan structured tool_calls"
  - "El sistema prompt DEBE ser estático (hardcoded) en producción — NO leer de base de datos en cada invocación"
  - "Los mensajes del historial DEBEN condensarse si superan 15 entradas (resumen + últimos 4)"
  - "Los errores 429/401/402 DEBEN manejarse con fallback automático (nunca cascada)"
```

## blueprint
```yaml
description: >
  Patrón arquitectónico unificado para todos los pipelines LangGraph
  del ecosistema. Se aplica tanto a agent-swarm (Python, 13 nodos + 3 gates)
  como a queenchat-agent (TypeScript, 4 nodos).

  ARQUITECTURA CANÓNICA:
  ```
  Entry Router → [Gate 0: Meta-Planner] → Prep → Orquestador
       → [Gate 1: Viabilidad] → Arquitecto → [Gate 2: Arq] 
       → Programador ⇄ Tester → [Gate 3: Loop] → Extractor → Reflexión → END
  ```

  Para QueenChat (conversacional):
  ```
  START → Classify (boss/lead/ally/unknown) → Agent (prompt + tools)
       → Tools (ejecución) → Agent → ... → END
  ```

  PRINCIPIOS:
  1. Un estado (TypedDict/interface), muchas vistas parciales
  2. Nodos puros, routing condicional, checkpoints para reanudar
  3. Human-in-the-loop solo en operaciones críticas
  4. Cache-friendly: system prompts estáticos, inputs estructurados
  5. Fallback multi-nivel para APIs externas
tech_decisions:
  - "Python: usar langgraph.graph.StateGraph con TypedDict como state"
  - "TypeScript: usar @langchain/langgraph con ConversationState"
  - "Checkpointer: MemorySaver para dev, SupabaseCheckpointer si se resuelve serialización circular"
  - "Tools: bindTools() en TS, functions manuales en Python"
  - "Interrupts: solo para calendar_cancel, calendar_create, daemon_execute en producción"
```

## code
```yaml
templates:
  - name: "python-state-graph"
    description: "Template de StateGraph en Python (agent-swarm style)"
    code: |
      from typing import TypedDict, Annotated, Optional
      from langgraph.graph import StateGraph, END, add_messages
      import operator

      class TeamState(TypedDict):
          user_requirement: str
          business_rules: list[str]
          source_code: dict
          test_report: dict
          scratchpad: Annotated[list[str], operator.add]
          iteration_count: int
          loop_detected: bool

      def router_node(state: TeamState) -> dict:
          if state.get("loop_detected"):
              return {"_next": "fail_diagnosis"}
          return {"_next": "programmer"}

      def build_graph() -> StateGraph:
          workflow = StateGraph(TeamState)
          workflow.add_node("programmer", lambda s: {"source_code": {"main.py": "# code"}})
          workflow.add_node("tester", lambda s: {"test_report": {"status": "PASS"}})
          workflow.add_node("fail_diagnosis", lambda s: {"scratchpad": ["diagnóstico"]})
          workflow.set_entry_point("tester")
          workflow.add_conditional_edges("tester", router_node, {
              "programmer": "programmer",
              "fail_diagnosis": "fail_diagnosis",
              END: END,
          })
          workflow.add_edge("programmer", "tester")
          return workflow.compile()

  - name: "typescript-agent-graph"
    description: "Template de StateGraph en TypeScript (queenchat-agent style)"
    code: |
      import { StateGraph, END, START, MemorySaver } from "@langchain/langgraph";
      import { ConversationState } from "./state";
      import { allTools } from "./tools";

      const model = new ChatOpenAI({ model: "qwen/qwen3-30b-a3b" }).bindTools(allTools);

      async function classify(state: typeof ConversationState.State) {
          return { agentType: "boss" };
      }

      async function agentNode(state: typeof ConversationState.State) {
          const systemPrompt = "Eres un asistente...";
          const messages = [new SystemMessage(systemPrompt), ...state.messages];
          const response = await model.invoke(messages);
          return { messages: [response] };
      }

      function toolsCondition(state: typeof ConversationState.State): string {
          const lastMsg = state.messages[state.messages.length - 1];
          if ((lastMsg as any).tool_calls?.length) return "tools";
          return END;
      }

      const agentGraph = new StateGraph(ConversationState)
          .addNode("classify", classify)
          .addNode("agent", agentNode)
          .addNode("tools", toolNode)
          .addEdge(START, "classify")
          .addConditionalEdges("classify", routeByType)
          .addConditionalEdges("agent", toolsCondition)
          .addEdge("tools", "agent")
          .compile({ checkpointer: new MemorySaver() });

libraries:
  - "Python: langgraph>=0.3.0, langchain-core, langchain-openai"
  - "TypeScript: @langchain/langgraph>=0.2.0, @langchain/openai, @langchain/core"
  - "Ambos: dotenv para configuración de entorno"
```

## checks
```yaml
validation_checks:
  - category: "Estructura del Grafo"
    checks:
      - "[ ] State definido como TypedDict (Python) o interface (TS)"
      - "[ ] Entry point definido (set_entry_point / addEdge START)"
      - "[ ] TODOS los nodos retornan dict parcial (no mutan state)"
      - "[ ] Conditional edges cubren TODOS los posibles valores de retorno"
      - "[ ] Hay al menos un nodo router/clasificador al inicio"
      - "[ ] Los checkpoints se limpian después de ejecución exitosa"
  - category: "Manejo de Errores"
    checks:
      - "[ ] Errores 429/401/402 tienen fallback multi-nivel"
      - "[ ] Tool calls tienen fallback parseTextToolCalls (TS)"
      - "[ ] Conversaciones largas se condensan (>15 mensajes)"
      - "[ ] System prompt es estático (no se lee de DB en cada request)"
  - category: "Human-in-the-loop"
    checks:
      - "[ ] Interrupts solo para operaciones sensibles"
      - "[ ] Boss no pasa por approval (ya confirma en texto)"
      - "[ ] Approval tiene timeout y cleanup"
  - category: "Performance"
    checks:
      - "[ ] System prompts estáticos para máximo cache hit"
      - "[ ] Historial de mensajes limitado (últimos 20 o condensado)"
      - "[ ] No hay llamadas blocking en nodos async"
```

## examples
```yaml
uso_tipico:
  - "Crear pipeline de agentes en Python con 5 nodos + gates de auditor"
  - "Migrar pipeline existente de LangChain a LangGraph"
  - "Añadir human-in-the-loop para operaciones críticas"
  - "Unificar patrón de estado entre agent-swarm y queenchat-agent"
  - "Implementar checkpointer persistente con Supabase"
```

*Skill generada por revisión estratégica | Junio 2026*

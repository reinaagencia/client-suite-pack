# 🧠 LangGraph Avanzado — Skill del Enjambre

> **Propósito**: Construcción de grafos de lenguaje avanzados con LangGraph. State management, conditional edges, checkpointing, interrupts, memory store, subgraphs y streaming.

---

## 📦 Instalación

```bash
pip install langgraph langgraph-checkpoint langgraph-store langchain-core
pip install langgraph-checkpoint-sqlite   # persistencia SQLite
pip install langgraph-checkpoint-postgres # persistencia PostgreSQL
```

### Requisitos
```python
langgraph >= 0.2.0
langchain-core >= 0.3.0
```

---

## 🔍 Conceptos clave

| Término | Descripción |
|---|---|
| **StateGraph** | Grafo principal que define nodos, aristas y estado |
| **Node** | Función que procesa el estado y devuelve actualizaciones |
| **Edge** | Conexión entre nodos (normal o condicional) |
| **State** | Diccionario tipado que fluye a través del grafo |
| **Checkpoint** | Snapshot del estado en un punto de ejecución |
| **Interrupt** | Pausa para intervención humana (HITL) |
| **Subgraph** | Grafo anidado como nodo dentro de otro grafo |
| **Store** | Memoria persistente entre ejecuciones |
| **Stream** | Emisión de eventos en tiempo real durante la ejecución |

---

## 🧰 Snippets de código

### 1. StateGraph básico con tipado

```python
from typing import TypedDict, Literal
from langgraph.graph import StateGraph, END
from langgraph.checkpoint import MemorySaver

# Definir estado tipado
class AgentState(TypedDict):
    messages: list
    next_agent: str
    context: dict
    retries: int

# Definir nodos
def agent_a(state: AgentState) -> AgentState:
    state["messages"].append("Procesado por A")
    state["next_agent"] = "b"
    return state

def agent_b(state: AgentState) -> AgentState:
    state["messages"].append("Procesado por B")
    state["next_agent"] = "end"
    return state

# Construir grafo
builder = StateGraph(AgentState)
builder.add_node("a", agent_a)
builder.add_node("b", agent_b)
builder.set_entry_point("a")
builder.add_edge("a", "b")
builder.add_edge("b", END)

# Compilar con checkpointing en memoria
graph = builder.compile(checkpointer=MemorySaver())

# Ejecutar
config = {"configurable": {"thread_id": "session-1"}}
result = graph.invoke(
    {"messages": ["Inicio"], "next_agent": "", "context": {}, "retries": 0},
    config
)
```

### 2. Conditional edges con routing dinámico

```python
from typing import TypedDict, Literal
from langgraph.graph import StateGraph, END

class RouterState(TypedDict):
    input_text: str
    classification: str
    confidence: float
    result: str

# Clasificador/router
def classifier(state: RouterState) -> RouterState:
    text = state["input_text"].lower()
    if "urgente" in text:
        state["classification"] = "priority"
    elif "consulta" in text:
        state["classification"] = "inquiry"
    else:
        state["classification"] = "general"
    state["confidence"] = 0.95
    return state

# Nodos especializados
def handle_priority(state: RouterState) -> RouterState:
    state["result"] = "Prioridad: respuesta inmediata"
    return state

def handle_inquiry(state: RouterState) -> RouterState:
    state["result"] = "Consulta: derivar a especialista"
    return state

def handle_general(state: RouterState) -> RouterState:
    state["result"] = "General: responder con FAQ"
    return state

# Función de routing condicional
def route_by_classification(state: RouterState) -> Literal["priority", "inquiry", "general"]:
    return state["classification"]

# Construir grafo con rutas condicionales
builder = StateGraph(RouterState)
builder.add_node("classifier", classifier)
builder.add_node("priority", handle_priority)
builder.add_node("inquiry", handle_inquiry)
builder.add_node("general", handle_general)

builder.set_entry_point("classifier")
builder.add_conditional_edges(
    "classifier",
    route_by_classification,
    {
        "priority": "priority",
        "inquiry": "inquiry",
        "general": "general"
    }
)
builder.add_edge("priority", END)
builder.add_edge("inquiry", END)
builder.add_edge("general", END)

graph = builder.compile()
result = graph.invoke({"input_text": "Urgente: necesito ayuda ahora", "classification": "", "confidence": 0.0, "result": ""})
```

### 3. Checkpointing con SQLite (persistencia)

```python
from langgraph.checkpoint.sqlite import SqliteSaver
from langgraph.graph import StateGraph, END
from typing import TypedDict

class TaskState(TypedDict):
    step: int
    data: dict
    completed: bool

def step_one(state: TaskState) -> TaskState:
    state["step"] = 1
    state["data"]["processed_one"] = True
    return state

def step_two(state: TaskState) -> TaskState:
    state["step"] = 2
    state["data"]["processed_two"] = True
    return state

# Persistencia con SQLite
with SqliteSaver.from_conn_string("checkpoints.db") as saver:
    builder = StateGraph(TaskState)
    builder.add_node("step1", step_one)
    builder.add_node("step2", step_two)
    builder.set_entry_point("step1")
    builder.add_edge("step1", "step2")
    builder.add_edge("step2", END)
    
    graph = builder.compile(checkpointer=saver)
    
    # Primera ejecución
    config = {"configurable": {"thread_id": "task-001"}}
    result = graph.invoke(
        {"step": 0, "data": {}, "completed": False},
        config
    )
    
    # Reanudar desde último checkpoint
    result = graph.invoke(None, config)  # continúa desde donde quedó

# Listar checkpoints
config = {"configurable": {"thread_id": "task-001"}}
states = graph.get_state(config)
print(states.values)
```

### 4. Interrupts (Human-in-the-Loop)

```python
from typing import TypedDict
from langgraph.graph import StateGraph, END
from langgraph.checkpoint import MemorySaver

class ApprovalState(TypedDict):
    request: str
    needs_review: bool
    approved: bool
    response: str

def review_node(state: ApprovalState) -> ApprovalState:
    """Punto de revisión humana con interrupt."""
    state["needs_review"] = True
    return state

def process_approved(state: ApprovalState) -> ApprovalState:
    state["response"] = f"Aprobado: {state['request']}"
    state["approved"] = True
    return state

def process_rejected(state: ApprovalState) -> ApprovalState:
    state["response"] = f"Rechazado: {state['request']}"
    state["approved"] = False
    return state

def after_review(state: ApprovalState) -> str:
    """Router post-revisión."""
    return "approved" if state["approved"] else "rejected"

# Grafo con interrupt
builder = StateGraph(ApprovalState)
builder.add_node("review", review_node)
builder.add_node("approved", process_approved)
builder.add_node("rejected", process_rejected)

builder.set_entry_point("review")
builder.add_conditional_edges("review", after_review)
builder.add_edge("approved", END)
builder.add_edge("rejected", END)

# Compilar con soporte de interrupts
graph = builder.compile(
    checkpointer=MemorySaver(),
    interrupt_before=["review"]  # pausar ANTES de review_node
)

# Ejecutar hasta el interrupt
config = {"configurable": {"thread_id": "approval-1"}}
result = graph.invoke(
    {"request": "Publicar artículo en blog", "needs_review": False, "approved": False, "response": ""},
    config
)

# El grafo se pausa en "review" — podemos inspeccionar
state = graph.get_state(config)
print("Estado actual:", state.values)

# Actualizar estado desde fuera (revisión humana)
graph.update_state(
    config,
    {"approved": True},
    as_node="review"  # actualiza como si review_node lo hubiera hecho
)

# Reanudar ejecución
result = graph.invoke(None, config)
print("Resultado final:", result["response"])
```

### 5. Memory Store (BaseStore con InMemoryStore)

```python
from langgraph.store import InMemoryStore
from langgraph.graph import StateGraph, END
from typing import TypedDict

class MemoryState(TypedDict):
    user_id: str
    query: str
    context: list

# Store persistente entre ejecuciones
store = InMemoryStore()

def agent_with_memory(state: MemoryState) -> MemoryState:
    user_id = state["user_id"]
    
    # Leer memoria del usuario
    namespace = ("users", user_id)
    memory = store.get(namespace, "conversation_history")
    history = memory.value if memory else []
    
    # Agregar contexto histórico
    state["context"] = history + [state["query"]]
    
    # Guardar en memoria
    store.put(namespace, "conversation_history", {"history": state["context"]})
    
    return state

builder = StateGraph(MemoryState)
builder.add_node("agent", agent_with_memory)
builder.set_entry_point("agent")
builder.add_edge("agent", END)

graph = builder.compile(store=store)

# Primera interacción
graph.invoke({"user_id": "user-42", "query": "Hola, ¿qué servicios ofrecen?", "context": []})

# Segunda interacción — el agente recuerda el contexto
graph.invoke({"user_id": "user-42", "query": "Cuéntame más del servicio premium", "context": []})

# Buscar en memoria
items = store.search(("users", "user-42"))
for item in items:
    print(f"Key: {item.key}, Value: {item.value}")
```

### 6. Subgraphs (composición de grafos)

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
from langgraph.graph.message import add_messages
from langgraph.checkpoint import MemorySaver

# Subgrafo: Validador de entrada
class InputState(TypedDict):
    raw_input: str
    validated: bool
    cleaned_input: str

def validate_node(state: InputState) -> InputState:
    state["validated"] = len(state["raw_input"]) > 0
    state["cleaned_input"] = state["raw_input"].strip()
    return state

def clean_node(state: InputState) -> InputState:
    if not state["validated"]:
        state["cleaned_input"] = "default_input"
    return state

input_subgraph_builder = StateGraph(InputState)
input_subgraph_builder.add_node("validate", validate_node)
input_subgraph_builder.add_node("clean", clean_node)
input_subgraph_builder.set_entry_point("validate")
input_subgraph_builder.add_edge("validate", "clean")
input_subgraph_builder.add_edge("clean", END)
input_subgraph = input_subgraph_builder.compile()

# Subgrafo: Procesador
class ProcessState(TypedDict):
    cleaned_input: str
    result: str

def process_node(state: ProcessState) -> ProcessState:
    state["result"] = f"Procesado: {state['cleaned_input']}"
    return state

process_subgraph_builder = StateGraph(ProcessState)
process_subgraph_builder.add_node("process", process_node)
process_subgraph_builder.set_entry_point("process")
process_subgraph_builder.add_edge("process", END)
process_subgraph = process_subgraph_builder.compile()

# Grafo principal que compone subgrafos
class MainState(TypedDict):
    raw_input: str
    cleaned_input: str
    validated: bool
    result: str

def route_after_input(state: MainState) -> str:
    return "processor" if state["validated"] else "processor"  # siempre procesar

builder = StateGraph(MainState)

# Añadir subgrafos como nodos
builder.add_node("input_validator", input_subgraph)
builder.add_node("processor", process_subgraph)

builder.set_entry_point("input_validator")

# Mapeo de estado entre grafo principal y subgrafo
builder.add_edge("input_validator", "processor")
builder.add_edge("processor", END)

graph = builder.compile()

result = graph.invoke({
    "raw_input": "  Hola mundo  ",
    "cleaned_input": "",
    "validated": False,
    "result": ""
})
print(result["result"])
```

### 7. Streaming de eventos

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict
import time

class StreamState(TypedDict):
    messages: list
    current_step: str
    progress: float

def step_a(state: StreamState) -> StreamState:
    state["messages"].append("Paso A iniciado")
    state["current_step"] = "A"
    state["progress"] = 0.33
    time.sleep(0.5)
    return state

def step_b(state: StreamState) -> StreamState:
    state["messages"].append("Paso B iniciado")
    state["current_step"] = "B"
    state["progress"] = 0.66
    time.sleep(0.5)
    return state

def step_c(state: StreamState) -> StreamState:
    state["messages"].append("Paso C completado")
    state["current_step"] = "C"
    state["progress"] = 1.0
    time.sleep(0.5)
    return state

builder = StateGraph(StreamState)
builder.add_node("a", step_a)
builder.add_node("b", step_b)
builder.add_node("c", step_c)
builder.set_entry_point("a")
builder.add_edge("a", "b")
builder.add_edge("b", "c")
builder.add_edge("c", END)

graph = builder.compile()

# Stream con eventos
for event in graph.stream(
    {"messages": [], "current_step": "", "progress": 0.0},
    stream_mode="updates"  # valores: "values", "updates", "events"
):
    print(f"Evento recibido: {event}")
```

### 8. Streaming con eventos detallados (v2)

```python
# Streaming con modo "events" para máximo detalle
from langgraph.graph import StateGraph, END

builder = StateGraph(StreamState)
# ... (misma definición de nodos)

graph = builder.compile()

# Event-level streaming
for event in graph.stream(
    {"messages": [], "current_step": "", "progress": 0.0},
    stream_mode="events"
):
    kind = event["event"]
    if kind == "on_chain_start":
        print(f"▶️ Iniciando: {event['name']}")
    elif kind == "on_chain_end":
        print(f"✅ Completado: {event['name']}")
    elif kind == "on_chain_stream":
        print(f"📦 Update: {event['data']}")
```

### 9. Manejo de errores con try/catch en nodos

```python
from typing import TypedDict
from langgraph.graph import StateGraph, END

class ErrorState(TypedDict):
    input_data: str
    error: str | None
    result: str | None

def risky_operation(state: ErrorState) -> ErrorState:
    try:
        # Operación que puede fallar
        if state["input_data"] == "fail":
            raise ValueError("Fallo intencional")
        state["result"] = f"Éxito: {state['input_data']}"
    except Exception as e:
        state["error"] = str(e)
        state["result"] = None
    return state

builder = StateGraph(ErrorState)
builder.add_node("process", risky_operation)
builder.set_entry_point("process")
builder.add_edge("process", END)

graph = builder.compile()

# Caso exitoso
result1 = graph.invoke({"input_data": "Hola", "error": None, "result": None})
print(result1["result"])  # "Éxito: Hola"

# Caso con error
result2 = graph.invoke({"input_data": "fail", "error": None, "result": None})
print(result2["error"])  # "Fallo intencional"
```

### 10. Grafo con ciclo (agente reactivo)

```python
from typing import TypedDict, Literal
from langgraph.graph import StateGraph, END

class ReActState(TypedDict):
    task: str
    steps: list
    current_thought: str
    action_result: str
    done: bool
    max_steps: int

def think(state: ReActState) -> ReActState:
    state["current_thought"] = f"Pensando sobre: {state['task']}, paso {len(state['steps'])+1}"
    state["steps"].append(state["current_thought"])
    return state

def act(state: ReActState) -> ReActState:
    state["action_result"] = f"Ejecutando acción para: {state['current_thought']}"
    return state

def should_continue(state: ReActState) -> Literal["think", "end"]:
    if state["done"] or len(state["steps"]) >= state["max_steps"]:
        return "end"
    return "think"

builder = StateGraph(ReActState)
builder.add_node("think", think)
builder.add_node("act", act)

builder.set_entry_point("think")
builder.add_edge("think", "act")
builder.add_conditional_edges("act", should_continue)

graph = builder.compile()

result = graph.invoke({
    "task": "Resolver problema",
    "steps": [],
    "current_thought": "",
    "action_result": "",
    "done": False,
    "max_steps": 3
})
print(f"Pasos ejecutados: {len(result['steps'])}")
```

---

## 📋 Reglas y mejores prácticas

### Regla 1: Siempre tipa el estado

Usa `TypedDict` para el estado del grafo. Esto permite autocompletado, validación estática y mejor legibilidad.

```python
# Bien
class AgentState(TypedDict):
    messages: list
    metadata: dict
    step: int

# Mal
class AgentState(TypedDict):
    pass  # estado sin estructura
```

### Regla 2: Usa `add_messages` para historial de chats

Para grafos conversacionales, usa el reductor `add_messages` que maneja merge de mensajes automáticamente.

```python
from typing import Annotated
from langgraph.graph.message import add_messages

class ChatState(TypedDict):
    messages: Annotated[list, add_messages]
    user_id: str
```

### Regla 3: Nunca mutes el estado directamente

Siempre retorna un nuevo diccionario con las actualizaciones. La mutación directa puede causar bugs sutiles.

```python
# Bien
def node(state: AgentState) -> AgentState:
    return {**state, "counter": state["counter"] + 1}

# Aceptable (cuando mutas manualmente)
def node(state: AgentState) -> AgentState:
    state["counter"] += 1
    return state
```

### Regla 4: Configura checkpointing desde el inicio

Incluso en desarrollo, usa `MemorySaver()` para checkpointing. Facilitará depuración y reintentos.

```python
# Siempre añade checkpointer
graph = builder.compile(checkpointer=MemorySaver())
```

### Regla 5: Usa `thread_id` para sesiones independientes

Cada sesión de usuario debe tener su propio `thread_id`. Esto aísla checkpoints y memoria.

```python
config = {"configurable": {"thread_id": f"user-{user_id}-{session_id}"}}
```

### Regla 6: Nombra los nodos con verbos en inglés

Los nombres de nodos deben ser descriptivos y en imperativo: `validate_input`, `process_data`, `generate_response`.

```python
# Bien
builder.add_node("validate_email", validate_email)
builder.add_node("check_approval", check_approval)

# Mal
builder.add_node("func1", func1)
builder.add_node("step_2", step_2)
```

### Regla 7: Prefiere `add_conditional_edges` sobre lógica dentro del nodo

Separa la lógica de routing del procesamiento. Cada nodo debe hacer una sola cosa.

```python
# Bien
def router(state: AgentState) -> str:
    return "end" if state["done"] else "continue"

# Mal
def process_and_route(state: AgentState) -> AgentState:
    if state["done"]:
        state["next"] = "end"  # mezcla lógica
    return state
```

### Regla 8: Usa subgrafos para módulos reutilizables

Componentes como validación, formateo, logging deben ser subgrafos independientes y compuestos.

```python
# Subgrafo reutilizable entre varios grafos padres
validation_subgraph = create_validation_subgraph()
formatting_subgraph = create_formatting_subgraph()

builder.add_node("validation", validation_subgraph)
builder.add_node("formatting", formatting_subgraph)
```

### Regla 9: Implementa límites de ejecución

Siempre protege contra loops infinitos con `max_steps` o `recursion_limit`.

```python
# En el estado
class SafeState(TypedDict):
    step_count: int
    max_steps: int  # límite

# En el conditional edge
def should_stop(state: SafeState) -> str:
    return "end" if state["step_count"] >= state["max_steps"] else "continue"

# O usando recursion_limit al invocar
graph.invoke(input_data, {"recursion_limit": 25})
```

### Regla 10: Aísla el store por namespace

Usa namespaces en el store para separar datos de diferentes dominios.

```python
store.put(("users", user_id, "preferences"), "theme", {"dark_mode": True})
store.put(("users", user_id, "history"), "last_action", {"action": "login"})
store.put(("system", "metrics"), "usage_stats", {"requests": 1000})
```

### Regla 11: Prueba cada nodo de forma independiente

Cada nodo debe ser testeable por separado sin necesidad de ejecutar el grafo completo.

```python
# Test unitario de un nodo
def test_validate_node():
    state = {"input": "test", "valid": False, "error": None}
    result = validate_node(state)
    assert result["valid"] == True
    assert result["error"] is None
```

### Regla 12: Documenta el flujo del grafo

Mantén un diagrama o descripción textual del grafo. Usa `graph.get_graph().draw_mermaid_png()` para visualizar.

```python
# Generar visualización del grafo
png_data = graph.get_graph().draw_mermaid_png()
with open("graph_diagram.png", "wb") as f:
    f.write(png_data)
```

---

## ⚠️ Anti-patrones comunes

| Anti-patrón | Problema | Alternativa |
|---|---|---|
| Estado sin tipo | Bugs difíciles de rastrear | Usar `TypedDict` siempre |
| Nodos que hacen demasiado | Difícil de testear y depurar | Un nodo = una responsabilidad |
| Sin checkpointing | Estado perdido en fallos | `MemorySaver()` incluso en desarrollo |
| Loops sin límite | Ejecución infinita | `max_steps` + `recursion_limit` |
| Mutación directa del estado | Side effects inesperados | Retornar nuevo estado |
| Ignorar `thread_id` | Checkpoints mezclados | Un `thread_id` por sesión |

---

## 🔗 Referencias

- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [LangGraph GitHub](https://github.com/langchain-ai/langgraph)
- [LangGraph How-To Guides](https://langchain-ai.github.io/langgraph/how-tos/)
- [LangGraph Concepts](https://langchain-ai.github.io/langgraph/concepts/)
- [Checkpointing Guide](https://langchain-ai.github.io/langgraph/concepts/checkpointing)
- [Streaming Guide](https://langchain-ai.github.io/langgraph/concepts/streaming)
- [LangGraph Examples](https://github.com/langchain-ai/langgraph/tree/main/examples)

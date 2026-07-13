---
name: model-router
description: Gestión inteligente de modelos de IA — enrutamiento por tarea, fallback automático, autenticación, créditos y planes. Core del ecosistema de agentes.
---

# Model Router

> Skill core del ecosistema. Gestiona qué modelo usar para cada tarea, con fallback automático, control de costos y autenticación centralizada.
> **No usa modelos gratuitos** — solo modelos de pago con SLA garantizado.

## metadata

- **id**: `model-router`
- **version**: 1.0.0
- **domain**: core
- **priority**: high
- **phase**: bootstrap

## triggers

```yaml
keywords:
  - "modelo"
  - "model router"
  - "enrutamiento"
  - "fallback"
  - "API key"
  - "autenticación"
  - "crédito"
  - "plan"
  - "costo"
  - "tokens"
  - "OpenRouter"
  - "tier"
  - "modelo gratuito"
  - "modelo de pago"
  - "429"
  - "401"
  - "timeout"
  - "rate limit"
  - "proveedor"
patterns:
  - "'¿qué modelo usa.*'"
  - "'error de API.*modelo'"
  - "'cómo configuro.*API'"
  - "'se agotaron los créditos'"
  - "'cambiar de modelo'"
  - "'fallback.*modelo'"
  - "'qué hacer si.*falla'"
exclude: []
```

## rules

```yaml
business_rules:
  - "Usar SIEMPRE el modelo del tier correcto según la tarea — NO usar modelos premium para tareas simples"
  - "El fallback automático es OBLIGATORIO: si tier N falla (429/401/timeout/error), escalar a tier N+1"
  - "Si TODOS los modelos fallan, retornar error controlado — NUNCA silencio ni respuesta vacía"
  - "NUNCA hardcodear API keys en código — usar variables de entorno o gestor de secretos"
  - "Solo modelos de pago con SLA — prohibido usar gratuitos en producción"
  - "Loggear cada llamada a API con modelo, tokens, costo y resultado"
  - "Verificar saldo/plan ANTES de enrutar — si se agotaron créditos, no destruir UX"
  - "Respetar rate limits del proveedor — implementar backoff exponencial"
  - "El orquestador DEBE cargar esta skill ante cualquier duda sobre modelos"
  - "Usar modelo distinto en micro-gates al usado en generación (sesgo de modelo)"
```

## blueprint

### 1. Tabla Maestra de Modelos

La tabla maestra define todos los modelos disponibles, organizados en **5 tiers** según costo y capacidad.
Usar modelos del tier más bajo que pueda cumplir la tarea.

```
Tier 1 — Ultra-económico  (~$0.03/M out)  → Clasificación, sentimiento, extracción simple
Tier 2 — Económico        (~$0.15/M out)  → Micro-gates, verificación, extracción compleja
Tier 3 — Estándar         (~$0.19/M out)  → Respuestas a usuarios (default)
Tier 4 — Premium          (~$0.80/M out)  → Decisiones complejas, clientes premium
Tier 5 — Emergencia       (~$0.80/M out)  → Fallback cuando todo falla
```

Cada entrada incluye:
- `id` del modelo (según nomenclatura del proveedor)
- `provider` (OpenRouter, Anthropic, OpenAI, Google, etc.)
- `costPer1MInput` / `costPer1MOutput` (USD)
- `tier` (1–5)
- `maxTokens` y `temperature` recomendados
- `description` funcional (para qué usarlo)

**Regla de selección**: Para cada `TaskType`, se define una secuencia ordenada de modelos
(preferredModels). El sistema intenta el primero; si falla, pasa al siguiente.

Las tareas típicas son:

| TaskType | Descripción | Tier sugerido |
|---|---|---|
| `routing` | Clasificar mensaje (tipo, urgencia, destino) | 1 |
| `sentiment` | Análisis de sentimiento | 1 |
| `extraction` | Extraer datos estructurados (nombres, fechas, entidades) | 1–2 |
| `summarization` | Resumir conversaciones largas | 2 |
| `microgate_confidence` | Verificar que respuesta está basada en datos | 2 |
| `microgate_safety` | Detectar inyección, PII, prompts maliciosos | 2 |
| `microgate_accuracy` | Verificar precios, servicios, factual correctness | 2 |
| `customer_response` | Respuesta a usuario final | 3 |
| `boss_response` | Respuesta a supervisores/dueños (máxima calidad) | 4 |
| `fallback` | Emergencia — último recurso | 5 |

### 2. Regla de Fallback Automático

El fallback es **obligatorio** y sigue este protocolo:

```
1. Intentar modelo principal (preferredModels[0])
2. Si falla con 429/401/timeout → intentar siguiente en cadena
3. Si falla otra vez → intentar siguiente
4. Si TODOS fallan → error controlado:
   - Loggear el error completo (taskType, modelos intentados, errores)
   - Retornar mensaje de error amigable al usuario
   - NOTIFICAR al {{ADMIN_EMAIL}} si es un patrón recurrente
```

Causas de fallback:
- **429** (rate limited) → backoff de 1s, luego fallback
- **401** (no auth) → intentar refrescar token, si persiste → fallback
- **5xx** (server error) → fallback inmediato
- **timeout** (>30s) → fallback inmediato
- **empty response** → reintentar 1 vez, luego fallback

Estrategia de backoff:
```
1er reintento: esperar 1s
2do reintento: esperar 2s
3er reintento: esperar 4s (máximo)
Si todos fallan → fallback al siguiente modelo
```

### 3. Configuración API

Toda la configuración se maneja a través de variables de entorno/secretos,
NUNCA hardcodeada en el código.

```yaml
# Configuración del proveedor principal (OpenRouter u otro)
OPENROUTER_API_KEY: "{{OPENROUTER_API_KEY}}"
OPENROUTER_BASE_URL: "{{OPENROUTER_BASE_URL}}"
OPENROUTER_REFERRER: "{{APP_URL}}"

# Proveedores alternativos (fallback si OpenRouter falla)
ANTHROPIC_API_KEY: "{{ANTHROPIC_API_KEY}}"
OPENAI_API_KEY: "{{OPENAI_API_KEY}}"
GOOGLE_API_KEY: "{{GOOGLE_API_KEY}}"
DEEPSEEK_API_KEY: "{{DEEPSEEK_API_KEY}}"

# Configuración del enrutador
DEFAULT_TEMPERATURE: "0.1"
DEFAULT_MAX_TOKENS: "4096"
FALLBACK_ENABLED: "true"
MAX_RETRIES_PER_MODEL: "3"
```

**Formato de las requests** (ejemplo con OpenRouter):

```
POST {{OPENROUTER_BASE_URL}}/chat/completions
Content-Type: application/json
Authorization: Bearer {{OPENROUTER_API_KEY}}
X-Title: {{APP_NAME}}

{
  "model": "{{SELECTED_MODEL_ID}}",
  "messages": [...],
  "max_tokens": {{MAX_TOKENS}},
  "temperature": {{TEMPERATURE}}
}
```

### 4. Protocolo de Autenticación Genérico

El protocolo es multi-proveedor y maneja tres modos de autenticación:

#### Modo 1: API Key directa (OpenRouter, OpenAI, Anthropic, etc.)

```
1. Obtener API key del gestor de secretos (variable de entorno, keychain, .env)
2. Validar que la key NO esté vacía y tenga formato válido
3. Enviar en header Authorization: Bearer {{KEY}}
4. Si response es 401:
   a. Intentar refrescar (si aplica)
   b. Si persiste → marcar provider como no disponible
   c. Hacer fallback al siguiente modelo
```

#### Modo 2: OAuth 2.0 (Google, Microsoft, etc.)

```
1. Verificar si token existe y no ha expirado
2. Si expirado → usar refresh token
3. Si refresh falla → redirigir a flujo de re-autenticación
4. Cachear token con expiry conocido
5. Usar en header Authorization: Bearer {{ACCESS_TOKEN}}
```

#### Modo 3: Autenticación por proxy/custom (modelos privados, on-premise)

```
1. Configurar proxy URL y headers en {{MODEL_PROXY_CONFIG}}
2. Enviar request al proxy con autenticación del proxy
3. El proxy maneja la auth contra el modelo interno
```

**Almacenamiento seguro de credenciales:**

| Secreto | Dónde almacenarlo | Formato |
|---|---|---|
| API Key principal | Variable de entorno | `{{PROVIDER}}_API_KEY` |
| OAuth tokens | Keychain / Secret store | JSON con access + refresh + expiry |
| Proxy config | Archivo de configuración (permisos 600) | YAML/JSON |

### 5. Gestión de Créditos y Planes

Cada cuenta tiene un **plan** que define límites de uso:

```yaml
planes:
  free:
    name: "Gratuito"
    max_requests_per_day: 50
    max_tokens_per_day: 100_000
    allowed_tiers: [1, 2]
    features: ["routing", "sentiment", "extraction"]
    
  basic:
    name: "Básico"
    max_requests_per_day: 500
    max_tokens_per_day: 1_000_000
    allowed_tiers: [1, 2, 3]
    features: ["routing", "sentiment", "extraction", "summarization", "customer_response"]
    
  pro:
    name: "Profesional"
    max_requests_per_day: 5000
    max_tokens_per_day: 10_000_000
    allowed_tiers: [1, 2, 3, 4]
    features: ["*"]  # Todas
    
  enterprise:
    name: "Empresarial"
    max_requests_per_day: 50000
    max_tokens_per_day: 100_000_000
    allowed_tiers: [1, 2, 3, 4, 5]
    features: ["*", "modelos_privados"]
```

**Límites y control de gasto:**

| Méctrica | Cómo se controla | Acción al exceder |
|---|---|---|
| Requests/día | Contador con reinicio diario | Degradar tier, notificar admin |
| Tokens/día | Suma de input+output | Pausar requests no críticos |
| Costo USD/mes | Acumulador mensual | Alertar al {{ADMIN_EMAIL}} al 80% |
| Rate limit (por minuto) | Contador deslizante | Backoff + cola |

**Tracking de costos en cada request:**

```yaml
log_entry:
  timestamp: "2026-07-02T10:30:00Z"
  task_type: "customer_response"
  model_id: "{{MODEL_ID}}"
  provider: "OpenRouter"
  input_tokens: 450
  output_tokens: 120
  cost_usd: 0.000087  # Calculado automáticamente
  tier: 3
  status: "success"  # success | fallback | error
  user_id: "{{USER_ID}}"  # Opcional, para facturación por cliente
```

**Estadísticas disponibles:**

- `totalCost`: costo acumulado desde el inicio
- `todayCost`: costo del día actual
- `byTask`: desglose por tipo de tarea
- `byModel`: desglose por modelo
- `totalCalls`: número total de llamadas
- `byUser`: (si aplica) desglose por usuario/cliente

**Alertas automáticas:**

| Evento | Acción |
|---|---|
| Costo mensual > 80% del presupuesto | Email a {{ADMIN_EMAIL}} |
| Tasa de fallback > 10% en 1 hora | Notificar al {{ORQUESTADOR}} |
| Plan free sin requests por 7 días | Email de re-engagement |
| Error 401 persistente | Marcar provider, alertar admin |

## references

```yaml
related_skills:
  - "autoaprendizaje": "Para entrenar nuevos modelos o proveedores"
  - "queenchat-stack": "Stack completo donde se implementó originalmente"
  - "find-skills": "Para descubrir skills relacionadas"
docs:
  - "OpenRouter API: https://openrouter.ai/docs"
  - "Configuración del suite: {{AGENTS_HOME}}/CONFIGURATION.md"
  - "Variables de entorno: {{AGENTS_HOME}}/.env.template"
```

## implementation

```python
# Pseudocódigo del enrutador — adaptar al lenguaje del proyecto

class ModelRouter:
    def __init__(self, config: dict):
        self.models = self._build_model_index(config["models"])
        self.routes = self._build_route_index(config["routes"])
        self.plan = config["plan"]
        self.cost_log = []
    
    def get_model_chain(self, task_type: str) -> list[dict]:
        """Devuelve modelos en orden de preferencia para una tarea."""
        route = self.routes.get(task_type)
        if not route:
            return [self._default_model()]
        return [self.models[m_id] for m_id in route["preferred_models"] if m_id in self.models]
    
    def get_next_fallback(self, task_type: str, current_model_id: str) -> dict | None:
        """Devuelve el siguiente modelo disponible tras uno fallido."""
        chain = self.get_model_chain(task_type)
        for i, m in enumerate(chain):
            if m["id"] == current_model_id and i < len(chain) - 1:
                return chain[i + 1]
        return None
    
    def is_last_resort(self, task_type: str, model_id: str) -> bool:
        chain = self.get_model_chain(task_type)
        return bool(chain) and chain[-1]["id"] == model_id
    
    def can_use_tier(self, tier: int) -> bool:
        """Verifica si el plan actual permite usar un tier."""
        return tier <= self.plan.get("max_tier", 1)
    
    def log_usage(self, task_type: str, model_id: str, input_tokens: int, output_tokens: int, status: str):
        model = self.models.get(model_id)
        if not model:
            return
        cost = (input_tokens / 1_000_000) * model["cost_per_1m_input"] + \
               (output_tokens / 1_000_000) * model["cost_per_1m_output"]
        self.cost_log.append({
            "timestamp": datetime.utcnow().isoformat(),
            "task_type": task_type,
            "model_id": model_id,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost_usd": round(cost, 6),
            "tier": model["tier"],
            "status": status,
        })
    
    def get_stats(self) -> dict:
        """Estadísticas de costo y uso."""
        today = date.today().isoformat()
        stats = {"total_cost": 0.0, "today_cost": 0.0, "by_task": {}, "by_model": {}, "total_calls": 0}
        for entry in self.cost_log:
            stats["total_cost"] += entry["cost_usd"]
            stats["by_task"][entry["task_type"]] = stats["by_task"].get(entry["task_type"], 0) + entry["cost_usd"]
            stats["by_model"][entry["model_id"]] = stats["by_model"].get(entry["model_id"], 0) + entry["cost_usd"]
            if entry["timestamp"].startswith(today):
                stats["today_cost"] += entry["cost_usd"]
        stats["total_calls"] = len(self.cost_log)
        return stats
```

## troubleshooting

| Síntoma | Causa probable | Solución |
|---|---|---|
| 401 Unauthorized | API key inválida o expirada | Verificar `{{PROVIDER}}_API_KEY` en el entorno |
| 429 Too Many Requests | Rate limit excedido | Esperar 1s + backoff exponencial. Si persiste, hacer fallback |
| 503 / timeout | Proveedor caído | Fallback inmediato al siguiente modelo |
| Costo muy alto | Tarea mal clasificada (usando tier 4 para routing) | Revisar el mapeo TaskType → tier |
| Respuestas vacías | Modelo no soporta la tarea | Marcar modelo como no disponible, hacer fallback |
| Error "model not found" | ID de modelo incorrecto o descontinuado | Actualizar tabla maestra, elegir alternativa |
| Créditos agotados | Plan free excedió límite diario | Esperar al reinicio o actualizar plan |
| Fallback loop infinito | Misma causa en todos los modelos | Detener después de 3 intentos, retornar error controlado |

## configuration_guide

Para configurar el model-router por primera vez:

```bash
# 1. Establecer API key del proveedor principal
export OPENROUTER_API_KEY="{{OPENROUTER_API_KEY}}"

# 2. (Opcional) API keys de proveedores alternativos
export ANTHROPIC_API_KEY="{{ANTHROPIC_API_KEY}}"
export OPENAI_API_KEY="{{OPENAI_API_KEY}}"

# 3. Configurar el plan por defecto
export MODEL_PLAN="{{MODEL_PLAN}}"  # free | basic | pro | enterprise

# 4. Verificar que funciona
curl -s -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"{{TEST_MODEL}}","messages":[{"role":"user","content":"ping"}],"max_tokens":10}' \
  "{{OPENROUTER_BASE_URL}}/chat/completions"
```

## verification

```python
def verify_model_router_setup():
    """Checklist de verificación post-instalación."""
    checks = {
        "api_key_set": bool(os.environ.get("OPENROUTER_API_KEY")),
        "models_defined": len(MODELS) > 0,
        "routes_defined": len(TASK_ROUTES) > 0,
        "plan_configured": os.environ.get("MODEL_PLAN") in ("free", "basic", "pro", "enterprise"),
        "fallback_chain_complete": all(
            len(route["preferred_models"]) >= 2 for route in TASK_ROUTES
        ),
        "no_hardcoded_secrets": not any(
            "sk-" in str(m) or "supabase" in str(m).lower()
            for m in globals().values() if isinstance(m, str)
        ),
    }
    all_ok = all(checks.values())
    return {"status": "OK" if all_ok else "ERROR", "checks": checks}
```

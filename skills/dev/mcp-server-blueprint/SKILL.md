---
name: mcp-server-blueprint
description: Patrón canónico para construir servidores MCP (Model Context Protocol). Cubre server.py, tools.py, client.py y validación completa del protocolo. Generada por el enjambre el 2026-07-02.
---

# MCP Server Blueprint

> Skill canónica para construir servidores MCP (Model Context Protocol)
> Arquitectura: server.py + tools.py + client.py + requirements.txt + .env.example
> Fecha: 2026-07-02

## metadata
- **id**: `mcp-server-blueprint`
- **version**: 1.0.0
- **domain**: desarrollo
- **priority**: high
- **phase**: blueprint

## triggers
```yaml
keywords:
  - "mcp server"
  - "mcp"
  - "model context protocol"
  - "server.py"
  - "tools.py"
  - "fastmcp"
  - "conector mcp"
  - "mcp tool"
  - "stdio transport"
  - "herramienta mcp"
patterns:
  - "crea un servidor mcp para"
  - "construye un conector mcp"
  - "implementa tools mcp"
  - "blueprint de servidor mcp"
  - "expón una api como mcp"
  - "integra con mcp"
exclude:
  - "solo cliente http"
  - "sin protocolo mcp"
  - "api rest sin mcp"
```

## rules
```yaml
business_rules:
  - "TODO servidor MCP DEBE usar `fastmcp` como librería base (no implementar el protocolo raw)"
  - "TODO entry point DEBE ser un solo archivo `server.py` que importe y registre tools desde `tools.py`"
  - "TODO tool DEBE tener type hints completos en parámetros y retorno"
  - "TODO tool DEBE tener docstring descriptivo que el LLM pueda leer (es la descripción que ve el modelo)"
  - "TODO error en una tool DEBE retornarse como `MCPError` con mensaje claro, nunca lanzar excepción cruda"
  - "TODO server DEBE leer configuración desde variables de entorno (`.env`), no desde hardcode"
  - "TODO server DEBE exportar un `mcp` object (instancia de FastMCP) para testing"
  - "TODO tool DEBE ser async si hace I/O (HTTP, DB, filesystem); sync si es puro cómputo"
  - "TODO server DEBE incluir un `requirements.txt` con pinned versions"
  - "TODO server DEBE incluir un `.env.example` con todas las variables requeridas documentadas"
  - "TODO client DEBE usar `requests` o `httpx` — nunca `urllib` raw"
  - "Los nombres de tools DEBEN ser verbos en imperativo inglés (get_user, create_order, search_docs)"
  - "Los nombres de tools DEBEN usar snake_case (no camelCase, no kebab-case)"
  - "Los parámetros de tools DEBEN tener default values o ser opcionales cuando sea posible para robustez del LLM"
  - "TODO schema de tool complejo (más de 5 parámetros) DEBE usar `pydantic.BaseModel` como input model"
  - "El server DEBE correr con `python -m server` o `python server.py` — nunca como módulo comprimido"
  - "NO incluir API keys ni secrets en ningún archivo del repositorio — solo en `.env`"
  - "TODO tool que acceda a un recurso externo (API, DB, archivo) DEBE tener timeout explícito"
```

## blueprint
```yaml
description: >
  Patrón canónico para construir servidores MCP utilizando la librería FastMCP.

  MCP (Model Context Protocol) es un protocolo abierto que permite a modelos de lenguaje
  (LLMs) descubrir e invocar herramientas externas de forma estandarizada. Este blueprint
  provee la estructura exacta para construir un servidor MCP que expone tools como servicios.

  ESTRUCTURA DE ARCHIVOS:
  ```
  proyecto/
  ├── server.py           # Entry point: crea el servidor FastMCP y registra las tools
  ├── tools.py            # Implementación de cada tool (lógica de negocio)
  ├── client.py           # Cliente HTTP opcional para pruebas e integración externa
  ├── requirements.txt    # Dependencias pinneadas
  └── .env.example        # Variables de entorno de ejemplo (sin secrets reales)
  ```

  ARQUITECTURA DE EJECUCIÓN:
  ```
  LLM / Host (Claude Code, etc.)
       │  JSON-RPC (stdin/stdout)
       ▼
  ┌──────────────────────┐
  │     server.py         │  ← FastMCP instance, registra tools
  │  ┌──────────────────┐ │
  │  │   tools.py        │ │  ← @mcp.tool() handlers con lógica
  │  └──────────────────┘ │
  │  ┌──────────────────┐ │
  │  │   client.py       │ │  ← Capa HTTP (opcional) para APIs externas
  │  └──────────────────┘ │
  └──────────────────────┘
       │
       ▼
  API externa / DB / Filesystem / etc.
  ```

  DATA FLOW:
  1. El LLM recibe la lista de tools disponibles (descubrimiento automático vía FastMCP)
  2. El LLM decide invocar una tool con parámetros específicos
  3. `server.py` recibe la solicitud JSON-RPC y la despacha al handler en `tools.py`
  4. `tools.py` ejecuta la lógica (posiblemente usando `client.py` para llamadas HTTP)
  5. El resultado se retorna como JSON-RPC response al LLM

tech_decisions:
  - "Usar `fastmcp` como framework principal (mantenido por Anthropic, diseño moderno sobre el SDK oficial)"
  - "Alternativa: `mcp` SDK oficial si se necesita control raw sobre el protocolo"
  - "Tools como funciones decoradas con @mcp.tool() — el decorador extrae el schema automáticamente"
  - "Pydantic v2 para modelos de datos complejos"
  - "python-dotenv para carga de .env"
  - "httpx para cliente HTTP async (con timeout y retry)"
  - "Transporte: stdio (entrada/salida estándar) — es el estándar para integración con hosts MCP"
  - "Logging: module-level logger con estructura nombre_modulo.child"
```

## code
```yaml
templates:
  - name: "server.py"
    path: "templates/server.py.tmpl"
    description: "Entry point del servidor MCP. Crea la instancia FastMCP, registra tools desde tools.py, y configura logging + dotenv."

  - name: "tools.py"
    path: "templates/tools.py.tmpl"
    description: "Implementación de las tools MCP. Cada función decorada con @mcp.tool() es una herramienta que el LLM puede invocar."

  - name: "client.py"
    path: "templates/client.py.tmpl"
    description: "Cliente HTTP async para consumir APIs externas desde las tools. Incluye timeout, retry, y manejo de errores."

snippets:
  - name: "tool-básica"
    description: "Estructura mínima de una tool MCP"
    code: |
      @mcp.tool()
      def get_user(user_id: str) -> dict:
          \"\"\"Obtiene un usuario por su ID. Útil para perfiles y verificación.
          
          Args:
              user_id: ID único del usuario a consultar.
          Returns:
              Diccionario con datos del usuario o error.
          \"\"\"
          try:
              return client.get(f"/users/{user_id}")
          except APIError as e:
              return {"error": str(e), "user_id": user_id}

  - name: "tool-async"
    description: "Tool async para operaciones I/O (recomendada para HTTP, DB, filesystem)"
    code: |
      @mcp.tool()
      async def search_docs(query: str, limit: int = 10) -> list[dict]:
          \"\"\"Busca documentos por query de texto. Retorna matches relevantes.
          
          Args:
              query: Término de búsqueda.
              limit: Máximo de resultados (default: 10).
          Returns:
              Lista de documentos encontrados.
          \"\"\"
          results = await db.search(query, limit=limit)
          return [doc.to_dict() for doc in results]

  - name: "tool-con-pydantic"
    description: "Tool con modelo de entrada Pydantic para parámetros complejos"
    code: |
      from pydantic import BaseModel, Field
      
      class CreateOrderInput(BaseModel):
          user_id: str = Field(..., description="ID del usuario que crea la orden")
          items: list[OrderItem] = Field(..., min_length=1, description="Productos en la orden")
          coupon_code: str | None = Field(None, description="Código de descuento opcional")
          shipping_address: Address = Field(..., description="Dirección de envío")
      
      @mcp.tool()
      def create_order(input_data: CreateOrderInput) -> dict:
          \"\"\"Crea una orden de compra. Valida inventario y aplica descuentos.
          
          Args:
              input_data: Datos completos de la orden (usuario, items, cupón, dirección).
          Returns:
              Dict con order_id, status, y total calculado.
          \"\"\"
          return order_service.create(input_data)

  - name: "mcp-error-handling"
    description: "Patrón de manejo de errores con MCPError"
    code: |
      from fastmcp.exceptions import MCPError
      
      @mcp.tool()
      def delete_resource(resource_id: str, force: bool = False) -> dict:
          \"\"\"Elimina un recurso por ID. Si force=True, omite confirmación.
          
          Args:
              resource_id: ID del recurso a eliminar.
              force: Si True, fuerza la eliminación sin confirmación.
          Returns:
              Dict con confirmación de eliminación.
          Raises:
              MCPError: Si el recurso no existe o no se puede eliminar.
          \"\"\"
          resource = storage.get(resource_id)
          if resource is None:
              raise MCPError(f"Resource '{resource_id}' not found")
          if not force and resource.status == "active":
              raise MCPError(
                  f"Resource '{resource_id}' is active. Use force=True to delete anyway."
              )
          storage.delete(resource_id)
          return {"deleted": True, "resource_id": resource_id}

  - name: "validacion-entrada"
    description: "Validación explícita de parámetros de entrada en tools"
    code: |
      @mcp.tool()
      def calculate_shipping(weight_kg: float, zip_code: str, express: bool = False) -> dict:
          \"\"\"Calcula costo de envío basado en peso y código postal.
          
          Args:
              weight_kg: Peso del paquete en kg (debe ser > 0 y <= 50).
              zip_code: Código postal de 5 dígitos.
              express: Si True, calcula tarifa exprés (default: False).
          Returns:
              Dict con costo estimado y tiempo de entrega.
          \"\"\"
          errors = []
          if weight_kg <= 0 or weight_kg > 50:
              errors.append(f"weight_kg debe ser entre 0 y 50, recibido: {weight_kg}")
          if not zip_code or len(zip_code) != 5 or not zip_code.isdigit():
              errors.append(f"zip_code debe ser 5 dígitos, recibido: '{zip_code}'")
          
          if errors:
              return {"error": " | ".join(errors), "valid": False}
          
          rate = 5.0 + (weight_kg * 0.5)
          if express:
              rate *= 2.5
          days = 1 if express else 5
          
          return {
              "cost_usd": round(rate, 2),
              "estimated_days": days,
              "valid": True,
              "zip_code": zip_code
          }

libraries:
  - "fastmcp >= 1.0.0, < 2.0.0 (framework MCP)"
  - "httpx >= 0.27.0, < 1.0.0 (cliente HTTP async)"
  - "pydantic >= 2.0.0, < 3.0.0 (validación de datos)"
  - "python-dotenv >= 1.0.0 (carga de variables de entorno)"
  - "mcp >= 1.0.0 (SDK oficial — dependencia de fastmcp, incluir explícitamente)"
```

## checks
```yaml
validation_checks:
  - category: "Estructura del proyecto"
    checks:
      - "[ ] Existe server.py con clase FastMCP o servidor MCP"
      - "[ ] Existe tools.py con al menos una @mcp.tool() decorada"
      - "[ ] Existe requirements.txt con fastmcp y httpx"
      - "[ ] Existe .env.example (sin secrets reales)"
      - "[ ] server.py importa tools desde el módulo tools"
  - category: "Calidad de tools"
    checks:
      - "[ ] Cada tool tiene type hints en todos los parámetros y retorno"
      - "[ ] Cada tool tiene docstring descriptivo (>1 línea, explica qué hace)"
      - "[ ] Los nombres de tools son verbos en imperativo (get_, create_, search_, etc.)"
      - "[ ] Los nombres de tools usan snake_case"
      - "[ ] Los parámetros tienen default values o son opcionales donde aplica"
      - "[ ] Tools con >5 parámetros usan Pydantic BaseModel"
  - category: "Manejo de errores"
    checks:
      - "[ ] Las tools usan MCPError para errores esperados"
      - "[ ] Las tools no lanzan excepciones genéricas (Exception, RuntimeError)"
      - "[ ] Las tools retornan dict con estructura predecible"
      - "[ ] El servidor tiene timeout configurado para operaciones I/O"
      - "[ ] Errores de red/API se capturan y retornan como error, no crash"
  - category: "Configuración y entorno"
    checks:
      - "[ ] No hay API keys hardcodeadas en ningún .py"
      - "[ ] .env.example documenta TODAS las variables necesarias"
      - "[ ] Las variables de entorno se cargan con load_dotenv() al inicio"
      - "[ ] Hay logging configurado (logging.basicConfig o similar)"
  - category: "Verificación funcional"
    checks:
      - "[ ] python -c \"from server import mcp\" — importa sin error"
      - "[ ] python -c \"from tools import *\" — importa sin error"
      - "[ ] python -m py_compile server.py tools.py client.py — sintaxis válida"
      - "[ ] El requirements.txt se puede instalar con pip install -r requirements.txt"
      - "[ ] El servidor responde al protocolo MCP (stdin/stdout JSON-RPC)"
  - category: "Template snippets"
    checks:
      - "[ ] tool-básica: imports correctos, decorador @mcp.tool(), retorno dict"
      - "[ ] tool-async: función async con await en I/O"
      - "[ ] tool-con-pydantic: BaseModel como parámetro, Field con description"
      - "[ ] mcp-error-handling: MCPError importado y lanzado condicionalmente"
      - "[ ] validacion-entrada: validación explícita con mensajes descriptivos"
```

## test_plan
```yaml
tests:
  - name: "test_imports"
    description: "Verifica que todos los módulos importan correctamente"
    code: |
      def test_imports():
          from server import mcp
          from tools import get_user, search_docs, create_order
          from client import APIClient
          assert mcp is not None

  - name: "test_tool_registration"
    description: "Verifica que las tools están registradas en el servidor"
    code: |
      def test_tool_registration():
          from server import mcp
          tool_names = [t.name for t in mcp._tool_manager.list_tools()]
          assert "get_user" in tool_names

  - name: "test_tool_execution"
    description: "Ejecuta una tool y verifica estructura de respuesta"
    code: |
      @pytest.mark.asyncio
      async def test_get_user():
          from tools import get_user
          result = await get_user(user_id="test-123")
          assert isinstance(result, dict)
          assert "error" in result or "name" in result

  - name: "test_env_loading"
    description: "Verifica que el servidor carga variables de entorno"
    code: |
      def test_env_loading(monkeypatch):
          monkeypatch.setenv("API_BASE_URL", "https://api.test.local")
          from server import load_config
          config = load_config()
          assert config["api_base_url"] == "https://api.test.local"

  - name: "test_client_timeout"
    description: "Verifica que el cliente HTTP tiene timeout configurado"
    code: |
      def test_client_timeout():
          from client import APIClient
          client = APIClient(base_url="https://api.test.local")
          assert client.timeout == 30.0
```

## references
- Documentación oficial MCP: https://modelcontextprotocol.io/
- FastMCP GitHub: https://github.com/jlowin/fastmcp
- MCP Python SDK: https://github.com/modelcontextprotocol/python-sdk
- JSON-RPC 2.0 spec: https://www.jsonrpc.org/specification

---

*Skill generada por el enjambre | mcp-server-blueprint v1.0.0 | 2026-07-02*

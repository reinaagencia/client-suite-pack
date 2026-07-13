# api-integration-pattern

Patrón estandarizado para integración con APIs REST usando `httpx`. Cubre cliente HTTP, autenticación, rate limiting, retry, manejo de errores HTTP y paginación.

---

## 📁 Estructura de archivos

```
project/
├── src/
│   ├── __init__.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── client.py          # Cliente HTTP base
│   │   ├── auth.py            # Handlers de autenticación
│   │   ├── errors.py          # Excepciones específicas de API
│   │   ├── rate_limiter.py    # Rate limiting
│   │   └── pagination.py      # Paginación genérica
│   └── api_endpoints.py       # Endpoints específicos del API
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_client.py
│   ├── test_auth.py
│   └── test_endpoints.py
├── pyproject.toml
└── README.md
```

---

## 🧱 Cliente HTTP base (`client.py`)

```python
"""Cliente HTTP base con manejo de errores y retry configurable."""

from __future__ import annotations

import logging
from collections.abc import AsyncGenerator, Generator
from dataclasses import dataclass, field
from typing import Any

import httpx

from src.api.auth import AuthHandler, NoAuth
from src.api.errors import ApiError, HttpError, TimeoutError
from src.api.rate_limiter import RateLimiter, NoOpLimiter

logger = logging.getLogger(__name__)


@dataclass
class ApiClientConfig:
    """Configuración del cliente HTTP."""

    base_url: str
    timeout: float = 30.0
    max_retries: int = 3
    retry_delay: float = 1.0
    retry_backoff: float = 2.0
    rate_limit_per_second: float = 10.0
    auth_handler: AuthHandler = field(default_factory=NoAuth)
    verify_ssl: bool = True
    user_agent: str = "ApiClient/1.0"


class ApiClient:
    """Cliente HTTP configurable con retry, rate limiting y auth."""

    def __init__(self, config: ApiClientConfig) -> None:
        self.config = config
        self.auth = config.auth_handler
        self.rate_limiter: RateLimiter = (
            RateLimiter(config.rate_limit_per_second)
            if config.rate_limit_per_second > 0
            else NoOpLimiter()
        )

        self._client = httpx.Client(
            base_url=config.base_url,
            timeout=httpx.Timeout(config.timeout),
            verify=config.verify_ssl,
            headers={"User-Agent": config.user_agent},
        )

    # ── Método principal ────────────────────────────────────────────

    def request(
        self,
        method: str,
        path: str,
        *,
        params: dict[str, Any] | None = None,
        json: dict[str, Any] | None = None,
        data: Any = None,
        headers: dict[str, str] | None = None,
        stream: bool = False,
    ) -> httpx.Response:
        """Ejecuta una petición HTTP con retry y rate limiting."""
        self.rate_limiter.wait()

        last_error: Exception | None = None
        url = path  # base_url ya está en el cliente

        for attempt in range(1, self.config.max_retries + 1):
            try:
                request_headers = self.auth.get_headers()
                if headers:
                    request_headers.update(headers)

                response = self._client.request(
                    method=method,
                    url=url,
                    params=params,
                    json=json,
                    data=data,
                    headers=request_headers,
                )

                self._check_response(response)
                return response

            except httpx.TimeoutException as e:
                last_error = TimeoutError(path, timeout=self.config.timeout)
                logger.warning("Timeout (intento %d/%d): %s", attempt, self.config.max_retries, path)
            except httpx.HTTPStatusError as e:
                last_error = HttpError(e.response.status_code, path, body=_safe_body(e.response))
                if not self._should_retry(e.response.status_code):
                    raise last_error from e
                logger.warning(
                    "HTTP %d (intento %d/%d): %s",
                    e.response.status_code, attempt, self.config.max_retries, path,
                )
            except httpx.RequestError as e:
                last_error = ApiError(f"Error de conexión: {e}")
                logger.warning("RequestError (intento %d/%d): %s", attempt, self.config.max_retries, e)

            if attempt < self.config.max_retries:
                delay = self.config.retry_delay * (self.config.retry_backoff ** (attempt - 1))
                import time
                time.sleep(delay)

        raise ApiError(f"Máximo de reintentos alcanzado ({self.config.max_retries})") from last_error

    # ── Helpers ─────────────────────────────────────────────────────

    def get(self, path: str, **kwargs: Any) -> httpx.Response:
        return self.request("GET", path, **kwargs)

    def post(self, path: str, **kwargs: Any) -> httpx.Response:
        return self.request("POST", path, **kwargs)

    def put(self, path: str, **kwargs: Any) -> httpx.Response:
        return self.request("PUT", path, **kwargs)

    def patch(self, path: str, **kwargs: Any) -> httpx.Response:
        return self.request("PATCH", path, **kwargs)

    def delete(self, path: str, **kwargs: Any) -> httpx.Response:
        return self.request("DELETE", path, **kwargs)

    # ── Internos ────────────────────────────────────────────────────

    @staticmethod
    def _check_response(response: httpx.Response) -> None:
        """Chequea errores HTTP. Lanza excepción si status >= 400."""
        if response.status_code >= 400:
            raise httpx.HTTPStatusError(
                f"HTTP {response.status_code}",
                request=response.request,
                response=response,
            )

    @staticmethod
    def _should_retry(status_code: int) -> bool:
        """Determina si un código HTTP debe reintentarse."""
        return status_code in {429, 500, 502, 503, 504}

    def close(self) -> None:
        """Cierra el cliente HTTP."""
        self._client.close()

    def __enter__(self) -> ApiClient:
        return self

    def __exit__(self, *args: Any) -> None:
        self.close()


def _safe_body(response: httpx.Response) -> str:
    """Extrae el cuerpo de respuesta de forma segura."""
    try:
        return response.text[:500]
    except Exception:
        return "<no readable>"
```

---

## 🔐 Autenticación (`auth.py`)

```python
"""Handlers de autenticación para APIs REST."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


class AuthHandler(ABC):
    """Interfaz para estrategias de autenticación."""

    @abstractmethod
    def get_headers(self) -> dict[str, str]:
        """Retorna headers HTTP para autenticación."""
        ...


class NoAuth(AuthHandler):
    """Sin autenticación."""

    def get_headers(self) -> dict[str, str]:
        return {}


@dataclass
class BearerTokenAuth(AuthHandler):
    """Autenticación Bearer Token."""

    token: str

    def get_headers(self) -> dict[str, str]:
        return {"Authorization": f"Bearer {self.token}"}


@dataclass
class ApiKeyAuth(AuthHandler):
    """Autenticación por API Key (header o query)."""

    key_name: str
    key_value: str
    in_header: bool = True

    def get_headers(self) -> dict[str, str]:
        if self.in_header:
            return {self.key_name: self.key_value}
        return {}  # Se agrega como query param en el request


@dataclass
class BasicAuth(AuthHandler):
    """Autenticación HTTP Basic."""

    username: str
    password: str

    def get_headers(self) -> dict[str, str]:
        import base64
        raw = f"{self.username}:{self.password}"
        encoded = base64.b64encode(raw.encode()).decode()
        return {"Authorization": f"Basic {encoded}"}


@dataclass
class MultiHeaderAuth(AuthHandler):
    """Autenticación con múltiples headers (ej: HMAC, firmas)."""

    headers: dict[str, str] = field(default_factory=dict)

    def get_headers(self) -> dict[str, str]:
        return dict(self.headers)
```

---

## ⏱ Rate Limiting (`rate_limiter.py`)

```python
"""Rate limiter con token bucket."""

from __future__ import annotations

import time
from collections.abc import Generator


class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, requests_per_second: float) -> None:
        if requests_per_second <= 0:
            raise ValueError("requests_per_second debe ser > 0")
        self.interval = 1.0 / requests_per_second
        self._last_call: float = 0.0

    def wait(self) -> None:
        """Espera si es necesario para respetar el rate limit."""
        now = time.monotonic()
        elapsed = now - self._last_call
        if elapsed < self.interval:
            time.sleep(self.interval - elapsed)
        self._last_call = time.monotonic()


class NoOpLimiter(RateLimiter):
    """Rate limiter que no limita (requests_per_second = 0)."""

    def __init__(self) -> None:
        pass

    def wait(self) -> None:
        pass
```

---

## ❌ Manejo de errores (`errors.py`)

```python
"""Excepciones específicas para integraciones API."""

from __future__ import annotations


class ApiError(Exception):
    """Error base de API."""

    def __init__(self, message: str, details: str | None = None) -> None:
        self.details = details
        super().__init__(message)


class HttpError(ApiError):
    """Error con código HTTP específico."""

    def __init__(self, status_code: int, path: str, body: str = "") -> None:
        self.status_code = status_code
        self.path = path
        self.body = body
        super().__init__(f"HTTP {status_code}: {path}", details=body[:300])

    def is_client_error(self) -> bool:
        """400 <= status < 500."""
        return 400 <= self.status_code < 500

    def is_server_error(self) -> bool:
        """500 <= status < 600."""
        return 500 <= self.status_code < 600


class TimeoutError(ApiError):
    """Timeout en petición."""

    def __init__(self, path: str, timeout: float) -> None:
        self.path = path
        self.timeout = timeout
        super().__init__(f"Timeout después de {timeout}s: {path}")


class RateLimitError(ApiError):
    """Rate limit alcanzado (HTTP 429)."""

    def __init__(self, retry_after: int | None = None) -> None:
        self.retry_after = retry_after
        msg = f"Rate limit alcanzado (retry after: {retry_after}s)" if retry_after else "Rate limit alcanzado"
        super().__init__(msg)


class AuthError(ApiError):
    """Error de autenticación (HTTP 401/403)."""

    def __init__(self, message: str = "Autenticación fallida") -> None:
        super().__init__(message)


class ValidationError(ApiError):
    """Error de validación (HTTP 422)."""

    def __init__(self, errors: list[dict] | None = None) -> None:
        self.errors = errors or []
        super().__init__("Error de validación de la API", details=str(self.errors))
```

---

## 📄 Paginación (`pagination.py`)

```python
"""Paginación genérica para APIs REST."""

from __future__ import annotations

from collections.abc import Generator
from typing import Any

from src.api.client import ApiClient


def paginate(
    client: ApiClient,
    path: str,
    *,
    params: dict[str, Any] | None = None,
    page_param: str = "page",
    per_page_param: str = "per_page",
    per_page: int = 100,
    max_pages: int | None = None,
    data_key: str | None = None,
    total_key: str | None = None,
) -> Generator[dict[str, Any], None, None]:
    """
    Pagina a través de resultados paginados.

    Args:
        client: Instancia de ApiClient.
        path: Ruta del endpoint.
        params: Parámetros adicionales de query.
        page_param: Nombre del parámetro de página (?page=1).
        per_page_param: Nombre del parámetro de items por página.
        per_page: Items por página (default: 100).
        max_pages: Máximo de páginas (None = todas).
        data_key: Clave donde están los items en la respuesta.
                  Si es None, la respuesta completa es la lista.
        total_key: Clave donde está el total (None = paginar hasta vacío).
    """
    page = 1
    fetched = 0
    request_params = dict(params or {})

    while max_pages is None or page <= max_pages:
        request_params[page_param] = page
        request_params[per_page_param] = per_page

        response = client.get(path, params=request_params)
        data = response.json()

        items = data[data_key] if data_key else data

        if not isinstance(items, list) or len(items) == 0:
            break

        yield from items  # type: ignore
        fetched += len(items)
        page += 1

        # Si el total_key existe y ya obtuvimos todo, salir
        if total_key and fetched >= data.get(total_key, 0):
            break


def paginate_cursor(
    client: ApiClient,
    path: str,
    *,
    params: dict[str, Any] | None = None,
    cursor_param: str = "cursor",
    cursor_field: str = "next_cursor",
    data_key: str = "data",
    max_iterations: int = 1000,
) -> Generator[dict[str, Any], None, None]:
    """
    Paginación basada en cursor.

    Args:
        client: Instancia de ApiClient.
        path: Ruta del endpoint.
        params: Parámetros adicionales.
        cursor_param: Nombre del parámetro de cursor en el request.
        cursor_field: Campo del cursor en la respuesta.
        data_key: Clave de los items en la respuesta.
        max_iterations: Límite de seguridad.
    """
    cursor: str | None = None
    iterations = 0
    request_params = dict(params or {})

    while iterations < max_iterations:
        if cursor:
            request_params[cursor_param] = cursor

        response = client.get(path, params=request_params)
        body = response.json()

        items = body.get(data_key, [])
        yield from items

        cursor = body.get(cursor_field)
        if not cursor:
            break

        iterations += 1
```

---

## 🧩 Snippet: Endpoints específicos

```python
"""Ejemplo de endpoints de una API específica."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from src.api.client import ApiClient
from src.api.pagination import paginate


@dataclass
class Project:
    id: str
    name: str
    status: str
    metadata: dict[str, Any]


class ProjectApi:
    """Cliente para el endpoint /projects."""

    def __init__(self, client: ApiClient) -> None:
        self._client = client

    def list(self, status: str | None = None) -> list[Project]:
        """Lista todos los proyectos."""
        params = {}
        if status:
            params["status"] = status

        results: list[Project] = []
        for item in paginate(
            self._client,
            "/projects",
            params=params,
            per_page=100,
            data_key="items",
        ):
            results.append(Project(
                id=item["id"],
                name=item["name"],
                status=item["status"],
                metadata=item.get("metadata", {}),
            ))
        return results

    def get(self, project_id: str) -> Project:
        """Obtiene un proyecto por ID."""
        resp = self._client.get(f"/projects/{project_id}")
        data = resp.json()
        return Project(
            id=data["id"],
            name=data["name"],
            status=data["status"],
            metadata=data.get("metadata", {}),
        )

    def create(self, name: str, **kwargs: Any) -> Project:
        """Crea un nuevo proyecto."""
        resp = self._client.post("/projects", json={"name": name, **kwargs})
        data = resp.json()
        return Project(
            id=data["id"],
            name=data["name"],
            status=data["status"],
            metadata=data.get("metadata", {}),
        )
```

---

## ✅ Checklist de calidad de integración API

| # | Check | Descripción |
|---|-------|-------------|
| 1 | Timeout configurable | `httpx.Timeout` en todas las peticiones |
| 2 | Retry con backoff exponencial | Máximo 3-5 intentos; solo en 429, 5xx |
| 3 | Rate limiter activo | Token bucket o similar, configurable |
| 4 | Auth desacoplada | `AuthHandler` como interfaz inyectable |
| 5 | Errores tipificados | Jerarquía `ApiError` → `HttpError`, `TimeoutError`, etc. |
| 6 | Logging de peticiones lentas | `logger.warning` si > threshold |
| 7 | Paginación abstracta | No mezclar lógica de paginación con endpoints |
| 8 | Tests con respuestas mockeadas | `httpx.MockTransport` o `respx` |
| 9 | Cerrar cliente explícitamente | Context manager o `close()` |
| 10 | Validación de schemas | Usar dataclasses o Pydantic para respuestas |
| 11 | Códigos HTTP manejados explícitamente | 401→AuthError, 403→AuthError, 422→ValidationError, 429→RateLimitError |
| 12 | body/text limitado en logs | No loguear respuestas completas sin truncar |

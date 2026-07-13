# error-handling-std

Manejo estandarizado de errores en Python. Define la jerarquía de excepciones, logging estructurado, patrones de try/except y fallos graceful.

---

## 📁 Estructura de archivos

```
project/
├── src/
│   ├── __init__.py
│   ├── errors.py            # Jerarquía de excepciones
│   ├── logger.py             # Logging estructurado
│   └── graceful.py           # Fallos graceful / shutdown
├── tests/
│   ├── __init__.py
│   ├── test_errors.py
│   └── test_logger.py
└── README.md
```

---

## 🔺 Jerarquía de excepciones (`errors.py`)

```python
"""Jerarquía base de excepciones del proyecto."""

from __future__ import annotations


class AppError(Exception):
    """Error base de la aplicación. Todas las excepciones heredan de aquí."""

    def __init__(self, message: str = "", *, code: str | None = None, details: dict | None = None) -> None:
        self.code = code or self.__class__.__name__
        self.details = details or {}
        super().__init__(message)

    @property
    def message(self) -> str:
        return str(self.args[0]) if self.args else ""


# ── Errores de datos ────────────────────────────────────────────────

class DataError(AppError):
    """Error en datos de entrada o procesamiento."""
    code = "DATA_ERROR"


class ValidationError(DataError):
    """Datos no pasan validación."""
    code = "VALIDATION_ERROR"


class ParseError(DataError):
    """Error al parsear un formato."""
    code = "PARSE_ERROR"


class SchemaError(DataError):
    """Error de schema o estructura de datos."""
    code = "SCHEMA_ERROR"


# ── Errores de I/O ──────────────────────────────────────────────────

class IOError_App(AppError):
    """Error de entrada/salida."""
    code = "IO_ERROR"


class FileNotFoundError_(IOError_App):
    """Archivo no encontrado."""
    code = "FILE_NOT_FOUND"


class FilePermissionError(IOError_App):
    """Permiso denegado para acceder al archivo."""
    code = "FILE_PERMISSION"


class EncodingError(IOError_App):
    """Error de codificación de caracteres."""
    code = "ENCODING_ERROR"


# ── Errores de red / API ────────────────────────────────────────────

class NetworkError(AppError):
    """Error de red o comunicación."""
    code = "NETWORK_ERROR"


class ApiError_(NetworkError):
    """Error de API externa."""
    code = "API_ERROR"


class TimeoutError_(NetworkError):
    """Timeout en operación de red."""
    code = "TIMEOUT"


class RateLimitError_(NetworkError):
    """Rate limit alcanzado."""
    code = "RATE_LIMIT"


# ── Errores de configuración ────────────────────────────────────────

class ConfigError(AppError):
    """Error de configuración."""
    code = "CONFIG_ERROR"


class MissingConfigError(ConfigError):
    """Configuración faltante."""
    code = "MISSING_CONFIG"


class InvalidConfigError(ConfigError):
    """Valor de configuración inválido."""
    code = "INVALID_CONFIG"


# ── Errores de pipeline / estado ────────────────────────────────────

class StateError(AppError):
    """Error de estado de la aplicación."""
    code = "STATE_ERROR"


class PreconditionError(StateError):
    """Precondición no cumplida."""
    code = "PRECONDITION"


class ResourceExhaustedError(StateError):
    """Recurso agotado (memoria, disco, etc.)."""
    code = "RESOURCE_EXHAUSTED"


# ── Errores de lógica de negocio ────────────────────────────────────

class BusinessError(AppError):
    """Error de regla de negocio."""
    code = "BUSINESS_ERROR"


class DuplicateError(BusinessError):
    """Elemento duplicado."""
    code = "DUPLICATE"


class NotFoundError(BusinessError):
    """Elemento no encontrado."""
    code = "NOT_FOUND"
```

---

## 📝 Logging estructurado (`logger.py`)

```python
"""Logging estructurado con formato consistente."""

from __future__ import annotations

import json
import logging
import sys
from collections.abc import Callable
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# ── Formateadores ───────────────────────────────────────────────────

class StructuredFormatter(logging.Formatter):
    """Formateador estructurado con campos consistentes.

    Formato: 2026-01-15T10:30:00.000Z | INFO  | module.func | Mensaje
    """

    def format(self, record: logging.LogRecord) -> str:
        timestamp = datetime.fromtimestamp(record.created, tz=timezone.utc).isoformat()
        module = f"{record.name}.{record.funcName}" if record.funcName else record.name
        return (
            f"{timestamp} | {record.levelname:<8s} | {module:<30s} | {record.getMessage()}"
        )


class JsonFormatter(logging.Formatter):
    """Formateador JSON para consumo por sistemas externos."""

    def format(self, record: logging.LogRecord) -> str:
        log_entry: dict[str, Any] = {
            "timestamp": datetime.fromtimestamp(record.created, tz=timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        if record.exc_info and record.exc_info[0]:
            log_entry["exception"] = {
                "type": record.exc_info[0].__name__,
                "message": str(record.exc_info[1]),
            }
        # Agregar campos extra (si se pasan como extra= en el log)
        if hasattr(record, "extra_fields"):
            log_entry.update(record.extra_fields)
        return json.dumps(log_entry, ensure_ascii=False, default=str)


# ── Logger factory ──────────────────────────────────────────────────

def get_logger(name: str, level: int = logging.INFO) -> logging.Logger:
    """Obtiene un logger configurado con output a stderr."""
    logger = logging.getLogger(name)

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stderr)
        handler.setFormatter(StructuredFormatter())
        logger.addHandler(handler)

    logger.setLevel(level)
    logger.propagate = False
    return logger


def setup_logging(
    *,
    level: int = logging.INFO,
    log_file: Path | None = None,
    json_format: bool = False,
) -> None:
    """Configura el logging global del proyecto."""
    root = logging.getLogger()
    root.setLevel(level)

    # Limpiar handlers existentes
    for h in root.handlers[:]:
        root.removeHandler(h)

    formatter = JsonFormatter() if json_format else StructuredFormatter()

    handler: logging.Handler
    if log_file:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        handler = logging.FileHandler(log_file, encoding="utf-8")
    else:
        handler = logging.StreamHandler(sys.stderr)

    handler.setFormatter(formatter)
    root.addHandler(handler)


# ── Decorador para loggear entry/exit ───────────────────────────────

def log_call(logger: logging.Logger | None = None) -> Callable:
    """Decorador que loggea entrada, salida y errores de una función."""
    def decorator(func: Callable) -> Callable:
        nonlocal logger
        if logger is None:
            logger = get_logger(func.__module__)

        def wrapper(*args: Any, **kwargs: Any) -> Any:
            func_name = f"{func.__module__}.{func.__qualname__}"
            logger.debug("→ %s args=%s kwargs=%s", func_name, args, kwargs)
            try:
                result = func(*args, **kwargs)
                logger.debug("← %s => %s", func_name, _truncate(result))
                return result
            except Exception as e:
                logger.error("✗ %s => %s: %s", func_name, type(e).__name__, e)
                raise
            except BaseException as e:
                logger.critical("💥 %s => %s: %s", func_name, type(e).__name__, e)
                raise

        return wrapper

    return decorator


def _truncate(value: Any, max_len: int = 200) -> str:
    """Trunca la representación de un valor para logging."""
    s = repr(value)
    return s[:max_len] + "..." if len(s) > max_len else s
```

---

## 🔄 Patrones de try/except

### Patrón 1: Captura específica con contexto

```python
def read_config(path: Path) -> dict[str, Any]:
    """Lee un archivo de configuración con manejo de errores detallado."""
    try:
        content = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise MissingConfigError(f"Archivo de configuración no encontrado: {path}")
    except PermissionError:
        raise FilePermissionError(f"Permiso denegado al leer: {path}")
    except UnicodeDecodeError as e:
        raise EncodingError(f"Error de codificación en {path}: {e}")

    try:
        return tomllib.loads(content)
    except tomllib.TOMLDecodeError as e:
        raise ParseError(f"Error parseando TOML en {path}: {e}")
```

### Patrón 2: Re-intentar con retry (operaciones transientes)

```python
def with_retry(
    func: Callable,
    max_retries: int = 3,
    retry_delay: float = 1.0,
    backoff: float = 2.0,
    retryable_exceptions: tuple[type[Exception], ...] = (TimeoutError, ConnectionError),
) -> Callable:
    """Decorador para reintentar operaciones transientes."""
    import time

    def wrapper(*args: Any, **kwargs: Any) -> Any:
        last_exc: Exception | None = None
        delay = retry_delay
        for attempt in range(1, max_retries + 1):
            try:
                return func(*args, **kwargs)
            except retryable_exceptions as e:
                last_exc = e
                logger = get_logger(func.__module__)
                logger.warning(
                    "Intento %d/%d falló para %s: %s. Reintentando en %.1fs...",
                    attempt, max_retries, func.__name__, e, delay,
                )
                time.sleep(delay)
                delay *= backoff

        raise last_exc  # type: ignore
    return wrapper
```

### Patrón 3: Try/except con cleanup

```python
def process_file(path: Path) -> list[dict[str, Any]]:
    """Procesa un archivo asegurando limpieza en caso de error."""
    tmp_output: Path | None = None
    try:
        tmp_output = path.with_suffix(".tmp")
        data = read_csv(path)
        result = transform(data)
        write_csv(tmp_output, result)
        tmp_output.rename(path.with_suffix(".processed.csv"))
        return result
    except Exception:
        if tmp_output and tmp_output.exists():
            tmp_output.unlink()
        raise
```

### Patrón 4: Error con acumulación (no detenerse en el primer error)

```python
def validate_batch(records: list[dict]) -> list[dict]:
    """Valida múltiples registros acumulando errores."""
    errors: list[str] = []
    valid: list[dict] = []

    for i, record in enumerate(records):
        try:
            validated = _validate_one(record)
            valid.append(validated)
        except ValidationError as e:
            errors.append(f"Registro {i}: {e}")

    if errors:
        logger = get_logger(__name__)
        logger.warning("%d registros inválidos de %d", len(errors), len(records))
        for err in errors:
            logger.debug("  - %s", err)

    return valid
```

### Patrón 5: Cadena de causas (raise from)

```python
def load_and_parse(path: Path) -> dict:
    """Carga y parsea un archivo, preservando la causa de errores."""
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as e:
        raise IOError_App(f"No se pudo leer {path}") from e

    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        raise ParseError(f"JSON inválido en {path}") from e
```

---

## 🧩 Snippet: Manejador global de errores

```python
"""Manejador global de errores no capturados."""

from __future__ import annotations

import logging
import sys
import traceback
from collections.abc import Callable

logger = logging.getLogger(__name__)


def setup_global_exception_handler() -> None:
    """Instala un manejador global para excepciones no capturadas."""

    def handle_exception(exc_type: type, exc_value: BaseException, exc_tb: object) -> None:
        if issubclass(exc_type, KeyboardInterrupt):
            sys.__excepthook__(exc_type, exc_value, exc_tb)
            return

        logger.critical(
            "Excepción no capturada: %s: %s",
            exc_type.__name__,
            exc_value,
            exc_info=(exc_type, exc_value, exc_tb),
        )
        sys.exit(1)

    sys.excepthook = handle_exception


def safe_main(main_func: Callable[[], int]) -> int:
    """Envuelve un main() con manejo de errores global."""
    setup_global_exception_handler()
    try:
        return main_func()
    except AppError as e:
        logger.error("%s [code=%s] details=%s", e.message, e.code, e.details)
        return 1
    except KeyboardInterrupt:
        logger.info("Operación cancelada por el usuario")
        return 130
    except Exception as e:
        logger.exception("Error inesperado: %s", e)
        return 1
```

---

## 🧩 Snippet: Context manager para medición de errores

```python
"""Context manager para medir y reportar errores en bloques de código."""

from __future__ import annotations

import logging
import time
from collections.abc import Generator
from contextlib import contextmanager
from typing import Any

logger = logging.getLogger(__name__)


@contextmanager
def error_boundary(
    operation: str,
    *,
    log_level: int = logging.ERROR,
    raise_on_error: bool = True,
) -> Generator[None, None, None]:
    """Captura y loggea errores en un bloque de código.

    Args:
        operation: Nombre descriptivo de la operación.
        log_level: Nivel de log para el error.
        raise_on_error: Si True, re-lanza la excepción.
    """
    try:
        start = time.perf_counter()
        yield
        elapsed = time.perf_counter() - start
        logger.debug("✓ %s completado en %.3fs", operation, elapsed)
    except AppError:
        logger.log(log_level, "✗ %s falló (error controlado)", operation)
        if raise_on_error:
            raise
    except Exception as e:
        logger.log(log_level, "✗ %s falló: %s", operation, e, exc_info=True)
        if raise_on_error:
            raise
```

### Uso:

```python
with error_boundary("carga de archivo", raise_on_error=False):
    data = read_csv(Path("datos.csv"))

with error_boundary("procesamiento de lote"):
    process_batch(data)
```

---

## ✅ Checklist de calidad de manejo de errores

| # | Check | Descripción |
|---|-------|-------------|
| 1 | Jerarquía de excepciones propia | Todas heredan de `AppError` |
| 2 | Códigos de error en excepciones | Cada excepción tiene atributo `.code` |
| 3 | Logging a stderr | Nunca loggear a stdout |
| 4 | `raise from` para preservar causa | Usar `raise X from original` |
| 5 | No capturar `Exception` genérica | Capturar la más específica posible |
| 6 | Errores con contexto | Incluir qué y dónde falló en el mensaje |
| 7 | Cleanup con try/finally o context manager | Archivos, conexiones, locks siempre liberados |
| 8 | `sys.excepthook` instalado | Capturar errores no manejados |
| 9 | No silenciar excepciones | `except: pass` prohibido |
| 10 | Funciones retornan códigos de error | main() retorna int, funciones lanzan excepción |
| 11 | Errores acumulables en batch | No detener todo el proceso en el primer error |
| 12 | Info sensible no en logs | Sanitizar passwords, tokens, PII antes de loggear |
| 13 | Errores de timeout tratados separadamente | Timeout ≠ connection refused |
| 14 | `KeyboardInterrupt` siempre manejado | Salida graceful con código 130 |

---

## 🔧 Script de validación

```python
#!/usr/bin/env python3
"""Valida que el código use manejo de errores correcto."""

import ast
import sys
from pathlib import Path


def check_file(path: Path) -> list[str]:
    issues: list[str] = []
    try:
        tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    except SyntaxError as e:
        issues.append(f"[SINTAXIS] {path.name}: {e}")
        return issues

    for node in ast.walk(tree):
        # Bare except
        if isinstance(node, ast.ExceptHandler) and node.type is None:
            if node.name is None:
                issues.append(f"[BARE_EXCEPT] {path.name}:{node.lineno}")

        # Captura de BaseException
        if isinstance(node, ast.ExceptHandler) and isinstance(node.type, ast.Name):
            if node.type.id == "BaseException":
                if node.name is None or node.name == "_":
                    issues.append(f"[BASE_EXCEPTION] {path.name}:{node.lineno}")

        # except Exception: sin loguear o re-lanzar
        if isinstance(node, ast.ExceptHandler):
            if isinstance(node.type, ast.Name) and node.type.id == "Exception":
                has_log = any(
                    isinstance(n, ast.Call)
                    and isinstance(n.func, ast.Attribute)
                    and isinstance(n.func.value, ast.Call)
                    and getattr(n.func.value.func, "attr", None) in ("warning", "error", "exception", "critical", "info")
                    for n in ast.walk(node)
                )
                if not has_log and len(node.body) == 1 and isinstance(node.body[0], ast.Raise):
                    pass  # except Exception: raise (ok, re-lanza limpio)
                elif not has_log:
                    issues.append(f"[SILENT_CATCH] {path.name}:{node.lineno} - captura Exception sin log")

    return issues


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("src")
    all_issues: list[str] = []
    for pyfile in sorted(root.rglob("*.py")):
        if pyfile.name.startswith("_"):
            continue
        all_issues.extend(check_file(pyfile))

    for issue in all_issues:
        print(issue, file=sys.stderr)

    if all_issues:
        print(f"\n⚠ {len(all_issues)} problemas encontrados", file=sys.stderr)
    else:
        print("✓ Sin problemas de manejo de errores")

    return min(len(all_issues), 255)


if __name__ == "__main__":
    sys.exit(main())
```

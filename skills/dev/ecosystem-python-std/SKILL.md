# ecosystem-python-std

Convenciones y estándares del ecosistema Python moderno (3.12+) para todo el código generado por el enjambre.

---

## 📋 Reglas de negocio (10+)

### 1. Type hints obligatorios (PEP 484 / PEP 695)
Toda función, método o propiedad pública debe tener type hints completos en parámetros y retorno. Usar sintaxis 3.10+ (`X | Y` en lugar de `Optional[X]`).

```python
# ✅ Correcto
def process_items(items: list[str] | None, timeout: float = 30.0) -> dict[str, int]: ...

# ❌ Incorrecto
def process_items(items, timeout=30.0):
    ...
```

### 2. `pathlib` en vez de `os.path`
Usar `pathlib.Path` para toda manipulación de rutas. Prohibido `os.path.join`, `os.path.exists`, `os.mkdir`.

```python
# ✅ Correcto
data_dir = Path("data") / "raw"
data_dir.mkdir(parents=True, exist_ok=True)

# ❌ Incorrecto
import os
os.makedirs(os.path.join("data", "raw"), exist_ok=True)
```

### 3. `argparse` en vez de `sys.argv`
Para cualquier herramienta CLI, usar `argparse`. Prohibido parsear `sys.argv` manualmente.

### 4. Encoding UTF-8 explícito
Toda operación de I/O de texto debe especificar `encoding="utf-8"`.

```python
# ✅ Correcto
with path.open("r", encoding="utf-8") as f: ...

# ❌ Incorrecto
with open(str(path), "r") as f: ...
```

### 5. Logging a stderr, no stdout
Usar `logging` con destino stderr para mensajes de registro. stdout reservado para output de datos.

```python
import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    stream=sys.stderr,
    format="%(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger(__name__)
```

### 6. Usar `try/except` con excepciones específicas
Nunca capturar `Exception` genérica sin registrar o re-lanzar. Capturar la excepción más específica posible.

```python
# ✅ Correcto
try:
    data = json.loads(raw)
except json.JSONDecodeError as e:
    logger.error("Formato inválido: %s", e)
    raise

# ❌ Incorrecto
try:
    data = json.loads(raw)
except Exception:
    pass
```

### 7. Context managers para recursos externos
Usar `with` para archivos, conexiones HTTP, DB, locks. Implementar `__enter__`/`__exit__` en recursos propios.

### 8. Dataclasses para estructuras de datos
Usar `@dataclass` (o `NamedTuple` cuando aplique) en vez de diccionarios para datos estructurados.

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Config:
    host: str
    port: int
    timeout: float = 30.0
```

### 9. Separación clara de concerns: library vs script
Cada archivo debe tener una sola responsabilidad:
- `modulo.py` → define clases/funciones (no ejecuta nada al importarse)
- `cli_main.py` → solo contiene el entry point `if __name__ == "__main__": main()`

### 10. Enums para constantes agrupadas
Usar `enum.StrEnum` o `enum.IntEnum` para conjuntos fijos de valores.

```python
from enum import StrEnum

class Status(StrEnum):
    PENDING = "pending"
    ACTIVE = "active"
    COMPLETED = "completed"
```

### 11. `functools.lru_cache` para funciones costosas
Cachear resultados de funciones puras con `@lru_cache` o `@cache`.

### 12. `typing.Protocol` para duck typing estructural
```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...
```

---

## 🧩 Snippets de código

### Snippet 1: Lectura segura de archivo con logging
```python
def read_text_file(path: Path) -> str | None:
    """Lee un archivo de texto con manejo de errores."""
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        logger.warning("Archivo no encontrado: %s", path)
        return None
    except PermissionError:
        logger.error("Permiso denegado: %s", path)
        return None
```

### Snippet 2: CLI con argparse y subcomandos
```python
def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="tool", description="Herramienta de ejemplo")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("status", help="Ver estado")
    run_parser = subparsers.add_parser("run", help="Ejecutar tarea")
    run_parser.add_argument("--input", "-i", type=Path, required=True)
    run_parser.add_argument("--verbose", "-v", action="store_true")
    return parser
```

### Snippet 3: Logger configurado con stderr
```python
def setup_logger(name: str, level: int = logging.INFO) -> logging.Logger:
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stderr)
        handler.setFormatter(logging.Formatter("%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"))
        logger.addHandler(handler)
        logger.setLevel(level)
    return logger
```

### Snippet 4: Dataclass con validación post-init
```python
from dataclasses import dataclass, field

@dataclass
class Range:
    start: int
    end: int

    def __post_init__(self) -> None:
        if self.start > self.end:
            raise ValueError(f"start ({self.start}) > end ({self.end})")
```

### Snippet 5: Decodificación segura con encoding
```python
def safe_decode(data: bytes, fallback: str = "latin-1") -> str:
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        logger.warning("Fallback encoding %s para %d bytes", fallback, len(data))
        return data.decode(fallback, errors="replace")
```

### Snippet 6: Iterador con paginación (generador)
```python
def chunked[T](items: list[T], size: int) -> Generator[list[T], None, None]:
    for i in range(0, len(items), size):
        yield items[i : i + size]
```

---

## ✅ Checks de validación

Estos checks deben ejecutarse contra todo código generado:

| # | Check | Descripción |
|---|-------|-------------|
| 1 | `type_hints_present` | Toda función pública tiene type hints |
| 2 | `no_os_path` | No se usa `os.path` donde `pathlib` aplica |
| 3 | `no_sys_argv` | No hay parsing manual de `sys.argv` |
| 4 | `encoding_utf8` | Todo `open()` de texto especifica `encoding="utf-8"` |
| 5 | `logging_stderr` | No hay `print()` para logs (usar `logging`) |
| 6 | `no_bare_except` | No hay `except:` sin especificar |
| 7 | `with_resources` | Archivos/recursos se abren con `with` |
| 8 | `dataclass_struct` | Datos estructurados usan `@dataclass` |
| 9 | `main_guard` | Código ejecutable protegido por `if __name__` |
| 10 | `enum_constants` | Constantes agrupadas usan `enum` |
| 11 | `pathlib_cross_platform` | Rutas usan `/` (Path) no separadores manuales |
| 12 | `f_strings_preferred` | Preferir f-strings sobre `.format()` o `%` |

---

## 🔧 Script de validación automática

```python
#!/usr/bin/env python3
# validate_style.py — corre contra `src/` o la ruta indicada

import ast
import sys
from pathlib import Path

ERRORS: list[str] = []

def check_file(filepath: Path) -> None:
    try:
        tree = ast.parse(filepath.read_text(encoding="utf-8"), filename=str(filepath))
    except SyntaxError as e:
        ERRORS.append(f"[SINTAXIS] {filepath.name}: {e}")
        return

    for node in ast.walk(tree):
        # Check 6: bare except
        if isinstance(node, ast.ExceptHandler) and node.type is None:
            if node.name is None or node.name == "_":
                ERRORS.append(f"[BARE_EXCEPT] {filepath.name}:{node.lineno}")

def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("src")
    for pyfile in root.rglob("*.py"):
        if pyfile.name.startswith("_"):
            continue
        check_file(pyfile)

    for err in ERRORS:
        print(err, file=sys.stderr)
    return min(len(ERRORS), 255)

if __name__ == "__main__":
    sys.exit(main())
```

---

## 📚 Referencias

- PEP 8 — Style Guide for Python Code
- PEP 484 — Type Hints
- PEP 695 — Type Parameter Syntax
- PEP 686 — UTF-8 Mode
- `argparse` docs — https://docs.python.org/3/library/argparse.html
- `pathlib` docs — https://docs.python.org/3/library/pathlib.html

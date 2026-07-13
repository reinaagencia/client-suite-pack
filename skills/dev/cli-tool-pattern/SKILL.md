# cli-tool-pattern

Patrón estandarizado para herramientas CLI con argparse. Proporciona estructura de archivos, manejo de argumentos, output formateado y un template reutilizable.

---

## 📁 Estructura de archivos

```
project/
├── cli_main.py            # Entry point (argparse + main)
├── src/
│   ├── __init__.py
│   ├── commands/
│   │   ├── __init__.py
│   │   ├── cmd_status.py  # Implementación de subcomando "status"
│   │   └── cmd_run.py     # Implementación de subcomando "run"
│   ├── formatter.py       # Output helpers (colores, tablas)
│   └── config.py          # Carga de configuración
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_cli_main.py   # Tests del parser
│   └── commands/
│       ├── __init__.py
│       ├── test_cmd_status.py
│       └── test_cmd_run.py
├── pyproject.toml          # Configuración (entry point console_scripts)
└── README.md
```

### Entry point en `pyproject.toml`

```toml
[project.scripts]
mi-herramienta = "cli_main:main"
```

---

## ⚙️ Manejo de argumentos y flags

### Patrón de parser (subcomandos obligatorios)

```python
# cli_main.py
import argparse
import sys
from pathlib import Path


def build_parser() -> argparse.ArgumentParser:
    """Construye el parser principal con subcomandos."""
    parser = argparse.ArgumentParser(
        prog="mi-herramienta",
        description="Descripción breve de la herramienta",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Ejemplo: mi-herramienta run --input datos.csv --output resultados.json",
    )

    # Argumentos globales
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Output detallado (log debug a stderr)",
    )
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Solo mostrar errores",
    )
    parser.add_argument(
        "--config", "-c",
        type=Path,
        default=Path("config.toml"),
        help="Ruta al archivo de configuración (default: config.toml)",
    )

    # Subcomandos
    subparsers = parser.add_subparsers(dest="command", required=True)

    _add_status_parser(subparsers)
    _add_run_parser(subparsers)
    _add_export_parser(subparsers)

    return parser


def _add_status_parser(subparsers: argparse._SubParsersAction) -> None:
    """Subcomando: status — muestra el estado actual."""
    p = subparsers.add_parser("status", help="Mostrar estado del sistema")
    p.add_argument("--format", choices=["text", "json"], default="text", help="Formato de salida")


def _add_run_parser(subparsers: argparse._SubParsersAction) -> None:
    """Subcomando: run — ejecuta una tarea."""
    p = subparsers.add_parser("run", help="Ejecutar una tarea")
    p.add_argument("--input", "-i", type=Path, required=True, help="Archivo de entrada")
    p.add_argument("--output", "-o", type=Path, required=True, help="Archivo de salida")
    p.add_argument("--force", "-f", action="store_true", help="Sobrescribir output existente")
    p.add_argument("--limit", type=int, default=0, help="Límite de registros a procesar (0=sín límite)")


def _add_export_parser(subparsers: argparse._SubParsersAction) -> None:
    """Subcomando: export — exporta datos a formato externo."""
    p = subparsers.add_parser("export", help="Exportar datos")
    p.add_argument("format", choices=["csv", "json", "xlsx"], help="Formato de exportación")
    p.add_argument("--destination", "-d", type=Path, required=True, help="Directorio destino")
```

### Validación post-parseo

```python
def validate_args(args: argparse.Namespace) -> None:
    """Valida argumentos después del parseo."""
    if hasattr(args, "input") and args.input and not args.input.exists():
        parser.error(f"Archivo de entrada no encontrado: {args.input}")

    if hasattr(args, "output") and args.output:
        if args.output.exists() and not getattr(args, "force", False):
            parser.error(
                f"El archivo {args.output} ya existe. Usa --force para sobrescribir."
            )
```

---

## 🎨 Output formateado

### Módulo `formatter.py`

```python
"""Helpers de formato para output CLI."""

import json
import sys
from collections.abc import Mapping, Sequence


# ── ANSI colors ─────────────────────────────────────────────────────
class Style:
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    CYAN = "\033[96m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    RESET = "\033[0m"


def ok(message: str) -> None:
    """Imprime mensaje de éxito en verde a stdout."""
    print(f"{Style.GREEN}✓{Style.RESET} {message}")


def warn(message: str) -> None:
    """Imprime advertencia en amarillo a stderr."""
    print(f"{Style.YELLOW}⚠ {message}{Style.RESET}", file=sys.stderr)


def fail(message: str) -> None:
    """Imprime error en rojo a stderr."""
    print(f"{Style.RED}✗ {message}{Style.RESET}", file=sys.stderr)


def info(message: str) -> None:
    """Imprime información en cyan a stdout."""
    print(f"{Style.CYAN}ℹ{Style.RESET} {message}")


# ── Tablas ──────────────────────────────────────────────────────────

def print_table(
    headers: Sequence[str],
    rows: Sequence[Sequence[str]],
    max_col_width: int = 60,
) -> None:
    """Imprime una tabla simple alineada."""
    col_widths = [len(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            col_widths[i] = max(col_widths[i], min(len(str(cell)), max_col_width))

    sep = " | "
    header_line = sep.join(h.ljust(w) for h, w in zip(headers, col_widths))
    print(header_line)
    print("-" * len(header_line))

    for row in rows:
        line = sep.join(
            str(cell).ljust(w)[:w] for cell, w in zip(row, col_widths)
        )
        print(line)


def print_json(data: object) -> None:
    """Imprime datos como JSON indentado a stdout."""
    print(json.dumps(data, indent=2, ensure_ascii=False, default=str))


# ── Barras de progreso (sin dependencias) ─────────────────────────

def print_progress(current: int, total: int, bar_size: int = 40) -> None:
    """Imprime una barra de progreso simple en stderr."""
    if total == 0:
        return
    fraction = current / total
    filled = int(bar_size * fraction)
    bar = "█" * filled + "░" * (bar_size - filled)
    print(
        f"\r  {bar} {current:>{len(str(total))}}/{total} ({fraction:.0%})",
        end="",
        file=sys.stderr,
    )
    if current >= total:
        print(file=sys.stderr)
```

---

## 🧩 Snippets comunes

### Snippet 1: Función `main()` canónica

```python
def main(argv: list[str] | None = None) -> int:
    """Entry point. Retorna código de salida (0=éxito, 1=error)."""
    parser = build_parser()
    try:
        args = parser.parse_args(argv)
        validate_args(args)
        _setup_logging(args)
        return _dispatch(args)
    except KeyboardInterrupt:
        warn("Operación cancelada por el usuario")
        return 130
    except Exception as e:
        fail(f"Error inesperado: {e}")
        if args and args.verbose:
            import traceback
            traceback.print_exc(file=sys.stderr)
        return 1


def _dispatch(args: argparse.Namespace) -> int:
    """Rutea al handler del subcomando."""
    match args.command:
        case "status":
            from src.commands.cmd_status import run_status
            return run_status(args)
        case "run":
            from src.commands.cmd_run import run_task
            return run_task(args)
        case "export":
            from src.commands.cmd_export import run_export
            return run_export(args)
        case _:
            parser.error(f"Comando desconocido: {args.command}")
            return 1


if __name__ == "__main__":
    sys.exit(main())
```

### Snippet 2: Logging basado en flags

```python
def _setup_logging(args: argparse.Namespace) -> None:
    """Configura logging según flags --verbose/--quiet."""
    import logging
    level = logging.WARNING if args.quiet else (logging.DEBUG if args.verbose else logging.INFO)
    logging.basicConfig(
        level=level,
        stream=sys.stderr,
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    )
```

### Snippet 3: Preguntar confirmación

```python
def confirm(prompt: str, default: bool = False) -> bool:
    """Pide confirmación al usuario."""
    suffix = " [Y/n]" if default else " [y/N]"
    response = input(prompt + suffix).strip().lower()
    if not response:
        return default
    return response in ("y", "yes", "sí", "si")
```

---

## 📄 Template: `cli_main.py.tmpl`

```python
#!/usr/bin/env python3
"""
Nombre de la herramienta — descripción breve.

Uso:
    herramienta status [--format text|json]
    herramienta run --input ARCHIVO --output ARCHIVO [--force]
    herramienta export FORMATO --destination DIR

Ejemplos:
    herramienta status --format json
    herramienta run -i datos.csv -o resultados.json --force
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path


def build_parser() -> argparse.ArgumentParser:
    """Construye el parser de argumentos."""
    parser = argparse.ArgumentParser(
        prog="herramienta",
        description="Descripción de la herramienta",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Documentación: https://docs.ejemplo.com/herramienta",
    )

    # ── Argumentos globales ──────────────────────────────────────
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Output detallado (debug a stderr)",
    )
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Solo mostrar errores",
    )
    parser.add_argument(
        "--log-file",
        type=Path,
        help="Archivo de log adicional",
    )

    # ── Subcomandos ──────────────────────────────────────────────
    subparsers = parser.add_subparsers(dest="command", required=True)

    # status
    p_status = subparsers.add_parser("status", help="Mostrar estado")
    p_status.add_argument(
        "--format",
        choices=["text", "json", "table"],
        default="text",
        help="Formato de salida (default: text)",
    )

    # process
    p_process = subparsers.add_parser("process", help="Procesar datos")
    p_process.add_argument("--input", "-i", type=Path, required=True, help="Archivo de entrada")
    p_process.add_argument("--output", "-o", type=Path, required=True, help="Archivo de salida")
    p_process.add_argument("--force", "-f", action="store_true", help="Sobrescribir si existe")
    p_process.add_argument("--limit", type=int, default=0, help="Límite de registros")
    p_process.add_argument("--filter", type=str, help="Filtro (expresión o patrón)")

    # validate
    p_validate = subparsers.add_parser("validate", help="Validar datos")
    p_validate.add_argument("files", type=Path, nargs="+", help="Archivos a validar")
    p_validate.add_argument("--strict", action="store_true", help="Fallo en primera advertencia")

    return parser


def validate_args(args: argparse.Namespace) -> None:
    """Validaciones post-parseo."""
    problems: list[str] = []

    if hasattr(args, "input") and args.input and not args.input.exists():
        problems.append(f"Archivo de entrada no encontrado: {args.input}")

    if hasattr(args, "output") and args.output and args.output.exists():
        if not getattr(args, "force", False):
            problems.append(f"Output ya existe (usa --force): {args.output}")

    if hasattr(args, "files") and args.files:
        missing = [str(f) for f in args.files if not f.exists()]
        if missing:
            problems.append(f"Archivo(s) no encontrado(s): {', '.join(missing)}")

    if problems:
        for p in problems:
            print(f"Error: {p}", file=sys.stderr)
        sys.exit(1)


def setup_logging(verbose: bool, quiet: bool, log_file: Path | None = None) -> None:
    """Configura logging según flags."""
    level = logging.WARNING if quiet else (logging.DEBUG if verbose else logging.INFO)
    handlers: list[logging.Handler] = [logging.StreamHandler(sys.stderr)]
    if log_file:
        handlers.append(logging.FileHandler(log_file, encoding="utf-8"))

    logging.basicConfig(
        level=level,
        handlers=handlers,
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    )


def dispatch_command(args: argparse.Namespace) -> int:
    """Rutea al comando correspondiente."""
    match args.command:
        case "status":
            return cmd_status(args)
        case "process":
            return cmd_process(args)
        case "validate":
            return cmd_validate(args)
        case _:
            print(f"Error: comando desconocido '{args.command}'", file=sys.stderr)
            return 1


# ── Handlers de comandos (implementar) ──────────────────────────────

def cmd_status(args: argparse.Namespace) -> int:
    """Muestra estado del sistema."""
    # TODO: implementar
    print("Estado: OK")
    return 0


def cmd_process(args: argparse.Namespace) -> int:
    """Procesa datos de entrada → salida."""
    # TODO: implementar
    logger = logging.getLogger(__name__)
    logger.info("Procesando %s → %s", args.input, args.output)
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Valida archivos de entrada."""
    # TODO: implementar
    logger = logging.getLogger(__name__)
    for f in args.files:
        logger.info("Validando %s ...", f)
    return 0


# ── Main ────────────────────────────────────────────────────────────

def main(argv: list[str] | None = None) -> int:
    """Entry point. Retorna código de salida (0=éxito, ≥1=error)."""
    try:
        parser = build_parser()
        args = parser.parse_args(argv)
        validate_args(args)
        setup_logging(args.verbose, args.quiet, getattr(args, "log_file", None))
        return dispatch_command(args)
    except KeyboardInterrupt:
        print("\nOperación cancelada.", file=sys.stderr)
        return 130
    except Exception as e:
        logging.getLogger(__name__).exception("Error inesperado: %s", e)
        return 1


if __name__ == "__main__":
    sys.exit(main())
```

---

## ✅ Checklist de calidad CLI

| # | Check | Descripción |
|---|-------|-------------|
| 1 | `prog` definido | `argparse.ArgumentParser(prog="...")` |
| 2 | `--help` detallado | `epilog` con ejemplos de uso |
| 3 | Subcomandos con `dest="command"` y `required=True` | Sin esto no hay ruteo |
| 4 | Logging a stderr, output a stdout | Nunca mezclar |
| 5 | Código de salida correcto | 0 = ok, 1 = error, 130 = Ctrl+C |
| 6 | `Path` como tipo de argumento para rutas | `type=Path` |
| 7 | `--force` para operaciones destructivas | Nunca sobrescribir sin confirmación |
| 8 | `--verbose`/`--quiet` en toda herramienta | Logging configurable |
| 9 | Tests del parser sin llamar a `main()` | `parser.parse_args([...])` en tests |
| 10 | Excepciones no capturadas globalmente | Solo `Exception` y `KeyboardInterrupt` |

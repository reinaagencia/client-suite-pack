# data-pipeline-pattern

Patrón estandarizado para pipelines de datos (ETL) con formatos CSV, JSON, Excel y más. Cubre lectura/escritura, transformaciones, validación y reportes.

---

## 📁 Estructura de archivos

```
project/
├── src/
│   ├── __init__.py
│   ├── pipeline/
│   │   ├── __init__.py
│   │   ├── extract.py       # Lectura de datos (CSV, JSON, Excel)
│   │   ├── transform.py     # Transformaciones
│   │   ├── load.py          # Escritura de datos
│   │   ├── validate.py      # Validación de datos
│   │   └── report.py        # Reportes de pipeline
│   ├── schemas.py           # Schemas de datos (dataclasses)
│   └── config.py            # Configuración de pipeline
├── tests/
│   ├── __init__.py
│   └── pipeline/
│       ├── __init__.py
│       ├── test_extract.py
│       ├── test_transform.py
│       └── test_load.py
├── data/                    # Datos de entrada/salida (gitignored)
│   ├── input/
│   └── output/
├── pyproject.toml
└── pipeline_main.py         # Entry point del pipeline
```

---

## 📥 Extracción (`extract.py`)

```python
"""Lectura de datos desde múltiples formatos."""

from __future__ import annotations

import csv
import json
from pathlib import Path
from typing import Any


def read_csv(path: Path, *, delimiter: str = ",", encoding: str = "utf-8-sig") -> list[dict[str, str]]:
    """Lee un archivo CSV y retorna lista de diccionarios."""
    if not path.exists():
        raise FileNotFoundError(f"Archivo no encontrado: {path}")

    with path.open("r", encoding=encoding) as f:
        reader = csv.DictReader(f, delimiter=delimiter)
        rows = list(reader)

    if not rows:
        import logging
        logging.getLogger(__name__).warning("CSV vacío: %s", path)

    return rows


def read_json(path: Path, encoding: str = "utf-8") -> Any:
    """Lee un archivo JSON."""
    if not path.exists():
        raise FileNotFoundError(f"Archivo no encontrado: {path}")

    with path.open("r", encoding=encoding) as f:
        return json.load(f)


def read_json_lines(path: Path, encoding: str = "utf-8") -> list[dict[str, Any]]:
    """Lee un archivo JSON Lines (una línea = un objeto)."""
    if not path.exists():
        raise FileNotFoundError(f"Archivo no encontrado: {path}")

    records: list[dict[str, Any]] = []
    with path.open("r", encoding=encoding) as f:
        for line_num, line in enumerate(f, 1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                records.append(json.loads(stripped))
            except json.JSONDecodeError as e:
                import logging
                logging.getLogger(__name__).warning("Línea %d ignorada (JSON inválido): %s", line_num, e)

    return records


def read_excel(path: Path, sheet_name: str | int = 0) -> list[dict[str, Any]]:
    """Lee una hoja de Excel y retorna lista de diccionarios."""
    try:
        import openpyxl
    except ImportError:
        raise ImportError("openpyxl requerido para leer Excel. Instalar con: pip install openpyxl")

    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)

    if isinstance(sheet_name, str):
        if sheet_name not in wb.sheetnames:
            raise ValueError(f"Hoja '{sheet_name}' no encontrada. Disponibles: {wb.sheetnames}")
        ws = wb[sheet_name]
    else:
        ws = wb.worksheets[sheet_name]

    rows = list(ws.iter_rows(values_only=True))
    if not rows:
        return []

    headers = [str(h) if h is not None else f"col_{i}" for i, h in enumerate(rows[0])]
    result: list[dict[str, Any]] = []
    for row in rows[1:]:
        row_dict = {}
        for i, val in enumerate(row):
            if i < len(headers):
                row_dict[headers[i]] = val
        result.append(row_dict)

    wb.close()
    return result


def detect_format(path: Path) -> str:
    """Detecta el formato de archivo por extensión."""
    ext = path.suffix.lower()
    format_map: dict[str, str] = {
        ".csv": "csv",
        ".tsv": "tsv",
        ".json": "json",
        ".jsonl": "jsonl",
        ".xlsx": "excel",
        ".xls": "excel",
        ".parquet": "parquet",
    }
    fmt = format_map.get(ext)
    if fmt is None:
        raise ValueError(f"Formato no soportado: {ext}")
    return fmt
```

---

## 🔄 Transformaciones (`transform.py`)

```python
"""Transformaciones de datos."""

from __future__ import annotations

import re
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any


@dataclass
class TransformRule:
    """Una regla de transformación."""
    field: str
    handler: Callable[[Any], Any]
    description: str = ""


def strip_whitespace(value: Any) -> Any:
    """Elimina espacios al inicio/final si es string."""
    return value.strip() if isinstance(value, str) else value


def to_lowercase(value: Any) -> Any:
    """Convierte a minúsculas si es string."""
    return value.lower() if isinstance(value, str) else value


def to_uppercase(value: Any) -> Any:
    return value.upper() if isinstance(value, str) else value


def to_float(value: Any) -> float | None:
    """Convierte a float de forma segura."""
    if value is None or value == "":
        return None
    try:
        cleaned = re.sub(r"[^\d.,\-]", "", str(value)).replace(",", ".")
        return float(cleaned)
    except (ValueError, TypeError):
        raise ValueError(f"No se pudo convertir a número: {value!r}")


def to_int(value: Any) -> int | None:
    """Convierte a entero de forma segura."""
    f = to_float(value)
    return int(f) if f is not None else None


def parse_date(value: Any, formats: list[str] | None = None) -> str | None:
    """Intenta parsear una fecha. Retorna string ISO o None."""
    from datetime import datetime

    if value is None or str(value).strip() == "":
        return None

    fmt_list = formats or [
        "%Y-%m-%d",
        "%d/%m/%Y",
        "%m/%d/%Y",
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%d %H:%M:%S",
        "%d-%m-%Y",
    ]

    for fmt in fmt_list:
        try:
            dt = datetime.strptime(str(value).strip(), fmt)
            return dt.date().isoformat()
        except ValueError:
            continue

    raise ValueError(f"No se pudo parsear fecha: {value!r}")


def map_values(mapping: dict[Any, Any], default: Any = None) -> Callable[[Any], Any]:
    """Retorna un handler que mapea valores según un diccionario."""
    def _mapper(value: Any) -> Any:
        return mapping.get(value, default if default is not None else value)
    return _mapper


def apply_rules(rows: list[dict[str, Any]], rules: list[TransformRule]) -> list[dict[str, Any]]:
    """Aplica una lista de reglas de transformación a todos los registros."""
    result: list[dict[str, Any]] = []
    for row in rows:
        transformed = dict(row)
        for rule in rules:
            if rule.field in transformed:
                try:
                    transformed[rule.field] = rule.handler(transformed[rule.field])
                except Exception as e:
                    raise ValueError(
                        f"Error aplicando regla '{rule.description or rule.field}' "
                        f"en registro: {e}"
                    )
        result.append(transformed)
    return result


def select_fields(rows: list[dict[str, Any]], fields: list[str]) -> list[dict[str, Any]]:
    """Selecciona solo los campos indicados."""
    return [{k: r.get(k) for k in fields} for r in rows]


def rename_fields(rows: list[dict[str, Any]], mapping: dict[str, str]) -> list[dict[str, Any]]:
    """Renombra campos según mapeo {viejo: nuevo}."""
    result: list[dict[str, Any]] = []
    for row in rows:
        renamed = {}
        for k, v in row.items():
            renamed[mapping.get(k, k)] = v
        result.append(renamed)
    return result


def filter_rows(
    rows: list[dict[str, Any]],
    predicate: Callable[[dict[str, Any]], bool],
) -> list[dict[str, Any]]:
    """Filtra registros según un predicado."""
    return [r for r in rows if predicate(r)]
```

---

## 📤 Carga (`load.py`)

```python
"""Escritura de datos a múltiples formatos."""

from __future__ import annotations

import csv
import json
from pathlib import Path
from typing import Any


def write_csv(path: Path, rows: list[dict[str, Any]], *, encoding: str = "utf-8-sig", overwrite: bool = False) -> Path:
    """Escribe datos a CSV."""
    if path.exists() and not overwrite:
        raise FileExistsError(f"{path} ya existe. Usa overwrite=True para sobrescribir.")

    path.parent.mkdir(parents=True, exist_ok=True)

    if not rows:
        path.write_text("", encoding=encoding)
        return path

    fieldnames = list(rows[0].keys())
    with path.open("w", encoding=encoding, newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    return path


def write_json(path: Path, data: Any, *, indent: int = 2, encoding: str = "utf-8", overwrite: bool = False) -> Path:
    """Escribe datos a JSON."""
    if path.exists() and not overwrite:
        raise FileExistsError(f"{path} ya existe. Usa overwrite=True para sobrescribir.")

    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding=encoding) as f:
        json.dump(data, f, indent=indent, ensure_ascii=False, default=str)

    return path


def write_json_lines(path: Path, rows: list[dict[str, Any]], *, encoding: str = "utf-8", overwrite: bool = False) -> Path:
    """Escribe datos como JSON Lines."""
    if path.exists() and not overwrite:
        raise FileExistsError(f"{path} ya existe. Usa overwrite=True para sobrescribir.")

    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding=encoding) as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False, default=str) + "\n")

    return path


def write_excel(
    path: Path,
    sheets: dict[str, list[dict[str, Any]]],
    *,
    overwrite: bool = False,
) -> Path:
    """Escribe datos a Excel (múltiples hojas)."""
    try:
        import openpyxl
    except ImportError:
        raise ImportError("openpyxl requerido para escribir Excel. pip install openpyxl")

    if path.exists() and not overwrite:
        raise FileExistsError(f"{path} ya existe. Usa overwrite=True para sobrescribir.")

    path.parent.mkdir(parents=True, exist_ok=True)

    wb = openpyxl.Workbook()
    wb.remove(wb.active)  # hoja por defecto

    for sheet_name, rows in sheets.items():
        ws = wb.create_sheet(title=sheet_name)
        if rows:
            headers = list(rows[0].keys())
            ws.append(headers)
            for row in rows:
                ws.append([row.get(h) for h in headers])

    wb.save(path)
    return path
```

---

## ✅ Validación (`validate.py`)

```python
"""Validación de datos."""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any


@dataclass
class ValidationError:
    """Un error de validación individual."""
    field: str
    message: str
    value: Any = None
    row: int | None = None


@dataclass
class ValidationRule:
    """Regla de validación."""
    field: str
    check: Callable[[Any], bool]
    error_message: str
    severity: str = "error"  # "error" | "warning"


@dataclass
class ValidationResult:
    """Resultado de validación de un conjunto de datos."""
    passed: bool = True
    errors: list[ValidationError] = field(default_factory=list)
    warnings: list[ValidationError] = field(default_factory=list)

    def add_error(self, error: ValidationError) -> None:
        self.errors.append(error)
        self.passed = False

    def add_warning(self, warning: ValidationError) -> None:
        self.warnings.append(warning)

    def summary(self) -> str:
        return f"{'✓' if self.passed else '✗'} {len(self.errors)} errores, {len(self.warnings)} advertencias"


def validate_rows(
    rows: list[dict[str, Any]],
    rules: list[ValidationRule],
) -> ValidationResult:
    """Valida una lista de registros contra reglas."""
    result = ValidationResult()

    for i, row in enumerate(rows):
        for rule in rules:
            value = row.get(rule.field)
            try:
                if not rule.check(value):
                    err = ValidationError(
                        field=rule.field,
                        message=rule.error_message,
                        value=value,
                        row=i + 1,
                    )
                    if rule.severity == "error":
                        result.add_error(err)
                    else:
                        result.add_warning(err)
            except Exception as e:
                err = ValidationError(
                    field=rule.field,
                    message=f"Excepción en validación: {e}",
                    value=value,
                    row=i + 1,
                )
                result.add_error(err)

    return result


# ── Check functions reutilizables ───────────────────────────────────

def not_empty(value: Any) -> bool:
    """El valor no debe ser None ni string vacío."""
    return value is not None and value != ""


def is_positive_number(value: Any) -> bool:
    """El valor debe ser un número positivo."""
    if value is None:
        return False
    try:
        return float(value) > 0
    except (ValueError, TypeError):
        return False


def is_in_range(min_val: float, max_val: float) -> Callable[[Any], bool]:
    """El valor debe estar en un rango numérico."""
    def _check(value: Any) -> bool:
        if value is None:
            return False
        try:
            return min_val <= float(value) <= max_val
        except (ValueError, TypeError):
            return False
    return _check


def matches_regex(pattern: str) -> Callable[[Any], bool]:
    """El valor debe coincidir con un patrón regex."""
    import re
    compiled = re.compile(pattern)

    def _check(value: Any) -> bool:
        if value is None:
            return False
        return bool(compiled.match(str(value)))
    return _check


def is_unique(rows: list[dict[str, Any]], field: str) -> list[ValidationError]:
    """Verifica que los valores de un campo sean únicos."""
    seen: set[Any] = set()
    errors: list[ValidationError] = []
    for i, row in enumerate(rows):
        val = row.get(field)
        if val in seen:
            errors.append(ValidationError(field, f"Valor duplicado: {val!r}", val, i + 1))
        seen.add(val)
    return errors
```

---

## 📊 Reportes (`report.py`)

```python
"""Reportes de ejecución del pipeline."""

from __future__ import annotations

import json
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class PipelineReport:
    """Reporte de una ejecución de pipeline."""
    pipeline_name: str
    start_time: float
    end_time: float | None = None
    input_rows: int = 0
    output_rows: int = 0
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    steps: list[dict[str, Any]] = field(default_factory=list)

    @property
    def elapsed(self) -> float:
        end = self.end_time or time.time()
        return end - self.start_time

    @property
    def success(self) -> bool:
        return len(self.errors) == 0

    def add_step(self, name: str, input_count: int, output_count: int, elapsed: float) -> None:
        self.steps.append({
            "step": name,
            "input": input_count,
            "output": output_count,
            "elapsed_s": round(elapsed, 3),
        })

    def print_summary(self) -> None:
        """Imprime resumen del pipeline en consola."""
        status = "✓" if self.success else "✗"
        print(f"\n{'='*50}")
        print(f" Pipeline: {self.pipeline_name}")
        print(f" Estado:   {status}")
        print(f" Tiempo:   {self.elapsed:.2f}s")
        print(f" Input:    {self.input_rows} registros")
        print(f" Output:   {self.output_rows} registros")
        if self.errors:
            print(f" Errores:  {len(self.errors)}")
            for e in self.errors[:5]:
                print(f"   - {e}")
        if self.warnings:
            print(f" Warn:     {len(self.warnings)}")
        print(f"{'='*50}\n")

    def to_dict(self) -> dict[str, Any]:
        return {
            "pipeline": self.pipeline_name,
            "success": self.success,
            "elapsed_s": round(self.elapsed, 3),
            "input_rows": self.input_rows,
            "output_rows": self.output_rows,
            "errors": self.errors,
            "warnings": self.warnings,
            "steps": self.steps,
        }

    def save_json(self, path: Path) -> None:
        """Guarda el reporte como JSON."""
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
```

---

## 🧩 Snippet: Pipeline ETL completo

```python
#!/usr/bin/env python3
"""Pipeline ETL completo de ejemplo."""

from __future__ import annotations

import logging
import sys
import time
from pathlib import Path

from src.pipeline.extract import read_csv, detect_format
from src.pipeline.transform import apply_rules, TransformRule, strip_whitespace, to_float, parse_date
from src.pipeline.load import write_csv, write_json
from src.pipeline.validate import validate_rows, ValidationRule, not_empty, is_positive_number, is_unique
from src.pipeline.report import PipelineReport

logger = logging.getLogger(__name__)


def run_pipeline(input_path: Path, output_path: Path) -> int:
    """Ejecuta el pipeline ETL completo."""
    report = PipelineReport(
        pipeline_name="etl_ejemplo",
        start_time=time.time(),
    )

    # 1. Extract
    logger.info("Extrayendo datos de %s ...", input_path)
    fmt = detect_format(input_path)

    if fmt in ("csv", "tsv"):
        delimiter = "\t" if fmt == "tsv" else ","
        rows = read_csv(input_path, delimiter=delimiter)
    else:
        raise ValueError(f"Formato no soportado: {fmt}")

    report.input_rows = len(rows)
    logger.info("Extraídos %d registros", len(rows))

    # 2. Validate
    rules = [
        ValidationRule("nombre", not_empty, "Nombre requerido"),
        ValidationRule("email", not_empty, "Email requerido"),
        ValidationRule("monto", is_positive_number, "Monto debe ser número positivo"),
    ]
    validation = validate_rows(rows, rules)
    if not validation.passed:
        for err in validation.errors:
            report.errors.append(f"Fila {err.row}: {err.field} - {err.message}")

        if report.errors:
            logger.error("Validación fallida: %d errores", len(report.errors))
            # Si hay errores, detener pipeline
            report.end_time = time.time()
            report.print_summary()
            return 1

    # 3. Transform
    logger.info("Transformando datos ...")
    t0 = time.time()
    transforms = [
        TransformRule("nombre", strip_whitespace),
        TransformRule("email", lambda v: v.strip().lower() if isinstance(v, str) else v),
        TransformRule("monto", to_float),
    ]
    transformed = apply_rules(rows, transforms)
    report.add_step("transform", len(rows), len(transformed), time.time() - t0)

    # 4. Post-validate (unicidad)
    dup_errors = is_unique(transformed, "email")
    for err in dup_errors:
        report.warnings.append(f"Fila {err.row}: {err.message}")
        validation.add_warning(err)

    # 5. Load
    logger.info("Cargando datos a %s ...", output_path)
    t0 = time.time()
    write_csv(output_path, transformed, overwrite=True)
    report.add_step("load", len(transformed), len(transformed), time.time() - t0)

    report.output_rows = len(transformed)
    report.end_time = time.time()
    report.print_summary()

    # Guardar reporte
    report_path = output_path.with_suffix(".report.json")
    report.save_json(report_path)
    logger.info("Reporte guardado en %s", report_path)

    return 0


def main() -> int:
    import argparse
    parser = argparse.ArgumentParser(description="Pipeline ETL de ejemplo")
    parser.add_argument("input", type=Path, help="Archivo de entrada")
    parser.add_argument("output", type=Path, help="Archivo de salida")
    parser.add_argument("--verbose", "-v", action="store_true", help="Log detallado")
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        stream=sys.stderr,
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    )

    return run_pipeline(args.input, args.output)


if __name__ == "__main__":
    sys.exit(main())
```

---

## ✅ Checklist de calidad de pipeline

| # | Check | Descripción |
|---|-------|-------------|
| 1 | Encoding explícito | Toda I/O de texto especifica `encoding="utf-8"` |
| 2 | Paths con `pathlib` | Sin `os.path` |
| 3 | Formato detectado por extensión | `detect_format()` antes de leer |
| 4 | Archivos de entrada validados | `FileNotFoundError` si no existen |
| 5 | Transformaciones atómicas | Una responsabilidad por función handler |
| 6 | Validación separada de transformación | Validar ANTES de transformar |
| 7 | `overwrite` controlado | No sobrescribir sin flag explícito |
| 8 | Reporte por ejecución | `PipelineReport` con resumen y métricas |
| 9 | Logging de progreso | Cada etapa loggea inicio/fin + conteo |
| 10 | Tipos de datos seguros | `to_float()`, `to_int()`, `parse_date()` sin crash |
| 11 | Errores no detienen todo el pipeline | Acumular errores, reportar al final |
| 12 | Códigos de salida | 0 = éxito, 1 = error de datos, 2 = error de sistema |

# testing-checklist

Checklist completa de testing con pytest para el enjambre. Cubre cobertura, fixtures, tests parametrizados y edge cases.

---

## 📋 Reglas de testing (10)

### 1. Todo módulo público debe tener test
Cada archivo `.py` en `src/` (excluyendo `__init__.py`, `_private.py`, `cli_main.py`) debe tener un archivo `test_*.py` correspondiente en `tests/`.

### 2. Tests aislados e independientes
Cada test debe ser ejecutable en cualquier orden. No compartir estado mutable entre tests. Usar fixtures para setup/teardown.

### 3. Nombrar tests descriptivamente
`test_[funcion]_[escenario]_[resultado_esperado]`

```python
def test_process_items_empty_list_returns_empty_dict(): ...
```

### 4. Un assertion por concepto lógico
Usar `pytest.approx()` para floats. Preferir `assert` nativo. Usar `pytest.raises()` para excepciones.

```python
def test_divide_by_zero_raises():
    with pytest.raises(ZeroDivisionError):
        divide(1, 0)
```

### 5. Fixtures en `conftest.py` y con scope adecuado
- `scope="function"` (default) → se crea/destruye por test
- `scope="session"` → una vez por sesión (ej: cliente HTTP, DB)
- Usar `conftest.py` para fixtures compartidos entre archivos de test

### 6. Tests parametrizados para múltiples casos
Usar `@pytest.mark.parametrize` para probar variantes sin duplicar código.

```python
@pytest.mark.parametrize(
    "input_str,expected",
    [
        ("", 0),
        ("a", 1),
        ("abc", 3),
        ("hello world", 11),
    ],
)
def test_count_chars(input_str: str, expected: int):
    assert count_chars(input_str) == expected
```

### 7. Cobertura mínima: 80% en módulos críticos
Usar `pytest-cov`. Para pipelines de datos, API clients o parsing: mínimo 90%.

```bash
python3 -m pytest --cov=src --cov-report=term-missing --cov-fail-under=80
```

### 8. No usar `print()` en tests — usar `assert` y logging
Si necesitas depurar, usar `caplog` fixture de pytest.

```python
def test_logs_on_failure(caplog: pytest.LogCaptureFixture) -> None:
    caplog.set_level(logging.WARNING)
    process_bad_data()
    assert "formato inválido" in caplog.text
```

### 9. Usar `tmp_path` para I/O temporal
Nunca usar rutas fijas. Usar el fixture `tmp_path` para archivos temporales.

```python
def test_save_to_file(tmp_path: Path) -> None:
    output = tmp_path / "result.json"
    save_data({"key": "val"}, output)
    assert output.exists()
    assert output.read_text(encoding="utf-8") == '{"key": "val"}'
```

### 10. Marcar tests lentos o externos
```python
@pytest.mark.slow
def test_full_pipeline():
    ...

@pytest.mark.skipif(
    not sys.platform.startswith("linux"),
    reason="Solo corre en Linux",
)
def test_platform_specific():
    ...
```

---

## ✅ Checklist de validación por categorías (20+ checks)

### 🔹 Estructura y organización

| # | Check | Cómo validar |
|---|-------|-------------|
| 1 | `tests/` existe con `__init__.py` | `ls tests/__init__.py` |
| 2 | `conftest.py` en tests/ | `ls tests/conftest.py` |
| 3 | Por cada `src/modulo.py` hay `tests/test_modulo.py` | Comparar listados |
| 4 | Sin archivos `test_*.py` vacíos o que solo importan | `grep -l "pass" tests/test_*.py` |
| 5 | `pytest.ini` o `pyproject.toml` con config de pytest | Revisar configuración |

### 🔹 Fixtures

| # | Check | Cómo validar |
|---|-------|-------------|
| 6 | Fixtures en `conftest.py` tienen docstring | `grep -A1 "def fixture" tests/conftest.py` |
| 7 | Fixtures de sesión usan `scope="session"` | Revisar decoradores |
| 8 | No hay fixtures que muten estado global | Revisión manual |
| 9 | Fixtures limpian recursos (ej: cerrar archivos, eliminar temporales) | Revisar código |
| 10 | `tmp_path` usado en vez de rutas fijas para archivos temporales | `grep "tmp_path" tests/` |

### 🔹 Tests parametrizados

| # | Check | Cómo validar |
|---|-------|-------------|
| 11 | Casos borde incluidos: `None`, `""`, `0`, negativo | Revisar @parametrize |
| 12 | Al menos 3 casos por parametrización | Revisar @parametrize |
| 13 | IDs descriptivos en parametrizados | `@pytest.mark.parametrize("x", [...], ids=["..."])` |
| 14 | Combinaciones relevantes cubiertas | Revisión manual |

### 🔹 Cobertura

| # | Check | Cómo validar |
|---|-------|-------------|
| 15 | Cobertura >= 80% en módulos core | `pytest --cov-fail-under=80` |
| 16 | Sin líneas sin probar en ramas condicionales | `--cov-report=term-missing` |
| 17 | Errores/lanzamientos de excepción cubiertos | `pytest.raises` presente |

### 🔹 Mocks y parches

| # | Check | Cómo validar |
|---|-------|-------------|
| 18 | I/O externo mockeado (HTTP, DB, FS) | `unittest.mock.patch` o `monkeypatch` |
| 19 | `autospec=True` en `mock.patch` para detectar cambios de API | Revisar llamados `patch` |
| 20 | Side effects probados (timeout, error, empty response) | `mock.side_effect = [...]` |

### 🔹 Edge cases

| # | Check | Cómo validar |
|---|-------|-------------|
| 21 | Cadenas vacías | `""` |
| 22 | Listas vacías | `[]` |
| 23 | Diccionarios vacíos | `{}` |
| 24 | `None` como argumento | `None` |
| 25 | Valores extremos (máximo/mínimo) | `sys.maxsize`, `0` |
| 26 | Unicode/UTF-8 edge cases | emojis, acentos, caracteres de control |
| 27 | Archivos vacíos o corruptos | `Path("").write_text("")` |
| 28 | Timeouts y conexiones rechazadas | `mock.side_effect = TimeoutError` |
| 29 | Duplicados en colecciones | `[1, 2, 2, 3]` |
| 30 | Orden de elementos no determinista | Sets, dicts keys |

---

## 📄 Template: `tests/test_skeleton.py.tmpl`

```python
#!/usr/bin/env python3
"""
Test skeleton template para nuevos módulos.

Uso: Copiar a tests/test_<modulo>.py y reemplazar los placeholders.
"""

from __future__ import annotations

from collections.abc import Generator
from pathlib import Path
from typing import Any
from unittest.mock import MagicMock, patch

import pytest

# ── Placeholder imports ─────────────────────────────────────────────
# from src.modulo import funcion_a_probar


# ── Fixtures ────────────────────────────────────────────────────────

@pytest.fixture
def sample_data() -> dict[str, Any]:
    """Proporciona datos de ejemplo para los tests."""
    return {"key": "value", "count": 42}


@pytest.fixture
def temp_output_dir(tmp_path: Path) -> Path:
    """Directorio temporal para archivos de salida."""
    output_dir = tmp_path / "output"
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir


@pytest.fixture
def mock_external_service() -> Generator[MagicMock, None, None]:
    """Mockea un servicio externo."""
    with patch("src.modulo.ExternalClient") as mock:
        mock.return_value.fetch.return_value = {"status": "ok"}
        yield mock


# ── Tests básicos ───────────────────────────────────────────────────

class TestFuncionPrincipal:
    """Tests para funcion_principal()."""

    def test_returns_expected_type(self, sample_data: dict[str, Any]) -> None:
        """Verifica que el tipo de retorno sea correcto."""
        pass  # result = funcion_principal(sample_data)
        # assert isinstance(result, dict)

    def test_empty_input_returns_default(self) -> None:
        """Edge case: entrada vacía."""
        pass  # result = funcion_principal({})
        # assert result == {}

    def test_none_input_raises(self) -> None:
        """Edge case: None como argumento."""
        pass  # with pytest.raises(TypeError):
        #     funcion_principal(None)


# ── Tests parametrizados ────────────────────────────────────────────

class TestProcesamiento:
    """Tests para procesar_datos() con múltiples casos."""

    @pytest.mark.parametrize(
        ("input_data", "expected"),
        [
            pytest.param([], [], id="empty"),
            pytest.param([1], [2], id="single"),
            pytest.param([1, 2, 3], [2, 4, 6], id="multiple"),
        ],
    )
    def test_doblar_numeros(self, input_data: list[int], expected: list[int]) -> None:
        """Verifica el procesamiento de listas de números."""
        pass  # assert procesar_datos(input_data) == expected


# ── Tests de errores ────────────────────────────────────────────────

class TestManejoErrores:
    """Tests para manejo de errores y excepciones."""

    def test_archivo_inexistente_devuelve_none(self) -> None:
        """Archivo que no existe retorna None sin excepción."""
        pass  # result = leer_archivo(Path("/no/existe.txt"))
        # assert result is None

    def test_formato_invalido_loggea_warning(self, caplog: pytest.LogCaptureFixture) -> None:
        """Formato inválido registra warning."""
        caplog.set_level(logging.WARNING)
        pass  # procesar("datos invalidos!!!")
        # assert "formato inválido" in caplog.text

    @pytest.mark.parametrize(
        "bad_input",
        [
            pytest.param(None, id="none"),
            pytest.param(42, id="integer"),
            pytest.param(b"bytes", id="bytes"),
        ],
    )
    def test_tipos_invalidos_rechazados(self, bad_input: Any) -> None:
        """Tipos no permitidos son rechazados."""
        pass  # with pytest.raises(TypeError):
        #     procesar(bad_input)


# ── Tests de integración / I/O ──────────────────────────────────────

class TestIO:
    """Tests para operaciones de entrada/salida."""

    def test_guardar_y_recuperar(self, temp_output_dir: Path) -> None:
        """Round-trip: guardar y recuperar datos."""
        filepath = temp_output_dir / "data.json"
        pass  # guardar({"a": 1}, filepath)
        # assert filepath.exists()
        # result = cargar(filepath)
        # assert result == {"a": 1}

    def test_mock_external_call(self, mock_external_service: MagicMock) -> None:
        """Verifica que se llame al servicio externo."""
        pass  # result = procesar_con_externo()
        # mock_external_service.return_value.fetch.assert_called_once()
        # assert result["status"] == "ok"


# ── Tests de rendimiento ────────────────────────────────────────────

class TestRendimiento:
    """Tests básicos de rendimiento."""

    def test_respuesta_rapida(self) -> None:
        """Operación debe completarse en < 100ms."""
        import time
        start = time.perf_counter()
        pass  # operacion_rapida()
        elapsed = time.perf_counter() - start
        assert elapsed < 0.1, f"Lento: {elapsed:.3f}s"
```

---

## 🚀 Comandos útiles

```bash
# Ejecutar todos los tests
python3 -m pytest tests/ -v

# Con cobertura
python3 -m pytest --cov=src --cov-report=term-missing

# Tests específicos
python3 -m pytest tests/test_modulo.py -v

# Tests por marcador
python3 -m pytest -m "not slow" -v

# Tests fallidos primero
python3 -m pytest --ff

# Repetir hasta fallar (buscar flaky tests)
python3 -m pytest --count=10 --maxfail=1 tests/test_flaky.py
```

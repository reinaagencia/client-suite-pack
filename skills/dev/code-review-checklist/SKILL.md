# Code Review Checklist — Revisión de Calidad Pre-Entrega

## metadata
- **id**: `code-review-checklist`
- **version**: 1.0.0
- **domain**: meta
- **priority**: low
- **phase**: meta

## triggers
```yaml
keywords:
  - "revisión"
  - "revisar"
  - "code review"
  - "pre-entrega"
  - "calidad"
  - "entrega"
  - "finalizar"
  - "completar"
  - "revisa el código"
  - "auditar"
  - "inspeccionar"
patterns:
  - "haz code review"
  - "revisa el código antes de"
  - "pre-entrega"
  - "antes de finalizar"
  - "control de calidad"
exclude:
  - "test"
  - "prueba"
  - "testing"
```

## rules
```yaml
business_rules:
  - "REVISAR que todos los archivos tengan encoding UTF-8 explícito en open()"
  - "REVISAR que no haya print() en módulos de librería (solo logging)"
  - "REVISAR que no haya except: pass sin logging"
  - "REVISAR que todas las funciones públicas tengan type hints + docstring"
  - "REVISAR que los nombres de variables sean descriptivos (nada de 'x', 'tmp', 'data2')"
  - "REVISAR que no haya código comentado o muerto"
  - "REVISAR que los imports estén organizados: stdlib → terceros → locales"
  - "REVISAR que los archivos tengan menos de 500 líneas (si más, dividir en módulos)"
  - "REVISAR que las rutas usen pathlib.Path (NO os.path ni strings concatenadas)"
  - "REVISAR que los archivos temporales se limpien en tests (tmp_path, NO archivos en /tmp)"
  - "REVISAR que no haya secrets/tokens hardcodeados en el código fuente"
  - "REVISAR que el .env.example incluya TODAS las variables de entorno usadas"
  - "REVISAR que requirements.txt tenga versiones fijas (no solo nombres)"
  - "REVISAR que el README.md (si existe) documente instalación y uso"
```

## blueprint
```yaml
architecture:
  description: >
    Revisión sistemática de código antes de considerar una tarea como completada.
    NO es un re-testing — es una revisión de calidad y consistencia del código.
  
  data_flow: >
    Código completo → revisar archivo por archivo → checklist por categoría →
    lista de hallazgos → correcciones necesarias → código final

  tech_decisions:
    - "La revisión es léxica y estructural (NO ejecuta el código)"
    - "Cada hallazgo debe incluir archivo + línea + sugerencia"
    - "Separar hallazgos por severidad: ERROR (debe corregirse), WARN (recomendado), INFO (cosmético)"
```

## code
```yaml
templates:
  - name: "review_checklist"
    description: "Checklist de revisión pre-entrega"

libraries:
  preferred:
    - "ast (verificación sintáctica)"
  avoid: []

snippets:
  - name: "review_report_template"
    description: "Formato estándar de reporte de revisión"
    code: |
      # Reporte de Code Review
      ## Resumen
      - Archivos revisados: N
      - ERRORES: N (deben corregirse)
      - WARNINGS: N (recomendado)
      - INFO: N (cosmético)
      
      ## Hallazgos por archivo
      ### archivo.py
      - [ERROR] Línea 42: print() usado en lugar de logging — debe cambiarse
      - [WARN] Línea 15: función sin type hints — agregar
      - [INFO] Línea 88: variable 'x' — renombrar descriptivamente

  - name: "ast_syntax_check"
    description: "Verificación sintáctica con ast.parse"
    code: |
      import ast
      from pathlib import Path
      
      def check_syntax(filepath: str | Path) -> list[str]:
          """Verifica sintaxis Python de un archivo. Retorna lista de errores."""
          path = Path(filepath)
          errors = []
          try:
              ast.parse(path.read_text(encoding="utf-8"))
          except SyntaxError as e:
              errors.append(f"Error sintáctico en {filepath}:{e.lineno}: {e.msg}")
          return errors
```

## checks
```yaml
validation_checks:
  - category: "estructura"
    checks:
      - "[ ] Archivos < 500 líneas cada uno"
      - "[ ] Imports organizados: stdlib → terceros → locales"
      - "[ ] Código comentado o muerto eliminado"
  - category: "nombres"
    checks:
      - "[ ] Variables descriptivas (nada de 'x', 'tmp', 'data2')"
      - "[ ] Funciones con nombres verbo (get_, process_, validate_)"
      - "[ ] Clases con nombres sustantivo (ClienteHTTP, no Http)"
  - category: "seguridad"
    checks:
      - "[ ] No hay secrets/tokens en el código fuente"
      - "[ ] .env.example con todas las variables"
      - "[ ] requirements.txt con versiones fijas"
  - category: "estilo"
    checks:
      - "[ ] encoding='utf-8' en todos los open()"
      - "[ ] print() solo en entry points, nunca en librerías"
      - "[ ] type hints en todas las funciones públicas"
      - "[ ] docstrings en funciones públicas"
      - "[ ] logging.getLogger(__name__) en cada módulo"
      - "[ ] pathlib.Path para rutas"
```

## examples
```yaml
examples:
  - input: "Revisa el código antes de entregarlo"
    skills_activated: ["code-review-checklist"]
    expected_output: >
      Reporte de code review con hallazgos por archivo y severidad (ERROR/WARN/INFO),
      lista de correcciones necesarias antes de considerar completa la tarea
```

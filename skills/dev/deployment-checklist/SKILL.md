# Deployment Checklist — Preparación para Producción

## metadata
- **id**: `deployment-checklist`
- **version**: 1.0.0
- **domain**: meta
- **priority**: low
- **phase**: meta

## triggers
```yaml
keywords:
  - "deploy"
  - "producción"
  - "production"
  - "release"
  - "entrega"
  - "publicar"
  - "subir"
  - "desplegar"
  - "railway"
  - "docker"
  - "container"
  - "cloud"
patterns:
  - "preparar para deploy"
  - "listo para producción"
  - "subir a producción"
  - "desplegar en"
  - "hacer deploy"
  - "empaquetar"
  - "build para producción"
exclude:
  - "test"
  - "debug"
  - "desarrollo local"
```

## rules
```yaml
business_rules:
  - "REVISAR que .env.example tenga TODAS las variables con comentarios"
  - "REVISAR que requirements.txt tenga versiones PINNEADAS (==X.Y.Z, no >=)"
  - "REVISAR que no haya secrets/tokens en ningún archivo de código"
  - "REVISAR que el entry point sea invocable desde CLI (if __name__ == '__main__')"
  - "REVISAR que logging no tenga nivel DEBUG por defecto (usar INFO o WARNING)"
  - "REVISAR que los timeouts de HTTP estén configurados (nunca infinitos)"
  - "REVISAR que los archivos temporales usen tempfile.gettempdir() o tmp_path"
  - "REVISAR que no haya rutas absolutas hardcodeadas (usar pathlib + relative)"
  - "AGREGAR versión semántica (__version__ = '1.0.0') en el módulo principal"
  - "VERIFICAR que python main.py --version funcione si es CLI"
  - "VERIFICAR que la herramienta funcione con python3 mínimo (no python)"
```

## blueprint
```yaml
architecture:
  description: >
    Checklist de preparación antes de cualquier deploy a producción.
    Asegura que el código sea portable, configurable y seguro.
  
  data_flow: >
    Código completado → checklist deploy → correcciones → versión final → listo para producción

  tech_decisions:
    - "Usar python-dotenv para variables de entorno en desarrollo"
    - "Requirements con versiones fijas (pip freeze > requirements.txt)"
    - "Entry point siempre con if __name__ == '__main__'"
    - "Versión semántica en __init__.py o módulo principal"
```

## code
```yaml
templates:
  - name: "deploy_checklist"
    description: "Checklist de preparación para deploy"

libraries:
  preferred:
    - "python-dotenv (configuración de entorno)"
    - "pathlib (rutas relativas)"
  avoid: []

snippets:
  - name: "version_semver"
    description: "Versión semántica estándar"
    code: |
      # En __init__.py o módulo principal
      __version__ = "1.0.0"
      __author__ = "Equipo Enjambre"

  - name: "requirements_pinned"
    description: "Formato de requirements.txt con versiones fijas"
    code: |
      # requirements.txt — generado con pip freeze
      httpx==0.27.0
      python-dotenv==1.0.0
      mcp==1.0.0
      pytest==8.0.0

  - name: "env_example_template"
    description: "Plantilla de .env.example completa"
    code: |
      # .env.example
      # --- API Configuration ---
      API_KEY=           # API key del servicio (obligatorio)
      API_BASE_URL=      # Base URL del API (default: https://api.example.com)
      
      # --- Runtime ---
      LOG_LEVEL=INFO     # Nivel de logging: DEBUG, INFO, WARNING, ERROR
      TIMEOUT=30         # Timeout en segundos para llamadas HTTP
```

## checks
```yaml
validation_checks:
  - category: "configuracion"
    checks:
      - "[ ] .env.example completo con todas las variables y comentarios"
      - "[ ] Variables de entorno con os.getenv() y valores default razonables"
      - "[ ] No hay rutas absolutas hardcodeadas"
  - category: "dependencias"
    checks:
      - "[ ] requirements.txt con versiones fijas (==)"
      - "[ ] requirements.txt incluye TODAS las dependencias del proyecto"
      - "[ ] No hay dependencias no utilizadas"
  - category: "seguridad"
    checks:
      - "[ ] No hay secrets/tokens en archivos de código"
      - "[ ] No hay contraseñas en .env.example (solo placeholders)"
      - "[ ] logging no expone datos sensibles"
  - category: "runtime"
    checks:
      - "[ ] Entry point con if __name__ == '__main__'"
      - "[ ] --version funciona y retorna algo útil"
      - "[ ] -v/--verbose funciona para logging"
      - "[ ] Timeouts configurados explícitamente"
      - "[ ] No hay DEBUG logging por defecto"
      - "[ ] __version__ definido en módulo principal"
```

## examples
```yaml
examples:
  - input: "Prepara el proyecto para deploy a producción"
    skills_activated: ["deployment-checklist"]
    expected_output: >
      Proyecto revisado: .env.example completo, requirements con versiones fijas,
      entry point con if __name__, --version funcional, sin secrets en código,
      logging configurado para producción

  - input: "Empaqueta la herramienta CLI para distribuir"
    skills_activated: ["deployment-checklist", "cli-tool-pattern"]
    expected_output: >
      CLI empaquetada: entry point con argparse, --version, requirements fijos,
      .env.example, logging a stderr con nivel INFO
```

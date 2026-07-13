---
name: autoaprendizaje
description: Meta-skill de autoaprendizaje y desarrollo de nuevas habilidades. Cuando el usuario dice "aprende a usar X herramienta..." o "aprende a hacer X cosa...", despliega un proceso completo de investigación, autoentrenamiento y generación de skills reutilizables. Pipeline de 6 fases que termina con una skill nueva en el catálogo, lista para usar inmediatamente.
---

# Autoaprendizaje — Meta-Skill de Autoformación

> **Filosofía**: El sistema no necesita que le enseñen — necesita un protocolo para enseñarse a sí mismo. Esta skill es ese protocolo.

## ⚡ Trigger

Activar esta skill cuando el usuario diga frases como:

| Frase | Intención |
|-------|-----------|
| "aprende a usar X" | Aprender una herramienta (ej: "aprende a usar ffmpeg para editar video") |
| "aprende a hacer X" | Aprender una técnica (ej: "aprende a hacer scraping con Playwright") |
| "quiero que aprendas X" | Solicitud explícita de aprendizaje |
| "necesito que sepas X" | Habilidad requerida para un proyecto futuro |
| "investiga y aprende X" | Investigación + aprendizaje |
| "certifícate en X" | Aprendizaje profundo con validación |

---

## 🏗️ Arquitectura General

### Pipeline de 7 Fases

```
Usuario dice "aprende a usar X"
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 0 — DIAGNÓSTICO Y ACTIVACIÓN                  ║
║   Determina si es herramienta, técnica, o concepto   ║
║   Clasifica dominio y profundidad requerida          ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 1 — INVESTIGACIÓN POR CAPAS                   ║
║   Capa 1: Documentación oficial (10 mins)            ║
║   Capa 2: Tutoriales y mejores prácticas (10 mins)   ║
║   Capa 3: Repositorios ejemplo y casos reales        ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 2 — PLAN DE APRENDIZAJE                       ║
║   Curriculum estructurado con objetivos,             ║
║   prerequisitos, y ejercicios progresivos            ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 3 — ENTRENAMIENTO PRÁCTICO                    ║
║   Ejecución del curriculum usando herramientas       ║
║   del sistema (CLI, scripting, pipelines)            ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 4 — EXTRACCIÓN Y SÍNTESIS                     ║
║   Destila conocimiento en secciones estructuradas:   ║
║   comandos, patterns, configs, pitfalls, ejemplos    ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 5 — GENERACIÓN DE SKILL                       ║
║   SKILL.md completo: triggers, rules, blueprint,     ║
║   code, checks. Guardado en skills/dev/<skill-name>/ ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
╔═══════════════════════════════════════════════════════╗
║   FASE 6 — VALIDACIÓN Y REGISTRO                     ║
║   Prueba que la skill matchea correctamente,         ║
║   ejecuta un caso de prueba, muestra al usuario      ║
╚═══════════════════════════════════════════════════════╝
         │
         ▼
   ✅ Nueva skill disponible en el catálogo
   El sistema ya "sabe" hacer la nueva tarea
```

---

## 📋 Protocolo Detallado de las 6 Fases

### FASE 0 — Diagnóstico y Activación

**Propósito**: Clasificar el tipo de aprendizaje y determinar la profundidad.

**Input**: El texto completo del usuario después de "aprende a..."

**Clasificación**:

| Tipo | Ejemplo | Profundidad | Fases a ejecutar |
|------|---------|-------------|------------------|
| **Herramienta CLI** | "aprende a usar ffmpeg" | Media | 1→2→3→4→5→6 |
| **Framework/Librería** | "aprende a usar Pandas" | Alta | 1→2→3→4→5→6 |
| **Técnica/Patrón** | "aprende a hacer web scraping" | Alta | 1→2→3→4→5→6 |
| **API/Plataforma** | "aprende a usar la API de Twitter" | Alta | 1→2→3→4→5→6 |
| **Concepto teórico** | "aprende cómo funciona blockchain" | Baja | 1→2→4→5 (sin F3) |
| **Herramienta GUI** | "aprende a usar Figma" | Media | 1→2→4→5 (sin F3) |

**Output de F0**:
```json
{
  "objetivo": "ffmpeg para edición de video",
  "tipo": "herramienta_cli",
  "profundidad": "media",
  "dominio": "multimedia",
  "prerequisitos": ["CLI básico", "conceptos de video"],
  "fases_a_ejecutar": [1, 2, 3, 4, 5, 6],
  "nombre_skill_sugerido": "ffmpeg-video-editing"
}
```

---

### FASE 1 — Investigación por Capas (Research)

**Propósito**: Obtener conocimiento estructurado de la herramienta/técnica objetivo usando recursos web.

**Duración estimada**: 20-40 minutos

**Capa 1 — Documentación oficial** (10 min)
```
1. Navegar a la documentación oficial vía browser automation
2. Tomar snapshot de la página de inicio/instalación
3. Navegar a secciones clave: Getting Started, API Reference, Examples
4. Capturar:
   - Comandos/funciones principales
   - Opciones de configuración
   - Formatos de entrada/salida
   - Flags/parámetros comunes
5. Guardar notas estructuradas
```

**Capa 2 — Tutoriales y mejores prácticas** (10 min)
```
1. Buscar en buscador web: "<herramienta> tutorial" + "<herramienta> best practices"
2. Abrir top 3 resultados (evitar SEO spam, priorizar:
   - Documentación oficial
   - Tutoriales de proveedores cloud reconocidos
   - Stack Overflow / Stack Exchange
   - GitHub Awesome lists
   - Blogs técnicos reconocidos)
3. Extraer:
   - Patrones de uso comunes
   - Anti-patterns
   - Configuraciones recomendadas
   - Casos de uso típicos con ejemplos
```

**Capa 3 — Repositorios y código real** (10 min)
```
1. Buscar en GitHub: "<herramienta> examples", "<herramienta> demo"
2. Leer README de repositorios ejemplo
3. Si es librería Python/Node: revisar tests y ejemplos de la doc
4. Si es herramienta CLI: buscar Makefiles, scripts de CI
5. Extraer:
   - Estructuras de proyecto típicas
   - Patrones de integración
   - Configuraciones de producción
```

**Output de F1** (guardar en variable `research_data`):
```markdown
## Research: ffmpeg-video-editing

### Instalación
- brew install ffmpeg (macOS)
- Verificar: ffmpeg -version

### Comandos básicos
- ffmpeg -i input.mp4 output.mp4 (conversión básica)
- ffmpeg -i input.mp4 -vf "scale=1280:720" output.mp4 (redimensionar)
- ffmpeg -i input.mp4 -ss 00:01:00 -t 30 output.mp4 (cortar)
- ...

### Mejores prácticas
- Usar -c:v libx264 para compatibilidad
- Usar -crf 23 para balance calidad/tamaño
- ...

### Casos de uso comunes
1. Convertir formatos (mp4→gif, mov→mp4)
2. Recortar segmentos
3. Concatenar videos
4. Extraer audio
5. Añadir subtítulos
```

---

### FASE 2 — Plan de Aprendizaje (Curriculum Design)

**Propósito**: Diseñar un curriculum estructurado con ejercicios progresivos que se ejecutará en F3.

**Formato del plan**:

```yaml
plan_aprendizaje:
  objetivo: "Aprender ffmpeg para edición de video desde CLI"
  nivel_partida: "principiante absoluto"
  nivel_destino: "capaz de producir videos editados para proyectos del sistema"

  modulos:
    - id: 1
      nombre: "Fundamentos de conversión"
      duracion_estimada: "15 min"
      ejercicios:
        - "Convertir un video MP4 a GIF usando ffmpeg"
        - "Extraer audio de un video a MP3"
        - "Cambiar codec de un video (h264 → h265)"
      criterio_exito: "Los 3 ejercicios producen archivos válidos"

    - id: 2
      nombre: "Edición temporal"
      duracion_estimada: "20 min"
      ejercicios:
        - "Cortar un segmento de 30 segundos de un video"
        - "Concatenar 2 videos"
        - "Crear un video timelapse acelerando 2x"
      criterio_exito: "Segmentos exactos, concatenación sin saltos"

    - id: 3
      nombre: "Filtros y efectos visuales"
      duracion_estimada: "20 min"
      ejercicios:
        - "Redimensionar video a 720p"
        - "Añadir texto/watermark"
        - "Ajustar brillo/contraste/saturación"
      criterio_exito: "Efectos aplicados correctamente"

    - id: 4
      nombre: "Audio avanzado"
      duracion_estimada: "15 min"
      ejercicios:
        - "Reemplazar audio de un video"
        - "Sincronizar audio externo"
        - "Normalizar volumen"
      criterio_exito: "Audio sincronizado y con volumen correcto"

    - id: 5
      nombre: "Integración en proyectos del sistema"
      duracion_estimada: "20 min"
      ejercicios:
        - "Crear un script Python que use subprocess + ffmpeg"
        - "Pipeline de procesamiento batch de videos"
      criterio_exito: "Script funcional y testeado"
```

**Reglas de diseño del plan**:
- Máximo 5 módulos (para mantener el aprendizaje enfocado)
- Cada módulo: 2-4 ejercicios prácticos
- Ejercicios progresivos en dificultad
- El último módulo SIEMPRE debe integrar la habilidad en el ecosistema del sistema
- Cada ejercicio debe tener un criterio de éxito medible

---

### FASE 3 — Entrenamiento Práctico (Hands-on)

**Propósito**: Ejecutar los ejercicios del plan de aprendizaje, producir artefactos reales.

**Mecanismo**: Usar el pipeline de ejecución del sistema (scripts, bash, etc.) para cada ejercicio que involucre código, o bash directamente para comandos/herramientas.

**Protocolo de ejecución**:

```
Para CADA módulo del plan:

1. Preparar entorno
   - Si requiere instalación: gestor de paquetes adecuado (brew/pip/npm)
   - Crear directorio de trabajo temporal para el entrenamiento
   - Preparar archivos de entrada (sample data, test files)

2. Ejecutar ejercicios
   - Para herramientas CLI: bash directo con verificación de output
   - Para código/librerías: scripts con verificación
   - Para conceptos: generar documentación/resumen

3. Verificar cada ejercicio
   - Ejercicio CLI: verificar que el archivo de salida existe y es válido
   - Ejercicio código: ejecutar tests
   - Registrar resultado (PASS/FAIL)

4. Si un ejercicio falla:
   - Diagnosticar: ¿error de comando? ¿falta de archivo? ¿parámetro incorrecto?
   - Reintentar hasta 2 veces con corrección
   - Si persiste: documentar como "pitfall aprendido" para la skill
   - NOTA: Si 3 intentos fallan, documentar como limitación conocida y continuar

5. Registrar aprendizaje por módulo
   - Comandos que funcionaron (con exactitud)
   - Errores comunes y sus soluciones
   - Variaciones útiles no contempladas en el plan original
```

**Ejemplo de ejecución de módulo** (ffmpeg módulo 1):

```
# Módulo 1: Fundamentos de conversión
# Directorio: /tmp/autoaprendizaje-training/ffmpeg-video-editing/modulo-1/

# Ejercicio 1: Convertir MP4 a GIF
ffmpeg -i sample.mp4 -vf "fps=10,scale=640:-1" output.gif
# ✓ Verificado: output.gif existe, 2.3MB, animación correcta

# Ejercicio 2: Extraer audio
ffmpeg -i sample.mp4 -q:a 0 -map a audio.mp3
# ✓ Verificado: audio.mp3 existe, 128kbps, 30s de duración

# Ejercicio 3: Cambiar codec
ffmpeg -i sample.mp4 -c:v libx265 -crf 28 output_h265.mp4
# ✓ Verificado: output_h265.mp4 existe, 40% menor que original
```

**Output de F3**: Directorio `/tmp/autoaprendizaje-training/<skill-name>/` con:
- `modulo-1/`, `modulo-2/`, ... — archivos de práctica y resultados
- `ejercicios.log` — log detallado de cada ejecución
- `pitfalls.md` — errores encontrados y cómo se resolvieron
- `comandos_utiles.md` — lista completa de comandos/funciones validados

---

### FASE 4 — Extracción y Síntesis (Knowledge Distillation)

**Propósito**: Destilar todo el aprendizaje en secciones estructuradas que alimentarán la generación de la skill.

**Input**:
- Research data (F1)
- Plan de aprendizaje (F2)
- Logs de entrenamiento y pitfalls (F3)

**Proceso de síntesis**:

```
1. Organizar por categorías:
   - Instalación y configuración
   - Comandos/funciones básicos
   - Patrones de uso común
   - Casos de uso avanzados
   - Errores frecuentes y soluciones
   - Integración con el ecosistema

2. Para cada comando/función:
   - Sintaxis exacta (con ejemplos reales de F3)
   - Parámetros clave
   - Output esperado
   - Variaciones comunes

3. Identificar:
   - 3-5 keywords de activación (mínimo)
   - 2-3 patrones de frase que activen la skill
   - 2-3 exclude words para evitar falsos positivos
   - 5-10 reglas de uso
   - 5-10 checks de validación

4. Evaluar calidad:
   - ¿Cubre los casos de uso del sistema?
   - ¿Están documentados los errores comunes?
   - ¿Los ejemplos son ejecutables y verificados?
   - ¿Faltó algo en el entrenamiento?
```

**Output de F4**: Estructura de datos lista para F5:
```json
{
  "skill_name": "ffmpeg-video-editing",
  "description": "Edición de video con ffmpeg desde CLI. Conversión, corte, concatenación, filtros, audio.",
  "domain": "multimedia",
  "triggers": {
    "keywords": ["ffmpeg", "video", "editar video", "convertir video", "gif"],
    "patterns": ["convierte este video", "edita este video", "procesa video"],
    "exclude": ["audio", "imagen", "foto"]
  },
  "rules": [
    "Siempre verificar que el archivo de entrada existe antes de ejecutar ffmpeg",
    "Usar -c:v libx264 para máxima compatibilidad",
    "CRF 18-28 para balance calidad/tamaño (18=alta, 28=compacta)",
    "Para GIF: fps=10-15, scale=640:-1 para rendimiento web"
  ],
  "blueprint": {},
  "code_templates": [],
  "checks": [],
  "command_reference": {
    "conversion": {
      "mp4_a_gif": "ffmpeg -i input.mp4 -vf 'fps=10,scale=640:-1' output.gif",
      "extraer_audio": "ffmpeg -i input.mp4 -q:a 0 -map a audio.mp3",
      "cambiar_codec": "ffmpeg -i input.mp4 -c:v libx265 -crf 28 output.mp4"
    },
    "edicion": {
      "cortar": "ffmpeg -i input.mp4 -ss 00:01:00 -t 30 -c copy output.mp4",
      "concatenar": "ffmpeg -f concat -i filelist.txt -c copy output.mp4",
      "acelerar": "ffmpeg -i input.mp4 -filter:v 'setpts=0.5*PTS' output.mp4"
    }
  },
  "pitfalls": [
    "Error: archivo de entrada no existe",
    "Error: codec GPL no disponible → instalar ffmpeg con --enable-gpl",
    "Advertencia: 'Non-monotonous DTS' → ignorar, no afecta output"
  ]
}
```

---

### FASE 5 — Generación de Skill (Skill Generation)

**Propósito**: Crear un archivo SKILL.md completo, compatible con el Skill Resolver, y guardarlo en el catálogo.

**Formato exacto del output** (DEBE generar exactamente esta estructura):

```markdown
---
name: ffmpeg-video-editing
description: Edición de video con ffmpeg desde CLI. Generada automáticamente por autoaprendizaje.
---

# FFmpeg Video Editing

> Skill auto-generada por el sistema de autoaprendizaje
> Entrenamiento validado: 5 módulos, 15 ejercicios, 100% PASS

## metadata
- **id**: `ffmpeg-video-editing`
- **version**: 1.0.0
- **domain**: multimedia
- **priority**: medium
- **phase**: domain

## triggers
```yaml
keywords:
  - "ffmpeg"
  - "video"
  - "editar video"
  - "convertir video"
  - "gif"
  - "procesar video"
patterns:
  - "convierte este video a"
  - "edita este video"
  - "necesito procesar un video"
exclude:
  - "imagen"
  - "foto"
  - "solo audio"
```

## rules
```yaml
business_rules:
  - "Siempre verificar que input existe antes de ejecutar ffmpeg"
  - "Usar -c:v libx264 para máxima compatibilidad en output"
  - "CRF 18-28 según calidad deseada (18=pérdida mínima, 23=default, 28=compacta)"
  - "Para GIF: fps=10-15, scale=640:-1 para rendimiento web óptimo"
  - "Siempre usar -y para sobrescribir sin preguntar en scripts automatizados"
  - "En Python: usar subprocess.run() con check=True, capturar stderr"
  - "Loggear comando ffmpeg completo antes de ejecutar para debug"
  - "Validar archivo de salida después de cada operación"
  - "Para batch: usar pathlib + glob para listar archivos"
  - "Documentar parámetros exactos usados en metadatos del output"
```

## blueprint
```yaml
description: >
  Procesamiento de video con ffmpeg desde línea de comandos o scripts Python.
  Cubre conversión de formatos, edición temporal, filtros visuales,
  manejo de audio, y procesamiento batch.
tech_decisions:
  - Usar subprocess en Python para invocar ffmpeg (NO bindings python-ffmpeg)
  - Preferir concat demuxer sobre filter concat para concatenación
  - Usar -map 0 para incluir todos los streams en conversión
```

## code
```yaml
templates:
  - name: "python-ffmpeg-wrapper"
    description: "Wrapper Python para invocar ffmpeg con logging y validación"
    code: |
      import subprocess
      import logging
      from pathlib import Path
      
      logger = logging.getLogger(__name__)
      
      def convert_video(input_path: Path, output_path: Path, 
                        codec: str = "libx264", crf: int = 23) -> bool:
          """Convierte video usando ffmpeg."""
          if not input_path.exists():
              raise FileNotFoundError(f"Input no encontrado: {input_path}")
          
          cmd = [
              "ffmpeg", "-y",
              "-i", str(input_path),
              "-c:v", codec,
              "-crf", str(crf),
              str(output_path)
          ]
          
          logger.info(f"Ejecutando: {' '.join(cmd)}")
          result = subprocess.run(cmd, capture_output=True, text=True)
          
          if result.returncode != 0:
              logger.error(f"ffmpeg error: {result.stderr[:500]}")
              return False
          
          if not output_path.exists() or output_path.stat().st_size == 0:
              logger.error("Output vacío o no generado")
              return False
          
          logger.info(f"Video convertido: {input_path.name} → {output_path.name}")
          return True

libraries:
  - "ffmpeg (instalación: brew install ffmpeg / apt install ffmpeg)"
  - "Python: solo subprocess + pathlib (biblioteca estándar)"
  - "No requiere paquetes pip — ffmpeg es binario externo"
```

## checks
```yaml
validation_checks:
  - category: "Instalación"
    checks:
      - "[ ] ffmpeg instalado: ffmpeg -version retorna sin error"
      - "[ ] Codecs disponibles: ffmpeg -encoders | grep libx264"
  - category: "Conversión básica"
    checks:
      - "[ ] MP4 a GIF: output.gif existe y tiene tamaño > 100KB"
      - "[ ] Extraer audio: output.mp3 existe y tiene duración correcta"
      - "[ ] Cambio codec: output usa el codec especificado"
  - category: "Edición temporal"
    checks:
      - "[ ] Corte exacto: duración del output = duración solicitada ±0.5s"
      - "[ ] Concatenación: output tiene la suma de duraciones"
      - "[ ] Time-lapse: duración output = duración input / factor"
  - category: "Scripts Python"
    checks:
      - "[ ] Wrapper Python maneja errores de ffmpeg"
      - "[ ] Script batch procesa N archivos sin fallar"
      - "[ ] Logging captura comandos y resultados"
```

## examples
```yaml
uso_tipico:
  - "Convertir video a GIF para web: ffmpeg -i demo.mp4 -vf 'fps=10,scale=640:-1' demo.gif"
  - "Cortar segmento: ffmpeg -i video.mp4 -ss 00:02:30 -t 60 -c copy clip.mp4"
  - "Concatenar varios videos desde lista de archivos"
  - "Redimensionar: ffmpeg -i input.mp4 -vf 'scale=1280:720' output.mp4"
```

---

*Skill generada por autoaprendizaje*
```

**Ubicación**: `{SKILLS_DIR}/dev/<skill-name>/SKILL.md`

**Reglas de generación**:
- El nombre de la skill debe ser en inglés, kebab-case: `ffmpeg-video-editing`
- El directorio debe crearse con `mkdir -p`
- Debe tener TODAS las secciones: metadata, triggers, rules, blueprint, code, checks, examples
- Los triggers deben incluir AL MENOS 3 keywords y 2 patterns
- Las rules deben ser específicas y accionables (mínimo 5)
- El code debe incluir AL MENOS 1 template con código real y validado
- Los checks deben cubrir instalación, uso básico, y casos avanzados
- NO incluir código no verificado — solo comandos/patrones que se probaron en F3

---

### FASE 6 — Validación y Registro

**Propósito**: Verificar que la skill funciona correctamente y está disponible.

**Subfases**:

#### 6.1 Verificación de integridad
```
1. ¿El archivo SKILL.md existe en la ruta correcta?
2. ¿Tiene todas las secciones (triggers, rules, blueprint, code, checks)?
3. ¿El YAML de triggers tiene formato válido?
4. ¿Los keywords y patterns son strings planos (no listas anidadas)?
5. ¿Hay exclude words para evitar falsos positivos?
```

#### 6.2 Prueba de matching (usando Skill Resolver)
```
Simular que el Skill Resolver procesa un requerimiento:

test_requirement = "Convierte este video MP4 a GIF usando ffmpeg"
matches = resolver.match(test_requirement)

assert "ffmpeg-video-editing" in matches, \
    "La nueva skill no matcheó el requerimiento de prueba"
```

#### 6.3 Prueba de integración (usando pipeline completo)
Ejecutar un pipeline completo de prueba con la skill activada para verificar que el flujo extremo a extremo funciona.

#### 6.4 Detección de duplicados
```
IMPORTANTE: Antes de generar la skill, VERIFICAR que no exista ya
una skill con el mismo stem (raíz del nombre) en el catálogo.

Algoritmo de detección:
1. Extraer stem = nombre_skill sin prefijo "auto_" ni sufijo "-std", "-v1", etc.
2. Buscar en el directorio de skills cualquier skill cuyo stem coincida
3. Si existe → NO generar nueva skill. Usar la existente.
4. Si el usuario insiste en regenerar → usar force=True
   pero NUNCA con prefijo "auto_" que cause recursión.

BUG CONOCIDO (corregido):
  El pipeline anterior no detectaba duplicados y regeneraba skills
  con prefijo "auto_", que en la siguiente iteración se detectaban
  como "nuevas" y se regeneraban como "auto_auto_*", etc.
  Esto creó skills basura que deben limpiarse manualmente.
```

#### 6.5 Solicitar validación al usuario
```
✅ Skill generada: ffmpeg-video-editing
📁 Ubicación: {SKILLS_DIR}/dev/ffmpeg-video-editing/SKILL.md
📊 Módulos completados: 5/5
🔧 Ejercicios: 15/15 PASS
🎯 Matching test: ✓ Matchea correctamente requerimientos de prueba

¿Quieres que ejecute el pipeline completo con esta skill para validarla?
¿O prefieres refinarla primero?
```

#### 6.6 Auditoría final (con modelo más potente, solo si hay dudas)
Si la skill es crítica o el usuario lo solicita, delegar a un modelo de mayor capacidad para validación final:
```
## Gate: Validación de Skill Auto-Generada
{
  "skill_name": "ffmpeg-video-editing",
  "triggers": ["ffmpeg", "video", "gif"],
  "rules_count": 10,
  "checks_count": 12,
  "training_modules": 5,
  "ejercicios_pass": 15,
  "ejercicios_fail": 0
}
Revisa: 1) ¿Los triggers son específicos? 2) ¿Las rules son correctas?
3) ¿Los checks son verificables? 4) ¿Hay riesgos?
```

---

### ⭐ FASE 7 — Registro y Persistencia

**Propósito**: Preservar cada skill generada para trazabilidad y consulta futura.

#### 7.1 Preparar resumen de la skill
```markdown
# Autoaprendizaje: Skill "<skill-name>" generada

**Fecha**: [YYYY-MM-DD]
**Skill**: <skill-name>
**Tipo**: [herramienta_cli | framework | tecnica_patron | concepto]
**Módulos**: [N] módulos, [M] ejercicios
**Estado**: ✅ PASS (F6 validado)

## Descripción
[Descripción de la skill]

## Triggers
- Keywords: [lista]
- Patterns: [lista]

## Comandos validados
[Lista de comandos/funciones con sintaxis]

## Lecciones
[Pitfalls y optimizaciones encontradas durante el entrenamiento]

## Archivos generados
- SKILL.md: {SKILLS_DIR}/dev/<skill-name>/SKILL.md
- Training: /tmp/autoaprendizaje-training/<skill-name>/
```

#### 7.2 Integración en el flujo completo
El pipeline de autoaprendizaje queda así:

```
F0 → F1 → F2 → F3 → F4 → F5 → F6 → [F7: Persistencia]
                                        │
                                        ▼
                              ✅ Skill en catálogo
                              ✅ Resumen persistido
                              ✅ Registro local actualizado
```

---

## 🔄 Ciclo de Refinamiento Continuo

Una skill generada por autoaprendizaje no es estática. Cada vez que se use la skill en un proyecto real, debe:

1. **Refinar triggers**: Si hay falsos positivos, agregar exclude words
2. **Ampliar rules**: Agregar reglas aprendidas en el uso real
3. **Mejorar checks**: Agregar validaciones de casos reales
4. **Actualizar ejemplos**: Agregar patrones de uso real

El sistema de refinamiento automático debe detectar:
- Skills muertas (0 matches en pruebas)
- Falsos positivos (matches en categorías incorrectas)
- Keywords demasiado genéricas
- YAML malformado

---

## 📂 Estructura de Archivos Generados

Para cada sesión de autoaprendizaje, se genera:

```
{SKILLS_DIR}/dev/
└── <skill-name>/
    ├── SKILL.md              ← Skill principal (cargable por Skill Resolver)
    └── training/
        ├── plan.md           ← Plan de aprendizaje original
        ├── research.md       ← Investigación (F1)
        ├── ejercicios.log    ← Log de ejecución (F3)
        ├── pitfalls.md       ← Errores y soluciones
        └── comandos.md       ← Referencia de comandos validados

/tmp/autoaprendizaje-training/
└── <skill-name>/
    ├── modulo-1/             ← Archivos de práctica
    ├── modulo-2/
    ├── ...
    └── sample-data/          ← Archivos de entrada para pruebas
```

---

## ⚠️ Casos Borde y Manejo de Errores

| Situación | Acción |
|-----------|--------|
| La herramienta no tiene documentación clara | Clasificar como "high risk". Buscar al menos 3 fuentes alternativas. Si no se encuentra documentación suficiente, informar al usuario y abortar. |
| El entrenamiento falla repetidamente | Documentar como "limitación conocida en la skill". Reducir profundidad. Informar al usuario. |
| La herramienta requiere API key | Generar la skill con placeholder `<API_KEY>`. Incluir instrucciones de configuración. |
| La herramienta es muy compleja (>100 flags) | Enfocar el entrenamiento en el 20% de features que cubren el 80% de casos de uso típicos. |
| Ya existe una skill similar en el catálogo | Hacer diff con la existente. Si la nueva aporta valor, generar como complemento. Si es redundante, sugerir usar la existente. |
| El usuario cancela a mitad del entrenamiento | Guardar todo el progreso en el directorio training/. Preguntar si quiere retomar después. |
| La herramienta no está disponible (no instalable) | Generar skill teórica (sin F3). Incluir instrucciones de instalación como prerequisito. |
| El entrenamiento toma >30 min | Informar al usuario del progreso. Ofrecer continuar en background o programar para después. |

---

## 🎯 Criterios de Éxito

Una sesión de autoaprendizaje es exitosa si cumple TODO:

- [ ] **F1**: Se investigaron al menos 3 fuentes distintas
- [ ] **F2**: Plan con ≥3 módulos y ≥9 ejercicios en total
- [ ] **F3**: ≥80% de ejercicios pasan (los fallos documentados como pitfalls)
- [ ] **F4**: Síntesis cubre comandos, pitfalls, y patrones de integración
- [ ] **F5**: SKILL.md generado con todas las secciones requeridas
- [ ] **F6**: La skill matchea correctamente un requerimiento de prueba
- [ ] **Skill Resolver**: La nueva skill aparece en las búsquedas del resolver

Si no se cumple alguno, se genera un reporte de fallo con diagnóstico.

---

## 📦 Integración con el Ecosistema

### Recursos necesarios para esta meta-skill

| Recurso | Propósito | ¿Obligatorio? |
|---------|-----------|:---:|
| Herramienta de búsqueda web | Investigación de documentación y tutoriales | Sí |
| Browser automation | Navegación web para investigación | Sí |
| Pipeline de ejecución (scripts/CLI) | Entrenamiento práctico | Sí (para herramientas que requieren código) |
| Skill Resolver | Validación de matching | Sí |
| Herramienta de fetch rápido | Descarga de documentación | Sí |
| Sistema de persistencia | Guardar resumen de habilidades aprendidas | No (recomendado) |

---

## 🧪 Ejemplo Completo: "aprende a usar ffmpeg para editar video"

```
Usuario: "Sistema, aprende a usar ffmpeg para editar video"

1. [F0] Diagnóstico:
   → Objetivo: ffmpeg
   → Tipo: herramienta CLI
   → Profundidad: media
   → Nombre de skill: ffmpeg-video-editing

2. [F1] Investigación (30 min):
   → Documentación oficial de ffmpeg.org
   → Tutorial FFmpeg de recursos educativos
   → Awesome FFmpeg repo en GitHub
   → Stack Overflow: mejores prácticas CRF

3. [F2] Plan de 5 módulos:
   → M1: Fundamentos de conversión (3 ejercicios)
   → M2: Edición temporal (3 ejercicios)
   → M3: Filtros visuales (3 ejercicios)
   → M4: Audio avanzado (3 ejercicios)
   → M5: Integración Python (3 ejercicios)

4. [F3] Entrenamiento:
   → 15/15 ejercicios PASS
   → 3 pitfalls documentados
   → 12 comandos validados en comandos.md

5. [F4] Síntesis:
   → 6 keywords, 3 patterns, 3 exclude words
   → 10 reglas de negocio
   → 1 template Python validado
   → 12 checks de validación

6. [F5] Skill generada:
   → SKILL.md completo con todas las secciones

7. [F6] Validación:
   → ✓ Archivo existe con todas las secciones
   → ✓ Matchea "Convierte este video MP4 a GIF"
   → ✓ Pipeline ejecuta correctamente con la skill activada

8. ⭐ [F7] Persistencia:
   → ✓ Resumen guardado

✅ El sistema ahora sabe usar ffmpeg.
```

---

## 🔮 Próximas Mejoras (Roadmap)

| Versión | Mejora | Descripción |
|---------|--------|-------------|
| 1.1 | **Aprendizaje por repositorio** | Aprender de un repositorio GitHub completo (README, tests, issues) |
| 1.2 | **Evaluación automática** | Generar examen de certificación para validar aprendizaje |
| 1.3 | **Memoria de skills** | Guardar skills aprendidas en base de datos con embeddings |
| 1.4 | **Transfer learning** | Detectar skills similares y transferir conocimiento |
| 1.5 | **Auto-evolución** | Skills que se refinan solas con cada uso en proyectos reales |
| 1.6 | **Auto-refinamiento cruzado** | Cada skill nueva analiza skills existentes y propone mejoras automáticamente |
| 2.0 | **Auto-descubrimiento** | El sistema identifica qué habilidades necesita y las aprende autónomamente |

---

> *"El mejor maestro no es el que más sabe, sino el que mejor aprende."*
> — Skill autoaprendizaje v1.0

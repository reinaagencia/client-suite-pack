---
name: visor-multimodal
description: Skill de delegación al agente visor-multimodal. Carga esta skill cuando necesites analizar imágenes, capturas de pantalla, videos, PDFs visuales o transcripciones de audio. El visor ejecuta un protocolo de 3 pasadas obligatorias para garantizar reportes exhaustivos. NO intentes analizar imágenes tú mismo — usa siempre al visor.
---

# Visor Multimodal — Skill de Delegación

Este skill te indica cómo delegar análisis visual/auditivo/multiformato al subagente `visor-multimodal`.

> **Nota para el {{ORQUESTADOR}}**: Este skill es para agentes que **delegan** al visor. El visor mismo tiene su propio prompt de agente con instrucciones de análisis detalladas.

---

## ¿Cuándo usar este skill?

| Situación | Acción |
|-----------|--------|
| El usuario comparte una **captura de pantalla** | → Delega al visor |
| El usuario envía una **imagen** (PNG, JPG, WEBP, etc.) | → Delega al visor |
| El usuario comparte un **PDF visual** (con gráficos, diagramas, diseños, mockups) | → Delega al visor |
| El usuario envía un **video** breve (MP4, MOV, GIF animado) | → Delega al visor (describe el contenido) |
| El usuario envía una **nota de voz** o audio | → El transcriptor transcribe, luego el visor analiza la transcripción |
| Necesitas **extraer texto, colores, elementos UI, estados** de una interfaz | → Delega al visor |
| Necesitas **comparar dos imágenes** o verificar diferencias visuales | → Delega al visor |
| Necesitas **describir una imagen para accesibilidad** o documentación | → Delega al visor |

> ⚠️ **NO intentes analizar imágenes por ti mismo aunque creas que puedes**. Los modelos no multimodales (DeepSeek, Qwen, etc.) **no pueden ver imágenes**. Siempre delega al visor.

---

## Cómo delegar al visor-multimodal

### Para imágenes, capturas de pantalla, PDFs visuales

Usa `task()` con `subagent_type: "visor-multimodal"`:

```
task(
  description: "Analizar [imagen/captura/PDF]",
  subagent_type: "visor-multimodal",
  prompt: """
## Contexto
[Explica qué estás viendo, por qué necesitas el análisis, qué necesita el usuario]
Ruta del archivo: [ruta absoluta al archivo]

## Tu tarea
Analiza el archivo siguiendo tu protocolo de 3 pasadas obligatorias.
Enfócate específicamente en: [aspectos a revisar: colores, textos, bugs, layout, elementos, etc.]

## Output esperado
Reporte completo con las 3 pasadas, descripción definitiva, elementos clave y problemas detectados.
"""
)
```

### Para transcripciones de audio (notas de voz)

**Pipeline de 2 pasos**: el transcriptor transcribe con Whisper, luego pasas la transcripción al visor:

```
// Paso 1: Transcriptor transcribe el audio
task(
  description: "Transcribir audio con Whisper",
  subagent_type: "transcriptor",
  prompt: """
Transcribe el siguiente archivo de audio usando Whisper.
Ruta: [ruta absoluta al archivo de audio]
Idioma: español
Devuelve la transcripción completa sin resumir.
"""
)

// Paso 2: Visor analiza la transcripción
task(
  description: "Analizar transcripción de audio",
  subagent_type: "visor-multimodal",
  prompt: """
## Contexto
El usuario envió una nota de voz. Esta es la transcripción obtenida por el transcriptor:

[TRANSCRIPCIÓN COMPLETA]

## Tu tarea
Aplica tu protocolo de 3 pasadas sobre el texto transcrito.
Extrae: instrucciones, tareas, deadlines, nombres, prioridades, cualquier elemento accionable.

## Output esperado
Lista de tareas accionables con prioridades, extraída siguiendo tus 3 pasadas.
"""
)
```

### Para videos

```
task(
  description: "Analizar video",
  subagent_type: "visor-multimodal",
  prompt: """
## Contexto
El usuario compartió un video. Ruta: [ruta absoluta al archivo de video]
Necesito extraer: [qué información se necesita]

## Tu tarea
Analiza el video con tu protocolo de 3 pasadas.
Describe: escenas, textos, personas, acciones, duración aproximada, momentos clave, elementos relevantes.

## Output esperado
Reporte estructurado con descripción definitiva del contenido del video.
"""
)
```

---

## El Protocolo de 3 Pasadas (obligatorio)

El visor-multimodal **siempre** ejecuta estas 3 pasadas en orden. Como agente que delega, debes **exigir que se cumplan** en el prompt:

### P1: Exploración Libre (visión general)

El visor examina el archivo sin restricciones, describiendo lo que ve de forma natural. Captura la impresión general, los elementos más obvios, el contexto global.

**Qué obtienes**: Una primera descripción holística, sin estructura forzada.

### P2: Análisis Sistemático (estructura detallada)

El visor aplica una rejilla de análisis estructurado:
- **Si es imagen/captura**: layout, colores, textos, elementos UI, personas, objetos, jerarquía visual
- **Si es PDF**: estructura de páginas, gráficos, tablas, encabezados, imágenes incrustadas
- **Si es transcripción**: estructura del discurso, temas, instrucciones explícitas, implícitas
- **Si es video**: línea de tiempo, escenas clave, diálogos, textos en pantalla

**Qué obtienes**: Un desglose sistemático, elemento por elemento.

### P3: Contraste y Verificación (consistencia)

El visor vuelve a examinar el archivo contrastando lo reportado en P1 y P2, buscando:
- Elementos que pudo haber omitido en la primera pasada
- Inconsistencias o contradicciones en su propio análisis
- Detalles finos que requieren atención (errores, cambios de estado)
- Confirmación de que la descripción definitiva es completa

**Qué obtienes**: Una descripción definitiva validada, con nota de confianza y elementos corroborados.

### Después de las 3 pasadas

El visor produce una **Descripción Definitiva** que sintetiza todo el análisis en un formato estructurado y accionable.

---

## Agentes que deben delegar al visor

| Agente en la suite | ¿Debe delegar al visor? | Motivo |
|---|---|---|
| **{{ORQUESTADOR}}** | ✅ Siempre | Es el usuario principal del visor. Toda petición visual/auditiva del cliente pasa por él. |
| **programador** | ✅ Cuando reciba imágenes | Si un requerimiento incluye capturas o mockups, debe delegar el análisis al visor. |
| **arquitecto** | ✅ Cuando reciba diagramas | Si un diseño incluye diagramas visuales, el visor los describe y extrae estructuras. |
| **investigador** | ✅ Cuando reciba imágenes | Si una investigación incluye imágenes de referencia, infografías o capturas de datos. |
| **lanzador** | ✅ Cuando reciba imágenes | Si una campaña incluye imágenes de referencia o capturas de resultados. |
| **estratega** | ✅ Cuando reciba imágenes | Si necesita analizar visuales para toma de decisiones estratégicas. |
| **desplegador** | ❌ Generalmente no | Trabaja con CI/CD, infraestructura y configuraciones. |
| **tester** | ✅ Cuando reciba capturas | Si un bug report incluye captura de pantalla, el tester delega al visor para describir el error. |
| **auditor** | ✅ Cuando reciba imágenes | Si necesita verificar visualmente resultados de calidad. |
| **instalador** | ❌ Generalmente no | Trabaja con bootstrap de entornos. |
| **trader** | ❌ Generalmente no | Trabaja con datos numéricos, no visuales. |
| **transcriptor** | ❌ No necesita | Su tarea es transcribir audio, no analizar contenido visual. |
| **visor-multimodal** | ❌ Es él mismo | No se delega a sí mismo. |

---

## Flujo típico con el visor

```
Usuario: "Mira esta captura de pantalla de la app"
  ↓
El agente identifica la ruta del archivo
  ↓
Verifica que la ruta NO tenga caracteres especiales (ver limitaciones abajo)
  ↓
Delega al visor: task(subagent_type="visor-multimodal", prompt="...")
  ↓
Visor ejecuta 3 pasadas: P1 (libre) → P2 (analítica) → P3 (contraste) → Descripción Definitiva
  ↓
Visor devuelve reporte estructurado con todo lo que vio
  ↓
El agente usa ese reporte para tomar decisiones, delegar fixes, o responder al usuario
```

---

## ⚠️ Limitación conocida: Archivos con caracteres especiales en el nombre

El visor-multimodal **no puede acceder** a archivos cuyos nombres contengan caracteres especiales debido a limitaciones del modelo subyacente al leer rutas:

| Caracteres problemáticos | Ejemplo |
|---|---|
| Paréntesis | `captura(1).png`, `la (copia).jpg` |
| Múltiples puntos consecutivos | `9.24.02 a.m..png`, `captura...final.jpg` |
| Caracteres Unicode/acentos | `í`, `ó`, `ñ`, `ü`, `ç` |
| Espacios (con quoting adecuado sí funcionan) | `mi captura.png` (funciona si se escapan) |

**Síntoma**: El visor reporta "File not found" o "Cannot access file" aunque el archivo existe en disco.

**Solución (el agente que delega debe hacer esto ANTES de llamar al visor)**:

```bash
# Copiar el archivo a una ruta limpia (sin caracteres especiales)
cp "/ruta/original/con (paréntesis) especiales.png" /tmp/analisis.png
# Luego delegar al visor con /tmp/analisis.png
```

O desde el prompt del task:
```
## Nota para el visor: Si no puedes leer el archivo, avísame y lo renombraré.
```

El agente que delega (que tiene acceso a `bash`) debe hacer la copia antes de llamar al visor. El visor **no tiene acceso a `bash`** y no puede hacer workarounds de filesystem por sí mismo.

---

## ⚠️ Otras limitaciones importantes

1. **El visor no ejecuta código**: Solo analiza contenido visual/textual. No le pidas que modifique archivos, ejecute scripts o haga transformaciones.
2. **El visor no tiene acceso a internet**: No puede buscar contexto adicional ni verificar URLs.
3. **El visor no recuerda análisis previos**: Cada delegación es independiente. Si necesitas comparar, incluye ambos archivos o descripciones en el mismo prompt.
4. **Archivos muy grandes (>20MB)**: Pueden causar timeouts o fallos. Si es necesario, reduce la resolución o tamaño antes de delegar.

---

## Reglas importantes para el agente que delega

1. **Siempre** incluye la ruta absoluta del archivo en el prompt
2. **Especifica** qué debe buscar el visor (contexto de la tarea, aspectos relevantes)
3. **No le pidas** al visor que ejecute código — solo analiza contenido visual/textual
4. **Para audios**: usa el pipeline de 2 pasos (transcriptor → visor), no delegues el audio directamente
5. **Confía en su protocolo de 3 pasadas**: las descripciones definitivas del visor son más confiables que un solo análisis superficial
6. **Antes de delegar**: verifica que la ruta del archivo NO contenga paréntesis, puntos múltiples o caracteres Unicode. Si los tiene, copia el archivo a `/tmp/analisis.png` o similar con nombre limpio usando `bash`
7. **Siempre revisa el output**: Si el visor reporta que no pudo acceder al archivo, aplica la solución de caracteres especiales y vuelve a delegar

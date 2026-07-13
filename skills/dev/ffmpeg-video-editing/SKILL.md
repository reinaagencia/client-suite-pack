# 🎬 FFmpeg Video Editing — Skill del Enjambre

> **Propósito**: Edición de video profesional desde CLI usando FFmpeg. Cortar, concatenar, transicionar, superponer, subtitular, extraer audio y optimizar para web.

---

## 📦 Instalación

### macOS (Homebrew)
```bash
brew install ffmpeg
```

### Linux (Debian/Ubuntu)
```bash
sudo apt update && sudo apt install ffmpeg -y
```

### Linux (Fedora/RHEL)
```bash
sudo dnf install ffmpeg -y
```

### Windows (Chocolatey)
```powershell
choco install ffmpeg
```

### Windows (Scoop)
```powershell
scoop install ffmpeg
```

### Verificar instalación
```bash
ffmpeg -version
ffprobe -version
```

---

## 🔍 Conceptos clave

| Término | Descripción |
|---|---|
| **Stream** | Flujo de datos (video, audio, subtítulos) dentro de un contenedor |
| **Codec** | Códec de compresión (h264, aac, libx265, etc.) |
| **Container** | Formato de archivo (mp4, mkv, avi, mov) |
| **Filter** | Cadena de procesamiento (escala, recorte, overlay) |
| **PTS** | Presentation Time Stamp — tiempo de presentación de cada frame |
| **Keyframe** | Frame completo (I-frame) usado como referencia |

---

## 🧰 Snippets de comandos

### 1. Cortar un segmento (sin re-codificar)

```bash
ffmpeg -i input.mp4 -ss 00:00:30 -to 00:01:15 -c copy output.mp4
```

- `-ss`: tiempo de inicio
- `-to`: tiempo de fin
- `-c copy`: copia streams sin re-codificar (rápido, exacto en keyframes)

**Precisión de keyframe**: usa `-ss` **antes** de `-i` para búsqueda por keyframe; después de `-i` para precisión de frame (requiere re-codificación):

```bash
# Preciso pero más lento (re-codifica desde keyframe más cercano)
ffmpeg -ss 00:00:30 -i input.mp4 -to 00:01:15 -c copy output.mp4
```

### 2. Cortar con precisión de frame (re-codificando)

```bash
ffmpeg -i input.mp4 -ss 00:00:30.500 -to 00:01:15.250 -c:v libx264 -c:a aac output.mp4
```

### 3. Concatenar múltiples archivos (mismo codec)

**Método 1 — Concatenation demuxer (recomendado)**:
```bash
# Crear archivo list.txt:
# file 'clip1.mp4'
# file 'clip2.mp4'
# file 'clip3.mp4'

ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp4
```

**Método 2 — Filtro concat (diferentes codecs)**:
```bash
ffmpeg -i clip1.mp4 -i clip2.mp4 -filter_complex \
  "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]" \
  -map "[outv]" -map "[outa]" output.mp4
```

### 4. Convertir formatos

```bash
# MP4 a AVI
ffmpeg -i input.mp4 output.avi

# MKV a MP4
ffmpeg -i input.mkv -c copy output.mp4

# MOV a MP4 con re-codificación
ffmpeg -i input.mov -c:v libx264 -preset medium -crf 23 -c:a aac output.mp4

# WebM a MP4
ffmpeg -i input.webm -c:v libx264 -c:a aac output.mp4
```

### 5. Optimizar para web

```bash
# H.264 estándar web (crf 23 = calidad equilibrada)
ffmpeg -i input.mp4 -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k output_web.mp4

# H.265 para mejor compresión
ffmpeg -i input.mp4 -c:v libx265 -preset medium -crf 28 -c:a aac -b:a 128k output_hevc.mp4

# Reducir resolución a 720p
ffmpeg -i input.mp4 -vf "scale=-2:720" -c:v libx264 -preset fast -crf 23 output_720p.mp4

# Redimensionar manteniendo aspecto
ffmpeg -i input.mp4 -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" output_padded.mp4
```

### 6. Extraer audio

```bash
# Extraer como MP3
ffmpeg -i input.mp4 -q:a 0 -map a output.mp3

# Extraer como AAC
ffmpeg -i input.mp4 -c:a aac -b:a 192k output.m4a

# Extraer como WAV (sin pérdida)
ffmpeg -i input.mp4 -c:a pcm_s16le output.wav

# Extraer un segmento de audio
ffmpeg -i input.mp4 -ss 00:01:00 -to 00:02:00 -q:a 0 -map a output_segment.mp3
```

### 7. Añadir transiciones

```bash
# Transición fade entre clips
ffmpeg -i clip1.mp4 -i clip2.mp4 -filter_complex \
  "[0:v]fade=t=out:st=5:d=1[f0]; \
   [1:v]fade=t=in:st=0:d=1[f1]; \
   [f0][f1]concat=n=2:v=1:a=0[outv]" \
  -map "[outv]" output.mp4
```

### 8. Overlay (logo/imagen sobre video)

```bash
# Overlay en esquina superior derecha
ffmpeg -i input.mp4 -i logo.png -filter_complex \
  "overlay=W-w-10:10" output.mp4

# Overlay animado (aparece gradualmente)
ffmpeg -i input.mp4 -i logo.png -filter_complex \
  "overlay=W-w-10:10:enable='between(t,2,10)'" output.mp4
```

### 9. Añadir subtítulos (quemados)

```bash
# SRT a video (quemado)
ffmpeg -i input.mp4 -vf "subtitles=subtitulos.srt" output.mp4

# ASS a video (quemado con estilos)
ffmpeg -i input.mp4 -vf "ass=estilos.ass" output.mp4

# Subtítulos desde archivo externo
ffmpeg -i input.mp4 -i subtitulos.srt -c copy -c:s mov_text output.mp4
```

### 10. Acelerar / Ralentizar video

```bash
# Acelerar 2x
ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" \
  -map "[v]" -map "[a]" output.mp4

# Ralentizar 0.5x
ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=2.0*PTS[v];[0:a]atempo=0.5[a]" \
  -map "[v]" -map "[a]" output.mp4
```

### 11. Recortar (crop)

```bash
# Recortar un área específica
ffmpeg -i input.mp4 -vf "crop=640:480:100:50" output.mp4
# crop=ancho:alto:x:y
```

### 12. Crear GIF animado

```bash
ffmpeg -i input.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" -loop 0 output.gif
```

### 13. Juntar video + audio separados

```bash
ffmpeg -i video_sin_audio.mp4 -i audio.mp3 -c:v copy -c:a aac -shortest output.mp4
```

### 14. Metadata y limpieza

```bash
# Ver metadata
ffprobe -v quiet -print_format json -show_format -show_streams input.mp4

# Eliminar metadata (útil para privacidad)
ffmpeg -i input.mp4 -map_metadata -1 -c copy output_clean.mp4
```

### 15. Estabilización de video

```bash
# Paso 1: analizar movimiento
ffmpeg -i input.mp4 -vf "vidstabdetect=shakiness=5:result=transforms.trf" -f null -

# Paso 2: aplicar estabilización
ffmpeg -i input.mp4 -vf "vidstabtransform=smoothing=10:input=transforms.trf" output_stabilized.mp4
```

### 16. Hacer un screenshot / thumbnail

```bash
# Frame en el segundo 10
ffmpeg -ss 00:00:10 -i input.mp4 -vframes 1 thumbnail.png

# Sprite sheet de thumbnails
ffmpeg -i input.mp4 -vf "fps=1/10,scale=160:90,tile=3x3" sprite.jpg
```

### 17. Bucle infinito con duración fija

```bash
ffmpeg -stream_loop 3 -i input.mp4 -c copy -t 30 output_loop_30s.mp4
```

---

## 📋 Reglas y mejores prácticas

### Regla 1: Siempre verifica el codec antes de operar
```bash
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1 input.mp4
```
Cortar con `-c copy` solo funciona si los codecs son compatibles entre origen y destino.

### Regla 2: Prefiere `-c copy` cuando no necesites re-codificar
Evita pérdida de calidad y ahorra tiempo. Solo re-codifica cuando:
- Cambies resolución/framerate
- Apliques filtros
- Cambies de codec
- Necesites precisión sub-second en cortes

### Regla 3: Usa CRF para control de calidad (no bitrate fijo)
- `-crf 18-23`: calidad visualmente sin pérdida (18 = máxima, 23 = buena)
- `-crf 28-32`: calidad baja / compresión alta (archivos pequeños)
- `-crf 0`: lossless (archivos enormes)

### Regla 4: El preset adecuado según tu caso
- `ultrafast` / `superfast`: desarrollo / pruebas
- `veryfast` / `faster`: uso general rápido
- `medium`: balance por defecto
- `slow` / `veryslow`: calidad máxima (40-60% más lento)

### Regla 5: Siempre mapea streams explícitamente
```bash
# Correcto — solo video y audio
ffmpeg -i input.mkv -map 0:v:0 -map 0:a:0 -c copy output.mp4

# Incorrecto — puede incluir subtítulos, chapters, etc.
ffmpeg -i input.mkv -c copy output.mp4
```

### Regla 6: Manejo de audio
- Usa `aac` para compatibilidad web universal
- Usa `mp3` solo cuando sea requerido
- `opus` es superior a ambos pero menos compatible
- Bitrate mínimo para calidad aceptable: 128k (aac), 192k (mp3)

### Regla 7: Orden de los parámetros importa
- `-ss` antes de `-i`: búsqueda rápida en keyframe
- `-ss` después de `-i`: búsqueda precisa pero lenta
- `-t` después de `-i`: duración
- `-to` después de `-i`: tiempo final

### Regla 8: Validación post-procesamiento
```bash
# Verificar que el archivo no está corrupto
ffmpeg -v error -i output.mp4 -f null - 2>&1 | grep -i error

# Verificar duración
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1 output.mp4
```

### Regla 9: GPU acceleration (cuando esté disponible)
```bash
# macOS (VideoToolbox)
ffmpeg -i input.mp4 -c:v h264_videotoolbox -b:v 5M output.mp4

# Linux (NVIDIA NVENC)
ffmpeg -i input.mp4 -c:v h264_nvenc -preset p4 -b:v 5M output.mp4

# Windows (Intel QSV)
ffmpeg -i input.mp4 -c:v h264_qsv -global_quality 23 output.mp4
```

### Regla 10: Aspect ratio y dimensiones
```bash
# Escalar manteniendo aspecto (dimensiones pares siempre)
-vf "scale=1280:-2"    # ancho fijo, alto automático (par)
-vf "scale=-2:720"     # alto fijo, ancho automático (par)
-vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:color=black"
```

### Regla 11: Fragmenta MP4 para streaming web
```bash
ffmpeg -i input.mp4 -c copy -movflags +faststart output_faststart.mp4
```
El flag `faststart` mueve la metadata al inicio del archivo, permitiendo reproducción antes de la descarga completa.

### Regla 12: Nunca sobrescribas el archivo de entrada
```bash
# MAL — puede corromper el original si falla
ffmpeg -i input.mp4 -c copy output.mp4 && mv output.mp4 input.mp4

# BIEN — procesa a temporal, luego renombra
ffmpeg -i input.mp4 -c copy temp.mp4 && mv temp.mp4 input.mp4
```

### Regla 13: Logging y debugging
```bash
# Log detallado a archivo
ffmpeg -i input.mp4 -v debug -c copy output.mp4 2> ffmpeg_debug.log

# Ver información de streams sin procesar
ffprobe -v quiet -print_format json -show_streams input.mp4
```

---

## ⚠️ Anti-patrones comunes

| Anti-patrón | Por qué evitarlo | Alternativa |
|---|---|---|
| `-q:v 1` con libx264 | No funciona como se espera | Usar `-crf 18` |
| `-b:v` sin CRF | Calidad inconsistente | `-crf 23` |
| Sobrescribir input | Puede corromper archivo | Usar archivo temporal |
| No verificar codecs | `-c copy` puede fallar | `ffprobe` primero |
| Dimensiones impares | Error de codec | Usar `scale=-2:N` |

---

## 🔗 Referencias

- [Documentación oficial ffmpeg](https://ffmpeg.org/documentation.html)
- [FFmpeg Wiki — H.264](https://trac.ffmpeg.org/wiki/Encode/H.264)
- [FFmpeg Wiki — H.265](https://trac.ffmpeg.org/wiki/Encode/H.265)
- [FFmpeg Filters](https://ffmpeg.org/ffmpeg-filters.html)
- [FFmpeg Streaming Guide](https://trac.ffmpeg.org/wiki/StreamingGuide)
- [Awesome FFmpeg](https://github.com/transitive-bullshit/awesome-ffmpeg)

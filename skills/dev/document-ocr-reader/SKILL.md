# 📄 Document OCR Reader — Skill del Enjambre

> **Propósito**: OCR y lectura de documentos digitales y escaneados con preprocesamiento de imagen, corrección post-OCR y protocolo de incertidumbre.

---

## 📦 Instalación

### Dependencias del sistema

#### macOS
```bash
brew install tesseract tesseract-lang  # todos los idiomas
brew install poppler                    # para PDF → imagen
```

#### Linux (Debian/Ubuntu)
```bash
sudo apt update && sudo apt install -y \
    tesseract-ocr \
    tesseract-ocr-spa \     # español
    tesseract-ocr-eng \     # inglés
    poppler-utils           # pdfimages, pdftoppm
```

#### Linux (Fedora/RHEL)
```bash
sudo dnf install tesseract tesseract-langpack-spa poppler-utils
```

#### Windows (Chocolatey)
```powershell
choco install tesseract poppler
```

### Dependencias Python
```bash
pip install pytesseract pillow opencv-python-headless pdf2image
pip install numpy pypdf2      # utilidades adicionales
pip install rapidfuzz         # corrección fuzzy
```

### Verificar instalación
```bash
tesseract --list-langs
python3 -c "import pytesseract; print(pytesseract.__version__)"
```

---

## 🔍 Conceptos clave

| Término | Descripción |
|---|---|
| **OCR** | Optical Character Recognition — reconocimiento óptico de caracteres |
| **Binarización** | Conversión de imagen a blanco y negro para mejorar contraste |
| **Umbral (threshold)** | Valor de corte para separar texto del fondo |
| **Deskew** | Corrección de inclinación/rotación del documento |
| **Denoising** | Eliminación de ruido (puntos, manchas, artefactos) |
| **DPI** | Dots Per Inch — resolución de escaneo (mínimo 300 para OCR) |
| **Confianza** | Score de 0-100 que indica qué tan seguro es el OCR |
| **Bounding Box** | Coordenadas [x, y, w, h] de cada palabra detectada |
| **Post-procesamiento** | Corrección de errores del OCR usando diccionarios/contexto |

---

## 🧰 Snippets de código

### 1. OCR básico con Tesseract

```python
import pytesseract
from PIL import Image

def ocr_basico(ruta_imagen: str, idioma: str = "spa") -> str:
    """
    Realiza OCR básico sobre una imagen.
    
    Args:
        ruta_imagen: Ruta al archivo de imagen
        idioma: Código de idioma (spa, eng, spa+eng)
    
    Returns:
        Texto extraído
    """
    imagen = Image.open(ruta_imagen)
    texto = pytesseract.image_to_string(imagen, lang=idioma)
    return texto.strip()

# Uso
texto = ocr_basico("documento.jpg", idioma="spa+eng")
print(texto)
```

### 2. OCR con datos estructurados (bounding boxes)

```python
import pytesseract
from PIL import Image
import json

def ocr_con_coordenadas(ruta_imagen: str, idioma: str = "spa") -> list[dict]:
    """
    Extrae texto con coordenadas de cada palabra/token.
    
    Returns:
        Lista de dicts con texto, confianza y bounding box
    """
    imagen = Image.open(ruta_imagen)
    datos = pytesseract.image_to_data(imagen, lang=idioma, output_type=pytesseract.Output.DICT)
    
    resultados = []
    for i in range(len(datos["text"])):
        if datos["text"][i].strip():
            resultados.append({
                "texto": datos["text"][i],
                "confianza": int(datos["conf"][i]),
                "bbox": {
                    "x": datos["left"][i],
                    "y": datos["top"][i],
                    "w": datos["width"][i],
                    "h": datos["height"][i]
                },
                "nivel": datos["level"][i],
                "bloque": datos["block_num"][i],
                "parrafo": datos["par_num"][i],
                "linea": datos["line_num"][i]
            })
    
    return resultados

# Uso
resultados = ocr_con_coordenadas("factura.jpg")
for r in resultados:
    if r["confianza"] > 60:  # filtrar baja confianza
        print(f"{r['texto']} (conf: {r['confianza']}%)")
```

### 3. Preprocesamiento — binarización y limpieza

```python
import cv2
import numpy as np
from PIL import Image

def preprocesar_para_ocr(ruta_imagen: str, umbral: int = 0) -> Image.Image:
    """
    Pipeline completo de preprocesamiento para mejorar OCR.
    
    Args:
        ruta_imagen: Ruta a la imagen
        umbral: 0 = OTSU automático, >0 = threshold fijo
    
    Returns:
        Imagen PIL preprocesada
    """
    # Cargar con OpenCV
    img = cv2.imread(ruta_imagen)
    if img is None:
        raise ValueError(f"No se pudo cargar la imagen: {ruta_imagen}")
    
    # 1. Convertir a escala de grises
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # 2. Reducir ruido (bilateral filter preserva bordes)
    denoised = cv2.bilateralFilter(gray, 9, 75, 75)
    
    # 3. Binarización
    if umbral > 0:
        _, binary = cv2.threshold(denoised, umbral, 255, cv2.THRESH_BINARY)
    else:
        # OTSU: umbral automático
        _, binary = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # 4. Eliminar ruido pequeño (morphological opening)
    kernel = np.ones((2, 2), np.uint8)
    cleaned = cv2.morphologyEx(binary, cv2.MORPH_OPEN, kernel)
    
    # Convertir OpenCV → PIL
    return Image.fromarray(cleaned)

# Uso
imagen_procesada = preprocesar_para_ocr("documento_escaneado.jpg")
texto = pytesseract.image_to_string(imagen_procesada, lang="spa")
```

### 4. Corrección de inclinación (deskew)

```python
import cv2
import numpy as np

def corregir_inclinacion(ruta_imagen: str) -> np.ndarray:
    """
    Detecta y corrige la inclinación del documento.
    
    Returns:
        Imagen corregida (numpy array)
    """
    img = cv2.imread(ruta_imagen)
    if img is None:
        raise ValueError(f"No se pudo cargar: {ruta_imagen}")
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Detectar bordes
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    
    # Detectar líneas con Hough
    lines = cv2.HoughLines(edges, 1, np.pi / 180, 200)
    
    if lines is None:
        print("No se detectaron líneas — sin corrección")
        return img
    
    # Calcular ángulo promedio
    angles = []
    for rho, theta in lines[:, 0]:
        angle = theta * 180 / np.pi - 90
        if -45 < angle < 45:
            angles.append(angle)
    
    if not angles:
        return img
    
    median_angle = np.median(angles)
    
    # Rotar imagen
    h, w = img.shape[:2]
    center = (w // 2, h // 2)
    matrix = cv2.getRotationMatrix2D(center, median_angle, 1.0)
    corrected = cv2.warpAffine(
        img, matrix, (w, h),
        flags=cv2.INTER_CUBIC,
        borderMode=cv2.BORDER_REPLICATE
    )
    
    print(f"Corrección aplicada: {median_angle:.2f} grados")
    return corrected
```

### 5. OCR sobre PDF escaneado

```python
from pdf2image import convert_from_path
import pytesseract
from PIL import Image

def ocr_pdf_escaneado(ruta_pdf: str, idioma: str = "spa", dpi: int = 300) -> str:
    """
    Convierte PDF escaneado a texto usando OCR página por página.
    
    Args:
        ruta_pdf: Ruta al archivo PDF
        idioma: Código de idioma
        dpi: Resolución para la conversión (mínimo 300)
    
    Returns:
        Texto completo del PDF
    """
    # Convertir PDF a imágenes
    imagenes = convert_from_path(
        ruta_pdf,
        dpi=dpi,
        fmt="jpeg",
        thread_count=4  # paralelizar
    )
    
    texto_completo = []
    for i, imagen in enumerate(imagenes):
        texto_pagina = pytesseract.image_to_string(imagen, lang=idioma)
        texto_completo.append(f"--- Página {i + 1} ---\n{texto_pagina}")
    
    return "\n".join(texto_completo)
```

### 6. OCR con detección de idioma automático

```python
import pytesseract
from PIL import Image

def ocr_deteccion_idioma(ruta_imagen: str) -> dict:
    """
    Detecta el idioma del documento y aplica OCR.
    
    Returns:
        Dict con texto y metadatos
    """
    imagen = Image.open(ruta_imagen)
    
    # OCR rápido para detectar idioma (siempre con spa+eng primero)
    texto_muestra = pytesseract.image_to_string(imagen, lang="spa+eng")[:200]
    
    # Determinar idioma basado en palabras características
    palabras_es = {"el", "la", "los", "las", "de", "del", "y", "en", "un", "una"}
    palabras_en = {"the", "a", "an", "and", "in", "of", "to", "is", "it", "this"}
    
    tokens = set(texto_muestra.lower().split())
    score_es = len(tokens & palabras_es)
    score_en = len(tokens & palabras_en)
    
    if score_es > score_en:
        idioma = "spa"
        idioma_label = "español"
    else:
        idioma = "eng"
        idioma_label = "inglés"
    
    # OCR completo con idioma detectado
    texto_completo = pytesseract.image_to_string(imagen, lang=idioma)
    datos = pytesseract.image_to_data(imagen, lang=idioma, output_type=pytesseract.Output.DICT)
    
    confianza_promedio = sum(datos["conf"]) / max(len([c for c in datos["conf"] if c > 0]), 1)
    
    return {
        "texto": texto_completo.strip(),
        "idioma_detectado": idioma_label,
        "codigo_idioma": idioma,
        "confianza_promedio": round(confianza_promedio, 2)
    }
```

### 7. Post-procesamiento y corrección

```python
from rapidfuzz import fuzz, process
import re

class CorrectorOCR:
    """
    Corrige errores comunes de OCR usando un diccionario de referencia.
    """
    
    def __init__(self, diccionario: list[str] = None):
        self.diccionario = diccionario or []
    
    @classmethod
    def con_diccionario_por_defecto(cls):
        """Crea corrector con palabras comunes en español."""
        palabras_comunes = [
            "factura", "cliente", "total", "subtotal", "iva", "fecha",
            "número", "dirección", "teléfono", "correo", "producto",
            "cantidad", "precio", "descuento", "pago", "efectivo",
            "tarjeta", "transferencia", "recibo", "comprobante",
            "señor", "señora", "empresa", "nit", "identificación",
            "ciudad", "departamento", "país", "código", "referencia",
        ]
        return cls(palabras_comunes)
    
    def corregir_palabra(self, palabra: str, umbral: int = 80) -> str:
        """
        Corrige una palabra comparándola con el diccionario.
        
        Args:
            palabra: Palabra a corregir
            umbral: Score mínimo de similitud (0-100)
        
        Returns:
            Palabra corregida o original si no hay match
        """
        if not palabra or len(palabra) < 3:
            return palabra
        
        mejor_match = process.extractOne(
            palabra,
            self.diccionario,
            scorer=fuzz.ratio,
            score_cutoff=umbral
        )
        
        if mejor_match:
            return mejor_match[0]
        return palabra
    
    def corregir_texto(self, texto: str) -> str:
        """
        Corrige palabras en todo un texto.
        """
        def _corregir_token(token: str) -> str:
            # No corregir números o tokens muy cortos
            if token.isdigit() or len(token) <= 2:
                return token
            return self.corregir_palabra(token)
        
        palabras = texto.split()
        palabras_corregidas = [_corregir_token(p) for p in palabras]
        return " ".join(palabras_corregidas)
    
    def limpiar_texto(self, texto: str) -> str:
        """
        Limpia artefactos comunes del OCR.
        """
        texto = re.sub(r'[|¦!¡¿?@#$%^&*()_+={}\[\]:";<>?,./]', ' ', texto)
        texto = re.sub(r'\s+', ' ', texto)
        texto = re.sub(r'\n{3,}', '\n\n', texto)
        return texto.strip()

# Uso
corrector = CorrectorOCR.con_diccionario_por_defecto()
texto_crudo = "Fáctura N° 00123 — TotaJ: $150.000"
texto_limpio = corrector.limpiar_texto(texto_crudo)
texto_corregido = corrector.corregir_texto(texto_limpio)
# Resultado: "Factura N° 00123 — Total: $150.000"
```

### 8. Pipeline completo de OCR

```python
import cv2
import pytesseract
from PIL import Image
import numpy as np

class PipelineOCR:
    """
    Pipeline completo: carga → preprocesamiento → OCR → post-procesamiento.
    """
    
    def __init__(self, idioma: str = "spa", diccionario: list[str] = None):
        self.idioma = idioma
        self.corrector = CorrectorOCR(diccionario or [])
        self.metadatos = {}
    
    def procesar(self, ruta_archivo: str) -> str:
        """
        Procesa un documento y devuelve texto extraído.
        Soporta: jpg, png, pdf, tiff, bmp
        """
        if ruta_archivo.lower().endswith(".pdf"):
            return self._procesar_pdf(ruta_archivo)
        else:
            return self._procesar_imagen(ruta_archivo)
    
    def _procesar_imagen(self, ruta: str) -> str:
        # Preprocesar
        img = self._preprocesar(ruta)
        
        # OCR
        texto = pytesseract.image_to_string(img, lang=self.idioma)
        
        # Post-procesar
        texto = self.corrector.limpiar_texto(texto)
        texto = self.corrector.corregir_texto(texto)
        
        return texto
    
    def _procesar_pdf(self, ruta: str) -> str:
        from pdf2image import convert_from_path
        imagenes = convert_from_path(ruta, dpi=300)
        textos = []
        for img in imagenes:
            texto = pytesseract.image_to_string(img, lang=self.idioma)
            textos.append(self.corrector.limpiar_texto(texto))
        return "\n".join(textos)
    
    def _preprocesar(self, ruta: str) -> Image.Image:
        img = cv2.imread(ruta)
        if img is None:
            raise ValueError(f"No se pudo cargar: {ruta}")
        
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        denoised = cv2.bilateralFilter(gray, 9, 75, 75)
        _, binary = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        
        return Image.fromarray(binary)

# Uso
pipeline = PipelineOCR(idioma="spa")
texto = pipeline.procesar("documento_escaneado.pdf")
```

### 9. Protocolo de incertidumbre

```python
import json
from dataclasses import dataclass, asdict
from typing import Optional

@dataclass
class ZonaIncierta:
    """Representa una zona del documento con baja confianza."""
    texto_ocr: str
    confianza: float  # 0-100
    bbox: dict       # coordenadas
    posibles_correciones: list[str]
    requiere_revision: bool

@dataclass
class ResultadoOCR:
    """Resultado completo del OCR con zonas de incertidumbre."""
    texto_completo: str
    zonas_inciertas: list[ZonaIncierta]
    confianza_general: float
    idioma: str
    num_palabras: int
    num_baja_confianza: int

def ocr_con_incertidumbre(ruta_imagen: str, idioma: str = "spa", 
                           umbral_confianza: int = 60) -> ResultadoOCR:
    """
    Protocolo de incertidumbre: detecta zonas problemáticas.
    
    Args:
        ruta_imagen: Ruta a la imagen
        idioma: Código de idioma
        umbral_confianza: Mínimo para considerar confiable (0-100)
    
    Returns:
        ResultadoOCR con zonas de incertidumbre identificadas
    """
    imagen = Image.open(ruta_imagen)
    datos = pytesseract.image_to_data(imagen, lang=idioma, output_type=pytesseract.Output.DICT)
    texto_completo = pytesseract.image_to_string(imagen, lang=idioma)
    
    zonas_inciertas = []
    palabra_actual = ""
    conf_palabra = []
    bbox_actual = None
    
    for i in range(len(datos["text"])):
        texto = datos["text"][i].strip()
        conf = int(datos["conf"][i])
        
        if texto:
            palabra_actual = texto
            conf_palabra.append(conf)
            bbox_actual = {
                "x": datos["left"][i],
                "y": datos["top"][i],
                "w": datos["width"][i],
                "h": datos["height"][i]
            }
            
            if conf < umbral_confianza:
                zonas_inciertas.append(ZonaIncierta(
                    texto_ocr=texto,
                    confianza=float(conf),
                    bbox=bbox_actual,
                    posibles_correciones=[],
                    requiere_revision=conf < 40
                ))
    
    num_palabras = len([c for c in datos["conf"] if c > 0])
    confianzas_validas = [c for c in datos["conf"] if c > 0]
    conf_general = sum(confianzas_validas) / max(len(confianzas_validas), 1) if confianzas_validas else 0
    
    return ResultadoOCR(
        texto_completo=texto_completo.strip(),
        zonas_inciertas=zonas_inciertas,
        confianza_general=round(conf_general, 2),
        idioma=idioma,
        num_palabras=num_palabras,
        num_baja_confianza=len(zonas_inciertas)
    )

# Uso con reporte
def reporte_incertidumbre(resultado: ResultadoOCR) -> str:
    """Genera reporte legible de incertidumbre."""
    partes = [
        f"Confianza general: {resultado.confianza_general}%",
        f"Palabras detectadas: {resultado.num_palabras}",
        f"Palabras con baja confianza: {resultado.num_baja_confianza}",
        f"Idioma: {resultado.idioma}",
        "",
        "=== Zonas inciertas ===",
    ]
    
    for z in resultado.zonas_inciertas:
        nivel = "⚠️ REVISAR" if z.requiere_revision else "⚡ baja confianza"
        partes.append(f"  [{nivel}] '{z.texto_ocr}' (conf: {z.confianza}%)")
    
    if not resultado.zonas_inciertas:
        partes.append("  (ninguna — OCR confiable)")
    
    return "\n".join(partes)

# Ejecutar protocolo
resultado = ocr_con_incertidumbre("documento_difuso.jpg")
print(reporte_incertidumbre(resultado))
```

### 10. OCR con múltiples pasadas (refinamiento)

```python
import pytesseract
from PIL import Image

def ocr_multipasada(ruta_imagen: str, idioma: str = "spa") -> str:
    """
    Ejecuta OCR con diferentes configuraciones y elige el mejor resultado.
    """
    imagen = Image.open(ruta_imagen)
    
    configuraciones = [
        {"psm": 3, "desc": "Auto — página completa"},
        {"psm": 4, "desc": "Columna de texto"},
        {"psm": 6, "desc": "Bloque uniforme de texto"},
        {"psm": 11, "desc": "Texto sin orden"},
    ]
    
    mejores_resultados = []
    
    for cfg in configuraciones:
        config_str = f"--psm {cfg['psm']} --oem 3"
        texto = pytesseract.image_to_string(imagen, lang=idioma, config=config_str)
        
        # Calcular calidad: longitud + diversidad de palabras
        palabras = texto.split()
        if not palabras:
            continue
        
        longitud = len(texto)
        palabras_unicas = len(set(p.lower() for p in palabras))
        score = longitud + (palabras_unicas * 10)
        
        mejores_resultados.append({
            "texto": texto.strip(),
            "config": cfg["desc"],
            "score": score,
            "palabras": len(palabras)
        })
    
    if not mejores_resultados:
        return ""
    
    # Seleccionar el mejor
    mejores_resultados.sort(key=lambda x: x["score"], reverse=True)
    mejor = mejores_resultados[0]
    
    print(f"Mejor configuración: {mejor['config']} "
          f"(score: {mejor['score']}, palabras: {mejor['palabras']})")
    
    return mejor["texto"]
```

### 11. Extracción de tablas con OCR

```python
import pytesseract
from PIL import Image
import re

def extraer_tabla_desde_ocr(ruta_imagen: str) -> list[list[str]]:
    """
    Intenta extraer una tabla estructurada del OCR.
    
    Returns:
        Lista de filas, cada fila es una lista de celdas
    """
    imagen = Image.open(ruta_imagen)
    
    # Usar TSV output para preservar estructura
    tsv = pytesseract.image_to_data(imagen, lang="spa", output_type=pytesseract.Output.DATAFRAME)
    
    # Agrupar por bloque y línea
    tabla = []
    linea_actual = []
    ultima_linea = None
    
    for _, row in tsv.iterrows():
        if row["text"] and str(row["text"]).strip():
            linea_num = int(row["line_num"])
            bloque_num = int(row["block_num"])
            
            # Nueva línea dentro del mismo bloque
            if ultima_linea is not None and linea_num != ultima_linea:
                if linea_actual:
                    tabla.append(linea_actual)
                linea_actual = []
            
            # Espaciado horizontal = nueva columna
            linea_actual.append(str(row["text"]).strip())
            ultima_linea = linea_num
    
    if linea_actual:
        tabla.append(linea_actual)
    
    return tabla

# Uso
tabla = extraer_tabla_desde_ocr("tabla_escaneada.png")
for fila in tabla:
    print(" | ".join(fila))
```

---

## 📋 Reglas y mejores prácticas

### Regla 1: Resolución mínima de 300 DPI

El OCR de Tesseract funciona mejor con 300-600 DPI. Por debajo de 200 DPI, la precisión cae drásticamente.

```python
# Verificar DPI de una imagen
from PIL import Image
img = Image.open("documento.jpg")
dpi = img.info.get("dpi", (72, 72))
if dpi[0] < 200:
    print(f"ADVERTENCIA: Baja resolución ({dpi[0]} DPI)")
```

### Regla 2: Siempre preprocesa antes de OCR

Nunca envíes la imagen cruda a Tesseract. Aplica al menos:
1. Escala de grises
2. Reducción de ruido
3. Binarización (umbral)

La mejora en accuracy es de 20-40% con preprocesamiento básico.

### Regla 3: Elige el PSM adecuado

| PSM | Uso | Descripción |
|---|---|---|
| `3` | Default | Página completa, detección automática |
| `4` | Columnas | Texto en columnas (periódicos) |
| `6` | Bloques | Bloque uniforme de texto |
| `7` | Línea | Una sola línea de texto |
| `11` | Sin orden | Texto disperso, sin estructura |
| `12` | Sparse | Texto con espacio variable |
| `13` | Raw | Texto crudo (sin post-procesamiento) |

```python
# Ejemplo: línea individual
config = "--psm 7 --oem 3"
texto = pytesseract.image_to_string(imagen, config=config)
```

### Regla 4: Idiomas específicos mejoran precisión

Siempre especifica el idioma del documento. Mezclar demasiados idiomas reduce precisión.

```python
# Bien: específico
texto = pytesseract.image_to_string(imagen, lang="spa")

# Aceptable: combinación limitada
texto = pytesseract.image_to_string(imagen, lang="spa+eng")

# Mal: demasiados idiomas
texto = pytesseract.image_to_string(imagen, lang="spa+eng+fra+deu+ita+por")
```

### Regla 5: Implementa el protocolo de incertidumbre

Todo pipeline de OCR DEBE reportar:
- Confianza general del OCR
- Palabras/zona con baja confianza (< 60%)
- Coordenadas de las zonas problemáticas
- Sugerencia de revisión manual si confianza < 40%

```python
resultado = ocr_con_incertidumbre("documento.jpg")
if resultado.confianza_general < 70:
    print("⚠️ Revisión humana recomendada")
    for z in resultado.zonas_inciertas:
        if z.requiere_revision:
            print(f"  Revise: '{z.texto_ocr}' en posición {z.bbox}")
```

### Regla 6: Normaliza saltos de línea y espacios

El OCR puede producir artefactos como:
- Espacios múltiples (`"  "` → `" "`)
- Saltos de línea falsos
- Caracteres extraños (`|` en vez de `I`, `0` en vez de `O`)

```python
import re

def normalizar_texto_ocr(texto: str) -> str:
    texto = re.sub(r'[|¦]', 'I', texto)       # pipes → I
    texto = re.sub(r'(\d)o(\d)', r'\10\2', texto)  # lo → 10 en números
    texto = re.sub(r'\s+', ' ', texto)         # espacios múltiples
    texto = re.sub(r'\n{3,}', '\n\n', texto)   # saltos múltiples
    return texto.strip()
```

### Regla 7: Procesa PDFs página por página

Los PDFs escaneados deben convertirse a imágenes página por página. Usa `pdf2image` con `thread_count` para paralelización.

```python
imagenes = convert_from_path(
    "documento.pdf", 
    dpi=300, 
    thread_count=4,
    fmt="jpeg",
    use_pdftocairo=True  # mejor calidad que pdftoppm
)
```

### Regla 8: Aplica corrección idiomática post-OCR

Usa un diccionario de palabras válidas para corregir errores del OCR. La corrección fuzzy con `rapidfuzz` es rápida y efectiva.

```python
corrector = CorrectorOCR.con_diccionario_por_defecto()
texto_corregido = corrector.corregir_texto(texto_ocr)
```

### Regla 9: Documenta límites de formato

El OCR tiene limitaciones conocidas:
- Texto manuscrito: precisión < 50% (usar modelos especializados)
- Fuentes decorativas/itálicas: rendimiento reducido
- Texto sobre fondo con patrón: requiere preprocesamiento extra
- Tablas sin bordes: difícil detección de estructura

### Regla 10: Guarda metadatos con cada resultado

Almacena siempre junto al texto extraído:
- Archivo fuente
- Fecha/hora de procesamiento
- Configuración usada (idioma, PSM, OEM)
- Confianza promedio
- Versión de Tesseract

```python
resultado = {
    "texto": texto_extraido,
    "metadatos": {
        "fuente": "factura_001.pdf",
        "fecha_procesamiento": "2026-07-02T10:30:00",
        "idioma": "spa",
        "psm": 3,
        "confianza": 85.3,
        "tesseract_version": pytesseract.get_tesseract_version(),
        "num_paginas": 1,
        "palabras_extraidass": 450,
        "palabras_baja_confianza": 12
    }
}
```

### Regla 11: Parámetros de Tesseract que mejoran resultados

```python
# Configuración avanzada de Tesseract
config = (
    "--psm 3 "                # modo de segmentación
    "--oem 3 "                # LSTM + Legacy combinados
    "-c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789áéíóúñ "
    "-c tessedit_do_invert=0 "     # no invertir automáticamente
    "-c textord_noise_norm=1 "     # normalizar ruido de fondo
)
```

### Regla 12: Prueba con muestras reales

Cada nuevo tipo de documento requiere calibración:
1. Toma 5-10 muestras representativas
2. Ejecuta OCR con configuración default
3. Revisa errores manualmente
4. Ajusta preprocesamiento y configuración
5. Repite hasta alcanzar accuracy > 85%

---

## ⚠️ Anti-patrones comunes

| Anti-patrón | Problema | Alternativa |
|---|---|---|
| OCR sin preprocesamiento | 20-40% menos precisión | Binarizar + denoising |
| Ignorar confianza del OCR | Errores pasan desapercibidos | Implementar protocolo de incertidumbre |
| DPI < 200 | Texto ilegible para OCR | Reescanear a 300+ DPI |
| No especificar idioma | Caracteres incorrectos | `lang="spa"` o `"spa+eng"` |
| Un solo PSM para todo | Resultados inconsistentes | Probar PSM 3, 4, 6 según documento |
| No limpiar post-OCR | Artefactos en texto final | Normalizar espacios y caracteres |

---

## 🔗 Referencias

- [Tesseract OCR Documentation](https://tesseract-ocr.github.io/)
- [pytesseract Python Package](https://github.com/madmaze/pytesseract)
- [OpenCV Image Processing](https://docs.opencv.org/master/d2/d96/tutorial_py_table_of_contents_imgproc.html)
- [pdf2image Documentation](https://pdf2image.readthedocs.io/)
- [rapidfuzz Fuzzy Matching](https://rapidfuzz.github.io/rapidfuzz/)
- [Tesseract PSM Modes](https://tesseract-ocr.github.io/tessdoc/ImproveQuality.html#page-segmentation-method)
- [Tesseract Best Practices](https://github.com/tesseract-ocr/tessdoc/blob/main/ImproveQuality.md)

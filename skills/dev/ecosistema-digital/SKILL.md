---
name: ecosistema-digital
description: Investigación integral de un cliente en redes/web, descarga de su archivo fotográfico, y construcción de sitio web profesional con portafolio de servicios. Generada por el enjambre el 2026-07-01 a partir del caso Gicela Ospina.
---

# 🌐 Ecosistema Digital — Investigación + Archivo Fotográfico + Web + Portafolio

> Skill generada por el enjambre a partir del proyecto piloto Gicela Ospina (@gicelaospina_)
> Caso real: 601K seguidores en Instagram, reseñadora colombiana de perfumes
> Fecha: 2026-07-01 | Versión: 1.0.0

---

## metadata

- **id**: `ecosistema-digital`
- **version**: 1.0.0
- **domain**: marketing-digital, desarrollo-web
- **priority**: high
- **phase**: discovery
- **orquestador**: Smith
- **subagentes**: investigador, estratega, arquitecto, programador, tester, visor-multimodal

---

## triggers

```yaml
keywords:
  - "investigación de cliente"
  - "ecosistema digital"
  - "portafolio para"
  - "página web para"
  - "construir portafolio"
  - "investigar influenciador"
  - "investiga a"
  - "descargar fotos de"
  - "banco de imágenes para"
  - "sitio web profesional para"
  - "media kit para"
  - "portafolio de servicios para"
  - "investigación profunda sobre"
patterns:
  - "investiga a [nombre] en redes"
  - "necesito una web para [cliente]"
  - "construye un portafolio para [cliente]"
  - "haz una investigación sobre [cliente]"
  - "descarga las fotos de [cliente]"
  - "crea el ecosistema digital de [cliente]"
  - "prepara el proyecto de [cliente]"
  - "todo el paquete para [cliente]"
  - "investigación completa de [cliente]"
exclude:
  - "solo logo"
  - "solo un icono"
  - "tarjeta de presentación"
  - "flyer"
  - "solo un post"
```

---

## rules

```yaml
business_rules:
  # === FASE 0: Activación ===
  - "Siempre comenzar con un diagnóstico rápido del tipo de cliente (influencer/empresa/marca personal)"
  - "Identificar qué tipo de contenido necesita: ¿solo web? ¿web + fotos? ¿web + fotos + portafolio? ¿todo el ecosistema?"

  # === FASE 1: Investigación ===
  - "La investigación debe ser multi-fuente: Instagram + TikTok + YouTube + Facebook + web propia + Linktree + menciones externas"
  - "Extraer SIEMPRE: handle de redes, número de seguidores, biografía, tipo de contenido, frecuencia de publicación"
  - "Identificar colaboraciones previas con marcas para construir el portafolio"
  - "Detectar la propuesta única de valor del cliente (qué lo diferencia en su nicho)"
  - "Si existe sitio web actual, analizarlo y documentar qué mejorar"
  - "Buscar la razón social/empresa registrada para credibilidad corporativa"
  - "No usar Google Search directo si da error 429 — usar Playwright MCP o webfetch con duckduckgo/bing"

  # === FASE 2: Archivo Fotográfico ===
  - "Crear carpeta dedicada: ~/Dev/<proyecto-cliente>-fotos/"
  - "Fuentes de descarga (por orden de prioridad):"
  - "  1. Sitio web oficial del cliente (hero images, logos)"
  - "  2. YouTube API (avatars en máxima resolución 1080×1080)"
  - "  3. Instagram API interna: i.instagram.com/api/v1/users/web_profile_info/?username=X"
  - "     Requiere header X-IG-App-ID: 1217981644879628 y User-Agent de iPhone"
  - "  4. Linktree UGC (avatars del perfil)"
  - "  5. OG images de Linktree (1200×630, útiles para banners)"
  - "Para Instagram: la API sin autenticación solo devuelve los últimos 12 posts"
  - "Si se necesitan más fotos de Instagram, intentar vía Playwright MCP con sesión Chrome autenticada"
  - "Para cada descarga: curl -L con timeout de 30s, User-Agent móvil, Referer apropiado"
  - "Verificar cada archivo descargado: no debe ser HTML (0 bytes o contenido HTML)"
  - "Nomenclatura de archivos: tipo_descripcion.ext (foto_hero_web.jpg, instagram_profile_hd.jpg, perfume-tokio.jpg)"
  - "Seleccionar TOP 5 mejores fotos: las más nítidas, profesionales, representativas del cliente"
  - "Crear README.md en la carpeta de fotos con organización por tipo de uso"
  - "Si hay productos físicos (perfumes, maquillaje, ropa), descargar/solicitar fotos individuales de cada producto"

  # === FASE 3: Documentación de Base ===
  - "Crear documento de base de conocimiento del cliente: ~/Dev/<proyecto-cliente>/docs/base-conocimiento.md"
  - "Incluir: datos generales, métricas de redes, negocio físico/virtual, marcas colaboradoras, análisis FODA"
  - "Crear documento de portafolio de servicios: ~/Dev/<proyecto-cliente>/docs/portafolio-servicios.md"
  - "El portafolio de servicios debe incluir: 5-6 paquetes con servicios, precios sugeridos, proceso de colaboración, términos"
  - "Crear brief técnico de página web: ~/Dev/<proyecto-cliente>/docs/brief-web.md"
  - "El brief debe incluir: arquitectura del sitio, especificaciones por sección, stack tecnológico, diseño UX, plan de implementación, KPIs"

  # === FASE 4: Construcción del Sitio Web ===
  - "Usar HTML+CSS+JS vanilla (sin frameworks) para máxima compatibilidad y rendimiento"
  - "Diseño mobile-first con breakpoints: 480px, 768px, 1024px"
  - "Paleta de colores: debe reflejar la personalidad del cliente (para perfumería: negro + dorado)"
  - "Tipografía: serif elegante para títulos (Playfair Display), sans-serif para cuerpo (Inter)"
  - "Google Fonts: cargar solo las necesarias (Playfair Display + Inter)"
  - "Estructura CSS modular: reset.css, variables.css, base.css, components.css, pages.css, animations.css"
  - "JavaScript modular: main.js (núcleo), components.js (interactividad), contact.js (formulario)"
  - "Schema.org para SEO: Person, Organization, Product según corresponda"
  - "Open Graph tags para compartir en redes sociales"
  - "WhatsApp flotante global si el cliente tiene WhatsApp Business"
  - "Todas las páginas deben tener: header sticky, footer, WhatsApp flotante"
  - "Los enlaces de navegación deben ser relativos (index.html, no /) para compatibilidad local y servidor"
  - "Animaciones con IntersectionObserver (no librerías externas)"
  - "La sección de productos/servicios propios debe tener fotos reales, no placeholders"
  - "Los precios solo deben mostrarse en la página de producto/servicio, no en el Home"

  # === FASE 5: Media Kits Descargables ===
  - "Crear media kits en formato 9:16 vertical (1080×1920) desde HTML+CSS+Playwright"
  - "NO usar Canva generate-design — el resultado es impredecible"
  - "Construir HTML con control píxel a píxel, cada página en un div .page con page-break-after"
  - "Usar Playwright headless browser para convertir HTML a PDF"
  - "pip install playwright && python3 -m playwright install chromium"
  - "Configurar viewport 1080×1920, device_scale_factor=2 para alta calidad"
  - "El script generate-pdf.py debe usar page.pdf() con print_background=True"
  - "Versión 1: Media Kit del cliente como creador/influencer (sin productos propios)"
  - "Versión 2: Media Kit + línea de productos/servicios propios (si aplica)"
  - "Estructura V1 (5 páginas): Portada → Sobre Mí → Métricas → Audiencia → Contacto"
  - "Estructura V2 (6 páginas): Portada → Sobre Mí → Métricas → Audiencia → Productos → Contacto"
  - "Ninguna versión debe mencionar tienda física o virtual si el cliente lo solicita"
  - "Usar SIEMPRE las fotos reales del cliente descargadas en Fase 2, no imágenes de stock"

  # === FASE 6: Documentación y Cierre ===
  - "Crear diario de desarrollo en ~/Dev/<proyecto-cliente>/diario-construccion-<cliente>.md"
  - "Actualizar al final de cada sesión con: actividades, lecciones aprendidas, pendientes, commits"
  - "Inicializar git repo y hacer commit inicial con todo el proyecto"
  - "Actualizar memoria de reinicio en ~/.agents/memoria-sessions/MEMORIA-<CLIENTE>.md"
  - "Actualizar ~/.agents/memoria-reinicio.md con la nueva sesión activa"

  # === REGLAS TRANSVERSALES ===
  - "Toda la comunicación con el cliente/usuario debe ser en español"
  - "Cada fase debe ser aprobada por el usuario antes de continuar"
  - "Si el usuario rechaza un resultado (ej: diseño), iterar máximo 3 veces antes de cambiar de estrategia"
  - "Documentar las decisiones técnicas y por qué se tomaron"
  - "Preservar todos los archivos generados (incluso descartados) para referencia"
```

---

## blueprint

```yaml
description: >
  Pipeline completo de creación de ecosistema digital para un cliente.
  Desde la investigación inicial hasta el sitio web funcionando y media kits descargables.
  Inspirado en el caso real de Gicela Ospina (601K IG, reseñadora de perfumes colombiana).

tech_decisions:
  # Investigación
  - "Usar webfetch + Playwright MCP como fuentes principales de investigación"
  - "Para Instagram: usar API interna con X-IG-App-ID header (sin auth devuelve últimos 12 posts)"
  - "Para YouTube: extraer avatar de perfil desde el HTML de la página del canal (yt3.ggpht.com)"
  - "Para Linktree: extraer avatares desde UGC de Linktree"

  # Archivo fotográfico
  - "curl con headers: -H 'User-Agent: Mozilla/5.0 (iPhone)' -H 'Referer: URL_origen'"
  - "Descargar siempre en máxima resolución disponible"
  - "Organizar con README.md de selección (TOP 5 para web + resto para galería)"

  # Sitio web
  - "HTML+CSS+JS vanilla. Sin frameworks, sin librerías externas. Solo Google Fonts."
  - "CSS modular: variables para design tokens, componentes reutilizables, páginas específicas"
  - "JS: IntersectionObserver para animaciones, FormData + fetch para formularios"
  - "6 páginas: Home, Línea Propia, Portafolio, Sobre Mí, Contacto, 404"
  - "Enlaces relativos (index.html) para compatibilidad file:// y servidor web"

  # Media Kits PDF
  - "HTML+CSS con Playwright headless → PDF. NO usar Canva generate-design."
  - "Formato 9:16 (1080×1920), cada página en un div .page con page-break-after: always"
  - "Fotos reales del cliente, no imágenes de stock"
```

---

## code

```yaml
templates:
  # Plantilla 1: Script de generación de PDF para Media Kits
  - name: "generate-pdf.py"
    description: "Script Python que usa Playwright para convertir HTML a PDF 9:16"
    code: |
      import asyncio
      from playwright.async_api import async_playwright
      import os

      async def generate_pdf(html_path, output_path, total_pages):
          async with async_playwright() as p:
              browser = await p.chromium.launch()
              page = await browser.new_page(
                  viewport={"width": 1080, "height": 1920},
                  device_scale_factor=2
              )
              await page.goto(f"file://{html_path}", wait_until="networkidle")
              await page.wait_for_timeout(1000)

              await page.pdf(
                  path=output_path,
                  width="1080px",
                  height="1920px",
                  print_background=True,
                  margin={"top": "0px", "right": "0px",
                          "bottom": "0px", "left": "0px"},
                  page_ranges=f"1-{total_pages}"
              )
              await browser.close()
              print(f"✅ PDF: {output_path}")

      async def main():
          base = os.path.dirname(os.path.abspath(__file__))
          await generate_pdf(
              os.path.join(base, "version1.html"),
              os.path.join(base, "..", "docs", "MediaKit-v1.pdf"), 5)
          await generate_pdf(
              os.path.join(base, "version2.html"),
              os.path.join(base, "..", "docs", "MediaKit-v2.pdf"), 6)

      asyncio.run(main())

  # Plantilla 2: Estructura HTML de página de media kit
  - name: "media-kit-page-template.html"
    description: "Estructura de una página individual del media kit en 9:16"
    code: |
      <div class="page" style="width:1080px;height:1920px;position:relative;
           overflow:hidden;page-break-after:always;background:#0a0a0a">
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap');
          :root {
            --gold: #C9A94E; --gold-light: #D4AF37;
            --white-dim: rgba(255,255,255,0.7);
            --font-serif: 'Playfair Display', Georgia, serif;
            --font-sans: 'Inter', -apple-system, sans-serif;
          }
          .page {
            width:1080px; height:1920px; position:relative; overflow:hidden;
            font-family: var(--font-sans); color: #fff; background: #0a0a0a;
            page-break-after: always;
          }
        </style>
        <!-- CONTENT HERE -->
      </div>

  # Plantilla 3: Estructura de proyecto web
  - name: "web-project-structure"
    description: "Árbol de directorios y archivos para el sitio web del cliente"
    code: |
      <proyecto-cliente>/
      ├── index.html              → Home
      ├── linea-propia.html       → Productos/servicios propios
      ├── portafolio.html         → Trabajos con marcas
      ├── sobre-mi.html           → Biografía
      ├── contacto.html           → Formulario + WhatsApp
      ├── 404.html                → Error
      ├── css/
      │   ├── reset.css           → Reset moderno
      │   ├── variables.css       → Design tokens
      │   ├── base.css            → Base + grid
      │   ├── components.css      → Componentes reutilizables
      │   ├── pages.css           → Estilos por página
      │   └── animations.css      → Keyframes
      ├── js/
      │   ├── main.js             → Sticky header, menú, animaciones
      │   ├── components.js       → Contadores, slider, nav active
      │   └── contact.js          → Validación formulario + WhatsApp
      ├── fotos/                  → Banco de imágenes
      │   └── README.md
      ├── media-kit/
      │   ├── version1.html       → Media Kit V1 (HTML)
      │   ├── version2.html       → Media Kit V2 (HTML)
      │   └── generate-pdf.py     → Script PDF
      ├── docs/
      │   ├── base-conocimiento.md
      │   ├── portafolio-servicios.md
      │   ├── brief-web.md
      │   ├── MediaKit-v1.pdf
      │   └── MediaKit-v2.pdf
      ├── diario-construccion-<cliente>.md
      └── .gitignore

libraries:
  - "Playwright: pip install playwright && python3 -m playwright install chromium"
  - "Google Fonts: Playfair Display + Inter (vía link rel='stylesheet')"
  - "Iconos: SVG inline (sin Font Awesome ni icon libraries)"
  - "Formulario: Formspree (https://formspree.io) para envío sin backend"

pitfalls:
  - ❌ ERROR: Google Search devuelve 429/JS challenge
    → Solución: Usar webfetch con duckduckgo/bing, o Playwright MCP con Chrome real

  - ❌ ERROR: Instagram API __a=1 está bloqueada
    → Solución: Usar i.instagram.com/api/v1/users/web_profile_info/?username=X
      con headers: X-IG-App-ID: 1217981644879628 + User-Agent iPhone

  - ❌ ERROR: Canva generate-design produce layout 16:9 comprimido en 9:16
    → Solución: NO usar Canva. Construir HTML+CSS desde cero y convertir con Playwright.

  - ❌ ERROR: Las fotos descargadas son HTML (páginas de error) en vez de imágenes
    → Solución: Verificar siempre: file_size > 1000 && !file.startswith('<')

  - ❌ ERROR: Enlaces / no funcionan en file:// (local)
    → Solución: Usar rutas relativas: href="index.html" no href="/"
```

---

## checks

```yaml
validation_checks:
  - category: "Investigación"
    checks:
      - "[ ] Se extrajeron métricas de al menos 3 plataformas (IG, TikTok, YouTube)"
      - "[ ] Se identificaron marcas colaboradoras (mínimo 5)"
      - "[ ] Se documentó la propuesta única de valor del cliente"
      - "[ ] Se verificó la razón social / registro empresarial (si aplica)"

  - category: "Archivo Fotográfico"
    checks:
      - "[ ] Carpeta de fotos creada con nombre estandarizado"
      - "[ ] Mínimo 8 fotos descargadas de fuentes diversas"
      - "[ ] TOP 5 seleccionadas y documentadas en README"
      - "[ ] Ninguna foto es imagen de stock / placeholder"
      - "[ ] Fotos de productos individuales (si aplica)"
      - "[ ] README.md en carpeta de fotos con organización por uso"

  - category: "Documentación"
    checks:
      - "[ ] docs/base-conocimiento.md creado"
      - "[ ] docs/portafolio-servicios.md creado (mínimo 4 paquetes)"
      - "[ ] docs/brief-web.md creado (arquitectura + stack + KPIs)"

  - category: "Sitio Web"
    checks:
      - "[ ] 6 páginas HTML: index, linea-propia, portafolio, sobre-mi, contacto, 404"
      - "[ ] 6 archivos CSS: reset, variables, base, components, pages, animations"
      - "[ ] 3 archivos JS: main, components, contact"
      - "[ ] Diseño mobile-first (media queries en 480px y 768px)"
      - "[ ] Enlaces relativos (index.html, no /)"
      - "[ ] WhatsApp flotante en todas las páginas"
      - "[ ] Schema.org + Open Graph tags"
      - "[ ] Header sticky con menú hamburguesa en mobile"
      - "[ ] Animaciones scroll con IntersectionObserver"

  - category: "Media Kits PDF"
    checks:
      - "[ ] V1: 5 páginas (Portada, Sobre Mí, Métricas, Audiencia, Contacto)"
      - "[ ] V2: 6 páginas (más Línea de Productos)"
      - "[ ] Formato 9:16 (1080×1920) — verificado con pikepdf"
      - "[ ] Fotos reales del cliente en todas las páginas"
      - "[ ] Sin mención de tienda física/virtual (si aplica)"
      - "[ ] HTML+CSS editables + script generate-pdf.py"

  - category: "Cierre"
    checks:
      - "[ ] Git repo inicializado con .gitignore"
      - "[ ] Commit inicial creado"
      - "[ ] Diario de desarrollo con primera sesión"
      - "[ ] Memoria de reinicio actualizada"
      - "[ ] README.md en la raíz del proyecto (si aplica)"
```

---

## examples

```yaml
uso_tipico:
  - "investiga a Gicela Ospina y prepárame portafolio de servicios + página web"
  - "necesito el ecosistema digital completo para un influenciador de moda"
  - "todo el paquete para la marca de café: investigación, fotos, web, media kit"
  - "prepara el proyecto de la chef Maria Pérez con su portafolio y web"
  - "investigación completa de la tienda de ropa + descarga de fotos + web"
  - "crea el ecosistema digital de la artesana de joyería"

flujo_completo:
  - nombre: "Caso Gicela Ospina (referencia)"
    pasos:
      1. "Investigar en IG (601K), TikTok (430K), YouTube (35.7K), Facebook (22.8K)"
      2. "Descargar 20 fotos: web, YouTube avatar, Instagram API, Linktree"
      3. "Crear base de conocimiento con FODA, marcas, métricas"
      4. "Crear 6 paquetes de servicios con precios sugeridos"
      5. "Crear brief de web con arquitectura de 6 páginas"
      6. "Construir web: 3,719 líneas, 6 páginas, responsive mobile-first"
      7. "Construir Media Kits V1 (5 págs) y V2 (6 págs) desde HTML+Playwright"
      8. "8 commits, diario de 5 sesiones, 41 archivos total"
    resultados:
      - "Web: gicela-ospina/web/index.html"
      - "PDFs: MediaKit-Gicela-Ospina-v1.pdf (2.8MB) y v2.pdf (4.1MB)"
      - "Docs: base-conocimiento.md, portafolio-servicios.md, brief-web.md"
      - "23 imágenes, 3 documentos de investigación, 3,719 líneas de código"
```

---

## Diagrama de flujo

```
Usuario: "investiga a [CLIENTE]"
         │
         ▼
╔══ FASE 0: DIAGNÓSTICO ═══════════════╗
║  ¿Qué tipo de cliente?               ║
║  ¿Qué necesita? (web? fotos? media?) ║
╚═══════════════════════════════════════╝
         │
         ▼
╔══ FASE 1: INVESTIGACIÓN ═════════════╗
║  Instagram + TikTok + YouTube + FB   ║
║  Web propia + Linktree + prensa      ║
║  Métricas, marcas, valor único       ║
╚═══════════════════════════════════════╝
         │
         ▼
╔══ FASE 2: ARCHIVO FOTOGRÁFICO ══════╗
║  Descargar de: web, YouTube, IG,    ║
║  Linktree. Seleccionar TOP 5.       ║
║  README.md con organización.         ║
╚═══════════════════════════════════════╝
         │
         ▼
╔══ FASE 3: DOCUMENTACIÓN ════════════╗
║  base-conocimiento.md               ║
║  portafolio-servicios.md             ║
║  brief-web.md                       ║
╚═══════════════════════════════════════╝
         │
         ▼
╔══ FASE 4: WEB ═══════════════════════╗
║  HTML+CSS+JS vanilla                ║
║  6 páginas responsive               ║
║  SEO + OG + Schema                  ║
╚═══════════════════════════════════════╝
         │
         ▼
╔══ FASE 5: MEDIA KITS PDF ═══════════╗
║  HTML → Playwright → PDF            ║
║  V1: reseñadora (5 págs)            ║
║  V2: + productos (6 págs)           ║
╚═══════════════════════════════════════╝
         │
         ▼
╔══ FASE 6: CIERRE ═══════════════════╗
║  Git init + commit                  ║
║  Diario de desarrollo               ║
║  Memoria de reinicio                ║
╚═══════════════════════════════════════╝
         │
         ▼
   ✅ Ecosistema digital completo
```

---

*Skill generada por el enjambre a partir del proyecto Gicela Ospina*
*Caso real: 601K IG, reseñadora colombiana de perfumes, Pereira*
*Entrenamiento: 5 sesiones, 41 archivos, 3,719 líneas de código, 2 PDFs*
*2026-07-01*

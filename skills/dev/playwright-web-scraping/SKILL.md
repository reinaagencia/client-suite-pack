# 🕷️ Playwright Web Scraping — Skill del Enjambre

> **Propósito**: Web scraping profesional con Playwright (Python). Navegación, extracción, autenticación, anti-detección, manejo de SPA y páginas dinámicas.

---

## 📦 Instalación y setup

### Requisitos
```bash
python >= 3.9
pip install playwright
```

### Instalar browsers
```bash
playwright install
# O solo Chromium (recomendado para scraping)
playwright install chromium
```

### Verificar instalación
```bash
python3 -c "from playwright.sync_api import sync_playwright; print('Playwright OK')"
```

---

## 🔍 Conceptos clave

| Término | Descripción |
|---|---|
| **Browser** | Instancia del navegador (Chromium, Firefox, WebKit) |
| **Context** | Sesión aislada (cookies, localStorage, caché separados) |
| **Page** | Pestaña individual |
| **Locator** | Estrategia para encontrar elementos (CSS, XPath, texto) |
| **Selector** | Query para identificar elementos en el DOM |
| **Wait** | Espera condicional (elemento visible, red estable, etc.) |

### API: Sync vs Async

Playwright soporta ambas APIs. Usa **sync** para scripts simples y **async** para mayor concurrencia.

```python
# Sync API (recomendada para scripts lineales)
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    print(page.title())
    browser.close()

# Async API (recomendada para producción con asyncio)
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        await page.goto("https://example.com")
        print(await page.title())
        await browser.close()

asyncio.run(main())
```

---

## 🧰 Snippets de código

### 1. Navegación básica y extracción de texto

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("https://example.com")

    # Extraer título
    title = page.title()
    
    # Extraer texto completo
    body_text = page.inner_text("body")
    
    # Extraer texto de un elemento específico
    heading = page.inner_text("h1")
    
    # Extraer atributo
    link_href = page.get_attribute("a", "href")
    
    print(f"Título: {title}")
    browser.close()
```

### 2. Extraer múltiples elementos (listas)

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("https://example.com/products")

    # Extraer todos los productos
    products = page.query_selector_all(".product-item")
    for product in products:
        name = product.inner_text(".product-name")
        price = product.inner_text(".product-price")
        link = product.get_attribute("a", "href")
        print(f"{name}: ${price} → {link}")

    browser.close()
```

### 3. Esperar elementos y timeouts

```python
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    
    # Timeout global de navegación (30s)
    page.set_default_navigation_timeout(30000)
    
    # Timeout para esperas (10s)
    page.set_default_timeout(10000)
    
    page.goto("https://example.com")
    
    # Esperar a que un elemento sea visible
    page.wait_for_selector(".dynamic-content", state="visible")
    
    # Esperar a que un texto aparezca
    page.wait_for_selector("text=Cargado exitosamente")
    
    # Esperar a que la red esté inactiva
    page.wait_for_load_state("networkidle")
    
    # Esperar con timeout personalizado
    try:
        page.wait_for_selector(".lazy-loaded", timeout=5000)
    except PlaywrightTimeout:
        print("Elemento no encontrado en 5s")
        page.screenshot(path="timeout_debug.png")
    
    browser.close()
```

### 4. Formularios y autenticación

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)  # headless=False para debug
    context = browser.new_context()
    page = context.new_page()
    
    page.goto("https://example.com/login")
    
    # Llenar formulario
    page.fill("input[name='username']", "usuario")
    page.fill("input[name='password']", "contraseña")
    
    # Hacer click en botón de login
    page.click("button[type='submit']")
    
    # Esperar navegación post-login
    page.wait_for_url("**/dashboard")
    
    # Guardar estado de autenticación (cookies + storage)
    context.storage_state(path="auth_state.json")
    
    browser.close()

# Reutilizar sesión autenticada
with sync_playwright() as p:
    browser = p.chromium.launch()
    context = browser.new_context(storage_state="auth_state.json")
    page = context.new_page()
    page.goto("https://example.com/dashboard")
    # Ya autenticado
    browser.close()
```

### 5. Anti-detección: User Agent y viewport

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    
    # Configurar contexto realista
    context = browser.new_context(
        user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                   "AppleWebKit/537.36 (KHTML, like Gecko) "
                   "Chrome/120.0.0.0 Safari/537.36",
        viewport={"width": 1920, "height": 1080},
        locale="es-CO",
        timezone_id="America/Bogota",
        geolocation={"latitude": 4.7110, "longitude": -74.0721},
        permissions=["geolocation"],
    )
    
    page = context.new_page()
    page.goto("https://example.com")
    
    # Simular movimiento de mouse
    page.mouse.move(100, 200)
    page.mouse.move(300, 150)
    
    # Simular scroll
    page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
    
    browser.close()
```

### 6. Proxies y rotación de IP

```python
from playwright.sync_api import sync_playwright

PROXIES = [
    "http://proxy1:8080",
    "http://proxy2:8080",
    "http://proxy3:8080",
]

import random

def scrape_with_proxy(url: str, proxy_url: str) -> dict:
    with sync_playwright() as p:
        browser = p.chromium.launch(
            proxy={"server": proxy_url}
        )
        context = browser.new_context()
        page = context.new_page()
        
        try:
            page.goto(url, timeout=30000)
            return {
                "url": url,
                "title": page.title(),
                "content": page.inner_text("body")[:500],
            }
        except Exception as e:
            return {"url": url, "error": str(e)}
        finally:
            browser.close()

# Rotar proxy aleatorio
proxy = random.choice(PROXIES)
result = scrape_with_proxy("https://example.com", proxy)
```

### 7. Páginas dinámicas (SPA) — esperar datos

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    
    # Interceptar peticiones de red
    responses = []
    
    def handle_response(response):
        if "/api/" in response.url:
            responses.append({
                "url": response.url,
                "status": response.status,
                "json": response.json() if "json" in response.headers.get("content-type", "") else None
            })
    
    page.on("response", handle_response)
    
    page.goto("https://spa-example.com")
    
    # Esperar a que una llamada API específica se complete
    page.wait_for_response(lambda res: "/api/data" in res.url and res.status == 200)
    
    # Extraer datos después de renderizado
    page.wait_for_selector(".data-table", state="visible")
    rows = page.query_selector_all(".data-table tr")
    
    for row in rows:
        cells = row.query_selector_all("td")
        print([cell.inner_text() for cell in cells])
    
    browser.close()
```

### 8. Scrolling infinito (paginación dinámica)

```python
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com/infinite-scroll")
    
    # Scroll hasta el final varias veces
    prev_height = 0
    for i in range(10):  # máximo 10 scrolls
        page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
        time.sleep(2)  # esperar carga
        
        new_height = page.evaluate("document.body.scrollHeight")
        if new_height == prev_height:
            print("No más contenido — scroll completado")
            break
        prev_height = new_height
    
    # Extraer todos los items cargados
    items = page.query_selector_all(".infinite-item")
    print(f"Total items: {len(items)}")
    
    browser.close()
```

### 9. Manejo de múltiples pestañas

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    
    # Abrir nueva pestaña
    with page.context.expect_page() as new_page_info:
        page.click("a[target='_blank']")  # click que abre nueva pestaña
    
    new_page = new_page_info.value
    new_page.wait_for_load_state()
    print(f"Nueva pestaña: {new_page.title()}")
    
    # Cambiar entre pestañas
    page.bring_to_front()  # volver a pestaña original
    
    browser.close()
```

### 10. Descarga de archivos

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com/downloads")
    
    # Esperar descarga
    with page.expect_download() as download_info:
        page.click("a.download-link")
    
    download = download_info.value
    
    # Guardar archivo
    download.save_as(f"./downloads/{download.suggested_filename}")
    
    # O guardar en buffer
    content = download.create_read_stream()
    print(f"Descargado: {download.suggested_filename}")
    
    browser.close()
```

### 11. Tomar screenshots y generar PDF

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    
    # Screenshot de página completa
    page.screenshot(path="full_page.png", full_page=True)
    
    # Screenshot de un elemento específico
    element = page.query_selector(".header")
    element.screenshot(path="header.png")
    
    # Generar PDF (solo Chromium)
    page.pdf(path="page.pdf", format="A4", print_background=True)
    
    browser.close()
```

### 12. Evaluar JavaScript en la página

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    
    # Ejecutar JS en contexto de página
    scroll_position = page.evaluate("""
        () => {
            window.scrollTo(0, 500);
            return {
                x: window.scrollX,
                y: window.scrollY
            };
        }
    """)
    print(f"Scroll: {scroll_position}")
    
    # Extraer datos de variable global
    app_data = page.evaluate("window.__INITIAL_STATE__")
    print(f"Datos iniciales: {app_data}")
    
    browser.close()
```

---

## 📋 Reglas y buenas prácticas

### Regla 1: Siempre usa contextos aislados

Cada sesión de scraping debe usar un `browser.new_context()` separado. Los contextos aíslan cookies, localStorage y caché entre sesiones.

```python
# Bien
context = browser.new_context()
page = context.new_page()

# Mal — estado compartido entre sesiones
page = browser.new_page()
```

### Regla 2: Prefiere locators sobre query_selector

Los locators son más robustos, tienen auto-waiting y mejor mensajería de error.

```python
# Bien (locator)
page.locator(".product-card").first().click()
page.locator("button", has_text="Comprar").click()

# Aceptable (query_selector cuando es necesario)
page.query_selector(".dynamic-element")
```

### Regla 3: Implementa timeouts explícitos

Nunca confíes en timeouts por defecto para scraping en producción.

```python
page.set_default_navigation_timeout(45000)
page.set_default_timeout(15000)
page.wait_for_selector(".content", timeout=10000)
page.wait_for_load_state("networkidle", timeout=30000)
```

### Regla 4: Maneja errores gracefulmente

```python
from playwright.sync_api import TimeoutError, Error as PlaywrightError

try:
    page.goto(url, timeout=30000)
    data = page.inner_text(".content")
except TimeoutError:
    page.screenshot(path=f"timeout_{url.replace('/', '_')}.png")
    data = None
except PlaywrightError as e:
    print(f"Error Playwright: {e}")
    data = None
finally:
    browser.close()
```

### Regla 5: Respeta robots.txt y políticas del sitio

```python
# Verificar robots.txt ANTES de scrapear
import requests
from urllib.robotparser import RobotFileParser

rp = RobotFileParser()
rp.set_url(f"{base_url}/robots.txt")
rp.read()

if rp.can_fetch("*", target_url):
    # Proceder con scraping
    pass
else:
    print(f"robots.txt bloquea: {target_url}")
```

### Regla 6: Rate limiting y delays entre peticiones

```python
import time
import random

def polite_delay():
    """Espera entre 1.5 y 3.5 segundos."""
    time.sleep(random.uniform(1.5, 3.5))

# Usar entre cada página scrapeada
for url in urls:
    scrape(url)
    polite_delay()
```

### Regla 7: Configura anti-detección siempre

Para evitar bloqueos, siempre configura:
- User Agent realista (de un navegador real)
- Viewport estándar (1920x1080)
- Locale y timezone
- Headers Accept-Language

```python
context = browser.new_context(
    user_agent=REAL_USER_AGENTS[0],
    viewport=STANDARD_VIEWPORTS[0],
    locale="es-CO",
    extra_http_headers={
        "Accept-Language": "es-CO,es;q=0.9,en;q=0.8",
    }
)
```

### Regla 8: Guarda y reutiliza estados de autenticación

```python
# Guardar después de login exitoso
context.storage_state(path="session.json")

# Reutilizar en futuras ejecuciones
context = browser.new_context(storage_state="session.json")
```

Esto evita re-autenticación en cada ejecución y reduce la huella en el servidor.

### Regla 9: Monitorea memoria y recursos

Para scraping a gran escala, usa el modo `persistent_context` y monitorea:

```python
# Usar persistent context para sesiones largas
user_data_dir = "./browser_data"
context = browser.launch_persistent_context(
    user_data_dir,
    headless=True,
)

# Limpiar contexto periódicamente
context.clear_cookies()
context.clear_permissions()
```

### Regla 10: Logging estructurado

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("scraper.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

logger.info(f"Iniciando scraping de {url}")
try:
    result = scrape_page(url)
    logger.info(f"Extraídos {len(result)} elementos")
except Exception as e:
    logger.error(f"Fallo en {url}: {e}")
```

### Regla 11: Screenshot en cada fallo

```python
def safe_scrape(page, url):
    try:
        page.goto(url)
        return page.inner_text(".content")
    except Exception:
        safe_name = url.replace("://", "_").replace("/", "_")[:50]
        page.screenshot(path=f"debug_{safe_name}.png")
        page.content(path=f"debug_{safe_name}.html")
        raise
```

### Regla 12: Usa `route` para bloquear recursos innecesarios

```python
# Bloquear imágenes, fuentes, analytics para acelerar
def block_resources(route):
    if route.request.resource_type in ["image", "font", "media", "stylesheet"]:
        route.abort()
    else:
        route.continue_()

page.route("**/*", block_resources)
```

---

## ⚠️ Anti-patrones comunes

| Anti-patrón | Problema | Alternativa |
|---|---|---|
| `time.sleep()` fijo | Frágil, muy lento o muy rápido | `wait_for_selector` o `wait_for_load_state` |
| Sin `headless=False` debug | Fallos ciegos sin entender por qué | Capturar screenshot en fallo |
| Mismo User Agent siempre | Fácil de detectar y bloquear | Rotar user agents realistas |
| Sin rate limiting | IP baneada permanentemente | Delay aleatorio 2-5s entre requests |
| No verificar status code | Scrapea páginas 404/error | Validar `response.ok` antes de extraer |
| Mezclar contextos | Cookies/estados contaminados | Un contexto por sesión independiente |

---

## 🔗 Referencias

- [Playwright Python Docs](https://playwright.dev/python/docs/intro)
- [Playwright API Reference](https://playwright.dev/python/docs/api/class-playwright)
- [Playwright Best Practices](https://playwright.dev/python/docs/best-practices)
- [Anti-detection patterns](https://bot-detector.refl.me/)
- [Playwright Sharp (C#)](https://github.com/microsoft/playwright-dotnet)
- [Awesome Playwright](https://github.com/mxschmitt/awesome-playwright)

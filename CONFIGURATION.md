# ⚙️ Guía de Configuración Post-Instalación

> Después de ejecutar `bash builder.sh`, sigue estos pasos para completar la configuración de tu Suite de Agentes.

---

## 📋 Checklist de Configuración

- [ ] **Paso 1:** Configurar API key de OpenCode
- [ ] **Paso 2:** Configurar modelo por defecto
- [ ] **Paso 3:** Configurar MCP servers
- [ ] **Paso 4:** Configurar cuentas de servicio
- [ ] **Paso 5:** Verificar la memoria de sesiones
- [ ] **Paso 6:** Verificar instalación
- [ ] **Paso 7:** ¡Primer uso!

---

## Paso 1: API Key de OpenCode

La suite necesita una API key de OpenCode para funcionar.

### 1.1 Obtener tu API Key

1. Ve a [https://opencode.ai](https://opencode.ai) e inicia sesión
2. Navega a Workspace → API Keys
3. Genera una nueva API key (o copia la existente)
4. Copia la key (comienza con `sk-...`)

### 1.2 Configurar la API Key

Crea o edita el archivo `{{AGENTS_HOME}}/.env`:

```bash
# Reemplaza "sk-tu-key-aqui" con tu API key real
echo 'OPENCODE_API_KEY=sk-tu-key-aqui' >> {{AGENTS_HOME}}/.env
echo 'OPENCODE_BASE_URL=https://opencode.ai/zen/v1' >> {{AGENTS_HOME}}/.env
```

O configúrala como variable de entorno global:

```bash
# En ~/.zshrc, ~/.bashrc o similar
export OPENCODE_API_KEY="sk-tu-key-aqui"
export OPENCODE_BASE_URL="https://opencode.ai/zen/v1"
```

---

## Paso 2: Modelos

### 2.1 Plan recomendado

La suite está optimizada para **OpenCode Go** (plan pago), pero también funciona con el **plan Zen** (gratuito) con límites de rate.

| Plan | Ventajas | Limitaciones |
|------|----------|--------------|
| **Zen (free)** | Sin costo | Rate limit, modelos flash gratuitos |
| **Go (pago)** | Sin rate limit, modelos premium | Costo mensual |

### 2.2 Modelos por agente

Los modelos se configuran en la cabecera (`frontmatter`) de cada archivo de agente en `{{OPENCODE_CONFIG_PATH}}/agent/*.md`:

```yaml
---
model: opencode-go/deepseek-v4-flash
---
```

| Agente | Modelo recomendado | Alternativa gratuita |
|--------|-------------------|---------------------|
| Orquestador y resto | `opencode-go/deepseek-v4-flash` | `opencode-go/deepseek-v4-flash` (modo Zen) |
| Auditor ⭐ | `opencode-go/deepseek-v4-pro` | No tiene versión gratuita |
| Visor-multimodal | `opencode-go/mimo-v2.5` | `opencode-go/mimo-v2.5` (modo Zen) |

### 2.3 Fallback automático

La skill `model-router` gestiona el fallback automático:
- Si el plan Zen da **rate limit (429)** → cambia automáticamente al modelo pago
- Si el plan Go falla por **créditos insuficientes (401/402)** → te notifica para que recargues

---

## Paso 3: MCP Servers

Los MCP servers son servicios externos que los agentes pueden usar.

### 3.1 Playwright MCP (navegador web) — RECOMENDADO

**Recomendado para:** Web scraping, investigación, automatización de navegador.

```bash
# Instalar si no lo tienes
npm install -g @playwright/mcp
npx playwright install chromium
```

En `{{OPENCODE_CONFIG_PATH}}/opencode.jsonc`, descomenta o agrega:

```json
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest"],
      "enabled": true
    }
  }
}
```

### 3.2 Otros MCP (opcionales)

| MCP | Para qué | Configuración |
|-----|----------|---------------|
| **Google MCP** | Calendar, Gmail, Drive | OAuth 2.0 en Google Cloud Console |
| **GitHub MCP** | Gestión de repositorios | GitHub Token |
| **WhatsApp MCP** | Automatización WhatsApp Business | Meta Business + Webhook |

---

## Paso 4: Cuentas de Servicio

### 4.1 GitHub (recomendado)

Para que el `desplegador` pueda hacer commits y push:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

### 4.2 Google Calendar (opcional)

Si necesitas que los agentes gestionen calendarios:

1. Crea un proyecto en [Google Cloud Console](https://console.cloud.google.com/)
2. Habilita Google Calendar API
3. Crea credenciales OAuth 2.0

---

## Paso 5: Memoria de Sesiones (NUEVO)

La suite incluye un sistema de **memoria multi-sesión** para retomar proyectos donde los dejaste.

### 5.1 Verificar que la memoria está activa

```bash
ls -la {{AGENTS_HOME}}/memoria-sessions/
```

Deberías ver:
- `index.json` — índice de sesiones
- `session-actual.md` — sesión activa actual
- `memoria-sessions-schema.json` — esquema de referencia

### 5.2 Verificar el tracker

```bash
cat {{AGENTS_HOME}}/memoria-reinicio.md
```

### 5.3 Cómo funciona

1. **Auto-save automático**: el orquestador guarda el progreso al final de cada respuesta
2. **Continuar sesiones**: en tu próxima sesión, di "continuar" para ver proyectos pendientes
3. **Múltiples proyectos**: cada proyecto tiene su propio archivo de sesión

---

## Paso 6: Verificar Instalación

### 6.1 Verificar que los agentes existen

```bash
ls {{OPENCODE_CONFIG_PATH}}/agent/
```

Deberías ver **11 archivos** `.md` (1 orquestador + 10 subagentes).

### 6.2 Verificar la configuración de OpenCode

```bash
cat {{OPENCODE_CONFIG_PATH}}/opencode.json
```

Debería mostrar el JSON con `default_agent: "{{ORQUESTADOR}}"`.

### 6.3 Verificar las skills

```bash
ls {{AGENTS_HOME}}/skills/
```

Deberías ver las carpetas de skills instaladas (28+ skills).

### 6.4 Verificar el diario del proyecto

```bash
cat {{WORKSPACE_PATH}}/diario-construccion.md
```

### 6.5 Probar un agente

Abre OpenCode en cualquier directorio:

```bash
cd {{WORKSPACE_PATH}}
opencode
```

Luego escribe: `"Hola, ¿qué agentes están disponibles?"`

El orquestador debería responder con la lista de 11 agentes disponibles.

---

## Paso 7: Primeros Pasos

### 🎯 Prueba rápida

Una vez instalado, prueba estas frases con tu orquestador:

1. **"¿Qué agentes tienes disponibles?"** → Lista los 11 agentes
2. **"Planifica una API REST en Flask con PostgreSQL"** → Activa el pipeline con superinteligencia
3. **"Analiza esta captura de pantalla"** → Activa al visor-multimodal
4. **"Transcribe este audio"** → Activa al transcriptor
5. **"Continuar"** → Muestra las sesiones pendientes
6. **"Aprende a usar docker"** → Activa autoaprendizaje

### 🧬 Probar la superinteligencia

```bash
"Necesito un análisis profundo de esta arquitectura, desde múltiples perspectivas"
```
→ Activa MoA + auto-superinteligencia-continua

### 📚 Explora las skills

Pregunta a tu orquestador:

- **"¿Qué skills tienes instaladas?"** → Lista el catálogo
- **"Aprende a usar ffmpeg"** → Activa autoaprendizaje
- **"Busca una skill para hacer scraping"** → Activa find-skills

---

## ❓ FAQ / Troubleshooting

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| "Model not found" | Modelo incorrecto en frontmatter | Verifica `model:` en el archivo del agente |
| "Rate limit exceeded" | Plan Zen agotado | Espera o cambia a modelo pago |
| "Agent not found" | No se cargó la configuración | Verifica `default_agent` en opencode.json |
| "Task delegation fails" | El agente no existe | `ls ~/.config/opencode/agent/` para verificar |
| "MCP server error" | Servicio no configurado | Configura credenciales o deshabilita el MCP |
| Skills no cargan | Ruta incorrecta | Verifica `skills.paths` en opencode.json |
| Memoria no funciona | Falta reinicio-memoria skill | Verifica que esté en `~/.agents/skills/reinicio-memoria/` |

---

## 🆘 Soporte

Si encuentras problemas durante la configuración:

1. Revisa este documento
2. Pregunta al orquestador: **"¿Cómo configuro X?"**
3. Usa el skill `find-skills`: **"Busca una skill para configurar Y"**

---

*¡Tu Suite de Agentes con Superinteligencia está lista para funcionar! 🚀*

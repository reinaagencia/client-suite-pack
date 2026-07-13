# whatsapp-agent

Blueprint para construir agentes de WhatsApp con IA usando Express + TypeScript + Meta Cloud API + OpenRouter + ngrok. Cubre desde el scaffolding del proyecto hasta el deploy con prompt conversacional, persistencia de conversaciones y control de mensajes entrantes/salientes.

---

## 📋 Reglas de negocio (10+)

### 1. Stack tecnológico — Decisiones de arquitectura

| Componente | Tecnología | Por qué |
|------------|------------|---------|
| Runtime | Node.js 20+ LTS | Soporte nativo de fetch, ESM, rendimiento |
| Framework | Express.js (4.x) | Madurez, simplicidad, documentación extensa |
| Lenguaje | TypeScript 5.x | Type safety, mejor experiencia de desarrollo |
| API de WhatsApp | Meta Cloud API v21+ | Oficial, gratuita, webhooks, templates |
| LLM | OpenRouter (cualquier modelo) | Flexibilidad: OpenAI, Anthropic, Mistral, Qwen |
| Persistencia | SQLite (mejor-sqlite3) + Supabase (opcional) | Ligero para desarrollo, escalable a producción |
| Deploy | Railway + ngrok | Railway para producción, ngrok para desarrollo local |
| Webhook | Express raw body + crypto (verificación) | Seguridad Meta requerida |

### 2. Verificación de webhook — Obligatorio
Meta requiere que el webhook responda a un challenge GET con el token configurado:

```typescript
// Meta envía GET con query params: hub.mode, hub.verify_token, hub.challenge
// Debes responder 200 con el challenge si el verify_token coincide
app.get("/webhook", (req, res) => {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];

  if (mode === "subscribe" && token === process.env.WEBHOOK_VERIFY_TOKEN) {
    return res.status(200).send(challenge);
  }
  return res.sendStatus(403);
});
```

### 3. Recepción de mensajes — Body raw obligatorio
Meta envía payload JSON en POST. Express debe recibir el body RAW para validar firma:

```typescript
app.post("/webhook", express.raw({ type: "application/json" }), async (req, res) => {
  // Responder 200 inmediatamente a Meta
  res.sendStatus(200);

  const body = JSON.parse(req.body.toString());
  // Procesar mensaje asincrónicamente después de responder
  await processIncomingMessage(body);
});
```

**Regla:** Siempre responder 200 a Meta inmediatamente. El procesamiento del mensaje va después para evitar timeouts.

### 4. Filtrado de mensajes entrantes
No todos los payloads de Meta son mensajes. Filtrar:

```typescript
function extractMessage(body: any): MessageData | null {
  const entry = body?.entry?.[0];
  const change = entry?.changes?.[0];
  const value = change?.value;
  const message = value?.messages?.[0];

  if (!message) return null; // No es un mensaje (status, reaction, etc.)

  return {
    from: message.from,         // Número del remitente
    text: message.text?.body,   // Contenido del mensaje
    id: message.id,
    timestamp: message.timestamp,
    type: message.type,         // "text", "interactive", "button", etc.
  };
}
```

### 5. Envío de mensajes — API de Meta
Usar la API de Meta Cloud API para responder:

```typescript
async function sendWhatsAppMessage(to: string, text: string): Promise<Response> {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;
  const payload = {
    messaging_product: "whatsapp",
    to,
    type: "text",
    text: { body: text },
  };

  return fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });
}
```

### 6. Manejo de conversación con LLM
El agente debe mantener contexto de conversación:

```typescript
@dataclass
class ConversacionWhatsApp {
  numero: string;
  mensajes: Array<{ rol: string; content: string }>;
  ultima_interaccion: Date;
  meta: Record<string, any>;  // datos extraídos del cliente
}

const conversaciones = new Map<string, ConversacionWhatsApp>();

function obtenerOcrearConversacion(numero: string): ConversacionWhatsApp {
  if (!conversaciones.has(numero)) {
    conversaciones.set(numero, {
      numero,
      mensajes: [],
      ultima_interaccion: new Date(),
      meta: {},
    });
  }
  return conversaciones.get(numero)!;
}
```

### 7. System prompt — Base para el agente
El prompt del agente debe incluir:

```
Eres un asistente virtual de [nombre de la empresa].
Tu objetivo es ayudar a los clientes con sus consultas de manera amable y profesional.

Reglas:
- Respondes en el mismo idioma que el cliente
- Usas un tono cálido y cercano
- No inventas información que no tengas
- Si no sabes algo, dices que lo vas a verificar
- Mantienes el contexto de la conversación
- Identificas oportunidades de venta y las comunicas
- Nunca compartes datos sensibles de otros clientes

Contexto actual:
[información de la empresa y productos]
```

### 8. Rate limiting y control de mensajes
Proteger contra abusos y cumplir con políticas de Meta:

| Límite | Recomendación |
|--------|---------------|
| Mensajes por segundo | Máximo 1 mensaje cada 500ms por número |
| Mensajes por día por número | 1000 (límite Meta) |
| Mensajes por minuto total | 60 (límite telefónico) |
| Tamaño de mensaje | Máximo 4096 caracteres |
| Sesión inactiva | Cerrar después de 30 minutos sin respuesta |

### 9. Plantillas de mensajes (Message Templates)
Para enviar el primer mensaje a un cliente (fuera de ventana de 24h), usar templates aprobados por Meta:

```typescript
async function sendTemplateMessage(to: string, templateName: string, parameters: string[]) {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;
  const payload = {
    messaging_product: "whatsapp",
    to,
    type: "template",
    template: {
      name: templateName,
      language: { code: "es" },
      components: [{
        type: "body",
        parameters: parameters.map(p => ({ type: "text", text: p })),
      }],
    },
  };

  return fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });
}
```

### 10. Manejo de errores y reintentos

| Error | Causa | Acción |
|-------|-------|--------|
| 400 | Payload inválido | Loggear payload, no reintentar |
| 401 | Token expirado | Renovar access_token, reintentar |
| 429 | Rate limit | Esperar y reintentar con backoff exponencial |
| 500 | Error de Meta | Reintentar hasta 3 veces con backoff |
| Timeout | Red lenta | Reintentar con timeout mayor |

**Backoff exponencial:**
```typescript
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
): Promise<T> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries - 1) throw error;
      const delay = Math.pow(2, attempt) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error("Max retries reached");
}
```

### 11. Seguridad y validación de firma
Meta firma cada petición entrante. Validar la firma evita ataques:

```typescript
import crypto from "node:crypto";

function validateSignature(req: express.Request, appSecret: string): boolean {
  const signature = req.headers["x-hub-signature-256"] as string;
  if (!signature) return false;

  const computed = crypto
    .createHmac("sha256", appSecret)
    .update(req.body)
    .digest("hex");

  return crypto.timingSafeEqual(
    Buffer.from(signature.replace("sha256=", "")),
    Buffer.from(computed),
  );
}
```

### 12. Deploy — Checklist de producción

| Ítem | Detalle |
|------|---------|
| Railway | Conectar repo GitHub, variables de entorno, dominio |
| ngrok | `ngrok http 3000` para desarrollo local |
| Webhook configurado | Dashboard Meta Developers → WhatsApp → Webhook |
| Token permanente | Generar access_token de larga duración (60 días) |
| Variables de entorno | `.env` con WA_ACCESS_TOKEN, WA_PHONE_NUMBER_ID, WEBHOOK_VERIFY_TOKEN, OPENROUTER_API_KEY |
| SSL/TLS | Railway maneja SSL automáticamente. ngrok también |
| Monitoreo | Railway logs, opcional Sentry para errores |
| Rate limiting | Implementar express-rate-limit |

---

## 🧩 Snippets de código (10+)

### Snippet 1: Project scaffolding completo
```typescript
// package.json (dependencies clave)
{
  "name": "whatsapp-agent",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "ngrok": "ngrok http 3000"
  },
  "dependencies": {
    "express": "^4.21.0",
    "dotenv": "^16.4.5",
    "zod": "^3.23.8",
    "better-sqlite3": "^11.3.0"
  },
  "devDependencies": {
    "typescript": "^5.6.0",
    "tsx": "^4.19.0",
    "@types/express": "^4.17.21",
    "@types/better-sqlite3": "^7.6.11"
  }
}
```

### Snippet 2: Servidor Express completo
```typescript
import express from "express";
import crypto from "node:crypto";
import "dotenv/config";

const app = express();
const PORT = process.env.PORT || 3000;

// GET /webhook — Meta verification
app.get("/webhook", (req, res) => {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];

  if (mode === "subscribe" && token === process.env.WEBHOOK_VERIFY_TOKEN) {
    console.log("Webhook verified successfully");
    return res.status(200).send(challenge);
  }
  return res.sendStatus(403);
});

// POST /webhook — Receive messages
app.post("/webhook", express.raw({ type: "application/json" }), async (req, res) => {
  // Validate signature (optional but recommended)
  if (process.env.APP_SECRET) {
    const valid = validateSignature(req, process.env.APP_SECRET);
    if (!valid) {
      console.warn("Invalid signature");
      return res.sendStatus(401);
    }
  }

  // Respond 200 immediately
  res.sendStatus(200);

  try {
    const body = JSON.parse(req.body.toString());
    await processMessage(body);
  } catch (error) {
    console.error("Error processing message:", error);
  }
});

app.listen(PORT, () => {
  console.log(`WhatsApp Agent running on port ${PORT}`);
});
```

### Snippet 3: Procesamiento de mensajes entrantes
```typescript
interface MessageData {
  from: string;
  text: string;
  id: string;
  timestamp: string;
  type: string;
}

function extractMessage(body: any): MessageData | null {
  try {
    const entry = body?.entry?.[0];
    const changes = entry?.changes?.[0];
    const value = changes?.value;
    const message = value?.messages?.[0];
    const from = value?.metadata?.display_phone_number;

    if (!message) return null;

    return {
      from: message.from,
      text: message.text?.body || "",
      id: message.id,
      timestamp: message.timestamp,
      type: message.type,
    };
  } catch {
    return null;
  }
}

async function processMessage(body: any): Promise<void> {
  const msg = extractMessage(body);
  if (!msg) return;

  console.log(`Message from ${msg.from}: "${msg.text}"`);

  // Aquí iría la lógica del LLM
  const response = await generateLLMResponse(msg.from, msg.text);
  await sendWhatsAppMessage(msg.from, response);
}
```

### Snippet 4: Envío de mensajes a WhatsApp
```typescript
async function sendWhatsAppMessage(to: string, text: string): Promise<boolean> {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to,
        type: "text",
        text: { body: text, preview_url: false },
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error("Error sending message:", error);
      return false;
    }

    return true;
  } catch (error) {
    console.error("Network error sending message:", error);
    return false;
  }
}
```

### Snippet 5: Integración con OpenRouter (LLM)
```typescript
interface OpenRouterResponse {
  choices: Array<{
    message: {
      content: string;
    };
  }>;
}

async function queryLLM(
  messages: Array<{ role: string; content: string }>,
): Promise<string> {
  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
      "Content-Type": "application/json",
      "HTTP-Referer": process.env.SITE_URL || "https://whatsapp-agent.local",
    },
    body: JSON.stringify({
      model: process.env.LLM_MODEL || "openai/gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: process.env.SYSTEM_PROMPT || "Eres un asistente virtual amable y servicial.",
        },
        ...messages,
      ],
      max_tokens: 500,
      temperature: 0.7,
    }),
  });

  if (!response.ok) {
    throw new Error(`LLM API error: ${response.status}`);
  }

  const data: OpenRouterResponse = await response.json();
  return data.choices[0]?.message?.content || "Lo siento, no pude procesar tu mensaje.";
}
```

### Snippet 6: Gestión de conversaciones con SQLite
```typescript
import Database from "better-sqlite3";

const db = new Database("conversations.db");

// Crear tablas
db.exec(`
  CREATE TABLE IF NOT EXISTS conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT NOT NULL,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE INDEX IF NOT EXISTS idx_phone ON conversations(phone);
`);

// Guardar mensaje
function saveMessage(phone: string, role: string, content: string): void {
  const stmt = db.prepare(
    "INSERT INTO conversations (phone, role, content) VALUES (?, ?, ?)"
  );
  stmt.run(phone, role, content);
}

// Obtener historial
function getHistory(phone: string, limit: number = 20): Array<{ role: string; content: string }> {
  const stmt = db.prepare(
    "SELECT role, content FROM conversations WHERE phone = ? ORDER BY created_at DESC LIMIT ?"
  );
  return stmt.all(phone, limit).reverse();
}
```

### Snippet 7: Pipeline completo agente — mensaje entrante a respuesta
```typescript
async function generateLLMResponse(phone: string, userMessage: string): Promise<string> {
  // 1. Guardar mensaje del usuario
  saveMessage(phone, "user", userMessage);

  // 2. Obtener historial
  const history = getHistory(phone, 20);

  // 3. Convertir a formato OpenRouter
  const messages = history.map(h => ({
    role: h.role as "user" | "assistant",
    content: h.content,
  }));

  // 4. Consultar LLM
  try {
    const response = await queryLLM(messages);

    // 5. Guardar respuesta
    saveMessage(phone, "assistant", response);

    return response;
  } catch (error) {
    console.error("LLM error:", error);
    const fallback = "Lo siento, estoy teniendo problemas técnicos. Por favor, intenta de nuevo en un momento.";
    saveMessage(phone, "assistant", fallback);
    return fallback;
  }
}
```

### Snippet 8: Envío de mensajes interactivos (botones)
```typescript
async function sendInteractiveButtons(
  to: string,
  body: string,
  buttons: Array<{ id: string; title: string }>,
): Promise<boolean> {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;

  const payload = {
    messaging_product: "whatsapp",
    recipient_type: "individual",
    to,
    type: "interactive",
    interactive: {
      type: "button",
      body: { text: body },
      action: {
        buttons: buttons.slice(0, 3).map(b => ({
          type: "reply",
          reply: { id: b.id, title: b.title.slice(0, 20) },
        })),
      },
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  return response.ok;
}
```

### Snippet 9: Rate limiter con express
```typescript
import rateLimit from "express-rate-limit";

const limiter = rateLimit({
  windowMs: 60 * 1000,       // 1 minuto
  max: 60,                    // 60 peticiones por minuto
  message: { error: "Demasiadas solicitudes. Intenta de nuevo en un momento." },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use("/webhook", limiter);
```

### Snippet 10: Marcar mensaje como leído
```typescript
async function markAsRead(messageId: string): Promise<void> {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;

  await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      messaging_product: "whatsapp",
      status: "read",
      message_id: messageId,
    }),
  });
}
```

### Snippet 11: Envío de imágenes
```typescript
async function sendImage(
  to: string,
  imageUrl: string,
  caption?: string,
): Promise<boolean> {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;

  const payload: any = {
    messaging_product: "whatsapp",
    to,
    type: "image",
    image: { link: imageUrl },
  };

  if (caption) {
    payload.image.caption = caption;
  }

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  return response.ok;
}
```

### Snippet 12: Envío de documentos
```typescript
async function sendDocument(
  to: string,
  documentUrl: string,
  filename: string,
  caption?: string,
): Promise<boolean> {
  const url = `https://graph.facebook.com/v21.0/${process.env.WA_PHONE_NUMBER_ID}/messages`;

  const payload: any = {
    messaging_product: "whatsapp",
    to,
    type: "document",
    document: { link: documentUrl, filename },
  };

  if (caption) {
    payload.document.caption = caption;
  }

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.WA_ACCESS_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  return response.ok;
}
```

---

## ✅ Checks de validación

| # | Check | Descripción |
|---|-------|-------------|
| 1 | `webhook_verify` | GET /webhook implementa verificación de token |
| 2 | `body_raw` | POST /webhook usa `express.raw()` para validación de firma |
| 3 | `respond_200_first` | Se responde 200 a Meta antes de procesar el mensaje |
| 4 | `message_filter` | Payload filtra correctamente solo mensajes (no status, reactions) |
| 5 | `llm_integration` | OpenRouter API configurada con fallback y manejo de errores |
| 6 | `history_persistence` | Conversaciones guardadas en SQLite con indexación |
| 7 | `rate_limiting` | express-rate-limit configurado en /webhook |
| 8 | `retry_backoff` | Llamadas a API externa tienen retry con backoff exponencial |
| 9 | `env_vars` | Variables sensibles en .env, no hardcodeadas |
| 10 | `error_handling` | Bloques try/catch en toda función async con logging |
| 11 | `signature_validation` | Firma de Meta validada en producción |
| 12 | `template_messages` | Templates de mensaje registrados y aprobados en Meta |

---

## 📚 Referencias

- Meta Cloud API — WhatsApp Cloud API Documentation (developers.facebook.com)
- OpenRouter — API Reference (openrouter.ai/docs)
- Express.js — Routing y middleware (expressjs.com)
- Railway — Deploy Documentation (docs.railway.app)
- ngrok — Webhook Testing (ngrok.com/docs)
- TypeScript — Handbook (typescriptlang.org)
- better-sqlite3 — SQLite for Node.js (github.com/WiseLibs/better-sqlite3)
- Zod — Schema validation (zod.dev)
- WhatsApp Business API — Message Templates and Policy (developers.facebook.com)
- WhatsApp Cloud API — Rate Limits Overview (developers.facebook.com)

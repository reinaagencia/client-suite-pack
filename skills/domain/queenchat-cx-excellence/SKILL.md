# queenchat-cx-excellence

Marco completo de excelencia en servicio al cliente omnicanal, ventas conversacionales, y arquitectura de prompts para agentes IA de CX. Diseñado para escalar experiencias de cliente de alta calidad en canales digitales (WhatsApp, Instagram, chat web, email).

---

## 📋 Reglas de negocio (10+)

### 1. Principio fundamental: la clienta es lo primero
Cada interacción debe comenzar con la premisa de que la persona al otro lado tiene una necesidad real, un contexto único y expectativas de ser tratada con respeto y eficiencia. El agente IA debe:
- **Reconocer** la necesidad explícita e implícita
- **Validar** la emoción del cliente antes de resolver el problema
- **Resolver** en el menor número de intercambios posible
- **Confirmar** satisfacción antes de cerrar

### 2. Personalización obligatoria
Nunca usar respuestas genéricas. Cada mensaje debe:
- Usar el nombre del cliente (si se conoce)
- Referenciar la conversación anterior explícitamente
- Adaptar el tono al canal y contexto
- Recordar preferencias pasadas
- Evitar jerga técnica si el cliente no la usa

### 3. Tono de voz — Matriz de adaptación

| Canal | Tono base | Excepción |
|-------|-----------|-----------|
| WhatsApp | Cálido, cercano, coloquial | Quejas → formal respetuoso |
| Instagram DM | Energético, juvenil, breve | Consultas técnicas → claro preciso |
| Instagram comentario | Amable, público, NO ventas directas | Queja pública → "enviame DM" |
| Email | Profesional, estructurado | Relación larga → cercano |
| Chat web | Directo, útil, rápido | Alta complejidad → pausado |

### 4. Arquitectura de prompts para agentes IA de CX
Todo prompt de agente CX debe contener:

```
[ROL] — Quién es el agente
[CONTEXTO] — Información relevante del cliente y conversación
[INSTRUCCIONES] — Reglas específicas para esta interacción
[Tono] — Cómo debe sonar la respuesta
[LIMITACIONES] — Lo que NO debe hacer
[FORMATO] — Estructura esperada de la respuesta
[CIERRE] — Cómo finalizar educadamente
[ESCALAMIENTO] — Cuándo y cómo escalar a humano
```

**Ejemplo mínimo:**
```
Eres una asesora de ventas de una agencia de marketing digital.
Contexto: La clienta preguntó por el servicio de community management.
Debes explicar los planes disponibles, responder dudas y ofrecer agendar una llamada.
Tono: cálido, entusiasta pero profesional. Usa "tú" no "usted".
No des descuentos ni prometas resultados específicos.
Termina cada respuesta con una pregunta abierta.
Si la clienta menciona presupuesto ajustado, ofrece el plan básico sin presionar.
```

### 5. Manejo de objeciones — Método LARA

| Paso | Acción | Ejemplo |
|------|--------|---------|
| **L** — Listen | Escucha sin interrumpir, valida | "Entiendo tu preocupación..." |
| **A** — Acknowledge | Reconoce la emoción | "Es completamente válido sentir eso..." |
| **R** — Respond | Responde con datos/hechos | "Déjame contarte cómo..." |
| **A** — Ask | Pregunta si resolvió | "¿Esto responde tu pregunta?" |

**Objeciones comunes:**
| Objeción | Respuesta sugerida |
|----------|-------------------|
| "Está muy caro" | Enfatizar ROI, ofrecer plan escalonado |
| "No tengo tiempo" | Explicar automatización y ahorro de tiempo |
| "Ya trabajo con alguien" | Preguntar qué le gusta y ofrecer diferencia |
| "Lo pensaré" | Identificar objeción real, ofrecer demo |
| "No es prioridad" | Conectar con dolor o resultado concreto |

### 6. Escalamiento inteligente
El agente IA debe escalar a humano cuando:

| Situación | Indicador |
|-----------|-----------|
| Cliente solicita explícitamente | "Quiero hablar con un humano" |
| Alta emocionalidad negativa | Groserías reiteradas, frustración intensa |
| Queja legal o regulatoria | Menciona demanda, derechos, superintendencia |
| Límite de resolución autónoma | 3 intentos fallidos de resolver |
| Datos sensibles solicitados | Números de tarjeta, documentos personales |

**Protocolo de escalamiento:**
1. Validar la emoción: "Entiendo tu frustración"
2. Explicar por qué se escala: "Esto requiere atención especializada"
3. Capturar contexto: resumir el problema en 2-3 líneas
4. Transferir con calidez: "Te voy a conectar con una persona que podrá ayudarte"

### 7. Gestión de quejas — Protocolo HEART

| Paso | Acción |
|------|--------|
| **H** — Hear | Oír sin interrumpir, validar emoción |
| **E** — Empathize | Mostrar empatía genuina, disculpa si corresponde |
| **A** — Apologize | Disculpa institucional (no personal) |
| **R** — Resolve | Ofrecer solución con opciones |
| **T** — Thank | Agradecer el feedback y cerrar |

### 8. Métricas de CX — El trípode de medición

| Métrica | Qué mide | Cómo se calcula | Target |
|---------|----------|-----------------|--------|
| **CSAT** | Satisfacción puntual | "¿Qué tan satisfecho quedaste?" (1-5) | >4.2 |
| **NPS** | Lealtad / recomendación | "¿Recomendarías?" (0-10) → Promotores - Detractores | >50 |
| **CES** | Esfuerzo del cliente | "¿Qué tan fácil fue resolver?" (1-7) | <3 |

**Regla:** No optimizar una métrica en detrimento de las otras. CES (bajo esfuerzo) correlaciona con lealtad a largo plazo.

### 9. Velocidad vs calidad — Balance crítico

| Canal | Tiempo ideal primera respuesta | Tiempo ideal resolución |
|-------|-------------------------------|------------------------|
| WhatsApp | < 30 segundos | < 5 minutos |
| Instagram DM | < 1 minuto | < 10 minutos |
| Instagram comentario | < 5 minutos | Resuelto en DM |
| Chat web | < 10 segundos | < 3 minutos |
| Email | < 4 horas | < 24 horas |

**Regla:** La velocidad sin calidad genera frustración. Una respuesta rápida pero incorrecta daña más que una respuesta correcta que tome 30 segundos más.

### 10. Ventas conversacionales — Framework CONVERSA

| Fase | Acción | Objetivo |
|------|--------|----------|
| **C** — Conectar | Saludo personalizado, referenciar contexto | Rapport inicial |
| **O** — Observar | Preguntar necesidades, escuchar activamente | Descubrimiento |
| **N** — Narrar | Contar historia del producto/servicio | Generar deseo |
| **V** — Valorar | Mostrar beneficios específicos para su caso | Construir valor |
| **E** — Evaluar | Manejar objeciones, ofrecer pruebas | Cerrar dudas |
| **R** — Resolver | Presentar propuesta, opciones, próximo paso | Cierre |
| **S** — Sostener | Seguimiento post-venta, fidelización | Relación larga |
| **A** — Ampliar | Upsell / crosssell contextual | Crecimiento |

### 11. Reglas de ética CX

| Regla | Descripción |
|-------|-------------|
| No mentir | Nunca prometer algo que no se pueda cumplir |
| No presionar | El cliente tiene derecho a pensar, comparar, decir que no |
| No inventar | Si no se sabe la respuesta, decir "lo voy a verificar" |
| No transferir sin contexto | Cada escalamiento debe incluir historial completo |
| No juzgar | Toda necesidad del cliente es válida |
| No etiquetar | No clasificar al cliente como "difícil" o "pesado" |
| Datos seguros | No compartir información sensible sin autorización |
| Consentimiento explícito | Preguntar antes de enviar información adicional |

### 12. Respuestas automáticas — Cuándo sí y cuándo no

**Sí usar respuestas automáticas para:**
- Confirmación de recepción ("Hemos recibido tu mensaje")
- Información de horarios y ubicación
- Respuestas a FAQs predecibles
- Seguimiento post-compra (tracking, factura)
- Recordatorios de citas o pagos

**NO usar respuestas automáticas para:**
- Quejas o reclamos emocionales
- Negociación de precios
- Confirmación de cambios complejos
- Cuando el cliente ya mostró frustración
- Respuestas legales o contractuales

---

## 🧩 Snippets de código

### Snippet 1: Evaluador de sentimiento para CX
```python
from enum import StrEnum
from dataclasses import dataclass

class Sentimiento(StrEnum):
    MUY_POSITIVO = "muy_positivo"
    POSITIVO = "positivo"
    NEUTRAL = "neutral"
    NEGATIVO = "negativo"
    MUY_NEGATIVO = "muy_negativo"
    FRUSTACION = "frustracion"
    ENOJADO = "enojado"

@dataclass
class EvaluacionSentimiento:
    texto: str
    sentimiento: Sentimiento
    urgencia: int  # 1-5
    requiere_escalamiento: bool
    palabras_clave: list[str]

# Palabras clave por categoría
PALABRAS_CLAVE: dict[Sentimiento, list[str]] = {
    Sentimiento.MUY_POSITIVO: ["excelente", "increíble", "maravilloso", "encantado", "feliz"],
    Sentimiento.POSITIVO: ["gracias", "bueno", "me gusta", "funciona", "perfecto"],
    Sentimiento.NEGATIVO: ["malo", "no funciona", "lento", "caro", "confuso"],
    Sentimiento.MUY_NEGATIVO: ["pésimo", "horrible", "terrible", "fatal", "decepcionante"],
    Sentimiento.FRUSTRACION: ["llevo", "ya te dije", "otra vez", "nadie responde"],
    Sentimiento.ENOJADO: ["queja formal", "demanda", "abogado", "incompetente", "estafa"],
}

def evaluar_sentimiento(texto: str) -> EvaluacionSentimiento:
    """Analiza el sentimiento del mensaje del cliente."""
    texto_lower = texto.lower()
    encontradas: list[str] = []
    sentimiento_max = Sentimiento.NEUTRAL
    urgencia = 1

    orden = [
        Sentimiento.MUY_POSITIVO, Sentimiento.POSITIVO, Sentimiento.NEUTRAL,
        Sentimiento.NEGATIVO, Sentimiento.MUY_NEGATIVO,
        Sentimiento.FRUSTRACION, Sentimiento.ENOJADO,
    ]

    for sent in orden:
        for palabra in PALABRAS_CLAVE.get(sent, []):
            if palabra in texto_lower:
                encontradas.append(palabra)
                if orden.index(sent) > orden.index(sentimiento_max):
                    sentimiento_max = sent

    # Asignar urgencia
    mapa_urgencia = {
        Sentimiento.NEUTRAL: 1,
        Sentimiento.POSITIVO: 1,
        Sentimiento.MUY_POSITIVO: 1,
        Sentimiento.NEGATIVO: 2,
        Sentimiento.MUY_NEGATIVO: 3,
        Sentimiento.FRUSTRACION: 4,
        Sentimiento.ENOJADO: 5,
    }
    urgencia = mapa_urgencia.get(sentimiento_max, 1)
    requiere_escalamiento = urgencia >= 4

    return EvaluacionSentimiento(
        texto=texto,
        sentimiento=sentimiento_max,
        urgencia=urgencia,
        requiere_escalamiento=requiere_escalamiento,
        palabras_clave=encontradas,
    )
```

### Snippet 2: Gestión de métricas CX
```python
from dataclasses import dataclass
from statistics import mean

@dataclass
class EncuestaCX:
    csat: int | None     # 1-5
    nps: int | None      # 0-10
    ces: int | None      # 1-7
    resolvio: bool | None
    comentario: str = ""

@dataclass
class MetricasCX:
    encuestas: list[EncuestaCX]

    def csat_promedio(self) -> float:
        valores = [e.csat for e in self.encuestas if e.csat is not None]
        return round(mean(valores), 2) if valores else 0.0

    def nps_score(self) -> int:
        """Calcula Net Promoter Score (-100 a +100)."""
        valores = [e.nps for e in self.encuestas if e.nps is not None]
        if not valores:
            return 0
        promotores = sum(1 for v in valores if v >= 9)
        detractores = sum(1 for v in valores if v <= 6)
        total = len(valores)
        return round(((promotores - detractores) / total) * 100)

    def ces_promedio(self) -> float:
        valores = [e.ces for e in self.encuestas if e.ces is not None]
        return round(mean(valores), 2) if valores else 0.0

    def tasa_resolucion(self) -> float:
        """Porcentaje de casos resueltos en primer contacto."""
        respondidas = [e for e in self.encuestas if e.resolvio is not None]
        if not respondidas:
            return 0.0
        return round(
            sum(1 for e in respondidas if e.resolvio) / len(respondidas) * 100, 1
        )

    def resumen(self) -> dict:
        return {
            "csat": self.csat_promedio(),
            "nps": self.nps_score(),
            "ces": self.ces_promedio(),
            "tasa_resolucion": self.tasa_resolucion(),
            "total_encuestas": len(self.encuestas),
        }
```

### Snippet 3: Template de prompt para agente CX
```python
PROMPT_CX_TEMPLATE = """## Rol
Eres {nombre_agente}, asesor{genero} de {marca}. Tu personalidad es {personalidad}.

## Contexto de la conversación
- Cliente: {nombre_cliente}
- Historial: {historial}
- Último mensaje: {ultimo_mensaje}
- Sentimiento detectado: {sentimiento}
- Canal: {canal}

## Instrucciones
{instrucciones}

## Tono
{tono}

## Reglas
1. Saluda solo la primera vez, no en cada mensaje
2. Usa el nombre del cliente al menos una vez
3. Responde en máximo 3 párrafos (mensajes de texto)
4. Termina con una pregunta abierta o llamado a la acción
5. Si no sabes algo, dilo honestamente: "Déjame verificar eso por ti"
6. {reglas_adicionales}

## Limitaciones
- No inventes precios, promociones ni políticas
- No compartas datos de otros clientes
- No hagas promesas que no puedas cumplir
- {limitaciones}

## Escalamiento
Escalar a humano si: {condiciones_escalamiento}

## Formato de respuesta
Mantén el formato natural del canal. En WhatsApp usa emojis con moderación.
En Instagram no uses formato markdown. Sé conversacional pero profesional.
"""

def generar_prompt(**kwargs) -> str:
    """Genera un prompt completo para agente CX con valores por defecto."""
    defaults = {
        "nombre_agente": "Asesora Virtual",
        "genero": "a",
        "marca": "la empresa",
        "personalidad": "cálida, paciente, resolutiva",
        "nombre_cliente": "cliente",
        "historial": "sin historial previo",
        "ultimo_mensaje": "—",
        "sentimiento": "neutral",
        "canal": "WhatsApp",
        "instrucciones": "Responde amablemente y resuelve la consulta.",
        "tono": "Profesional pero cercano. Usa 'tú'.",
        "reglas_adicionales": "",
        "limitaciones": "",
        "condiciones_escalamiento": "el cliente lo solicita, frustración alta, queja legal",
    }
    params = {**defaults, **kwargs}
    return PROMPT_CX_TEMPLATE.format(**params)
```

### Snippet 4: Clasificador de intención
```python
from enum import StrEnum

class Intencion(StrEnum):
    SALUDO = "saludo"
    CONSULTA_PRODUCTO = "consulta_producto"
    CONSULTA_PRECIO = "consulta_precio"
    QUEJA = "queja"
    RECLAMO = "reclamo"
    SOLICITUD_INFO = "solicitud_info"
    COMPRA = "compra"
    POST_VENTA = "post_venta"
    CANCELACION = "cancelacion"
    SOPORTE_TECNICO = "soporte_tecnico"
    OTRO = "otro"

PATRONES_INTENCION: dict[Intencion, list[str]] = {
    Intencion.SALUDO: ["hola", "buenos días", "buenas tardes", "hey", "qué tal"],
    Intencion.CONSULTA_PRODUCTO: ["qué es", "cómo funciona", "me interesa", "quiero saber"],
    Intencion.CONSULTA_PRECIO: ["cuánto", "precio", "costo", "tarifa", "valor", "cuesta"],
    Intencion.QUEJA: ["queja", "mal servicio", "insatisfecho", "decepcionado"],
    Intencion.RECLAMO: ["reclamo", "devolución", "reembolso", "garantía", "falla"],
    Intencion.SOLICITUD_INFO: ["información", "info", "detalles", "requisitos", "documentos"],
    Intencion.COMPRA: ["comprar", "adquirir", "contratar", "suscribirme", "orden"],
    Intencion.POST_VENTA: ["factura", "recibo", "seguimiento", "estado del pedido"],
    Intencion.CANCELACION: ["cancelar", "terminar", "dar de baja", "suspender"],
    Intencion.SOPORTE_TECNICO: ["no funciona", "error", "falla técnica", "bug", "problema técnico"],
}

def clasificar_intencion(mensaje: str) -> tuple[Intencion, float]:
    """Clasifica la intención del mensaje con nivel de confianza."""
    texto = mensaje.lower()
    mejor_intencion = Intencion.OTRO
    max_puntaje = 0

    for intencion, patrones in PATRONES_INTENCION.items():
        puntaje = sum(2 if p in texto else 0 for p in patrones)
        if puntaje > max_puntaje:
            max_puntaje = puntaje
            mejor_intencion = intencion

    confianza = min(max_puntaje / 4, 1.0)  # normalizado
    return mejor_intencion, confianza
```

### Snippet 5: Matriz de escalamiento
```python
@dataclass
class ReglaEscalamiento:
    condicion: str
    prioridad: int    # 1 (más baja) a 5 (crítica)
    equipo: str       # equipo humano destino

REGLAS_ESCALAMIENTO: list[ReglaEscalamiento] = [
    ReglaEscalamiento("cliente solicita humano explícitamente", 4, "servicio_cliente"),
    ReglaEscalamiento("lenguaje ofensivo o groserías reiteradas", 3, "calidad"),
    ReglaEscalamiento("menciona: demanda, abogado, superintendencia", 5, "legal"),
    ReglaEscalamiento("3 intentos fallidos de resolución autónoma", 4, "servicio_cliente"),
    ReglaEscalamiento("solicita datos de tarjeta de crédito", 5, "seguridad"),
    ReglaEscalamiento("problema técnico no identificado", 2, "soporte_tecnico"),
    ReglaEscalamiento("solicita cambio de plan o cancelación", 3, "ventas"),
]

def evaluar_escalamiento(
    mensaje: str,
    historial: list[str],
    intentos_fallidos: int = 0,
) -> list[dict]:
    """Evalúa si una conversación requiere escalamiento según reglas."""
    texto = mensaje.lower()
    activadas = []

    for regla in REGLAS_ESCALAMIENTO:
        if regla.condicion.startswith(("cliente solicita", "menciona")):
            # Buscar palabras clave en el mensaje
            palabras = regla.condicion.split(":")[-1].strip().split(", ")
            if any(p in texto for p in palabras):
                activadas.append({
                    "regla": regla.condicion,
                    "prioridad": regla.prioridad,
                    "equipo": regla.equipo,
                })
        elif regla.condicion.startswith("3 intentos") and intentos_fallidos >= 3:
            activadas.append({
                "regla": regla.condicion,
                "prioridad": regla.prioridad,
                "equipo": regla.equipo,
            })

    return sorted(activadas, key=lambda x: x["prioridad"], reverse=True)
```

### Snippet 6: Respuesta CONVERSA para ventas
```python
from dataclasses import dataclass, field

@dataclass
class ClienteVenta:
    nombre: str
    necesidad: str
    objeciones: list[str] = field(default_factory=list)
    etapa: str = "conectar"  # conectar, observar, narrar, valorar, evaluar, resolver, sostener

@dataclass
class GuionVenta:
    conectar: str
    observar: list[str]
    narrar: str
    valorar: list[str]
    manejo_objeciones: dict[str, str]
    resolver: str
    sostener: str

def construir_respuesta_venta(cliente: ClienteVenta, guion: GuionVenta) -> str:
    """Construye la respuesta de venta según la etapa del cliente."""
    if cliente.etapa == "conectar":
        return f"¡{cliente.nombre}! {guion.conectar} ¿Cómo puedo ayudarte hoy?"
    elif cliente.etapa == "observar":
        preguntas = " ".join(f"¿{p}?" for p in guion.observar)
        return f"Cuéntame más: {preguntas}"
    elif cliente.etapa == "narrar" and cliente.necesidad:
        return f"Justo por tu consulta sobre {cliente.necesidad}: {guion.narrar}"
    elif cliente.etapa == "evaluar" and cliente.objeciones:
        for obj in cliente.objeciones:
            if obj in guion.manejo_objeciones:
                return guion.manejo_objeciones[obj]
        return "Entiendo tu punto. ¿Te parece si vemos los beneficios concretos?"
    elif cliente.etapa == "resolver":
        return guion.resolver
    return "Cuéntame más sobre lo que necesitas para poder ayudarte mejor."
```

---

## ✅ Checks de validación

| # | Check | Descripción |
|---|-------|-------------|
| 1 | `prompt_completo` | Todo prompt CX tiene ROL, CONTEXTO, INSTRUCCIONES, TONO, LIMITACIONES |
| 2 | `personalizacion_aplicada` | La respuesta usa nombre del cliente o referencia al historial |
| 3 | `tono_adaptado_al_canal` | El tono coincide con la matriz de canales |
| 4 | `objecion_manejada` | Toda objeción identificada tiene respuesta LARA |
| 5 | `escalamiento_evaluado` | Se verificaron condiciones de escalamiento antes de cada respuesta |
| 6 | `emocion_validada` | Se reconoce y valida la emoción del cliente |
| 7 | `no_promesas_falsas` | No se inventan precios, plazos ni políticas |
| 8 | `cierre_con_pregunta` | Toda respuesta termina con pregunta abierta o CTA |
| 9 | `metrica_asociada` | Cada interacción es medible por CSAT, NPS o CES |
| 10 | `resolucion_eficiente` | No supera el número de intercambios ideales por canal |
| 11 | `confidencialidad_respetada` | No se comparten datos sensibles sin autorización |
| 12 | `post_venta_planificado` | Toda venta tiene seguimiento post-cierre definido |

---

## 📚 Referencias

- ISO 9001:2015 — Sistemas de gestión de calidad
- ISO 22458:2022 — Inclusive service design and delivery
- Medallia / Qualtrics — Best practices for CX measurement
- Bain & Company — NPS system and loyalty economics
- Gartner — Customer effort score research
- Harvard Business Review — "The One Number You Need to Grow" (Reichheld, 2003)
- Zendesk — CX Trends Report (anual)
- Salesforce — State of the Connected Customer Report
- McColl-Kennedy et al. (2015) — "Customer Experience Management"
- Meyer & Schwager (2007) — "Understanding Customer Experience" HBR

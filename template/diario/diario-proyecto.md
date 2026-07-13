# 📓 Diario de Construcción — {{PROJECT_NAME}}

> **Iniciado:** {{START_DATE}}
> **Propósito:** {{PROJECT_PURPOSE}}

---

## 🌱 Sesión 1 — Instalación de la Suite

### Fecha: {{INSTALL_DATE}

### Logros
- Suite de agentes instalada con `builder.sh`
- {{AGENT_COUNT}} agentes configurados en `~/.config/opencode/agent/`
- {{SKILL_COUNT}} skills instaladas en `~/.agents/skills/`
- Sistema de memoria multi-sesión inicializado

### Configuración aplicada
- **Orquestador:** `{{ORQUESTADOR}}`
- **Modelo default:** `{{DEFAULT_MODEL}}`
- **Modelo premium:** `{{PRO_MODEL}}`
- **Workspace:** `{{WORKSPACE_PATH}}`

### Pendientes
- [ ] Configurar API key de OpenCode
- [ ] Configurar MCP servers (Playwright, etc.)
- [ ] Configurar cuentas de servicio
- [ ] Primer proyecto de prueba

---

## 📝 Cómo registrar avances

Cada vez que trabajes con la suite:

1. **Al empezar**: Abre este diario y crea una nueva entrada con la fecha
2. **Durante la sesión**: El orquestador guarda automáticamente el progreso en `~/.agents/memoria-sessions/`
3. **Al terminar**: Haz commit de los cambios si trabajaste en código
4. **Después del commit**: El orquestador te preguntará si quieres registrar el avance aquí

### Formato de entrada

```
## Sesión {N} — {Fecha}

### Commit: {hash} — {mensaje}

### Qué se hizo
- {acción 1}
- {acción 2}

### Estado actual
{breve descripción}

### Próximos pasos
- [ ] {siguiente tarea}
```

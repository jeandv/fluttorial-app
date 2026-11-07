# 15 · IA y agentes en apps móviles

> Anterior: [14 · Pagos](14-pagos.md) · Volver al [índice](../README.md)

Cómo integrar modelos de IA generativa (aquí, **Claude** de Anthropic) en una app Flutter: generar consejos, documentos e imágenes, y construir **agentes** que usan las funciones de tu app para cumplir lo que pide el usuario.

> 📱 **En la app:** *Ejemplos → Apps reales → Estudio IA* y *Agente IA*. Sin configurar nada funcionan en **modo demo** (respuestas de ejemplo). La §2 explica cómo activar la IA real.

---

## 1. Conceptos en 2 minutos

| Concepto | Qué es |
|---|---|
| **LLM** (modelo de lenguaje) | Recibe texto (y opcionalmente imágenes o documentos) y genera texto. Claude, GPT y Gemini son LLM. |
| **Prompt** | Lo que le envías. Se divide en **system** (quién es y cómo debe responder) y **messages** (la conversación). |
| **Tokens** | Unidades de texto (~¾ de palabra). Se paga por tokens de entrada y de salida. |
| **Streaming** | Recibir la respuesta poco a poco, mientras se genera (texto que "se escribe solo"). |
| **Herramientas (tools)** | Funciones de TU app que el modelo puede pedir usar. El modelo no las ejecuta: te pide que lo hagas y le das el resultado. |
| **Agente** | Un modelo con herramientas en un **bucle**: decide, usa herramientas, observa el resultado y repite hasta terminar. |
| **Effort / thinking** | Cuánto razona el modelo antes de responder. Más esfuerzo → mejores respuestas en tareas difíciles, pero más lento y caro. |

---

## 2. Configuración y seguridad ⚠️

### La regla de oro
> **Nunca publiques una app con la API key dentro.** Cualquiera puede extraerla del archivo de la app y gastar tu saldo.

| Forma | Cómo | Cuándo |
|---|---|---|
| **Proxy propio** ✅ | La app llama a TU servidor; el servidor añade la key y llama a Anthropic. Ahí también controlas límites por usuario, autenticación y costes. | **Producción** |
| **Key en la app** ⚠️ | `--dart-define` con la key | **Solo para aprender en tu ordenador** |

Ambas están soportadas: [Env.aiProxyUrl](../lib/core/config/env.dart#L67 "→ static const aiProxyUrl") y [Env.anthropicApiKey](../lib/core/config/env.dart#L70 "→ static const anthropicApiKey").

### Activar la IA real en tu ordenador (aprendizaje)
1. Crea una cuenta en [platform.claude.com](https://platform.claude.com), añade saldo y crea una **API key**.
2. Copia la plantilla (el archivo `config/secrets.json` está en `.gitignore`, **nunca** se sube a git):
   ```bash
   cp config/secrets.example.json config/secrets.json
   ```
3. Pega tu key en `config/secrets.json` y ejecuta:
   ```bash
   flutter run --dart-define-from-file=config/secrets.json
   ```
4. El aviso "MODO DEMO" desaparece y las respuestas vienen de Claude.

### Proxy mínimo (idea)
Tu servidor recibe la petición de la app, comprueba que el usuario ha iniciado sesión y su límite de uso, y la reenvía a `https://api.anthropic.com/v1/messages` añadiendo la cabecera `x-api-key` con la key guardada en el servidor. Con `AI_PROXY_URL` configurada, el [ClaudeClient](../lib/features/ai/claude_client.dart#L63 "→ class ClaudeClient") no envía ninguna key.

---

## 3. El cliente de la API

📄 [claude_client.dart](../lib/features/ai/claude_client.dart)

Dart **no tiene SDK oficial** de Anthropic, así que se llama a la API REST con el paquete `http`. Existe [`anthropic_sdk_dart`](https://pub.dev/packages/anthropic_sdk_dart) de la comunidad, pero hacerlo a mano enseña cómo funciona.

| Detalle | Código |
|---|---|
| Endpoint `POST /v1/messages` | [_endpoint](../lib/features/ai/claude_client.dart#L83 "→ Uri get _endpoint") |
| Cabeceras: `x-api-key`, `anthropic-version: 2026-10-21` | [_headers](../lib/features/ai/claude_client.dart#L85 "→ Map<String, String> get _headers") |
| Modelo `claude-opus-5-5` | [defaultModel](../lib/features/ai/claude_client.dart#L73 "→ static const defaultModel") |
| `output_config.effort` (low/medium/high…) | [buildBody](../lib/features/ai/claude_client.dart#L107 "→ 'output_config': {'effort': effort}") |
| `fallbacks: "default"`: si el modelo rechaza la petición por seguridad, Anthropic la reintenta con el modelo adecuado | [fallbacks](../lib/features/ai/claude_client.dart#L106 "→ 'fallbacks': 'default'") |
| Comprobar `stop_reason == "refusal"` **antes** de leer el contenido | [refusal](../lib/features/ai/claude_client.dart#L149 "→ if (json['stop_reason'] == 'refusal')") |
| Streaming con Server-Sent Events (solo `text_delta`) | [streamText](../lib/features/ai/claude_client.dart#L160 "→ Stream<String> streamText") |
| Ignorar los bloques de razonamiento (`thinking`) al mostrar texto | [textOf](../lib/features/ai/claude_client.dart#L214 "→ static String textOf") |
| Errores HTTP comprensibles (401, 429, 529…) | [_httpError](../lib/features/ai/claude_client.dart#L221 "→ ClaudeException _httpError") |
| Timeout | [timeout](../lib/features/ai/claude_client.dart#L138 "→ .timeout(const Duration(minutes: 3))") |

Petición equivalente con `curl`, útil para probar tu key:
```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2026-10-21" \
  -d '{"model":"claude-opus-5-5","max_tokens":1024,"messages":[{"role":"user","content":"Hola"}]}'
```

---

## 4. Casos de uso del Estudio IA

📄 [ai_service.dart](../lib/features/ai/ai_service.dart) · [ai_studio_screen.dart](../lib/features/ai/ai_studio_screen.dart)

### Arquitectura
```
AiStudioScreen ──> AiService (interfaz)
                     ├── ClaudeAiService ──> ClaudeClient ──> API (o tu proxy)
                     └── DemoAiService   (sin red: demo y tests)
```
[aiServiceProvider](../lib/features/ai/ai_service.dart#L228 "→ final aiServiceProvider") elige uno según la configuración. La UI no sabe cuál usa.

### 4.1 Consejos (texto en streaming)
| Concepto | Código |
|---|---|
| Prompt con `system` (rol) y formato pedido (lista Markdown) | [tips](../lib/features/ai/ai_service.dart#L85 "→ static const _mentor") |
| `effort: 'low'` para respuestas rápidas | [effort low](../lib/features/ai/ai_service.dart#L94 "→ effort: 'low'") |
| Consumir el stream y acumular texto con `setState` | [startStream](../lib/features/ai/ai_studio_screen.dart#L101 "→ void startStream") |
| Cancelar la suscripción en `dispose` y con "Detener" | [dispose](../lib/features/ai/ai_studio_screen.dart#L102 "→ _sub?.cancel("); // ⚠️) |
| Renderizar Markdown (`flutter_markdown_plus`) | [MarkdownBody](../lib/features/ai/ai_studio_screen.dart#L149 "→ MarkdownBody(data: output") |
| Reutilizar la lógica con un **mixin** | [_StreamingText](../lib/features/ai/ai_studio_screen.dart#L95 "→ mixin _StreamingText") |

### 4.2 Documentos
Tipos predefinidos con instrucciones específicas: descripción para la tienda, notas de versión, política de privacidad (marcada como borrador legal), README y email de soporte → [DocKind](../lib/features/ai/ai_service.dart#L26 "→ enum DocKind"). Se pueden **copiar** y **compartir** (`share_plus`).

### 4.3 Imágenes
- Claude genera **SVG** (gráficos vectoriales en forma de código): ideal para iconos, ilustraciones planas y diagramas. Se dibuja con [`flutter_svg`](https://pub.dev/packages/flutter_svg) → [SvgPicture.string](../lib/features/ai/ai_studio_screen.dart#L381 "→ SvgPicture.string(") .
- El modelo a veces envuelve el SVG en un bloque de código Markdown: [extractSvg](../lib/features/ai/ai_service.dart#L148 "→ String extractSvg") lo saca.
- **Fotos o imágenes realistas** requieren un **modelo de imagen**, por ejemplo **Imagen** de Google (vía [`firebase_ai`](https://pub.dev/packages/firebase_ai), con Firebase como proxy seguro) u **OpenAI GPT Image**. Se integran igual: añade un método a `AiService` y una implementación que llame a ese servicio desde tu backend.

---

## 5. Agentes

📄 [todo_agent.dart](../lib/features/ai/todo_agent.dart) · [agent_screen.dart](../lib/features/ai/agent_screen.dart)

El agente gestiona **tu lista real de Tareas**. Prueba "Añade comprar leche y llamar a mamá" y luego abre la pestaña Tareas.

### El bucle
```
usuario: "Añade comprar leche"
   │
   ▼
┌─► API (conversación + herramientas)
│      stop_reason = "tool_use" → [tool_use add_todo {title: "Comprar leche"}]
│   la APP ejecuta add_todo → "Tarea creada"
│   se envía [tool_result con el mismo id]
└── se repite hasta stop_reason = "end_turn" → "¡Listo! Añadí…"
```

| Paso | Código |
|---|---|
| Definir herramientas con JSON Schema (`strict: true`) | [definitions](../lib/features/ai/todo_agent.dart#L82 "→ static const definitions") |
| Descripciones que dicen **cuándo** usarlas | [list_todos](../lib/features/ai/todo_agent.dart#L84 "→ 'name': 'list_todos'") |
| Ejecutar la herramienta en la app | [execute](../lib/features/ai/todo_agent.dart#L146 "→ (String, bool") execute) |
| El bucle con límite de pasos | [send](../lib/features/ai/todo_agent.dart#L221 "→ final checkpoint = _messages.length") |
| Guardar la respuesta del asistente **sin modificar** (incluye bloques de razonamiento) | [assistant](../lib/features/ai/todo_agent.dart#L237 "→ _messages.add({'role': 'assistant', 'content': content})") |
| Todos los `tool_result` en **un solo** mensaje, con su `tool_use_id` | [results](../lib/features/ai/todo_agent.dart#L265 "→ _messages.add({'role': 'user', 'content': results})") |
| Errores de herramienta con `is_error: true` | [is_error](../lib/features/ai/todo_agent.dart#L260 "→ 'is_error': true") |
| Deshacer el turno si la API falla | [rollback](../lib/features/ai/todo_agent.dart#L273 "→ _messages.removeRange(checkpoint") |
| Conectar con Riverpod (inyectar funciones) | [todoAgentProvider](../lib/features/ai/agent_screen.dart#L28 "→ final todoAgentProvider") |
| Mostrar cada herramienta usada en el chat | [_ChatBubble](../lib/features/ai/agent_screen.dart#L233 "→ class _ChatBubble") |

### Reglas de seguridad para agentes
- **Mínimo privilegio:** solo las herramientas necesarias. Aquí **no hay "borrar tarea"** a propósito.
- **Confirmación humana** antes de acciones destructivas o irreversibles (borrar, pagar, enviar mensajes): muestra un diálogo y devuelve "el usuario lo rechazó" si no confirma.
- **Valida las entradas** de las herramientas como si vinieran de un usuario desconocido.
- **Limita los pasos** (aquí, 8) y el gasto.
- El texto que lee el agente (webs, emails, documentos) puede contener **instrucciones maliciosas** (*prompt injection*): trátalo como datos, nunca como órdenes.

---

## 6. Más ideas de IA para apps

| Idea | Cómo |
|---|---|
| Chat de soporte | Streaming + historial + `system` con la información de tu producto |
| Resumir o preguntar sobre un PDF | Enviar el PDF como bloque `document` (base64) en el mensaje |
| Entender una foto (OCR, describir, clasificar) | Enviar la imagen (`image_picker`) como bloque `image` |
| Extraer datos estructurados (de un ticket, un email…) | Salidas estructuradas (`output_config.format` con un JSON Schema) |
| Moderación de contenido | Prompt de clasificación con `effort: low` |
| Búsqueda en tus datos (RAG) | Busca en tu base de datos y pasa los resultados en el prompt |
| Asistente por voz | Voz → texto (`speech_to_text`) → Claude → texto → voz (`flutter_tts`) |

---

## 7. Costes y buenas prácticas

- Precio orientativo de `claude-opus-5-5`: 4 $ por millón de tokens de entrada y 20 $ por millón de salida (precios en [platform.claude.com](https://platform.claude.com)). Un consejo corto cuesta fracciones de céntimo, pero **multiplícalo por tus usuarios**.
- **Effort** bajo para tareas simples y más alto solo donde mejora el resultado.
- **Prompt caching** si repites un `system` largo (abarata y acelera).
- **Límites por usuario** en tu proxy (por ejemplo, 20 peticiones al día en el plan gratuito y sin límite en el Pro: ¡combínalo con el paywall de docs/14!).
- **Streaming** en todo lo que el usuario lee: la espera percibida es mucho menor.
- **Revisa** lo que genera la IA antes de publicarlo (textos legales, médicos o financieros).
- Informa al usuario de que el contenido lo genera una IA y cumple las políticas de las tiendas sobre IA generativa (mecanismo para reportar contenido inapropiado).

---

## 8. Paquetes relacionados (pub.dev, 7/11/2026)

| Paquete | Descargas/30 días | Para qué | En este proyecto |
|---|---:|---|---|
| `http` | 14,8 M | Llamar a la API REST | ✅ |
| [`flutter_svg`](https://pub.dev/packages/flutter_svg) | 6,2 M | Dibujar las ilustraciones SVG | ✅ |
| [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus) | 915 K | Mostrar respuestas en Markdown (sucesor del descontinuado `flutter_markdown`) | ✅ |
| [`firebase_ai`](https://pub.dev/packages/firebase_ai) | 118 K | Gemini e Imagen con Firebase como proxy | — |
| [`anthropic_sdk_dart`](https://pub.dev/packages/anthropic_sdk_dart) | 28 K | Cliente de Claude de la comunidad (no oficial) | — |
| [`flutter_ai_toolkit`](https://pub.dev/packages/flutter_ai_toolkit) | 13 K | Widgets de chat ya hechos | — |

---

## 9. Tests

- [claude_client_test.dart](../test/features/ai/claude_client_test.dart): cabeceras y cuerpo enviados, proxy sin key, `refusal`, error 401, streaming SSE y extracción de SVG, todo con `MockClient` (sin gastar saldo).
- [todo_agent_test.dart](../test/features/ai/todo_agent_test.dart): el bucle completo (`tool_use` → ejecutar → `tool_result` → respuesta), que el contenido del asistente se reenvía intacto y que un error deshace el turno.

📚 Documentación oficial: [docs de la API de Claude](https://platform.claude.com/docs) · [uso de herramientas](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview).

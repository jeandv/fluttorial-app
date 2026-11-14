# 00 · Ruta de aprendizaje

> Volver al [índice](../README.md) · Empieza por: [01 · Entorno e instalación](01-entorno-e-instalacion.md)

---

Esta guía tiene **17 documentos**, pero no hace falta leerlos todos ni en el orden del índice. Esta página te dice **por dónde empezar, en qué orden seguir y cuáles abrir solo cuando los necesites**.

## 🧭 Cómo usar esta guía

1. **Sigue la ruta de abajo, de arriba hacia abajo.** Cada documento tiene al principio qué aprenderás y qué necesitas antes, y al final unas preguntas para comprobar que lo entendiste.
2. **Ejecuta la app mientras lees.** Cada concepto enlaza a la demo y al código real: ábrelos, cambia algo y mira qué pasa.
3. **Haz el reto del final.** Aprender Flutter es sobre todo escribir Flutter. Algunos retos traen un test que empieza en rojo: tu trabajo es ponerlo en verde (ver [`exercises/`](../exercises/README.md)).
4. **Los documentos de consulta no se leen de corrido.** Ábrelos cuando tengas el problema concreto.

## 🛤️ La ruta, paso a paso

| Etapa | Documento | Qué te llevas | Tiempo aprox. |
|---|---|---|---|
| 🧰 **1. Preparar** | [01 · Entorno e instalación](01-entorno-e-instalacion.md) | Un entorno que pasa `flutter doctor` | 30 min |
| | [02 · Estructura del proyecto](02-estructura-del-proyecto.md) | Sabes qué es cada carpeta y qué no tocar | 20 min |
| | [04 · Ejecutar y simular](04-ejecutar-y-simular.md) | La app corre en un simulador y usas hot reload | 30 min |
| 🎯 **2. El lenguaje** | [05 · Dart esencial](05-dart-esencial.md) | Lees y escribes Dart con null safety, `async` y records | 1–2 h |
| 🧱 **3. Construir** | [06 · Construir la app](06-construir-la-app.md) | Widgets, layout, navegación y estado (con lecciones de go_router y Riverpod) | 2–3 h |
| | [16 · Cómo piensa Flutter](16-como-piensa-flutter.md) | Modelos mentales: árboles, constraints, rebuilds, keys, event loop | 1 h |
| 🔍 **4. Ver todo en acción** | [10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md) | Cada demo explicada, con enlace a su código | 1–2 h |
| ✅ **5. Calidad** | [07 · Pruebas y calidad](07-pruebas-y-calidad.md) | Pruebas unitarias, de widget e integración | 1 h |
| 🧠 **6. Profundizar** | [11 · Configuraciones avanzadas](11-configuraciones-avanzadas.md) | Arquitectura, go_router, Riverpod, tema, i18n, entornos | 2 h |
| | [17 · Calidad de producción](17-calidad-de-produccion.md) | Accesibilidad, errores globales, rendimiento y golden tests | 1 h |
| 🚀 **7. Apps reales** | [13 · Onboarding](13-onboarding.md) | Un flujo de primer uso con router | 45 min |
| | [14 · Pagos](14-pagos.md) | Checkout, suscripciones y seguridad | 45 min |
| | [15 · IA y agentes](15-ia-y-agentes.md) | Claude por API, streaming y agentes con herramientas | 1 h |
| 📦 **8. Publicar** | [08 · Compilar y publicar](08-compilar-y-publicar.md) | Firma, AAB/IPA y envío a las tiendas | 1 h |

> 💡 **Si ya sabes programar** puedes saltarte lo básico de 05 y quedarte con lo específico de Dart (null safety, `async`, records). **Si nunca programaste**, no te saltes ninguna etapa y haz todos los retos.

## 📖 Documentos de consulta (no se leen en orden)

| Documento | Ábrelo cuando… |
|---|---|
| [03 · Comandos](03-comandos.md) | Necesitas recordar un comando (`flutter`, `xcrun simctl`, `adb`, `gradlew`) |
| [09 · Solución de problemas](09-solucion-de-problemas.md) | Algo falla al instalar, compilar o ejecutar |
| [12 · Librerías más usadas](12-librerias-mas-usadas.md) | Vas a elegir un paquete y quieres datos de pub.dev |

## 🏋️ Retos

| Doc | Reto | ¿Test? |
|---|---|---|
| 01 | Lee tu `flutter doctor` | — |
| 02 | El mapa de memoria | — |
| 04 | Hot reload vs hot restart | — |
| 05 | Cuenta tareas con un record | ✅ `e03` |
| 06 | Límite en el contador | ✅ `e01` |
| 16 | Mide los rebuilds | — |
| 10 | Tu propia demo | ✅ `e04` |
| 07 | Tus propios tests | — |
| 11 | Completar todas las tareas | ✅ `e02` |
| 17 | Hazla accesible | — |
| 13 | Indicador de onboarding | ✅ `e06` |
| 14 | Las tarjetas de prueba | — |
| 15 | Una herramienta nueva para el agente | ✅ `e05` |
| 08 | ¿Qué te falta para publicar? | — |

Los retos con test viven en la carpeta [`exercises/`](../exercises/README.md): empiezan en rojo y se ejecutan con `flutter test exercises/<archivo>_test.dart`. Cada uno tiene su solución aparte, para que no la veas antes de intentarlo.

## 🔁 Cómo estudiar con esta guía (sin leer de más)

- **Lee → ejecuta → cambia → rompe → arregla.** Si solo lees, olvidas; si cambias el código y lo rompes a propósito, entiendes.
- **Contesta las preguntas antes de abrir la respuesta.** Si fallas, vuelve a la sección: es la señal más barata de qué no entendiste.
- **Un documento por sesión** es un buen ritmo. No avances a la etapa siguiente sin haber hecho el reto de la actual.
- **Cuando algo falle, busca primero en [09](09-solucion-de-problemas.md)**, luego en la documentación oficial.

## ➡️ Siguiente paso

Empieza con **[01 · Entorno e instalación](01-entorno-e-instalacion.md)**.

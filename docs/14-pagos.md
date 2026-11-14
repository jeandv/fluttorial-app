# 14 · Pagos: interfaces e implementación

> Anterior: [13 · Onboarding](13-onboarding.md) · Volver al [índice](../README.md) · Siguiente: [15 · IA y agentes](15-ia-y-agentes.md)

> 🎯 **Aprenderás:** a decidir cómo cobrar según lo que vendes (compra integrada o pasarela), a leer la interfaz del checkout y del paywall de la app y a seguir el flujo seguro con Stripe.
> 📋 **Necesitas antes:** [11 · Configuraciones avanzadas](11-configuraciones-avanzadas.md) (Riverpod, entornos con `--dart-define`) y [13 · Onboarding](13-onboarding.md).
> ⏱️ **Tiempo:** ~15 min de lectura + ~10 min practicando

Cobrar dentro de una app tiene **reglas de las tiendas, de seguridad y de experiencia de usuario** que conviene conocer antes de escribir código. Este documento explica cuál usar en cada caso, cómo diseñar la interfaz y cómo implementarlo de verdad.

> 📱 **En la app:** *Ejemplos → Apps reales → Pago (checkout)* y *Suscripción (paywall)*. Están en **modo demo**: no se cobra nada y ningún dato sale del teléfono.

---

## 1. Primero, la regla más importante: ¿qué vendes?

| Lo que vendes | Cómo cobrarlo | Ejemplos | Comisión típica |
|---|---|---|---|
| **Contenido o funciones digitales usadas en la app** | **Obligatorio:** compra integrada de Apple / Google | Versión Pro, suscripciones, monedas de un juego, eliminar anuncios | 15-30 % para la tienda |
| **Bienes o servicios físicos / fuera de la app** | Pasarela de pago (Stripe, Mercado Pago, PayPal, Adyen…) | Tienda online, comida a domicilio, taxi, entradas, reservas | ~3 % + fija |
| **Donaciones a ONG, pagos entre personas** | Pasarela de pago | — | Según la pasarela |

⚠️ Si vendes contenido digital con Stripe en vez de la compra integrada, **Apple y Google rechazarán o retirarán tu app**. (Hay excepciones y cambios regulatorios por país, por ejemplo en la UE y EE. UU.; revisa las normas actuales de [App Store](https://developer.apple.com/app-store/review/guidelines/#payments) y [Google Play](https://support.google.com/googleplay/android-developer/answer/9858738).)

---

## 2. Demo: checkout (bienes físicos o servicios)

📄 [lib/features/payments/](../lib/features/payments/)

### Lo que enseña la interfaz
| Elemento | Por qué importa | Código |
|---|---|---|
| Resumen del pedido con subtotal, impuestos y total | Transparencia: nadie paga sin ver el total | [resumen](../lib/features/payments/checkout_screen.dart#L188 "→ _SummaryRow('Subtotal'") |
| Precios en **céntimos (enteros)** | `0.1 + 0.2 != 0.3` en coma flotante: nunca uses `double` para dinero | [CartItem](../lib/features/payments/checkout_screen.dart#L29 "→ class CartItem") · [PaymentRequest](../lib/features/payments/payment_gateway.dart#L70 "→ final int amountCents") |
| Formato de moneda según el idioma | `$1.234,56` o `$1,234.56` según el país | [_money](../lib/features/payments/checkout_screen.dart#L86 "→ String _money") |
| Selector de método (tarjeta / Apple Pay / Google Pay según plataforma) | Las billeteras convierten mucho más (sin teclear) | [SegmentedButton](../lib/features/payments/checkout_screen.dart#L198 "→ SegmentedButton<PaymentMethodType>") |
| Tarjeta visual que se rellena al escribir | Confianza y menos errores | [_CardPreview](../lib/features/payments/checkout_screen.dart#L402 "→ class _CardPreview") |
| Formateo automático al escribir | `4242424242424242` → `4242 4242 4242 4242` | [CardNumberInputFormatter](../lib/features/payments/card_utils.dart#L137 "→ class CardNumberInputFormatter") · [ExpiryInputFormatter](../lib/features/payments/card_utils.dart#L152 "→ class ExpiryInputFormatter") |
| Teclado numérico + autocompletado del sistema | Menos fricción (iOS/Android sugieren la tarjeta guardada) | [autofillHints](../lib/features/payments/checkout_screen.dart#L290 "→ AutofillHints.creditCardNumber") |
| Detección de marca y CVV de 3 o 4 dígitos | Amex usa 4 | [detectBrand](../lib/features/payments/card_utils.dart#L50 "→ CardBrand detectBrand") |
| Algoritmo de Luhn | Detecta errores de tecleo antes de enviar | [luhnValid](../lib/features/payments/card_utils.dart#L70 "→ bool luhnValid") |
| Caducidad válida hasta fin de mes | Error clásico: dar por caducada una tarjeta válida | [validateExpiry](../lib/features/payments/card_utils.dart#L114 "→ String? validateExpiry") |
| Botón desactivado y "Procesando…" | **Evita cobrar dos veces** por doble toque | [onPressed: _processing ? null](../lib/features/payments/checkout_screen.dart#L230 "→ onPressed: _processing ? null : _pay") |
| Resultado con `sealed class` | El compilador obliga a manejar éxito **y** error | [PaymentResult](../lib/features/payments/payment_gateway.dart#L78 "→ sealed class PaymentResult") · [switch](../lib/features/payments/checkout_screen.dart#L128 "→ switch (result)") |
| Recibo con animación + vibración | Confirmación clara del éxito | [_ReceiptScreen](../lib/features/payments/checkout_screen.dart#L514 "→ class _ReceiptScreen") |
| Errores comprensibles | "Fondos insuficientes", no "Error 402" | [FakePaymentGateway](../lib/features/payments/payment_gateway.dart#L107 "→ class FakePaymentGateway") |

### Tarjetas de prueba (las de Stripe en modo test)
| Número | Resultado |
|---|---|
| `4242 4242 4242 4242` | ✅ Aprobada |
| `4000 0000 0000 0002` | ❌ Rechazada |
| `4000 0000 0000 9995` | 💸 Fondos insuficientes |
| `4000 0000 0000 0069` | ⌛ Caducada |

Cualquier fecha futura y cualquier CVV. Los chips de la demo las rellenan por ti.

### Arquitectura: interfaz + implementación intercambiable
```dart
abstract interface class PaymentGateway {        // lo que la UI conoce
  Future<PaymentResult> pay(PaymentRequest request);
}
class FakePaymentGateway implements PaymentGateway { … }    // demo / tests
class StripePaymentGateway implements PaymentGateway { … }  // producción
```
Pasar a producción = cambiar el [paymentGatewayProvider](../lib/features/payments/payment_gateway.dart#L149 "→ final paymentGatewayProvider"). La pantalla no se toca.

---

## 3. Implementación real con Stripe

> 🔐 **Regla de oro (PCI-DSS):** el número de tarjeta **nunca** debe pasar por tu app ni por tu servidor en texto plano. Lo captura el SDK de la pasarela y viaja cifrado directamente a ella. En la demo hay un formulario propio solo para enseñar la interfaz; en producción usa el **PaymentSheet** de Stripe.

### Flujo
```
App                        Tu servidor                    Stripe
 │  POST /crear-pago {pedido}  │                              │
 │ ───────────────────────────>│  crea PaymentIntent (clave   │
 │                             │  SECRETA) ──────────────────>│
 │   {clientSecret}            │<──────────────────────────── │
 │ <───────────────────────────│                              │
 │  PaymentSheet (SDK) ─── tarjeta cifrada ─────────────────> │
 │                             │   webhook "payment_succeeded"│
 │                             │<──────────────────────────── │
 │                             │  marca el pedido como pagado │
```
El servidor calcula el **importe** (nunca te fíes del precio que envía la app) y confirma el pago por **webhook** antes de entregar nada.

### Pasos
```bash
flutter pub add flutter_stripe
```
1. Crea una cuenta en [stripe.com](https://stripe.com) y obtén las claves de **test** (`pk_test_…` publicable para la app, `sk_test_…` secreta solo para el servidor).
2. **Android:** `MainActivity` debe heredar de `FlutterFragmentActivity` y el tema de la app debe ser `Theme.AppCompat` o `Theme.MaterialComponents` (ver el README de `flutter_stripe`). **iOS:** versión mínima indicada en el README.
3. Inicializa en `main()`:
   ```dart
   Stripe.publishableKey = const String.fromEnvironment('STRIPE_PK');
   await Stripe.instance.applySettings();
   ```
4. Pagar:
   ```dart
   final clientSecret = await miApi.crearPago(pedidoId); // tu backend
   await Stripe.instance.initPaymentSheet(
     paymentSheetParameters: SetupPaymentSheetParameters(
       paymentIntentClientSecret: clientSecret,
       merchantDisplayName: 'Mi Tienda',
       applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
       googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US', testEnv: true),
     ),
   );
   await Stripe.instance.presentPaymentSheet(); // lanza StripeException si se cancela/falla
   ```
5. Servidor (por ejemplo una Cloud Function o un endpoint en Node/Python): crear el `PaymentIntent` y escuchar el webhook.

> Comprueba los nombres exactos de clases y parámetros en el README de la versión que instales: el SDK evoluciona.

### Apple Pay y Google Pay
- Con **Stripe PaymentSheet** se activan con un parámetro (ver arriba). Apple Pay requiere un *Merchant ID* y un certificado en tu cuenta de Apple Developer.
- Sin Stripe: el paquete [`pay`](https://pub.dev/packages/pay) (de Google) muestra los botones oficiales y devuelve un *token* que envías a tu pasarela.
- Usa siempre los **botones oficiales** (las tiendas tienen normas de marca).

### Otras pasarelas
| Pasarela | Paquete | Fuerte en |
|---|---|---|
| Stripe | `flutter_stripe` (493 K/mes) | Global, la mejor documentación |
| Mercado Pago | SDK web / checkout por URL | Latinoamérica |
| PayPal | WebView / SDK nativo | Usuarios que no quieren dar su tarjeta |
| Razorpay | `razorpay_flutter` | India |
| Adyen, Braintree | SDK nativos | Grandes empresas |

---

## 4. Demo: suscripciones (paywall)

📄 [paywall_screen.dart](../lib/features/payments/paywall_screen.dart)

| Elemento | Por qué | Código |
|---|---|---|
| Beneficios claros | El usuario compra resultados, no funciones | [beneficios](../lib/features/payments/paywall_screen.dart#L146 "→ Proyectos guiados paso a paso") |
| Plan anual preseleccionado con "AHORRA 33 %" | Ancla de precio: es el que más convierte | [_selected = Plan.yearly](../lib/features/payments/paywall_screen.dart#L84 "→ Plan _selected = Plan.yearly") |
| Precios que **vienen de la tienda** | Ya llegan localizados en la moneda del usuario | [comentario](../lib/features/payments/paywall_screen.dart#L40 "→ NUNCA los escribas a mano") |
| Prueba gratuita explicada | Más conversiones; Apple exige explicar cuándo empieza a cobrar | [texto de renovación](../lib/features/payments/paywall_screen.dart#L185 "→ Se renueva") |
| **Restaurar compras** | **Obligatorio en iOS** (rechazo si falta) | [_restore](../lib/features/payments/paywall_screen.dart#L93 "→ Future<void> _restore") |
| Términos y Privacidad | Obligatorios en apps con suscripción | [enlaces](../lib/features/payments/paywall_screen.dart#L196 "→ Text('Términos')") |
| Estado de la suscripción en un provider | Toda la app sabe si el usuario es Pro | [subscriptionProvider](../lib/features/payments/paywall_screen.dart#L72 "→ final subscriptionProvider") |

### Implementación real

**Opción A — RevenueCat (recomendada para empezar)** · [`purchases_flutter`](https://pub.dev/packages/purchases_flutter) (680 K/mes) + [`purchases_ui_flutter`](https://pub.dev/packages/purchases_ui_flutter) (paywalls ya hechos)
- Unifica App Store y Google Play, valida los recibos en su servidor, gestiona renovaciones, cancelaciones y reembolsos, y trae analítica (MRR, *churn*). Gratis hasta cierto volumen de ingresos.
```dart
await Purchases.configure(PurchasesConfiguration('appl_xxx')); // clave pública
final offerings = await Purchases.getOfferings();
final package = offerings.current!.annual!;
final result = await Purchases.purchasePackage(package);
final isPro = result.customerInfo.entitlements.active.containsKey('pro');
```
(Comprueba la firma exacta en el README de la versión instalada.)

**Opción B — oficial** · [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) (807 K/mes, del equipo de Flutter)
- Gratis y sin intermediarios, pero **tú** validas los recibos en tu servidor y gestionas renovaciones y estados. Más trabajo y más riesgo de errores.

### Pasos comunes
1. Crea los productos en **App Store Connect** (*Monetización → Suscripciones*) y en **Google Play Console** (*Monetizar → Productos*), con los mismos IDs.
2. Firma los acuerdos de "Apps de pago" y rellena los datos bancarios y fiscales en ambas consolas.
3. Prueba con **sandbox** (iOS: cuenta de prueba en App Store Connect; Android: *testers con licencia* y pista de prueba interna).
4. Muestra el paywall en el **momento de valor** (cuando el usuario intenta usar una función Pro), no al abrir la app.

---

## 5. Checklist de pagos en producción

- [ ] ¿Digital → compra integrada? ¿Físico → pasarela?
- [ ] El importe lo calcula **el servidor**.
- [ ] La entrega se confirma por **webhook / validación de recibo**, no porque la app diga "pagado".
- [ ] Botón desactivado durante el proceso (sin dobles cobros).
- [ ] Claves secretas solo en el servidor; en la app, solo claves **publicables**.
- [ ] Errores en lenguaje humano y opción de reintentar.
- [ ] "Restaurar compras", términos, privacidad y texto de renovación (suscripciones).
- [ ] Probado en sandbox o modo test en las dos plataformas.
- [ ] Impuestos por país (Apple y Google los gestionan en la compra integrada; con Stripe usa Stripe Tax o tu contabilidad).

---

## 6. Tests

📄 [payments_test.dart](../test/features/payments/payments_test.dart): marcas, Luhn, formato, caducidad, CVV, formateadores y las respuestas de la pasarela simulada. La lógica de pagos debe ser la parte **más probada** de una app.

---

## ✅ Comprueba que entendiste

1. Vendes una versión Pro dentro de la app. ¿Puedes cobrarla con Stripe?
   <details><summary>Respuesta</summary>

   No: el contenido o las funciones digitales usadas en la app exigen la compra integrada de Apple / Google; con Stripe, las tiendas rechazarán o retirarán tu app. Ver [§1](#1-primero-la-regla-más-importante-qué-vendes).

   </details>
2. ¿Por qué los precios se guardan en céntimos enteros y no con `double`?
   <details><summary>Respuesta</summary>

   Porque en coma flotante `0.1 + 0.2 != 0.3`; con enteros no hay errores de redondeo. Ver [PaymentRequest](../lib/features/payments/payment_gateway.dart#L70 "→ final int amountCents").

   </details>
3. ¿Qué pasa si el botón de pagar no se desactiva mientras se procesa el pago?
   <details><summary>Respuesta</summary>

   Un doble toque puede cobrar dos veces. La demo lo evita con [onPressed: _processing ? null](../lib/features/payments/checkout_screen.dart#L230 "→ onPressed: _processing ? null : _pay").

   </details>
4. ¿Por qué el importe lo calcula el servidor y la entrega se confirma por webhook?
   <details><summary>Respuesta</summary>

   Porque nunca te puedes fiar del precio que envía la app ni de que la app diga "pagado": el servidor calcula el importe y el webhook de Stripe confirma el pago antes de entregar nada.

   </details>

## 🏋️ Reto

**Las tarjetas de prueba.** Prueba en el checkout simulado cada tarjeta de la tabla de [Tarjetas de prueba](#tarjetas-de-prueba-las-de-stripe-en-modo-test) y anota el mensaje que devuelve cada una.

- ✅ **Cómo saber que lo lograste:** tienes los 4 mensajes anotados y puedes explicar cuál de ellos viene de [FakePaymentGateway](../lib/features/payments/payment_gateway.dart#L107 "→ class FakePaymentGateway") y por qué la UI no necesita cambiar.
- 💡 **Pista:** los chips de la demo rellenan el número por ti; usa cualquier fecha futura y cualquier CVV.

## ➡️ Siguiente paso

Continúa con **[15 · IA y agentes](15-ia-y-agentes.md)**: ya sabes cobrar; ahora verás cómo integrar un modelo de IA y construir un agente con herramientas. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).

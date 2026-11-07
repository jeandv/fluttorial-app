// ============================================================================
// lib/features/payments/payment_gateway.dart — PASARELA DE PAGO (abstracción)
// ============================================================================
//
// QUÉ HACE
//   Define QUÉ necesita la app para cobrar (una interfaz PaymentGateway) y una
//   implementación FALSA para practicar sin cuentas ni dinero real.
//
// POR QUÉ UNA INTERFAZ
//   La pantalla de pago solo conoce `PaymentGateway`. Para pasar a Stripe,
//   Mercado Pago o PayPal, creas `StripePaymentGateway implements
//   PaymentGateway` y cambias UNA línea (el provider). La UI no se toca.
//   En los tests se usa FakePaymentGateway con delay cero.
//
// CÓMO SE COBRA DE VERDAD (resumen, detalle en docs/14-pagos.md)
//   1. La app pide a TU servidor un "PaymentIntent" con el importe.
//   2. El servidor (con la clave secreta) lo crea en Stripe y devuelve un
//      client_secret.
//   3. La app abre la hoja de pago del SDK (flutter_stripe PaymentSheet):
//      el SDK captura la tarjeta y habla con Stripe directamente. Tu app y tu
//      servidor NUNCA ven el número de tarjeta (así cumples PCI-DSS).
//   4. Stripe avisa a tu servidor por webhook → entregas el pedido.
//
// TARJETAS DE PRUEBA (las mismas que publica Stripe para su modo test)
//   4242 4242 4242 4242 → pago aprobado
//   4000 0000 0000 0002 → tarjeta rechazada
//   4000 0000 0000 9995 → fondos insuficientes
//   4000 0000 0000 0069 → tarjeta caducada
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/features/payments/card_utils.dart';

enum PaymentMethodType { card, applePay, googlePay }

/// Datos de tarjeta SOLO para la demo. En producción esta clase no existe:
/// el SDK del procesador captura la tarjeta (ver cabecera del archivo).
@immutable
class DemoCardDetails {
  const DemoCardDetails({
    required this.number,
    required this.expiry,
    required this.cvv,
    required this.holder,
  });

  final String number;
  final String expiry;
  final String cvv;
  final String holder;

  String get last4 {
    final d = digitsOnly(number);
    return d.substring(d.length - 4);
  }
}

@immutable
class PaymentRequest {
  const PaymentRequest({
    required this.amountCents,
    required this.currency,
    required this.method,
    this.card,
  });

  /// Importe en CÉNTIMOS (entero). Nunca uses double para dinero: 0.1 + 0.2
  /// no es exactamente 0.3 en coma flotante.
  final int amountCents;
  final String currency;
  final PaymentMethodType method;
  final DemoCardDetails? card;
}

/// Resultado del pago: éxito o fallo. `sealed` obliga a manejar ambos casos
/// en un `switch` (el compilador avisa si olvidas uno).
sealed class PaymentResult {
  const PaymentResult();
}

class PaymentSuccess extends PaymentResult {
  const PaymentSuccess({required this.transactionId, required this.summary});

  final String transactionId;

  /// Ej.: "Visa •••• 4242" o "Apple Pay".
  final String summary;
}

class PaymentFailure extends PaymentResult {
  const PaymentFailure({required this.code, required this.message});

  /// Código estable para lógica/analítica (card_declined, insufficient_funds…).
  final String code;

  /// Texto para mostrar al usuario.
  final String message;
}

/// Lo que la app necesita de cualquier procesador de pagos.
abstract interface class PaymentGateway {
  Future<PaymentResult> pay(PaymentRequest request);
}

/// Pasarela simulada: imita las respuestas de las tarjetas de prueba.
class FakePaymentGateway implements PaymentGateway {
  const FakePaymentGateway({this.delay = const Duration(seconds: 2)});

  final Duration delay;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    await Future<void>.delayed(delay); // simula la red

    final id = 'demo_${DateTime.now().millisecondsSinceEpoch}';
    switch (request.method) {
      case PaymentMethodType.applePay:
        return PaymentSuccess(transactionId: id, summary: 'Apple Pay');
      case PaymentMethodType.googlePay:
        return PaymentSuccess(transactionId: id, summary: 'Google Pay');
      case PaymentMethodType.card:
        final card = request.card!;
        final number = digitsOnly(card.number);
        return switch (number) {
          '4000000000000002' => const PaymentFailure(
            code: 'card_declined',
            message: 'Tu banco ha rechazado la tarjeta. Prueba con otra.',
          ),
          '4000000000009995' => const PaymentFailure(
            code: 'insufficient_funds',
            message: 'Fondos insuficientes.',
          ),
          '4000000000000069' => const PaymentFailure(
            code: 'expired_card',
            message: 'La tarjeta está caducada.',
          ),
          _ => PaymentSuccess(
            transactionId: id,
            summary: '${detectBrand(number).label} •••• ${card.last4}',
          ),
        };
    }
  }
}

/// La UI pide la pasarela a Riverpod: cambiarla (o sustituirla en tests)
/// es cuestión de un override.
final paymentGatewayProvider = Provider<PaymentGateway>(
  (ref) => const FakePaymentGateway(),
);

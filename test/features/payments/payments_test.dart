// ============================================================================
// test/features/payments/payments_test.dart — LÓGICA DE PAGOS
// ============================================================================
// La lógica de pagos debe estar MUY probada: un error aquí cuesta dinero.
// Todo es lógica pura o una pasarela falsa: no hace falta interfaz ni red.
// ============================================================================

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/payments/card_utils.dart';
import 'package:mi_primera_app/features/payments/payment_gateway.dart';

void main() {
  group('detectBrand', () {
    test('reconoce las marcas por sus primeros dígitos', () {
      expect(detectBrand('4242'), CardBrand.visa);
      expect(detectBrand('5555 5555'), CardBrand.mastercard);
      expect(detectBrand('2221 0000'), CardBrand.mastercard);
      expect(detectBrand('3782'), CardBrand.amex);
      expect(detectBrand('6011'), CardBrand.discover);
      expect(detectBrand('9999'), CardBrand.unknown);
      expect(detectBrand(''), CardBrand.unknown);
    });
  });

  group('luhnValid', () {
    test('acepta números de prueba válidos', () {
      for (final n in [
        '4242424242424242',
        '5555555555554444',
        '378282246310005',
        '4000000000000002',
      ]) {
        expect(luhnValid(n), isTrue, reason: n);
      }
    });

    test('rechaza un dígito cambiado', () {
      expect(luhnValid('4242424242424241'), isFalse);
    });
  });

  test('formatCardNumber agrupa 4-4-4-4 y 4-6-5 (Amex)', () {
    expect(formatCardNumber('4242424242424242'), '4242 4242 4242 4242');
    expect(formatCardNumber('378282246310005'), '3782 822463 10005');
    expect(formatCardNumber('4242 42'), '4242 42');
    // Corta los dígitos sobrantes.
    expect(formatCardNumber('42424242424242429999'), '4242 4242 4242 4242');
  });

  group('validateExpiry', () {
    final now = DateTime(2026, 11, 7);

    test('válida hasta el último día del mes indicado', () {
      expect(validateExpiry('11/26', now: now), isNull);
      expect(validateExpiry('12/30', now: now), isNull);
    });

    test('errores de formato, mes y caducidad', () {
      expect(validateExpiry('1126', now: now), 'Formato MM/AA');
      expect(validateExpiry('13/27', now: now), 'Mes no válido');
      expect(validateExpiry('10/26', now: now), 'La tarjeta está caducada');
    });
  });

  test('validateCvv: 3 dígitos o 4 para Amex', () {
    expect(validateCvv('123', CardBrand.visa), isNull);
    expect(validateCvv('12', CardBrand.visa), '3 dígitos');
    expect(validateCvv('1234', CardBrand.amex), isNull);
  });

  test('validateCardNumber detecta incompletos e inválidos', () {
    expect(validateCardNumber('4242 4242 4242 4242'), isNull);
    expect(validateCardNumber('4242 4242'), 'Número incompleto');
    expect(
      validateCardNumber('4242424242424241'),
      'Número de tarjeta no válido',
    );
  });

  test('los formateadores de texto funcionan mientras se escribe', () {
    TextEditingValue type(TextInputFormatter f, String text) => f
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

    expect(type(CardNumberInputFormatter(), '42424242').text, '4242 4242');
    expect(type(ExpiryInputFormatter(), '1229').text, '12/29');
    expect(type(ExpiryInputFormatter(), '1').text, '1');
  });

  group('FakePaymentGateway', () {
    const gateway = FakePaymentGateway(delay: Duration.zero);

    PaymentRequest cardRequest(String number) => PaymentRequest(
      amountCents: 1000,
      currency: 'USD',
      method: PaymentMethodType.card,
      card: DemoCardDetails(
        number: number,
        expiry: '12/30',
        cvv: '123',
        holder: 'TEST',
      ),
    );

    test('4242… aprueba y resume la tarjeta', () async {
      final result = await gateway.pay(cardRequest('4242 4242 4242 4242'));
      expect(result, isA<PaymentSuccess>());
      expect((result as PaymentSuccess).summary, 'Visa •••• 4242');
    });

    test('las tarjetas de error devuelven su código', () async {
      final declined = await gateway.pay(cardRequest('4000000000000002'));
      final noFunds = await gateway.pay(cardRequest('4000000000009995'));
      expect((declined as PaymentFailure).code, 'card_declined');
      expect((noFunds as PaymentFailure).code, 'insufficient_funds');
    });

    test('Apple Pay aprueba sin datos de tarjeta', () async {
      final result = await gateway.pay(
        const PaymentRequest(
          amountCents: 500,
          currency: 'USD',
          method: PaymentMethodType.applePay,
        ),
      );
      expect((result as PaymentSuccess).summary, 'Apple Pay');
    });
  });
}

// ============================================================================
// lib/features/payments/card_utils.dart — VALIDAR Y FORMATEAR TARJETAS
// ============================================================================
//
// QUÉ HACE
//   Funciones PURAS (sin interfaz) para formularios de tarjeta:
//   - Detectar la marca (Visa, Mastercard, Amex, Discover) por sus primeros
//     dígitos (el "BIN" o IIN).
//   - Algoritmo de Luhn: detecta errores de tecleo en el número.
//   - Formatear mientras se escribe: "4242424242424242" → "4242 4242 4242 4242".
//   - Validar caducidad (MM/AA) y CVV.
//
// ⚠️ IMPORTANTE
//   Validar en la app mejora la experiencia (errores al instante), pero NO
//   sustituye la validación del procesador de pagos. En producción los datos
//   de tarjeta los captura el SDK del procesador (Stripe, Adyen…), nunca tu
//   servidor. Ver docs/14-pagos.md.
//
// Probado en test/features/payments/card_utils_test.dart.
// ============================================================================

import 'package:flutter/services.dart';

enum CardBrand { visa, mastercard, amex, discover, unknown }

extension CardBrandInfo on CardBrand {
  String get label => switch (this) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
    CardBrand.amex => 'American Express',
    CardBrand.discover => 'Discover',
    CardBrand.unknown => 'Tarjeta',
  };

  /// Amex usa 4 dígitos de CVV; el resto, 3.
  int get cvvLength => this == CardBrand.amex ? 4 : 3;

  /// Cómo se agrupan los dígitos al mostrarlos.
  List<int> get groups =>
      this == CardBrand.amex ? const [4, 6, 5] : const [4, 4, 4, 4];

  /// Longitud total del número.
  int get length => groups.fold(0, (a, b) => a + b);
}

/// Quita todo lo que no sea dígito: "4242 4242" → "42424242".
String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

/// Detecta la marca por los primeros dígitos.
CardBrand detectBrand(String input) {
  final d = digitsOnly(input);
  if (d.isEmpty) return CardBrand.unknown;
  if (d.startsWith('4')) return CardBrand.visa;
  if (d.startsWith('34') || d.startsWith('37')) return CardBrand.amex;
  if (d.length >= 2) {
    final two = int.parse(d.substring(0, 2));
    if (two >= 51 && two <= 55) return CardBrand.mastercard;
  }
  if (d.length >= 4) {
    final four = int.parse(d.substring(0, 4));
    if (four >= 2221 && four <= 2720) return CardBrand.mastercard;
    if (four == 6011) return CardBrand.discover;
  }
  if (d.startsWith('65')) return CardBrand.discover;
  return CardBrand.unknown;
}

/// Algoritmo de Luhn: desde la derecha, duplica uno de cada dos dígitos
/// (si pasa de 9, resta 9) y suma todo. Es válido si la suma es múltiplo de 10.
bool luhnValid(String input) {
  final d = digitsOnly(input);
  if (d.length < 12) return false;
  var sum = 0;
  for (var i = 0; i < d.length; i++) {
    var digit = int.parse(d[d.length - 1 - i]);
    if (i.isOdd) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 == 0;
}

/// "4242424242424242" → "4242 4242 4242 4242" (o 4-6-5 para Amex).
String formatCardNumber(String input) {
  final brand = detectBrand(input);
  var d = digitsOnly(input);
  if (d.length > brand.length) d = d.substring(0, brand.length);
  final parts = <String>[];
  var start = 0;
  for (final size in brand.groups) {
    if (start >= d.length) break;
    final end = (start + size).clamp(0, d.length);
    parts.add(d.substring(start, end));
    start = end;
  }
  return parts.join(' ');
}

// ----------------------------------------------------------- VALIDADORES
// Devuelven null si es válido o el mensaje de error (para TextFormField).

String? validateCardNumber(String? value) {
  final d = digitsOnly(value ?? '');
  if (d.isEmpty) return 'Introduce el número de la tarjeta';
  final brand = detectBrand(d);
  if (d.length != brand.length) return 'Número incompleto';
  if (!luhnValid(d)) return 'Número de tarjeta no válido';
  return null;
}

/// Valida "MM/AA". La tarjeta es válida hasta el ÚLTIMO día de ese mes.
String? validateExpiry(String? value, {DateTime? now}) {
  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value ?? '');
  if (match == null) return 'Formato MM/AA';
  final month = int.parse(match[1]!);
  final year = 2000 + int.parse(match[2]!);
  if (month < 1 || month > 12) return 'Mes no válido';
  final today = now ?? DateTime.now();
  // Primer día del mes SIGUIENTE a la caducidad.
  final expiresAt = DateTime(year, month + 1);
  if (!today.isBefore(expiresAt)) return 'La tarjeta está caducada';
  return null;
}

String? validateCvv(String? value, CardBrand brand) {
  final d = digitsOnly(value ?? '');
  if (d.length != brand.cvvLength) return '${brand.cvvLength} dígitos';
  return null;
}

// --------------------------------------------------- FORMATEADORES DE TEXTO
// TextInputFormatter: transforma el texto MIENTRAS el usuario escribe.

/// Agrupa los dígitos del número de tarjeta según la marca.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatCardNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Inserta la "/" de MM/AA automáticamente.
class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = digitsOnly(newValue.text);
    if (d.length > 4) d = d.substring(0, 4);
    final text = d.length > 2 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

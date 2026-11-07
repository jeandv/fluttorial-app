// ============================================================================
// test/features/advanced/isolates_test.dart — PRUEBA DE UNA FUNCIÓN PURA
// ============================================================================
// Las funciones "puras" (mismo argumento → mismo resultado, sin efectos) son
// las más fáciles de probar. countPrimes se ejecuta igual en el hilo
// principal o en un isolate, así que basta con probar la función.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/advanced/isolates_screen.dart';

void main() {
  test('countPrimes cuenta los primos menores que el límite', () {
    expect(countPrimes(2), 0);
    expect(countPrimes(20), 8); // 2, 3, 5, 7, 11, 13, 17, 19
    expect(countPrimes(100), 25);
  });

  test(
    'compute ejecuta la función en otro isolate con el mismo resultado',
    () async {
      expect(await compute(countPrimes, 100), 25);
    },
  );
}

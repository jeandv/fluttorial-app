// ============================================================================
// lib/features/advanced/isolates_screen.dart — DEMO AVANZADA: ISOLATES
// ============================================================================
//
// QUÉ ENSEÑA
//   Por qué un cálculo pesado CONGELA la interfaz y cómo evitarlo moviéndolo
//   a otro "isolate" (un hilo de Dart con su propia memoria).
//
// EL PROBLEMA
//   Flutter dibuja la interfaz en el hilo principal ~60-120 veces por segundo.
//   Si ese hilo está ocupado 3 segundos calculando, no puede dibujar: la
//   ruedita se para y los botones no responden. `async/await` NO soluciona
//   esto: solo sirve para ESPERAR (red, disco), no para CALCULAR.
//
// LA SOLUCIÓN
//   - `compute(funcion, argumento)` (de flutter/foundation): ejecuta la
//     función en otro isolate y devuelve un Future con el resultado.
//   - `Isolate.run(() => ...)` (dart:isolate): equivalente moderno en Dart.
//   La función debe ser de nivel superior o `static` (no puede usar `this`).
//
// CUÁNDO USARLO
//   Procesar JSON muy grandes, comprimir imágenes, cifrado, búsquedas en
//   listas enormes, cálculos matemáticos.
//
// 🧪 PRUEBA: pulsa "En el hilo principal" y mira cómo se congela la ruedita.
//    Luego pulsa "En un isolate": la ruedita sigue girando.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

/// Cuenta los números primos menores que [limit] (trabajo de CPU a propósito
/// lento). Es una función de NIVEL SUPERIOR: puede ejecutarse en un isolate.
int countPrimes(int limit) {
  var count = 0;
  for (var n = 2; n < limit; n++) {
    var isPrime = true;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) count++;
  }
  return count;
}

class IsolatesScreen extends StatefulWidget {
  const IsolatesScreen({super.key});

  @override
  State<IsolatesScreen> createState() => _IsolatesScreenState();
}

class _IsolatesScreenState extends State<IsolatesScreen> {
  static const _limit = 6000000;

  bool _working = false;
  String _result = 'Sin calcular';

  Future<void> _run({required bool useIsolate}) async {
    setState(() {
      _working = true;
      _result = 'Calculando…';
    });
    // Deja que Flutter dibuje "Calculando…" antes de empezar.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final stopwatch = Stopwatch()..start();
    final primes = useIsolate
        ? await compute(countPrimes, _limit) // ✅ otro isolate
        : countPrimes(_limit); // ❌ hilo principal: congela la UI
    stopwatch.stop();

    if (!mounted) return;
    setState(() {
      _working = false;
      _result =
          '$primes primos menores que $_limit\n'
          '${useIsolate ? 'Isolate' : 'Hilo principal'}: '
          '${stopwatch.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Isolates',
      explanation:
          'El trabajo de CPU pesado en el hilo principal congela la interfaz. '
          'compute() / Isolate.run() lo ejecutan en paralelo y devuelven el '
          'resultado con un Future.',
      sourceFile: 'lib/features/advanced/isolates_screen.dart',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Si esta ruedita se detiene, la interfaz está congelada.
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 8),
          const Text(
            '↑ Si se detiene, la interfaz está congelada',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: _working ? null : () => _run(useIsolate: false),
            child: const Text('❌ En el hilo principal'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _working ? null : () => _run(useIsolate: true),
            child: const Text('✅ En un isolate (compute)'),
          ),
          const SizedBox(height: 24),
          Text(
            _result,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

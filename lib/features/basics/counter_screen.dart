// ============================================================================
// lib/features/basics/counter_screen.dart — DEMO BÁSICA: CONTADOR (setState)
// ============================================================================
//
// QUÉ ENSEÑA
//   - StatefulWidget: un widget con datos que cambian.
//   - setState(): avisa a Flutter de que redibuje.
//   - Ciclo de vida: initState → build → (setState → build)* → dispose.
//
// CÓMO FUNCIONA
//   Un StatefulWidget se divide en DOS clases:
//     1. CounterScreen (el widget): configuración inmutable.
//     2. _CounterScreenState (el estado): datos que cambian + build().
//   Al pulsar un botón se modifica `_count` DENTRO de setState(() {...});
//   Flutter vuelve a llamar a build() y la pantalla muestra el nuevo valor.
//   Si cambias `_count` sin setState, el valor cambia en memoria pero la
//   pantalla NO se actualiza.
//
// CUÁNDO USAR setState
//   Para estado LOCAL de una sola pantalla (un contador, si un panel está
//   abierto, el texto de un campo…). Si varias pantallas necesitan el mismo
//   dato, usa Riverpod (ver features/todos/).
//
// 🧪 PRUEBA: suma unas veces, cambia `Colors.red` por `Colors.green` en
//    build(), guarda y pulsa "r" (hot reload). El color cambia y el contador
//    NO vuelve a 0: hot reload conserva el estado. Con "R" sí se reinicia.
//    (Ojo: cambiar el valor inicial de un campo, como `_count = 0`, NO se
//    aplica con hot reload porque initState/los campos no se re-ejecutan.)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  // createState() crea el objeto State. Flutter lo conserva aunque el widget
  // se reconstruya (por eso el estado sobrevive a hot reload).
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  static const _step = 1;

  // Lista de eventos del ciclo de vida, para verlos en pantalla.
  final List<String> _log = [];

  void _addLog(String event) {
    _log.insert(0, '${TimeOfDay.now().format(context)} · $event');
    if (_log.length > 6) _log.removeLast();
  }

  /// initState: se ejecuta UNA vez, al insertar el widget en pantalla.
  /// Úsalo para inicializar controladores, suscripciones o cargar datos.
  /// (No se puede usar `context` para leer el tema/idioma aquí todavía.)
  @override
  void initState() {
    super.initState(); // siempre primero
    debugPrint('CounterScreen.initState');
    _log.add('initState()');
  }

  /// dispose: se ejecuta al quitar el widget (al salir de la pantalla).
  /// Úsalo para liberar controladores, timers y suscripciones.
  @override
  void dispose() {
    debugPrint('CounterScreen.dispose');
    super.dispose(); // siempre al final
  }

  void _increment() => setState(() {
    _count += _step;
    _addLog('setState → $_count');
  });

  void _decrement() => setState(() {
    if (_count > 0) _count -= _step;
    _addLog('setState → $_count');
  });

  void _reset() => setState(() {
    _count = 0;
    _addLog('reset');
  });

  /// build: describe la interfaz. Se ejecuta MUCHAS veces (cada setState,
  /// cambio de tema, rotación…), así que debe ser rápido y sin efectos
  /// secundarios (nada de peticiones HTTP aquí).
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DemoScaffold(
      title: 'Contador',
      explanation:
          'Estado local con StatefulWidget y setState(). Cada vez que '
          'llamas a setState, Flutter vuelve a ejecutar build() y redibuja '
          'la pantalla con los nuevos valores. Abajo ves el ciclo de vida.',
      sourceFile: 'lib/features/basics/counter_screen.dart',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const Text(
            'Has pulsado el botón esta cantidad de veces:',
            textAlign: TextAlign.center,
          ),
          // AnimatedSwitcher anima el cambio de número (bonus de animación).
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$_count',
              // La `key` le dice a AnimatedSwitcher que es un widget NUEVO.
              key: ValueKey(_count),
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                color: _count > 10 ? Colors.red : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Restar',
                onPressed: _count == 0
                    ? null
                    : _decrement, // null = desactivado
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                tooltip: 'Incrementar',
                onPressed: _increment,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          DemoSection(
            title: 'Ciclo de vida',
            description: 'Eventos del State, del más reciente al más antiguo.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final event in _log)
                  Text(event, style: const TextStyle(fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

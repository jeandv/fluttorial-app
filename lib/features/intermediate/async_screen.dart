// ============================================================================
// lib/features/intermediate/async_screen.dart — DEMO: ASINCRONÍA
// ============================================================================
//
// QUÉ ENSEÑA
//   - Future + async/await: operaciones que tardan (red, disco, temporizadores).
//   - try / catch / finally: manejar errores de operaciones asíncronas.
//   - Estado de carga manual (isLoading) con setState.
//   - FutureBuilder: dibujar según el estado de un Future (cargando/error/dato).
//   - StreamBuilder: dibujar cada nuevo valor de un Stream (flujo de datos).
//   - Timer: ejecutar código periódicamente (y cancelarlo en dispose).
//
// IDEA CLAVE
//   Flutter tiene UN hilo para la interfaz. `await` NO bloquea ese hilo: la app
//   sigue respondiendo mientras espera. Pero el trabajo de CPU pesado sí la
//   congela (para eso están los Isolates, ver la demo avanzada).
// ============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class AsyncScreen extends StatefulWidget {
  const AsyncScreen({super.key});

  @override
  State<AsyncScreen> createState() => _AsyncScreenState();
}

class _AsyncScreenState extends State<AsyncScreen> {
  // ---- Ejemplo 1: async/await manual
  bool _isLoading = false;
  String _result = 'Pulsa el botón';
  bool _shouldFail = false;

  // ---- Ejemplo 2: FutureBuilder
  // ⚠️ El Future se crea UNA vez (en initState o al pulsar), NUNCA dentro de
  // build(): build se ejecuta muchas veces y repetiría la operación.
  late Future<int> _luckyNumber;

  // ---- Ejemplo 3: StreamBuilder
  late final Stream<DateTime> _clock;

  // ---- Ejemplo 4: Timer
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _luckyNumber = _fetchLuckyNumber();
    // Stream que emite la hora actual cada segundo.
    _clock = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  void dispose() {
    _timer?.cancel(); // ⚠️ siempre cancelar timers y suscripciones
    super.dispose();
  }

  /// Simula una petición a un servidor que tarda 2 segundos.
  Future<String> _fakeRequest() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (_shouldFail) throw Exception('El servidor no responde');
    final now = DateTime.now();
    // Nota: no usamos `context` después de un `await` (podría no ser válido).
    return 'Datos recibidos a las ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _fakeRequest(); // espera sin bloquear la interfaz
      if (!mounted) return; // la pantalla pudo cerrarse mientras esperábamos
      setState(() => _result = '✅ $data');
    } catch (error) {
      if (!mounted) return;
      setState(() => _result = '❌ Error: $error');
    } finally {
      // finally se ejecuta SIEMPRE (haya éxito o error).
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<int> _fetchLuckyNumber() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return Random().nextInt(100);
  }

  void _toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    } else {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _seconds++),
      );
    }
    setState(() {}); // redibuja el texto del botón
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Asincronía',
      explanation:
          'Future representa un valor que llegará más tarde; Stream, varios '
          'valores a lo largo del tiempo. await espera sin congelar la '
          'interfaz. FutureBuilder y StreamBuilder redibujan solos cuando '
          'llegan datos.',
      sourceFile: 'lib/features/intermediate/async_screen.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: '1. async / await + try / catch',
            description:
                'Estado de carga manual: isLoading = true → await → '
                'isLoading = false. Activa "Simular error" para ver el catch.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simular error'),
                  value: _shouldFail,
                  onChanged: (v) => setState(() => _shouldFail = v),
                ),
                Row(
                  children: [
                    FilledButton(
                      // Desactivado mientras carga (evita doble petición).
                      onPressed: _isLoading ? null : _load,
                      child: const Text('Cargar datos'),
                    ),
                    const SizedBox(width: 16),
                    if (_isLoading)
                      const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_result),
              ],
            ),
          ),
          DemoSection(
            title: '2. FutureBuilder',
            description:
                'Dibuja según snapshot.connectionState / hasError / data.',
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _luckyNumber,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LinearProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return Text('Tu número de la suerte: ${snapshot.data}');
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Repetir',
                  // Crear un Future NUEVO hace que FutureBuilder empiece de 0.
                  onPressed: () =>
                      setState(() => _luckyNumber = _fetchLuckyNumber()),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          DemoSection(
            title: '3. StreamBuilder',
            description:
                'Se redibuja con cada valor del Stream (un reloj que emite '
                'cada segundo). Ejemplos reales: chat, GPS, Firestore.',
            child: StreamBuilder<DateTime>(
              stream: _clock,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Esperando…');
                final t = snapshot.data!;
                String two(int n) => n.toString().padLeft(2, '0');
                return Text(
                  '${two(t.hour)}:${two(t.minute)}:${two(t.second)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ),
          DemoSection(
            title: '4. Timer.periodic',
            description:
                'Ejecuta código cada X tiempo. Hay que cancelarlo en dispose() '
                'o seguirá funcionando al salir de la pantalla.',
            child: Row(
              children: [
                Text(
                  '$_seconds s',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _toggleTimer,
                  child: Text(
                    (_timer?.isActive ?? false) ? 'Pausar' : 'Iniciar',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

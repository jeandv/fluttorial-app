// ============================================================================
// lib/features/packages/dio/dio_demo_screen.dart — DEMO: DIO
// ============================================================================
//
// QUÉ ENSEÑA
//   GET, POST, manejo de errores por tipo, cancelación con CancelToken y
//   cómo los interceptores ven pasar cada petición (panel "Registro").
//   El cliente está en dio_client.dart.
// ============================================================================

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/features/packages/dio/dio_client.dart';

class DioDemoScreen extends StatefulWidget {
  const DioDemoScreen({super.key});

  @override
  State<DioDemoScreen> createState() => _DioDemoScreenState();
}

class _DioDemoScreenState extends State<DioDemoScreen> {
  late final Dio _dio;
  final List<String> _log = [];
  String _result = 'Elige una petición';
  bool _loading = false;

  /// Token de cancelación de la petición en curso.
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    // Los interceptores escriben en _log → se ve cada paso en pantalla.
    // `mounted`: al cerrar la pantalla, dispose() cancela la petición y el
    // interceptor registra el error DESPUÉS de destruir el widget.
    _dio = createDio(
      onLog: (line) {
        if (mounted) setState(() => _log.insert(0, line));
      },
    );
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Pantalla cerrada'); // no dejar peticiones vivas
    _dio.close();
    super.dispose();
  }

  /// Ejecuta una petición mostrando cargando / resultado / error.
  Future<void> _run(
    Future<Response<dynamic>> Function(CancelToken) request,
  ) async {
    final token = CancelToken();
    setState(() {
      _loading = true;
      _cancelToken = token;
      _result = 'Cargando…';
    });
    try {
      final response = await request(token);
      // response.data YA es un Map/List: Dio decodificó el JSON.
      final pretty = const JsonEncoder.withIndent('  ').convert(response.data);
      _result = 'HTTP ${response.statusCode}\n$pretty';
    } on DioException catch (e) {
      _result = '❌ ${describeDioError(e)}\n(type: ${e.type.name})';
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final mono = Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontFamily: 'monospace');

    return DemoScaffold(
      title: 'Dio',
      explanation:
          'Dio es el cliente HTTP más usado en apps profesionales: interceptores '
          '(token, logs), JSON automático, cancelación y errores tipados. '
          'Mira el panel "Registro": ahí escriben los interceptores.',
      sourceFile: 'lib/features/packages/dio/',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: 'Peticiones',
            description:
                'Todas pasan por AuthInterceptor (añade el token) y '
                'LogCollectorInterceptor (registra cada paso).',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _loading
                      ? null
                      : () => _run((t) => _dio.get('/users/1', cancelToken: t)),
                  child: const Text('GET /users/1'),
                ),
                FilledButton.tonal(
                  onPressed: _loading
                      ? null
                      : () => _run(
                          (t) => _dio.post(
                            '/posts',
                            // `data` se convierte a JSON automáticamente.
                            data: {
                              'title': 'Hola',
                              'body': 'Desde Dio',
                              'userId': 1,
                            },
                            cancelToken: t,
                          ),
                        ),
                  child: const Text('POST /posts'),
                ),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () => _run(
                          (t) => _dio.get('/posts/999999', cancelToken: t),
                        ),
                  child: const Text('Error 404'),
                ),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          _run((t) => _dio.get('/photos', cancelToken: t));
                          // Cancela casi enseguida para ver el error "cancel".
                          Future<void>.delayed(
                            const Duration(milliseconds: 30),
                            () => _cancelToken?.cancel(
                              'Cancelado por el usuario',
                            ),
                          );
                        },
                  child: const Text('Cancelar petición'),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Resultado',
            description: 'response.data ya llega decodificado (Map o List).',
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: SelectableText(_result, style: mono),
              ),
            ),
          ),
          DemoSection(
            title: 'Registro (interceptores)',
            description: '→ petición · ← respuesta · ✖ error',
            child: _log.isEmpty
                ? const Text('Aún no hay peticiones')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in _log.take(12)) Text(line, style: mono),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

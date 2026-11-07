// ============================================================================
// lib/features/advanced/native_channel.dart — DEMO: CÓDIGO NATIVO (MethodChannel)
// ============================================================================
//
// QUÉ ENSEÑA
//   Cómo llamar desde Dart a código NATIVO escrito en Kotlin (Android) y Swift
//   (iOS). Es lo que hacen por dentro TODOS los plugins (cámara, GPS…). Lo
//   necesitarás cuando no exista un paquete para lo que quieres hacer.
//
// CÓMO FUNCIONA
//   Dart                         canal "com.jeanrondon.mi_primera_app/device"         Nativo
//   ─────                        ─────────────────────────────────────────────         ──────
//   invokeMethod('getDeviceInfo')  ───────── mensaje ─────────►  MainActivity.kt (Android)
//                                                                AppDelegate.swift (iOS)
//   Future<Map> ◄──────────────── result.success(mapa) ─────────
//
//   1. Ambos lados usan el MISMO nombre de canal (String).
//   2. Dart llama `invokeMethod('nombre', argumentos)` → devuelve un Future.
//   3. El lado nativo recibe la llamada, comprueba el nombre del método y
//      responde con result.success(valor), result.error(...) o
//      result.notImplemented().
//   4. Tipos permitidos: null, bool, int, double, String, List, Map, Uint8List.
//
// DÓNDE ESTÁ EL CÓDIGO NATIVO
//   - Android: android/app/src/main/kotlin/com/jeanrondon/mi_primera_app/MainActivity.kt
//   - iOS:     ios/Runner/AppDelegate.swift
//
// ⚠️ Tras modificar código nativo hay que DETENER la app y volver a ejecutar
//    `flutter run` (hot reload/restart solo recargan Dart).
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 8)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

/// Servicio que encapsula el canal. La UI no sabe nada de MethodChannel.
class DeviceInfoService {
  const DeviceInfoService();

  // El nombre debe coincidir EXACTAMENTE con el del código nativo.
  static const _channel = MethodChannel('com.jeanrondon.mi_primera_app/device');

  /// Pide al sistema operativo información del dispositivo.
  Future<Map<String, String>> getDeviceInfo() async {
    final result = await _channel.invokeMapMethod<String, String>(
      'getDeviceInfo',
    );
    return result ?? const {};
  }

  /// Envía un argumento y recibe una respuesta calculada en nativo.
  Future<String> greet(String name) async {
    final result = await _channel.invokeMethod<String>('greet', {'name': name});
    return result ?? '';
  }
}

class NativeChannelScreen extends StatefulWidget {
  const NativeChannelScreen({super.key});

  @override
  State<NativeChannelScreen> createState() => _NativeChannelScreenState();
}

class _NativeChannelScreenState extends State<NativeChannelScreen> {
  final _service = const DeviceInfoService();
  Map<String, String>? _info;
  String? _greeting;
  String? _error;

  Future<void> _call(Future<void> Function() action) async {
    setState(() => _error = null);
    try {
      await action();
    } on PlatformException catch (e) {
      // El código nativo respondió con result.error(...)
      setState(() => _error = 'PlatformException: ${e.code} ${e.message}');
    } on MissingPluginException {
      // Nadie escucha ese canal (p. ej. en web, o si no reiniciaste la app
      // después de añadir el código nativo).
      setState(
        () => _error =
            'MissingPluginException: el canal no está implementado en esta '
            'plataforma. Detén la app y ejecuta de nuevo flutter run.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Código nativo',
      explanation:
          'Un MethodChannel conecta Dart con Kotlin (Android) y Swift (iOS). '
          'Dart llama invokeMethod y el código nativo responde. Así funcionan '
          'por dentro todos los plugins.',
      sourceFile:
          'lib/features/advanced/native_channel.dart · MainActivity.kt · '
          'AppDelegate.swift',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: "invokeMethod('getDeviceInfo')",
            description:
                'Kotlin lee android.os.Build; Swift lee UIDevice.current.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: () => _call(() async {
                    final info = await _service.getDeviceInfo();
                    setState(() => _info = info);
                  }),
                  icon: const Icon(Icons.phone_iphone),
                  label: const Text('Leer datos del dispositivo'),
                ),
                if (_info != null) ...[
                  const SizedBox(height: 12),
                  for (final MapEntry(:key, :value) in _info!.entries)
                    Text('$key: $value'),
                ],
              ],
            ),
          ),
          DemoSection(
            title: "invokeMethod('greet', {'name': 'Jean'})",
            description:
                'Enviar argumentos: el código nativo los lee y devuelve un '
                'texto construido en Kotlin/Swift.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.tonal(
                  onPressed: () => _call(() async {
                    final text = await _service.greet('Jean');
                    setState(() => _greeting = text);
                  }),
                  child: const Text('Saludar desde nativo'),
                ),
                if (_greeting != null) ...[
                  const SizedBox(height: 8),
                  Text(_greeting!),
                ],
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

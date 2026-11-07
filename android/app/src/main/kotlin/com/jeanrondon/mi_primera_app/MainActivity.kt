// ============================================================================
// MainActivity.kt — PUNTO DE ENTRADA NATIVO DE ANDROID
// ============================================================================
// Es la única "pantalla" (Activity) nativa de la app. FlutterActivity arranca
// el motor de Flutter y dibuja dentro toda la interfaz de lib/main.dart.
//
// Normalmente NO necesitas tocarlo. Solo lo editarás si escribes código nativo
// Kotlin (por ejemplo, un MethodChannel para hablar entre Dart y Android).
//
// El `package` debe coincidir con `namespace` en android/app/build.gradle.kts.
// 📚 Más: android/README.md
// ============================================================================
package com.jeanrondon.mi_primera_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()

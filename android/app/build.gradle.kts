// ============================================================================
// android/app/build.gradle.kts — CONFIGURACIÓN DE COMPILACIÓN DE ANDROID
// ============================================================================
// Archivo de Gradle (escrito en Kotlin) que define cómo se compila la app
// Android. Lo tocarás para:
//   - Cambiar el ID de la app (applicationId)          → antes de publicar
//   - Subir la versión mínima de Android (minSdk)      → si un plugin lo pide
//   - Configurar la firma de release (signingConfigs)  → para Google Play
//   - Crear "flavors" (dev/prod)                        → avanzado
//
// La versión (versionCode/versionName) NO se cambia aquí: viene de
// `version:` en pubspec.yaml.
//
// 📚 Más: android/README.md · docs/08-compilar-y-publicar.md (sección 3)
// ============================================================================

plugins {
    id("com.android.application")
    // El plugin de Gradle de Flutter debe aplicarse DESPUÉS de los plugins de
    // Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Paquete del código Kotlin/Java nativo (debe coincidir con el `package`
    // de MainActivity.kt).
    namespace = "com.jeanrondon.mi_primera_app"

    // Versión del SDK de Android con la que se compila. Flutter la gestiona.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // ID ÚNICO de la app en Google Play y en el teléfono.
        // ⚠️ No se puede cambiar después de publicar.
        // Info: https://developer.android.com/studio/build/application-id.html
        applicationId = "com.jeanrondon.mi_primera_app"

        // minSdk: versión MÍNIMA de Android en la que se puede instalar.
        //   Si un plugin dice "minSdkVersion X cannot be smaller than Y",
        //   cambia esta línea por ejemplo a: minSdk = 23
        // targetSdk: versión de Android para la que está optimizada la app.
        // Más info: https://flutter.dev/to/review-gradle-config
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Vienen de `version: 1.0.0+1` en pubspec.yaml:
        //   versionName = "1.0.0"  (la que ve el usuario)
        //   versionCode = 1        (entero que debe subir en cada publicación)
        // Con APKs divididos por ABI, Flutter suma 1000 * ABI_VERSION automáticamente.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ⚠️ PENDIENTE ANTES DE PUBLICAR: crear tu propia firma de release.
            // Ahora se firma con la clave de DEBUG para que `flutter run --release`
            // funcione, pero Google Play rechaza apps firmadas así.
            // Instrucciones paso a paso: docs/08-compilar-y-publicar.md (3.1–3.3).
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    // Ruta al proyecto Flutter (dos niveles arriba: android/app → raíz).
    source = "../.."
}

// ============================================================================
// lib/main.dart — PUNTO DE ENTRADA DE LA APP
// ============================================================================
//
// Este es el primer archivo que ejecuta Flutter. Aquí se define:
//   1. main()          → la función que arranca todo.
//   2. MyApp           → la raíz de la app (tema, título, pantalla inicial).
//   3. MyHomePage      → la pantalla del contador (un StatefulWidget).
//
// Cómo ejecutarla (desde la carpeta del proyecto):
//   flutter run                 → en el dispositivo disponible
//   flutter run -d all          → en todos (iPhone + Android a la vez)
//   Teclas: r = hot reload · R = hot restart · q = salir · h = ayuda
//
// 📚 Guías relacionadas:
//   - docs/04-ejecutar-y-simular.md   → cómo ejecutarla y simularla
//   - docs/05-dart-esencial.md        → sintaxis de Dart usada aquí
//   - docs/06-construir-la-app.md     → widgets, estado, navegación
//   - lib/README.md                   → cómo organizar esta carpeta
// ============================================================================

// "material.dart" trae todos los widgets de Material Design (estilo Google):
// MaterialApp, Scaffold, AppBar, Text, botones, iconos, colores…
// Para widgets estilo iOS existe 'package:flutter/cupertino.dart'.
import 'package:flutter/material.dart';

/// Punto de entrada. `runApp` recibe el widget raíz y lo dibuja en pantalla.
///
/// ⚠️ Los cambios dentro de main() NO se aplican con hot reload (r);
/// necesitas hot restart (R).
void main() {
  runApp(const MyApp());
}

// ----------------------------------------------------------------------------
// MyApp: widget raíz
// ----------------------------------------------------------------------------
// Es un StatelessWidget: no guarda datos que cambien. Solo configura la app.
// `const` permite a Flutter reutilizar el widget en vez de recrearlo (rendimiento).
class MyApp extends StatelessWidget {
  // `super.key` pasa la "key" opcional al padre. Las keys ayudan a Flutter a
  // identificar widgets (útil en listas y en tests con find.byKey).
  const MyApp({super.key});

  // build() describe la interfaz. Flutter lo llama cada vez que necesita
  // dibujar este widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp configura cosas globales: título, tema, idioma, rutas…
    return MaterialApp(
      // Título que usa el sistema (p. ej. en el selector de apps de Android).
      // El nombre bajo el icono se define en AndroidManifest.xml (android:label)
      // e ios/Runner/Info.plist (CFBundleDisplayName).
      title: 'Mi Primera App',

      // Oculta la franja "DEBUG" de la esquina superior derecha.
      // Cámbialo a true si quieres verla mientras desarrollas.
      debugShowCheckedModeBanner: false,

      // Tema visual de toda la app.
      theme: ThemeData(
        // 🧪 PRUEBA ESTO: cambia Colors.deepPurple por Colors.green, guarda y
        // pulsa "r" (hot reload). Verás el cambio sin que el contador vuelva
        // a cero: el estado se conserva. Con "R" (hot restart) sí se reinicia.
        //
        // `.fromSeed(...)` es un "dot shorthand" de Dart 3.10+: equivale a
        // `ColorScheme.fromSeed(...)`. Dart deduce el tipo por el contexto.
        // fromSeed genera una paleta completa (primary, secondary, surface…)
        // a partir de un solo color.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),

      // Modo oscuro (opcional). Descomenta estas líneas para que la app siga
      // el ajuste claro/oscuro del teléfono:
      // darkTheme: ThemeData(
      //   colorScheme: .fromSeed(
      //     seedColor: Colors.deepPurple,
      //     brightness: Brightness.dark,
      //   ),
      // ),
      // themeMode: ThemeMode.system,

      // Primera pantalla que se muestra. En apps con varias pantallas se suele
      // usar `routes` o el paquete go_router (ver docs/06, sección 4).
      home: const MyHomePage(title: 'Mi primera app'),
    );
  }
}

// ----------------------------------------------------------------------------
// MyHomePage: pantalla con estado
// ----------------------------------------------------------------------------
// Un StatefulWidget se divide en DOS clases:
//   1. MyHomePage (el widget): datos de configuración inmutables (`final`).
//   2. _MyHomePageState (el estado): datos que cambian + el método build().
// Así Flutter puede reconstruir el widget sin perder el estado.
class MyHomePage extends StatefulWidget {
  // `required` obliga a pasar el título al crear la pantalla.
  const MyHomePage({super.key, required this.title});

  // Los campos de un Widget siempre son `final` (inmutables).
  final String title;

  // Crea el objeto State asociado a este widget.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// El guion bajo `_` hace la clase PRIVADA: solo es visible en este archivo.
class _MyHomePageState extends State<MyHomePage> {
  // Estado: el valor del contador. Al ser privado (_), solo se usa aquí.
  int _counter = 0;

  // Método que se ejecuta al pulsar el botón "+".
  void _incrementCounter() {
    // setState() avisa a Flutter de que el estado cambió, y Flutter vuelve a
    // llamar a build() para redibujar la pantalla con el nuevo valor.
    // Si cambias _counter SIN setState, el número no se actualiza en pantalla.
    setState(() {
      _counter++;
    });
  }

  // 💡 Otros métodos del ciclo de vida que puedes sobrescribir aquí:
  //   initState()  → se ejecuta UNA vez al crear la pantalla (cargar datos,
  //                  crear controladores). No se re-ejecuta con hot reload.
  //   dispose()    → al destruir la pantalla (liberar controladores, streams).

  @override
  Widget build(BuildContext context) {
    // Este método se ejecuta cada vez que se llama a setState. Flutter está
    // optimizado para que reconstruir widgets sea muy rápido.

    // Theme.of(context) obtiene el tema definido en MaterialApp.
    final theme = Theme.of(context);

    // Scaffold = esqueleto estándar de una pantalla Material.
    // Tiene huecos para: appBar, body, floatingActionButton, drawer,
    // bottomNavigationBar, etc.
    return Scaffold(
      // Barra superior.
      appBar: AppBar(
        // 🧪 PRUEBA ESTO: cambia por Colors.amber y haz hot reload.
        backgroundColor: theme.colorScheme.inversePrimary,
        // `widget.title` accede a los campos del StatefulWidget (MyHomePage)
        // desde su State.
        title: Text(widget.title),
      ),

      // Contenido principal de la pantalla.
      body: Center(
        // Center: widget de layout que centra a su único hijo.
        child: Column(
          // Column: coloca sus hijos (children) en VERTICAL.
          // (Row hace lo mismo en horizontal.)
          //
          // mainAxisAlignment controla la alineación en el eje principal
          // (vertical en Column). `.center` = MainAxisAlignment.center.
          //
          // 🧪 PRUEBA ESTO: en la terminal de `flutter run` pulsa "p" para
          // activar "debug paint" y ver los bordes de cada widget.
          mainAxisAlignment: .center,
          children: [
            // `const` porque este texto nunca cambia.
            const Text('Has pulsado el botón esta cantidad de veces:'),
            Text(
              // Interpolación de strings: '$variable' o '${expresión}'.
              '$_counter',
              // Estilo tomado del tema (tamaño de título mediano).
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      // Botón flotante redondo de la esquina inferior derecha.
      floatingActionButton: FloatingActionButton(
        // Función que se ejecuta al tocarlo. Se pasa SIN paréntesis
        // (_incrementCounter, no _incrementCounter()) porque es un callback.
        onPressed: _incrementCounter,
        // Texto que se muestra al mantener pulsado (y que leen los lectores
        // de pantalla para accesibilidad).
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================================
// 🚀 SIGUIENTES PASOS (ejercicios sugeridos)
// ============================================================================
// 1. Añade un segundo botón que reste (Icons.remove). Pista: usa una Row con
//    dos FloatingActionButton, o un segundo botón en el body.
// 2. Añade un botón "Reiniciar" en el AppBar con `actions: [IconButton(...)]`.
// 3. Cambia el color del número a rojo cuando sea mayor que 10.
// 4. Mueve MyHomePage a su propio archivo: lib/screens/home_screen.dart
//    e impórtalo aquí con:
//    import 'package:mi_primera_app/screens/home_screen.dart';
// 5. Ejecuta `flutter test` para comprobar que el test de test/widget_test.dart
//    sigue pasando después de tus cambios.
// ============================================================================

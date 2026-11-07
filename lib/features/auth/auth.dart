// ============================================================================
// lib/features/auth/auth.dart — SESIÓN SIMULADA + RUTA PROTEGIDA
// ============================================================================
//
// QUÉ ENSEÑA
//   El patrón de "rutas protegidas" de casi todas las apps con login:
//   1. Un provider guarda si hay sesión iniciada (authProvider).
//   2. El router (app_router.dart → redirect) consulta ese provider ANTES de
//      mostrar /privado. Si no hay sesión → redirige a /login?desde=/privado.
//   3. Al iniciar sesión, el router se "refresca" (refreshListenable),
//      vuelve a evaluar redirect y te lleva a donde querías ir.
//
// EN UNA APP REAL
//   `login()` llamaría a tu backend (Firebase Auth, Supabase, tu API…) y el
//   token se guardaría con flutter_secure_storage. Aquí solo simulamos una
//   espera de 1 segundo.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/core/router/routes.dart';

/// Estado de la sesión: true = sesión iniciada.
class AuthController extends Notifier<bool> {
  @override
  bool build() => false; // al abrir la app no hay sesión

  Future<void> login() async {
    await Future<void>.delayed(const Duration(seconds: 1)); // simula la API
    state = true;
  }

  void logout() => state = false;
}

final authProvider = NotifierProvider<AuthController, bool>(AuthController.new);

/// Pantalla de inicio de sesión (simulada).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).login();
    // No hace falta navegar: el redirect del router detecta la sesión y nos
    // lleva automáticamente a la ruta original.
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_outlined, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Has intentado abrir una ruta protegida. El router te ha '
                'redirigido aquí porque no hay sesión iniciada.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _login,
                icon: _loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Entrar (simulado)'),
              ),
              TextButton(
                // canPop: ¿hay una pantalla anterior a la que volver?
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.examples),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla privada: solo se ve con sesión iniciada.
class PrivateScreen extends ConsumerWidget {
  const PrivateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zona privada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user, size: 72, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                '¡Bienvenido! Solo puedes ver esta pantalla con sesión '
                'iniciada. Vuelve a la demo e intenta abrirla de nuevo: '
                'ya no te pedirá iniciar sesión.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  // Salimos de la zona privada. Si no lo hiciéramos, el
                  // redirect nos mandaría a /login al detectar el cierre.
                  context.go(AppRoutes.navigation);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

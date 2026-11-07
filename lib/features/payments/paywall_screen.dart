// ============================================================================
// lib/features/payments/paywall_screen.dart — DEMO: SUSCRIPCIONES (paywall)
// ============================================================================
//
// QUÉ ENSEÑA
//   El "paywall" es la pantalla que vende la versión Pro de una app. Es la
//   forma más común de monetizar apps hoy. Elementos que NO pueden faltar
//   (las tiendas los exigen o mejoran la conversión):
//   - Beneficios claros (qué obtiene el usuario).
//   - Planes con precio por periodo y el plan recomendado destacado.
//   - Prueba gratuita (trial) bien explicada.
//   - "Restaurar compras" (OBLIGATORIO en iOS).
//   - Enlaces a Términos y Privacidad + texto de renovación automática
//     (Apple rechaza la app si faltan).
//
// ⚠️ REGLA DE LAS TIENDAS
//   Contenido o funciones DIGITALES que se usan dentro de la app (Pro,
//   monedas, suscripciones) → hay que cobrarlos con la compra integrada de
//   Apple/Google (in_app_purchase o RevenueCat). Stripe/PayPal solo para
//   bienes o servicios FÍSICOS/externos (envíos, viajes, comida…).
//
// Aquí SubscriptionController SIMULA la compra. Cómo hacerlo de verdad con
// in_app_purchase o RevenueCat: docs/14-pagos.md.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

enum Plan { monthly, yearly, lifetime }

extension PlanInfo on Plan {
  String get title => switch (this) {
    Plan.monthly => 'Mensual',
    Plan.yearly => 'Anual',
    Plan.lifetime => 'De por vida',
  };

  /// En una app real los precios llegan de la tienda (ya localizados en la
  /// moneda del usuario): NUNCA los escribas a mano.
  String get price => switch (this) {
    Plan.monthly => r'$4,99 / mes',
    Plan.yearly => r'$39,99 / año',
    Plan.lifetime => r'$99,99 una vez',
  };

  String? get badge => switch (this) {
    Plan.yearly => 'AHORRA 33 %',
    _ => null,
  };
}

/// Estado de la suscripción (simulado). En producción lo daría la tienda o
/// RevenueCat (CustomerInfo.entitlements).
class SubscriptionController extends Notifier<Plan?> {
  @override
  Plan? build() => null; // null = usuario gratuito

  Future<void> purchase(Plan plan) async {
    await Future<void>.delayed(const Duration(seconds: 2)); // la tienda
    state = plan;
  }

  Future<bool> restore() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return state != null; // en la demo no hay compras previas que restaurar
  }

  void cancel() => state = null;
}

final subscriptionProvider = NotifierProvider<SubscriptionController, Plan?>(
  SubscriptionController.new,
);

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Plan _selected = Plan.yearly; // el plan recomendado viene preseleccionado
  bool _busy = false;

  Future<void> _purchase() async {
    setState(() => _busy = true);
    await ref.read(subscriptionProvider.notifier).purchase(_selected);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore() async {
    final messenger = ScaffoldMessenger.of(context);
    final restored = await ref.read(subscriptionProvider.notifier).restore();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          restored
              ? 'Compras restauradas'
              : 'No encontramos compras anteriores en esta cuenta',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(subscriptionProvider);
    return DemoScaffold(
      title: 'Suscripción (paywall)',
      explanation:
          'Pantalla para vender la versión Pro: beneficios, planes, prueba '
          'gratis, restaurar compras y textos legales. La compra está '
          'simulada; en una app real se usa in_app_purchase o RevenueCat.',
      sourceFile: 'lib/features/payments/paywall_screen.dart',
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: current == null
            ? _offer(context)
            : _ProView(
                plan: current,
                onCancel: () =>
                    ref.read(subscriptionProvider.notifier).cancel(),
              ),
      ),
    );
  }

  Widget _offer(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('offer'),
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.workspace_premium, size: 72, color: colors.primary),
        const SizedBox(height: 8),
        Text(
          'Desbloquea Flutter Pro',
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        for (final benefit in const [
          'Proyectos guiados paso a paso',
          'Plantillas de apps listas para publicar',
          'Asistente de IA sin límites',
          'Sin anuncios',
        ])
          ListTile(
            dense: true,
            leading: Icon(Icons.check_circle, color: colors.primary),
            title: Text(benefit),
          ),
        const SizedBox(height: 8),
        for (final plan in Plan.values)
          _PlanCard(
            plan: plan,
            selected: plan == _selected,
            onTap: () => setState(() => _selected = plan),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _busy ? null : _purchase,
            child: _busy
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _selected == Plan.lifetime
                        ? 'Comprar'
                        : 'Empezar 7 días gratis',
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // Texto legal de renovación automática (Apple lo exige).
        Text(
          _selected == Plan.lifetime
              ? 'Pago único. Sin renovaciones.'
              : 'Gratis 7 días, después ${_selected.price}. Se renueva '
                    'automáticamente; cancela cuando quieras en los ajustes de '
                    'tu cuenta de la tienda.',
          textAlign: TextAlign.center,
          style: text.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(onPressed: _restore, child: const Text('Restaurar')),
            TextButton(onPressed: () {}, child: const Text('Términos')),
            TextButton(onPressed: () {}, child: const Text('Privacidad')),
          ],
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2.5 : 1,
            ),
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.4)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? colors.primary : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(plan.price),
                  ],
                ),
              ),
              if (plan.badge != null)
                Chip(
                  label: Text(plan.badge!),
                  backgroundColor: colors.primary,
                  labelStyle: TextStyle(color: colors.onPrimary, fontSize: 11),
                  side: BorderSide.none,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProView extends StatelessWidget {
  const _ProView({required this.plan, required this.onCancel});

  final Plan plan;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('pro'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 96, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '¡Eres Pro! ✨',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('Plan: ${plan.title}'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onCancel,
              child: const Text('Simular cancelación'),
            ),
          ],
        ),
      ),
    );
  }
}

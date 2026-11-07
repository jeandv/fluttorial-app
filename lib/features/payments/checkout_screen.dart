// ============================================================================
// lib/features/payments/checkout_screen.dart — DEMO: PANTALLA DE PAGO (checkout)
// ============================================================================
//
// QUÉ ENSEÑA (interfaz de pago típica de una tienda)
//   - Resumen del pedido: subtotal, impuestos y total con formato de moneda.
//   - Selección de método: tarjeta o Apple Pay / Google Pay según plataforma.
//   - Tarjeta VISUAL que se rellena mientras escribes.
//   - Formulario con formateo automático (TextInputFormatter), detección de
//     marca, validación Luhn, caducidad y CVV.
//   - Estado "procesando" (botón desactivado + spinner) para evitar dobles
//     cobros, y pantallas de éxito (recibo) y error (reintentar).
//
// ⚠️ MODO DEMO: ningún dato sale del teléfono. FakePaymentGateway simula las
//    respuestas. Usa las tarjetas de prueba de los chips.
//
// 📚 Guía completa (Stripe, Apple/Google Pay, reglas de las tiendas): docs/14-pagos.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/features/payments/card_utils.dart';
import 'package:mi_primera_app/features/payments/payment_gateway.dart';

/// Un producto del carrito. Precio en CÉNTIMOS (enteros: nunca double).
class CartItem {
  const CartItem(this.name, this.priceCents, this.quantity, this.icon);

  final String name;
  final int priceCents;
  final int quantity;
  final IconData icon;

  int get totalCents => priceCents * quantity;
}

const demoCart = <CartItem>[
  CartItem('Curso Flutter Pro', 4999, 1, Icons.school),
  CartItem('Pack de iconos', 999, 2, Icons.palette),
];

/// Impuesto de ejemplo (16 %). Se calcula en céntimos y se redondea.
const taxRate = 0.16;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  PaymentMethodType _method = PaymentMethodType.card;
  bool _processing = false;

  int get _subtotal => demoCart.fold(0, (sum, item) => sum + item.totalCents);
  int get _tax => (_subtotal * taxRate).round();
  int get _total => _subtotal + _tax;

  @override
  void initState() {
    super.initState();
    // Redibuja la tarjeta visual en cada tecla.
    for (final c in [_number, _holder, _expiry, _cvv]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_number, _holder, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  String _money(int cents) => NumberFormat.simpleCurrency(
    locale: Localizations.localeOf(context).toString(),
    name: 'USD',
  ).format(cents / 100);

  void _fillTestCard(String number) {
    _number.text = formatCardNumber(number);
    _holder.text = 'JEAN RONDON';
    _expiry.text = '12/${(DateTime.now().year + 3) % 100}';
    _cvv.text = '123';
  }

  Future<void> _pay() async {
    if (_method == PaymentMethodType.card &&
        !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _processing = true);

    final result = await ref
        .read(paymentGatewayProvider)
        .pay(
          PaymentRequest(
            amountCents: _total,
            currency: 'USD',
            method: _method,
            card: _method == PaymentMethodType.card
                ? DemoCardDetails(
                    number: _number.text,
                    expiry: _expiry.text,
                    cvv: _cvv.text,
                    holder: _holder.text,
                  )
                : null,
          ),
        );

    if (!mounted) return;
    setState(() => _processing = false);

    // `switch` sobre una sealed class: el compilador exige cubrir ambos casos.
    switch (result) {
      case PaymentSuccess():
        HapticFeedback.mediumImpact(); // vibración breve de confirmación
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) =>
                _ReceiptScreen(result: result, total: _money(_total)),
          ),
        );
      case PaymentFailure(:final message):
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.error_outline),
            title: const Text('Pago no completado'),
            content: Text(message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final walletMethod = isIOS
        ? PaymentMethodType.applePay
        : PaymentMethodType.googlePay;

    return DemoScaffold(
      title: 'Pago (checkout)',
      explanation:
          'Interfaz de pago completa: resumen del pedido, método de pago, '
          'tarjeta con validación en vivo y resultado. Es una DEMO: usa los '
          'chips de tarjetas de prueba; ningún dato sale del teléfono.',
      sourceFile: 'lib/features/payments/',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _DemoBanner(),
            const SizedBox(height: 16),
            // ------------------------------------------------ Resumen
            Text('Tu pedido', style: Theme.of(context).textTheme.titleMedium),
            for (final item in demoCart)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(item.icon)),
                title: Text(item.name),
                subtitle: Text('${item.quantity} × ${_money(item.priceCents)}'),
                trailing: Text(_money(item.totalCents)),
              ),
            const Divider(),
            _SummaryRow('Subtotal', _money(_subtotal)),
            _SummaryRow('Impuestos (16 %)', _money(_tax)),
            _SummaryRow('Total', _money(_total), bold: true),
            const SizedBox(height: 24),
            // ------------------------------------------- Método de pago
            Text(
              'Método de pago',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<PaymentMethodType>(
              segments: [
                const ButtonSegment(
                  value: PaymentMethodType.card,
                  icon: Icon(Icons.credit_card),
                  label: Text('Tarjeta'),
                ),
                ButtonSegment(
                  value: walletMethod,
                  icon: Icon(
                    isIOS ? Icons.apple : Icons.account_balance_wallet,
                  ),
                  label: Text(isIOS ? 'Apple Pay' : 'Google Pay'),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            const SizedBox(height: 16),
            // AnimatedSize: anima el cambio de altura al ocultar el formulario.
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _method == PaymentMethodType.card
                  ? _cardForm()
                  : _WalletInfo(isIOS: isIOS),
            ),
            const SizedBox(height: 24),
            // ------------------------------------------------- Botón pagar
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                // Desactivado mientras procesa: evita pagar dos veces.
                onPressed: _processing ? null : _pay,
                icon: _processing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock),
                label: Text(
                  _processing ? 'Procesando…' : 'Pagar ${_money(_total)}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '🔒 Pago cifrado. No guardamos los datos de tu tarjeta.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardForm() {
    final brand = detectBrand(_number.text);
    return Column(
      children: [
        _CardPreview(
          number: _number.text,
          holder: _holder.text,
          expiry: _expiry.text,
          brand: brand,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final (label, number) in [
              ('✅ Aprobada', '4242424242424242'),
              ('❌ Rechazada', '4000000000000002'),
              ('💸 Sin fondos', '4000000000009995'),
            ])
              ActionChip(
                label: Text(label),
                onPressed: () => _fillTestCard(number),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _number,
          decoration: InputDecoration(
            labelText: 'Número de tarjeta',
            prefixIcon: const Icon(Icons.credit_card),
            suffixText: brand == CardBrand.unknown ? null : brand.label,
          ),
          keyboardType: TextInputType.number,
          // Formateadores: solo dígitos + agrupar en bloques.
          inputFormatters: [CardNumberInputFormatter()],
          autofillHints: const [AutofillHints.creditCardNumber],
          validator: validateCardNumber,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _holder,
          decoration: const InputDecoration(
            labelText: 'Nombre del titular',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.characters,
          autofillHints: const [AutofillHints.creditCardName],
          validator: (v) =>
              (v == null || v.trim().length < 3) ? 'Introduce el nombre' : null,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiry,
                decoration: const InputDecoration(
                  labelText: 'Caducidad',
                  hintText: 'MM/AA',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ExpiryInputFormatter()],
                autofillHints: const [AutofillHints.creditCardExpirationDate],
                validator: (v) => validateExpiry(v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvv,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '•' * brand.cvvLength,
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(brand.cvvLength),
                ],
                autofillHints: const [AutofillHints.creditCardSecurityCode],
                validator: (v) => validateCvv(v, brand),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, color: colors.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'MODO DEMO: no se cobra nada y ningún dato sale del teléfono. '
              'Usa las tarjetas de prueba.',
              style: TextStyle(color: colors.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// Tarjeta visual con degradado según la marca.
class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.number,
    required this.holder,
    required this.expiry,
    required this.brand,
  });

  final String number;
  final String holder;
  final String expiry;
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final colors = switch (brand) {
      CardBrand.visa => [const Color(0xFF1A237E), const Color(0xFF3949AB)],
      CardBrand.mastercard => [
        const Color(0xFFB71C1C),
        const Color(0xFFFF8F00),
      ],
      CardBrand.amex => [const Color(0xFF00695C), const Color(0xFF26A69A)],
      CardBrand.discover => [const Color(0xFFE65100), const Color(0xFFFFB74D)],
      CardBrand.unknown => [const Color(0xFF37474F), const Color(0xFF78909C)],
    };
    const white = TextStyle(color: Colors.white);
    // AspectRatio 1.586 = proporción real de una tarjeta (85,6 × 54 mm).
    return AspectRatio(
      aspectRatio: 1.586,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, 8),
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: Colors.amber, size: 36),
                const Spacer(),
                Text(
                  brand.label,
                  style: white.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              child: Text(
                number.isEmpty ? '•••• •••• •••• ••••' : number,
                style: white.copyWith(fontSize: 22, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    holder.isEmpty ? 'NOMBRE APELLIDO' : holder.toUpperCase(),
                    style: white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(expiry.isEmpty ? 'MM/AA' : expiry, style: white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletInfo extends StatelessWidget {
  const _WalletInfo({required this.isIOS});

  final bool isIOS;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          isIOS
              ? 'Apple Pay usa la tarjeta guardada en Wallet y Face ID. En una '
                    'app real se integra con el paquete `pay` o con la hoja de '
                    'pago de Stripe (ver docs/14).'
              : 'Google Pay usa la tarjeta guardada en tu cuenta de Google. En '
                    'una app real se integra con el paquete `pay` o con la hoja '
                    'de pago de Stripe (ver docs/14).',
        ),
      ),
    );
  }
}

/// Recibo tras un pago correcto.
class _ReceiptScreen extends StatelessWidget {
  const _ReceiptScreen({required this.result, required this.total});

  final PaymentSuccess result;
  final String total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pago completado')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TweenAnimationBuilder: el check "crece" al aparecer.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 96,
                ),
              ),
              const SizedBox(height: 16),
              Text('¡Gracias por tu compra!', style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(total, style: text.displaySmall),
              const SizedBox(height: 16),
              Text('Pagado con ${result.summary}'),
              SelectableText(
                'ID: ${result.transactionId}',
                style: text.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

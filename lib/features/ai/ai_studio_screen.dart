// ============================================================================
// lib/features/ai/ai_studio_screen.dart — DEMO: ESTUDIO DE IA
// ============================================================================
//
// QUÉ ENSEÑA (3 usos de la IA generativa en una app)
//   1. Consejos   → texto en STREAMING (aparece palabra a palabra).
//   2. Documentos → generar textos útiles (descripción de tienda, README,
//                   privacidad…) renderizados como Markdown, para copiar o
//                   compartir.
//   3. Imágenes   → la IA genera código SVG (gráfico vectorial) que se dibuja
//                   con flutter_svg. Para FOTOS/imágenes realistas se usa un
//                   modelo de imagen (ver docs/15).
//
// CÓMO SE CONSUME UN STREAM EN LA UI
//   stream.listen((trozo) => setState(() => texto += trozo))
//   y se cancela la suscripción en dispose() o al pulsar "Detener".
//
// Sin API key funciona en MODO DEMO (respuestas de ejemplo).
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/features/ai/ai_service.dart';
import 'package:share_plus/share_plus.dart';

class AiStudioScreen extends ConsumerWidget {
  const AiStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(aiServiceProvider).isDemo;
    return DefaultTabController(
      length: 3,
      child: DemoScaffold(
        title: 'Estudio IA',
        explanation:
            'Tres usos de la IA generativa con Claude: consejos en streaming, '
            'redacción de documentos en Markdown e ilustraciones SVG. Sin API '
            'key funciona en modo demo. Configuración en docs/15.',
        sourceFile: 'lib/features/ai/',
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.lightbulb_outline), text: 'Consejos'),
            Tab(icon: Icon(Icons.description_outlined), text: 'Documentos'),
            Tab(icon: Icon(Icons.brush_outlined), text: 'Imágenes'),
          ],
        ),
        body: Column(
          children: [
            if (isDemo) const AiDemoBanner(),
            const Expanded(
              child: TabBarView(
                children: [_TipsTab(), _DocsTab(), _ImageTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso visible cuando no hay IA real configurada.
class AiDemoBanner extends StatelessWidget {
  const AiDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colors.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'MODO DEMO: respuestas de ejemplo. Para usar Claude de verdad, ejecuta '
        'con --dart-define-from-file=config/secrets.json (ver docs/15).',
        style: TextStyle(color: colors.onTertiaryContainer, fontSize: 12),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lógica común de las pestañas con texto en streaming.
// ---------------------------------------------------------------------------

/// Mixin reutilizable: gestiona la suscripción al stream, el texto acumulado,
/// el estado de carga y los errores.
mixin _StreamingText<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  StreamSubscription<String>? _sub;
  String output = '';
  String? error;
  bool get isStreaming => _sub != null;

  void startStream(Stream<String> stream) {
    _sub?.cancel();
    setState(() {
      output = '';
      error = null;
    });
    _sub = stream.listen(
      (chunk) => setState(() => output += chunk), // ← cada trozo nuevo
      onError: (Object e) => setState(() {
        error = e.toString();
        _sub = null;
      }),
      onDone: () => setState(() => _sub = null),
    );
  }

  void stopStream() {
    _sub?.cancel();
    setState(() => _sub = null);
  }

  @override
  void dispose() {
    _sub?.cancel(); // ⚠️ siempre cancelar: si no, sigue llamando a setState
    super.dispose();
  }

  /// Resultado en Markdown + botones copiar/compartir.
  Widget buildOutput() {
    if (error != null) {
      return Text(
        '❌ $error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    if (output.isEmpty) {
      return isStreaming
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            // flutter_markdown_plus convierte el Markdown en widgets.
            child: MarkdownBody(data: output, selectable: true),
          ),
        ),
        if (!isStreaming)
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: output));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copiado al portapapeles')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
              TextButton.icon(
                onPressed: () =>
                    SharePlus.instance.share(ShareParams(text: output)),
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
              ),
            ],
          ),
      ],
    );
  }

  Widget actionButton({required String label, required VoidCallback onStart}) {
    return FilledButton.icon(
      onPressed: isStreaming ? stopStream : onStart,
      icon: Icon(isStreaming ? Icons.stop : Icons.auto_awesome),
      label: Text(isStreaming ? 'Detener' : label),
    );
  }
}

// ---------------------------------------------------------------- CONSEJOS

class _TipsTab extends ConsumerStatefulWidget {
  const _TipsTab();

  @override
  ConsumerState<_TipsTab> createState() => _TipsTabState();
}

class _TipsTabState extends ConsumerState<_TipsTab>
    with _StreamingText<_TipsTab> {
  final _topic = TextEditingController(text: 'gestión de estado en Flutter');

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _topic,
          decoration: const InputDecoration(
            labelText: '¿Sobre qué quieres consejos?',
            prefixIcon: Icon(Icons.lightbulb_outline),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final t in const [
              'publicar en App Store',
              'rendimiento de listas',
              'diseño de onboarding',
              'monetizar una app',
            ])
              ActionChip(label: Text(t), onPressed: () => _topic.text = t),
          ],
        ),
        const SizedBox(height: 12),
        actionButton(
          label: 'Generar consejos',
          onStart: () =>
              startStream(ref.read(aiServiceProvider).tips(_topic.text)),
        ),
        const SizedBox(height: 16),
        buildOutput(),
      ],
    );
  }
}

// -------------------------------------------------------------- DOCUMENTOS

class _DocsTab extends ConsumerStatefulWidget {
  const _DocsTab();

  @override
  ConsumerState<_DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends ConsumerState<_DocsTab>
    with _StreamingText<_DocsTab> {
  DocKind _kind = DocKind.storeDescription;
  final _brief = TextEditingController(
    text:
        'App guía para aprender Flutter con ejemplos interactivos: mapas, '
        'pagos, IA, tareas y más.',
  );

  @override
  void dispose() {
    _brief.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<DocKind>(
          initialValue: _kind,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Tipo de documento'),
          items: [
            for (final k in DocKind.values)
              DropdownMenuItem(value: k, child: Text(k.label)),
          ],
          onChanged: (k) => setState(() => _kind = k!),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _brief,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Describe tu app o el contexto',
          ),
        ),
        const SizedBox(height: 12),
        actionButton(
          label: 'Redactar',
          onStart: () => startStream(
            ref.read(aiServiceProvider).document(_kind, _brief.text),
          ),
        ),
        const SizedBox(height: 16),
        buildOutput(),
      ],
    );
  }
}

// ----------------------------------------------------------------- IMÁGENES

class _ImageTab extends ConsumerStatefulWidget {
  const _ImageTab();

  @override
  ConsumerState<_ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends ConsumerState<_ImageTab> {
  final _prompt = TextEditingController(
    text: 'un cohete despegando sobre montañas al atardecer',
  );
  // Un Future en el estado + FutureBuilder: patrón para cargas puntuales.
  Future<String>? _svg;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _prompt,
          minLines: 1,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Describe la ilustración',
            prefixIcon: Icon(Icons.brush_outlined),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => setState(
            () => _svg = ref
                .read(aiServiceProvider)
                .svgIllustration(_prompt.text),
          ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generar ilustración'),
        ),
        const SizedBox(height: 8),
        Text(
          'Claude genera gráficos VECTORIALES (código SVG): ideales para '
          'iconos, ilustraciones y diagramas. Para fotos realistas se usa un '
          'modelo de imagen como Imagen o GPT Image (ver docs/15).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (_svg != null)
          FutureBuilder<String>(
            future: _svg,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) return Text('❌ ${snapshot.error}');
              final svg = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      // flutter_svg dibuja el SVG a cualquier tamaño sin perder
                      // calidad. errorBuilder: si el SVG viene mal formado.
                      child: SvgPicture.string(
                        svg,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => const Center(
                          child: Text('El SVG generado no es válido'),
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: svg)),
                    icon: const Icon(Icons.code),
                    label: const Text('Copiar código SVG'),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

// ============================================================================
// lib/features/ai/agent_screen.dart — DEMO: CHAT CON UN AGENTE DE IA
// ============================================================================
//
// QUÉ ENSEÑA
//   - Interfaz de chat (burbujas de usuario y asistente, autoscroll).
//   - Ver "por dentro" a un agente: cada herramienta que usa y su resultado.
//   - El agente modifica DATOS REALES de la app: abre la pestaña Tareas
//     después de hablar con él.
//   - Inyección de dependencias: el agente recibe funciones que leen y
//     escriben en todosProvider (Riverpod).
//
// La lógica del agente (el bucle de herramientas) está en todo_agent.dart.
// ============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/features/ai/ai_service.dart';
import 'package:mi_primera_app/features/ai/ai_studio_screen.dart';
import 'package:mi_primera_app/features/ai/todo_agent.dart';
import 'package:mi_primera_app/features/todos/todos_controller.dart';

/// Crea el agente conectado a la lista de tareas real.
final todoAgentProvider = Provider.autoDispose<TodoAgent>((ref) {
  final tools = TodoToolbox(
    list: () => ref.read(todosProvider),
    add: (title) => ref.read(todosProvider.notifier).add(title),
    toggle: (id) => ref.read(todosProvider.notifier).toggle(id),
  );
  final client = ref.watch(claudeClientProvider);
  return client == null ? DemoTodoAgent(tools) : ClaudeTodoAgent(client, tools);
});

/// Un elemento del chat: mensaje del usuario o evento del agente.
sealed class _ChatItem {}

class _UserItem extends _ChatItem {
  _UserItem(this.text);
  final String text;
}

class _AgentItem extends _ChatItem {
  _AgentItem(this.event);
  final AgentEvent event;
}

class AgentScreen extends ConsumerStatefulWidget {
  const AgentScreen({super.key});

  @override
  ConsumerState<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends ConsumerState<AgentScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatItem> _items = [];
  bool _working = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _working) return;
    _input.clear();
    setState(() {
      _items.add(_UserItem(text));
      _working = true;
    });
    _scrollToEnd();

    try {
      // `await for` consume el Stream de eventos del agente uno a uno.
      await for (final event in ref.read(todoAgentProvider).send(text)) {
        if (!mounted) return;
        setState(() => _items.add(_AgentItem(event)));
        _scrollToEnd();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _items.add(_AgentItem(AgentText('❌ $e'))));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _scrollToEnd() {
    // Espera al siguiente frame (cuando el nuevo mensaje ya se dibujó).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final agent = ref.watch(todoAgentProvider);
    final pending = ref.watch(pendingCountProvider);

    return DemoScaffold(
      title: 'Agente IA',
      explanation:
          'Un agente usa herramientas (funciones de la app) para cumplir lo que '
          'pides: aquí lista, añade y completa tareas de la pestaña Tareas. '
          'Verás cada herramienta que decide usar. Lógica en todo_agent.dart.',
      sourceFile: 'lib/features/ai/todo_agent.dart',
      body: Column(
        children: [
          if (agent.isDemo) const AiDemoBanner(),
          ListTile(
            dense: true,
            leading: const Icon(Icons.checklist),
            title: Text('Tareas pendientes ahora: $pending'),
            trailing: TextButton(
              onPressed: () {
                agent.reset();
                setState(_items.clear);
              },
              child: const Text('Nueva charla'),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _items.isEmpty
                ? _Suggestions(onTap: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length + (_working ? 1 : 0),
                    itemBuilder: (context, i) => i == _items.length
                        ? const _Thinking()
                        : _ChatBubble(item: _items[i]),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: !_working,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ej.: añade comprar pan y llamar a Ana',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _working ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});

  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.smart_toy_outlined, size: 64),
        const SizedBox(height: 12),
        const Text(
          'Pídeme que gestione tus tareas. Uso herramientas reales de la app.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        for (final s in const [
          'Añade comprar leche y llamar a mamá',
          '¿Qué tareas tengo pendientes?',
          'Marca como hecha la de leche',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(onPressed: () => onTap(s), child: Text(s)),
          ),
      ],
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(8),
    child: Row(
      children: [
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 8),
        Text('Pensando…'),
      ],
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.item});

  final _ChatItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (item) {
      _UserItem(:final text) => Align(
        alignment: Alignment.centerRight,
        child: _bubble(text, colors.primary, colors.onPrimary),
      ),
      _AgentItem(event: AgentText(:final text)) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: MarkdownBody(data: text),
        ),
      ),
      // Llamadas a herramientas: se muestran como "chips" técnicos.
      _AgentItem(event: AgentToolCall(:final name, :final input)) => _toolLine(
        context,
        '🔧 $name(${input.isEmpty ? '' : jsonEncode(input)})',
        colors.secondary,
      ),
      _AgentItem(event: AgentToolResult(:final output, :final isError)) =>
        _toolLine(
          context,
          '${isError ? '⚠️' : '↳'} $output',
          isError ? colors.error : colors.outline,
        ),
    };
  }

  Widget _bubble(String text, Color bg, Color fg) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(12),
    constraints: const BoxConstraints(maxWidth: 300),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(text, style: TextStyle(color: fg)),
  );

  Widget _toolLine(BuildContext context, String text, Color color) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
    child: Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(fontFamily: 'monospace', color: color),
    ),
  );
}

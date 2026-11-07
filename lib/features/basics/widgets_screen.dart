// ============================================================================
// lib/features/basics/widgets_screen.dart — DEMO BÁSICA: WIDGETS COMUNES
// ============================================================================
//
// QUÉ ENSEÑA
//   Los widgets que usarás en casi todas las apps:
//   - Texto con estilos del tema (textTheme).
//   - Botones: Filled, Elevated, Outlined, Text, Icon.
//   - Controles: Switch, Checkbox, Slider, SegmentedButton.
//   - Feedback: SnackBar, AlertDialog, BottomSheet.
//   - Contenido: Card, ListTile, CircleAvatar, Chips, Badge, Tooltip.
//
// CÓMO FUNCIONA
//   Es un StatefulWidget porque los controles (switch, slider…) tienen valor.
//   Cada control recibe su valor actual y una función `onChanged` que, con
//   setState, guarda el nuevo valor → Flutter redibuja el control.
//   Esto se llama "widget controlado": el estado vive fuera del control.
//
// 📚 Catálogo completo de widgets: https://docs.flutter.dev/ui/widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

enum _Size { small, medium, large }

class WidgetsScreen extends StatefulWidget {
  const WidgetsScreen({super.key});

  @override
  State<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends State<WidgetsScreen> {
  bool _notifications = true;
  bool? _accepted = false;
  double _volume = 40;
  _Size _size = _Size.medium;
  final Set<String> _selectedChips = {'Dart'};

  /// SnackBar: mensaje breve en la parte inferior.
  /// ScaffoldMessenger se encarga de mostrarlo aunque cambies de pantalla.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // ".." = cascada: varias llamadas al mismo objeto
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
  }

  /// Diálogo de confirmación. `showDialog` devuelve un Future con el valor
  /// pasado a Navigator.pop(context, valor) → así sabemos qué eligió.
  Future<void> _showConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('¿Eliminar elemento?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    // Tras un `await`, el widget podría haberse cerrado: comprobar `mounted`
    // antes de usar `context` evita errores.
    if (!mounted) return;
    _showSnackBar(confirmed == true ? 'Eliminado' : 'Cancelado');
  }

  /// Hoja inferior con opciones. Devuelve la opción elegida.
  Future<void> _showOptionsSheet() async {
    final option = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (icon, label) in [
              (Icons.share, 'Compartir'),
              (Icons.edit, 'Editar'),
              (Icons.delete, 'Eliminar'),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                onTap: () => Navigator.pop(context, label),
              ),
          ],
        ),
      ),
    );
    if (!mounted || option == null) return;
    _showSnackBar('Elegiste: $option');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return DemoScaffold(
      title: 'Widgets comunes',
      explanation:
          'Botones, controles y mensajes. Los controles son "widgets '
          'controlados": reciben su valor y avisan con onChanged; tú guardas '
          'el nuevo valor con setState.',
      sourceFile: 'lib/features/basics/widgets_screen.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: 'Texto',
            description:
                'Usa los estilos del tema (Theme.of(context).textTheme) en '
                'vez de tamaños fijos: respetan el tamaño de letra del usuario.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('headlineSmall', style: text.headlineSmall),
                Text('titleMedium', style: text.titleMedium),
                Text('bodyMedium', style: text.bodyMedium),
                Text('labelSmall', style: text.labelSmall),
                const Text.rich(
                  TextSpan(
                    text: 'Text.rich permite ',
                    children: [
                      TextSpan(
                        text: 'mezclar ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'estilos',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Botones',
            description:
                'De más a menos importante: Filled → Elevated/Tonal → '
                'Outlined → Text. onPressed: null desactiva el botón.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _showSnackBar('FilledButton'),
                  child: const Text('Filled'),
                ),
                FilledButton.tonal(
                  onPressed: () => _showSnackBar('Tonal'),
                  child: const Text('Tonal'),
                ),
                ElevatedButton(
                  onPressed: () => _showSnackBar('ElevatedButton'),
                  child: const Text('Elevated'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showSnackBar('OutlinedButton'),
                  icon: const Icon(Icons.download),
                  label: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () => _showSnackBar('TextButton'),
                  child: const Text('Text'),
                ),
                const FilledButton(onPressed: null, child: Text('Desactivado')),
                IconButton(
                  tooltip: 'Favorito', // texto al mantener pulsado
                  onPressed: () => _showSnackBar('IconButton'),
                  icon: const Icon(Icons.favorite_border),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Controles',
            description: 'Switch, Checkbox, Slider y SegmentedButton.',
            child: Column(
              children: [
                // Versiones "ListTile": fila completa tocable con texto.
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Notificaciones'),
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Acepto los términos'),
                  value: _accepted,
                  onChanged: (value) => setState(() => _accepted = value),
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        max: 100,
                        divisions: 10,
                        label: _volume.round().toString(),
                        onChanged: (value) => setState(() => _volume = value),
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                const SizedBox(height: 8),
                // SegmentedButton: elegir una opción entre pocas (sustituye a
                // los grupos de botones de radio).
                SegmentedButton<_Size>(
                  segments: const [
                    ButtonSegment(value: _Size.small, label: Text('S')),
                    ButtonSegment(value: _Size.medium, label: Text('M')),
                    ButtonSegment(value: _Size.large, label: Text('L')),
                  ],
                  selected: {_size},
                  onSelectionChanged: (selection) =>
                      setState(() => _size = selection.first),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Chips',
            description: 'FilterChip permite selección múltiple.',
            child: Wrap(
              spacing: 8,
              children: [
                for (final tag in ['Dart', 'Flutter', 'Firebase', 'Riverpod'])
                  FilterChip(
                    label: Text(tag),
                    selected: _selectedChips.contains(tag),
                    onSelected: (selected) => setState(
                      () => selected
                          ? _selectedChips.add(tag)
                          : _selectedChips.remove(tag),
                    ),
                  ),
              ],
            ),
          ),
          DemoSection(
            title: 'Diálogos, hojas y mensajes',
            description:
                'showDialog, showModalBottomSheet y SnackBar devuelven el '
                'resultado de la elección del usuario.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _showConfirmDialog,
                  child: const Text('Diálogo'),
                ),
                OutlinedButton(
                  onPressed: _showOptionsSheet,
                  child: const Text('Bottom sheet'),
                ),
                OutlinedButton(
                  onPressed: () => _showSnackBar('¡Hola desde un SnackBar!'),
                  child: const Text('SnackBar'),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Card, ListTile, Avatar y Badge',
            description: 'Bloques típicos para listas de contactos o mensajes.',
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const CircleAvatar(child: Text('JR')),
                title: const Text('Jean Rondon'),
                subtitle: const Text('Desarrollador Flutter'),
                trailing: Badge.count(
                  count: 3,
                  child: const Icon(Icons.mail_outline),
                ),
                onTap: () => _showSnackBar('Tocaste la tarjeta'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

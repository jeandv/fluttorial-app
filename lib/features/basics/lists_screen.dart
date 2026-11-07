// ============================================================================
// lib/features/basics/lists_screen.dart — DEMO BÁSICA: LISTAS Y CUADRÍCULAS
// ============================================================================
//
// QUÉ ENSEÑA
//   - ListView.builder: listas LARGAS eficientes (solo construye lo visible).
//   - ListView.separated: con separadores entre elementos.
//   - GridView.builder: cuadrículas.
//   - Dismissible: deslizar para borrar.
//   - RefreshIndicator: "tirar hacia abajo para recargar".
//   - TabBar + TabBarView: pestañas superiores con DefaultTabController.
//
// POR QUÉ .builder
//   ListView(children: [...]) crea TODOS los elementos aunque no se vean.
//   ListView.builder los crea "bajo demanda" mientras haces scroll. Con 1.000
//   elementos la diferencia de memoria y velocidad es enorme.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController conecta automáticamente el TabBar con el
    // TabBarView (sin crear un TabController a mano).
    return const DefaultTabController(
      length: 3,
      child: DemoScaffold(
        title: 'Listas',
        explanation:
            'ListView.builder construye solo los elementos visibles: úsalo '
            'para listas largas o de datos de una API. Desliza un elemento de '
            'la pestaña "Editable" para borrarlo y tira hacia abajo para '
            'recargar.',
        sourceFile: 'lib/features/basics/lists_screen.dart',
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'Builder'),
            Tab(icon: Icon(Icons.grid_view), text: 'Grid'),
            Tab(icon: Icon(Icons.swipe), text: 'Editable'),
          ],
        ),
        body: TabBarView(children: [_LongList(), _Grid(), _EditableList()]),
      ),
    );
  }
}

/// 1.000 elementos con ListView.builder.
class _LongList extends StatelessWidget {
  const _LongList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      // itemBuilder se llama SOLO para los índices visibles (+ un margen).
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text('Elemento ${index + 1}'),
        subtitle: const Text('Construido bajo demanda'),
      ),
    );
  }
}

/// Cuadrícula con columnas de ancho máximo (se adapta a móvil y tablet).
class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      // MaxCrossAxisExtent: "cada celda mide como máximo 140 px de ancho",
      // así el número de columnas depende del tamaño de la pantalla.
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 30,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          // Colors.primaries: lista de colores de Material.
          color: Colors.primaries[index % Colors.primaries.length],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

/// Lista con estado: deslizar para borrar y tirar para recargar.
class _EditableList extends StatefulWidget {
  const _EditableList();

  @override
  State<_EditableList> createState() => _EditableListState();
}

class _EditableListState extends State<_EditableList> {
  List<String> _items = _initialItems();

  static List<String> _initialItems() =>
      List.generate(8, (i) => 'Mensaje ${i + 1}');

  /// RefreshIndicator necesita una función que devuelva un Future: el
  /// indicador gira hasta que el Future termina.
  Future<void> _reload() async {
    await Future<void>.delayed(const Duration(seconds: 1)); // simula una API
    setState(() => _items = _initialItems());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        // Permite tirar hacia abajo aunque la lista sea corta o esté vacía.
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Dismissible(
            // ⚠️ La key debe ser ÚNICA y ESTABLE (no el índice): Flutter la
            // usa para saber qué elemento se eliminó.
            key: ValueKey(item),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              setState(() => _items.removeAt(index));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$item eliminado')));
            },
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(item),
              subtitle: const Text('Desliza a la izquierda para borrar'),
            ),
          );
        },
      ),
    );
  }
}

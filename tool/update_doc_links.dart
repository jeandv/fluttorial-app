// ============================================================================
// tool/update_doc_links.dart — ACTUALIZA LOS ENLACES "A LA LÍNEA" DE LOS DOCS
// ============================================================================
//
// QUÉ HACE
//   Los documentos (docs/*.md y los README) enlazan a líneas concretas del
//   código, por ejemplo:
//     [redirect](../lib/core/router/app_router.dart#L93 "→ redirect: (context, state)")
//   El texto entre comillas (después de →) es lo que se BUSCA en el archivo.
//   Si el código cambia y la línea se mueve, este script vuelve a buscar ese
//   texto y corrige el número de línea (#L93 → #L97).
//
//   También convierte marcadores escritos a mano con esta forma:
//     [texto](@L lib/ruta/archivo.dart :: texto a buscar)
//   (la ruta es relativa a la raíz del proyecto).
//
// CÓMO SE USA (desde la raíz del proyecto)
//   dart run tool/update_doc_links.dart
//
// Los enlaces #L funcionan en GitHub y en VS Code (Cmd+clic en el editor, o
// clic en la vista previa del Markdown: Cmd+Shift+V).
// ============================================================================

import 'dart:io';

/// Archivos Markdown que se procesan.
List<File> _markdownFiles() => [
  ...Directory('docs')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md')),
  for (final path in [
    'README.md',
    'lib/README.md',
    'test/README.md',
    'android/README.md',
    'ios/README.md',
  ])
    if (File(path).existsSync()) File(path),
];

/// Marcador nuevo: (@L ruta :: patrón)
final _marker = RegExp(r'\(@L (\S+) :: (.*?)\)(?=[\s|.,;]|$)', multiLine: true);

/// Enlace ya resuelto: (ruta#L12 "→ patrón")
final _resolved = RegExp(r'\(([^)\s]+?)#L\d+ "→ ([^"]+)"\)');

final _errors = <String>[];

/// ¿Es una línea de comentario? (Dart/Kotlin/Swift `//`, YAML `#`, XML `<!--`)
bool _isComment(String line) {
  final t = line.trimLeft();
  return t.startsWith('//') ||
      t.startsWith('#') ||
      t.startsWith('<!--') ||
      t.startsWith('*');
}

/// Devuelve el número de línea (1-based) donde aparece [pattern] en [file].
/// Prefiere líneas de CÓDIGO; si solo aparece en comentarios, usa la primera.
int? _findLine(String file, String pattern) {
  final f = File(file);
  if (!f.existsSync()) return null;
  final lines = f.readAsLinesSync();
  var index = lines.indexWhere((l) => l.contains(pattern) && !_isComment(l));
  if (index == -1) index = lines.indexWhere((l) => l.contains(pattern));
  return index == -1 ? null : index + 1;
}

/// Ruta de [target] (relativa a la raíz) vista desde la carpeta de [mdFile].
String _relative(String mdFile, String target) {
  final depth = mdFile.split('/').length - 1;
  return '${'../' * depth}$target';
}

/// Convierte una ruta relativa al .md en ruta relativa a la raíz.
String _toRoot(String mdFile, String link) {
  final parts = [...mdFile.split('/')..removeLast()];
  for (final segment in link.split('/')) {
    if (segment == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else if (segment != '.') {
      parts.add(segment);
    }
  }
  return parts.join('/');
}

String _link(String mdFile, String target, String pattern) {
  final line = _findLine(target, pattern);
  if (line == null) {
    _errors.add('$mdFile → no se encontró "$pattern" en $target');
    return '(${_relative(mdFile, target)})';
  }
  return '(${_relative(mdFile, target)}#L$line "→ $pattern")';
}

void main() {
  var updated = 0;
  for (final file in _markdownFiles()) {
    final mdPath = file.path.replaceFirst('./', '');
    final original = file.readAsStringSync();

    var text = original.replaceAllMapped(
      _marker,
      (m) => _link(mdPath, m[1]!, m[2]!),
    );
    text = text.replaceAllMapped(
      _resolved,
      (m) => _link(mdPath, _toRoot(mdPath, m[1]!), m[2]!),
    );

    if (text != original) {
      file.writeAsStringSync(text);
      updated++;
      stdout.writeln('✔ $mdPath');
    }
  }

  stdout.writeln('Archivos actualizados: $updated');
  if (_errors.isNotEmpty) {
    stderr.writeln('\n⚠️ Enlaces sin resolver (revisa el texto buscado):');
    _errors.forEach(stderr.writeln);
    exitCode = 1;
  }
}

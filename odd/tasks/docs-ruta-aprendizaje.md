# docs-ruta-aprendizaje — turn `docs/` from a reference manual into a learning path

Objective: deliver plan items P2–P5 of `~/.claude/plans/explora-docs-y-async-lark.md` for the Spanish Flutter guide in `docs/`. Branch: `main`. **NO commits, no branch** (user instruction, L3). Delivery: uncommitted working-tree changes.
Test runner / checks: `flutter test` (60 tests, must stay green) · `flutter analyze` (must stay clean) · link checker `python3 -I /private/tmp/claude-501/-Users-jeanrondon-Documents-dev-tutorial-mobile-dev-mi-primera-app/876ad109-e335-4090-ab2f-71a536aeed89/scratchpad/check_links.py .` (0 problems) · `dart run tool/update_doc_links.dart` (parent only).

## Specs

**S1 — Learning path.** New `docs/00-ruta-de-aprendizaje.md` (owner: parent). Fixed order: `01 → 02 → 04 → 05 → 06 → 16 → 10 → 07 → 11 → 17 → 13 → 14 → 15 → 08`. Reference docs, "de consulta, no se leen en orden": `03`, `09`, `12`. `README.md` index gets rows 00, 16, 17 and a pointer to `exercises/`.

**S2 — Per-document template.** Quoted from the plan: "Arriba: `Aprenderás · Necesitas antes · Tiempo`. Abajo: `Comprueba que entendiste` (3–5 preguntas con respuesta plegada en `<details>`) y `Siguiente paso`." Exact markup:

Top block of a TUTORIAL doc (01, 02, 04, 05, 06, 07, 08, 10, 11, 13, 14, 15, 16, 17), placed right below the `> Anterior: …` navigation line and before the first `---`:
```
> 🎯 **Aprenderás:** <1–3 concrete, checkable outcomes>
> 📋 **Necesitas antes:** <prior docs / knowledge, or "Nada: es el punto de partida">
> ⏱️ **Tiempo:** ~<N> min de lectura + ~<M> min practicando
```
Top block of a REFERENCE doc (03, 09, 12):
```
> 📖 **Documento de consulta:** no se lee de corrido; ábrelo cuando lo necesites.
> 🎯 **Te sirve para:** <when to open it>
> 🧭 **Ruta de aprendizaje:** [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md)
```
Bottom of a TUTORIAL doc, in this order, at the end of the file:
```
---

## ✅ Comprueba que entendiste

1. <question>
   <details><summary>Respuesta</summary>

   <1–3 sentences, with a link to code or section when it helps>

   </details>
2. …

## 🏋️ Reto            ← only if the doc has one (see S5)

## ➡️ Siguiente paso

Continúa con **[NN · Título](NN-archivo.md)**: <why it comes now>. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
```
Bottom of a REFERENCE doc: only `## ➡️ Siguiente paso` → "Vuelve a la [ruta de aprendizaje](00-ruta-de-aprendizaje.md)."
Questions: 3–5, answerable from the doc, at least one "¿por qué…?" or "¿qué pasa si…?", answers verified against the doc/code (no trivia, no invented facts).
"Siguiente paso" map: 01→02 · 02→04 · 04→05 · 05→06 · 06→16 · 16→10 · 10→07 · 07→11 · 11→17 · 17→13 · 13→14 · 14→15 · 15→08 · 08→ doc 00 ("¡Has completado la ruta!" + retos: `exercises/README.md`).
"Necesitas antes" (path order): 01 nada · 02 01 · 04 01–02 · 05 01 · 06 05 · 16 06 · 10 06 y 16 · 07 06 y 10 · 11 06 §4–§5 y 10 · 17 06 y 16 · 13 11 · 14 11 y 13 · 15 05 (async/streams) y 11 · 08 04 y 07.

**S3 — No forward references.** A doc must not rely on a concept first explained in a later doc. Known cases (line numbers approximate): 05 (`SingleTickerProviderStateMixin`/`ThemeExtension` in 05 §clases, `ref.watch(todoFilterProvider)`, `AsyncValue`), 06 (`ConsumerWidget` in the StatelessWidget/StatefulWidget 📂 box), 07 (`ProviderContainer`, `overrideWithValue`, isolates/`compute`), 03 (`riverpod_generator`/`build_runner` mentions), 09 (links to demos only explained in 10). Fix: use a pure-Dart or already-seen example, or add a one-line notice "→ lo verás en [doc §](link)". Do not delete useful 📂 code links: re-label them with the notice.

**S4 — Riverpod and go_router as lessons.** Quoted: "Riverpod y go_router como lección, no como tabla". Doc 06 §4 (navegación) and §5 (estado) teach the *why* with a minimal example; doc 11 §1/§2 stay as configuration reference. 06 §5 must include, before Riverpod: local vs shared state and *lifting state up* with a minimal example, then why Riverpod, `Provider`/`NotifierProvider`, `ref.watch` vs `ref.read`. 06 §4 must include imperative (`Navigator.push`) vs declarative (go_router URLs) in a concrete minimal example, `context.go` vs `context.push`, path parameters, and a pointer to `redirect`. Add as H3 inside the existing H2s (do not renumber H2s). Every full-class snippet is verified in a scratch copy of the project (see S8).

**S5 — Retos ("🏋️ Reto").** Heading exactly `## 🏋️ Reto` (docs that already have an exercises section keep it and add the test-backed info there; see 10 §8, 13 §5, 06 §13). Format:
```
## 🏋️ Reto

**<title>.** <1–3 sentence statement>.

- ✅ **Cómo saber que lo lograste:** <observable criterion; for test-backed: `flutter test exercises/<slug>_test.dart` pasa a verde>
- 💡 **Pista:** <one hint>
- 🔑 **Solución (inténtalo antes):** [<slug>](../exercises/solutions/<slug>.md)    ← test-backed only
```
Test-backed retos live in top-level `exercises/` (NOT in `test/`: `flutter test` and CI only run `test/`; `analysis_options.yaml` excludes `exercises/**` so `flutter analyze` stays green while the tests are red). Each exercise file is red on the base code and green with its solution (writer E verifies both in a scratch copy).

| Doc | Slug / title | Statement (Spanish, keep this intent) |
|---|---|---|
| 06 | `e01_contador_limite` · Límite en el contador | Desactiva el botón `+` cuando el contador llegue a 20 (igual que `−` está desactivado en 0). Archivo: `lib/features/basics/counter_screen.dart`. |
| 11 | `e02_todos_completar_todas` · Completar todas las tareas | Añade `completeAll()` a `TodosController`: marca todas las tareas como hechas **sin mutar el estado** y persiste el resultado, como hacen `toggle` y `clearCompleted`. |
| 05 | `e03_records_contar_tareas` · Cuenta tareas con un record | Crea `countTodos(List<Todo> todos)` en `lib/features/todos/todo_stats.dart`: devuelve un *record* con campos con nombre `pending` y `done`. |
| 10 | `e04_mi_demo` · Tu propia demo | Sigue los 5 pasos de esta sección para añadir una demo titulada `Mi demo` al catálogo (nivel básico) que se abra al tocarla y use `DemoScaffold`. |
| 15 | `e05_agente_herramienta` · Una herramienta nueva para el agente | Añade `clear_completed` a `TodoToolbox`: borra las tareas completadas y devuelve cuántas borró. |
| 13 | `e06_onboarding_indicador` · (ejercicio 3 existente) | Cambia el efecto del indicador por `WormEffect`. |

Retos without a test (criterion is observable by hand):
- 01 **Lee tu `flutter doctor`**: ejecuta `flutter doctor -v` y explica con tus palabras qué comprueba cada sección; resuelve cada ✗ con ayuda de [09]. Criterio: todo en verde o sabes explicar por qué no aplica.
- 02 **El mapa de memoria**: sin mirar, dibuja el árbol de carpetas de un proyecto Flutter y marca qué se edita, qué se genera y qué no se sube a git; compara con §1 y §4.
- 04 **Hot reload vs hot restart**: cambia un texto de `counter_screen.dart` y guarda (hot reload); luego cambia algo en `main()` y observa por qué `r` no basta (usa `R`).
- 07 **Tus propios tests**: escribe pruebas unitarias para `validateExpiry` (con `now` fijo): mes inválido, tarjeta caducada y fecha válida, sin copiar las de `payments_test.dart`. Criterio: `flutter test` en verde.
- 08 **¿Qué te falta para publicar?**: recorre la checklist de §1 con esta app y anota qué falta, sin cambiar nada.
- 14 **Las tarjetas de prueba**: prueba en el checkout simulado cada tarjeta de la tabla de pruebas de este doc y anota el mensaje que devuelve cada una.
- 16 **Mide los rebuilds**: activa «Track widget rebuilds» en DevTools, abre la demo Contador y mira qué widgets se reconstruyen al pulsar `+`; añade `const` donde puedas y compara.
- 17 **Hazla accesible**: activa VoiceOver/TalkBack (o `showSemanticsDebugger`) y recorre la demo Contador: ¿se entiende cada botón? Añade lo que falte.
- 03, 09, 12: no reto (reference docs).

**S6 — Two new docs.**
- `docs/16-como-piensa-flutter.md` (title "16 · Cómo piensa Flutter (modelos mentales)"). Sections, in order: 1 Los tres árboles (Widget, Element, RenderObject) · 2 `BuildContext`: tu posición en el árbol · 3 Restricciones: "las restricciones bajan, los tamaños suben" · 4 Rebuilds, `const` y por qué `build` debe ser barato · 5 Keys: cuándo importan · 6 Ciclo de vida de `State` (`initState`, `didChangeDependencies`, `didUpdateWidget`, `dispose`) · 7 ¿Quién es dueño del estado? (conceptual summary, ≤10 lines, link to 06 §5) · 8 Inmutabilidad: por qué no se muta el estado · 9 Navegación imperativa vs declarativa (≤10 lines, link to 06 §4) · 10 El event loop de Dart: microtasks, eventos e isolates · 11 Scroll: viewports y slivers.
- `docs/17-calidad-de-produccion.md` (title "17 · Calidad de producción: accesibilidad, errores y rendimiento"). Sections: 1 Accesibilidad (`Semantics`, escala de texto, contraste, áreas táctiles) · 2 Ciclo de vida de la app (`AppLifecycleListener`) · 3 Errores globales (`FlutterError.onError`, `PlatformDispatcher.instance.onError`) · 4 Rendimiento con DevTools (jank, rebuilds, UI vs raster, `RepaintBoundary`) · 5 Pruebas golden (`matchesGoldenFile`).
Both link to existing repo code via `[text](@L path :: pattern)` markers wherever a real example exists (e.g. `ValueKey` in `lib/features/todos/todos_screen.dart`, constraints comment in `lib/features/basics/layout_screen.dart`, `CustomScrollView` in `lib/features/catalog/catalog_screen.dart`, `textScalerOf` in `lib/features/advanced/responsive_screen.dart`). Conceptual-overlap rule: 06 owns the practical lessons (state, navigation); 16 holds only the conceptual summary and links to 06. Every API named must exist in current Flutter/Dart (verify with context7 docs when unsure); never invent behavior.

**S7 — One source per topic.** Quoted: "Una sola fuente por tema (el resto enlaza)". Dedupers only SHORTEN the non-canonical copies to a 1–2 sentence summary + link; they never move content, never change canonical sections, and keep any fact that is not already in the canonical section.

| Topic | Canonical source | Other docs |
|---|---|---|
| `--dart-define` / entornos / flavors | 11 §6 | 03, 04 §9, 08 §6, README: command + 1 line + link |
| Permiso INTERNET y permisos nativos | 06 §9 | 02, 08, 09, 11: link |
| go_router | lesson 06 §4 · reference 11 §1 | 10 §3.2: "dónde verlo" table only |
| Riverpod | lesson 06 §5 · reference 11 §2 | 10 §7 (Tareas): table only |
| i18n | 11 §4 | 06 §12: ≤10 lines + link; 10 §3.5 table only |
| Tema | 11 §3 | 06 §10: minimal snippet + link |
| HTTP | lesson 06 §8 · reference 11 §7 | 10 §3.4: table only |
| Código nativo | 11 §8 | 10 §4.3: table only |
| Tests | 07 | 11 §10: advanced only, links to 07 |
| Estructura | 02 (project tree) · 11 §0 (lib/ architecture) | 06 §2: keep beginner options, drop any third copy of this project's tree |
| Comandos run/devices/hot reload/build modes/DevTools | 04 (workflow, the why) | 03 keeps command tables only and links to 04; also 09 |
| "Hot reload no basta" | 04 | 03, 06 §6, 09: link |
| 12 §3 (7 tables of 7 columns) | 12 | fold detail tables inside `<details>`; keep the one-line summary table visible |
| Link walls (single lines of 400+ chars) | each doc | convert to bullet lists |

**S8 — Invariants.**
- Language: neutral/professional Spanish, second person "tú", same voice and emoji density as the existing docs. Code comments in Spanish.
- Do NOT rename, renumber or delete existing headings (other docs and the README link to their anchors). New sections/H3s are fine.
- New code links use the marker `[text](@L lib/path.dart :: pattern)`; the pattern must be a verbatim fragment of one code line and its parentheses must be balanced. Do NOT run `tool/update_doc_links.dart` (parent runs it once at the end).
- Links to other docs: relative path + GitHub-style anchor. Links to 00, 16, 17: file-level only (no anchors), because their headings are being written in parallel.
- No git write commands. No commits. No repo-wide formatters/generators/installs. Edit only your declared surfaces.
- Verify what you can: run the link checker and read only the lines of your own files; full-class Dart snippets and exercises are verified in a scratch copy of the project made with `mktemp -d` OUTSIDE the worktree (copy `pubspec.yaml`, `pubspec.lock`, `l10n.yaml`, `analysis_options.yaml`, `lib/`, `test/helpers/`; run `flutter pub get` there). Report scratch paths; the parent deletes them.
- Existing facts must stay accurate: when you shorten a duplicate, re-read the canonical section first.

## Tasks

| ID | Specs | Route | Owner / surface | Status | Evidence |
|---|---|---|---|---|---|
| T1 | all | inline | parent: this document, canonical decisions | done | feature doc written |
| T2 | S1 | inline | parent: `docs/00-…`, `README.md` | done (links to 16/17/exercises pending their writers) | docs/00 written, README rows 00/16/17 + pointer |
| T3 | S2 S3 S5 S7 | delegated (parallel units) | writer A: docs 01 02 03 04 08 09 | done (reported; seam check pending) | only unresolved link: ../exercises/README.md (writer E); 04 §1 now holds "Hot reload no basta"; answers checked vs doc text only |
| T4 | S2 S3 S4 S5 S7 | delegated (parallel units) | writer B: docs 05 06 07 | done (reported; seam check pending) | snippets verified in scratch (4 tests pass); scratch to delete: /var/folders/ns/_syddhcs7xxc4cmcb8lp3_rm0000gn/T/tmp.FaWdeKlEvQ ; @L markers unresolved until tool run |
| T5 | S2 S3 S5 S7 | delegated (parallel units) | writer C: docs 10 11 12 | done (reported; seam check pending) | doc 12 rows 183→183; 11 §6 now holds the unique --dart-define facts from 03/04/08; scratch helper scripts fold12.py, ed10.py in scratchpad |
| T6 | S2 S3 S5 S7 | delegated (parallel units) | writer D: docs 13 14 15 | done (reported; seam check pending) | writer report: only missing links are e05/e06 solutions (writer E); check e05 pista vs how the test builds `TodoToolbox` |
| T7 | S5 | delegated (parallel units) | writer E: `exercises/**`, `analysis_options.yaml` | done | RED/GREEN observed per exercise in scratch (15 tests green with solutions); scratch deleted |
| T8 | S6 | delegated (parallel units) | writer F: `docs/16-como-piensa-flutter.md` | done (reported; seam check pending) | 11 @L markers verified by grep; UNVERIFIED claims to check in seam: DevTools "Track widget rebuilds" menu/debug-only, Riverpod change detection wording (§8), mounted/didChangeDependencies rule, Isolate.run/compute, ListView-in-Column unbounded height |
| T9 | S6 | delegated (parallel units) | writer G: `docs/17-calidad-de-produccion.md` | done (reported; seam check pending) | golden + tap-target guideline run in scratch (deleted). UNVERIFIED in seam: withClampedTextScaling, ErrorWidget.builder, showSemanticsDebugger, DevTools labels, 16/8 ms budgets, 48dp/44pt, "tooltip exposed as semantics label" (bySemanticsLabel found nothing) |
| T10 | all | inline | parent seam | done | tool run: 0 unresolved after fixing 1 mangled link in doc 10; checker 901 links / 0 problems; analyze clean; 60 tests pass; dart format clean; review assess: unassessable (untracked files, nothing committed per L3) |

Route declaration: T3–T9 are seven independent units with disjoint edit surfaces, each several minutes of work (Writer trigger a, parallelism). T1, T2, T10 stay inline.

## Log

L1 (2026-11-14, user, verbatim): Explora @docs/ y dime que se podria mejorar para hacer mi aprendizaje de flutter mucho mejor.
L2 (2026-11-14, user, verbatim): Empieza
L3 (2026-11-14, user, verbatim): continua sin commitear no hace falta, sigue con lo que queda del plan.
L4 (2026-11-14): P1 (error fixes) finished before this feature started: README conflict markers, `tool/update_doc_links.dart` regex (balanced parentheses), 7 leaked fragments, docs 07 examples, misleading links, isar/pagos contradictions, doc 10 renumbering + map, 06 note, 15 beta header. Evidence: 676 relative links (400 `#L`) OK, `flutter analyze` clean, 60 tests pass.
L5: Design notes. Exercises live in `exercises/` (not `test/`) because a red test inside `test/` would break `flutter test`/CI, and `flutter analyze` would reject tests that reference code the learner has not written yet. Doc 17 is split from doc 16 to keep each doc short (cognitive load). The counter already has a reset button, so E01 is a maximum-value limit instead.

L6: Seam done. Not verified against live docs: DevTools menu labels, 16/8 ms budgets, tap-target minimums, Riverpod change-detection wording in doc 16 §8.

// ============================================================================
// lib/features/packages/maps/map_screen.dart — DEMO: MAPAS (flutter_map)
// ============================================================================
//
// QUÉ ENSEÑA
//   - flutter_map: mapa interactivo con OpenStreetMap (SIN API key, gratis).
//   - Capas (layers): teselas (TileLayer), marcadores (MarkerLayer),
//     rutas (PolylineLayer), círculos (CircleLayer) y atribución.
//   - MapController: mover la cámara, hacer zoom y encuadrar varios puntos
//     (CameraFit.coordinates) por código.
//   - Eventos: tocar el mapa para añadir marcadores, tocar un marcador para
//     ver su información.
//   - geolocator: pedir permiso y centrar el mapa en tu ubicación.
//   - latlong2: coordenadas (LatLng) y distancias reales.
//
// CÓMO FUNCIONA UN MAPA EN FLUTTER
//   El mapa del mundo se divide en "teselas" (tiles): imágenes de 256×256 px
//   para cada nivel de zoom. TileLayer descarga las que se ven en pantalla
//   desde una URL con el patrón {z}/{x}/{y}. Encima se dibujan capas con
//   widgets normales de Flutter (marcadores = cualquier widget).
//
// flutter_map vs google_maps_flutter
//   - flutter_map: puro Flutter, sin claves, cualquier proveedor de mapas
//     (OSM, Mapbox, MapTiler…). Ideal para aprender y para muchos proyectos.
//   - google_maps_flutter: SDK nativo de Google, requiere API key y cuenta de
//     facturación en Google Cloud. Muy demandado en empresas (ver docs/12).
//
// ⚠️ POLÍTICA DE USO DE OPENSTREETMAP
//   Los servidores de tile.openstreetmap.org son gratuitos pero limitados:
//   - Hay que mostrar la atribución "© OpenStreetMap contributors".
//   - Hay que identificar la app (userAgentPackageName).
//   - Para una app publicada con mucho tráfico, usa un proveedor de teselas
//     (MapTiler, Stadia, Mapbox, Thunderforest…) y cambia `urlTemplate`.
//   En modo debug flutter_map imprime en la consola un aviso recordándolo:
//   es informativo, no un error.
//
// 🧪 EN EL SIMULADOR
//   iOS: menú Features → Location → Custom Location… (ej. 10.4806, -66.9036)
//   Android: ⋯ (Extended controls) → Location → busca un lugar → Set location
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/features/packages/maps/map_data.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.locationService = const LocationService()});

  /// Inyectable para poder sustituirlo en tests.
  final LocationService locationService;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // MapController: controla la "cámara" del mapa (centro y zoom).
  final _mapController = MapController();

  final List<LatLng> _customMarkers = [];
  LatLng? _myLocation;
  bool _showRoute = true;
  bool _locating = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- ACCIONES

  void _zoom(double delta) {
    final camera = _mapController.camera; // estado actual de la cámara
    _mapController.move(camera.center, camera.zoom + delta);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _myLocation = location);
      _mapController.move(location, 15);
    } on LocationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.canOpenSettings
              ? SnackBarAction(
                  label: 'Ajustes',
                  onPressed: widget.locationService.openSettings,
                )
              : null,
        ),
      );
    } catch (e) {
      // Por ejemplo, tiempo de espera agotado sin señal GPS.
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo obtener: $e')));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Se llama al tocar el mapa: añade un marcador en ese punto.
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => _customMarkers.add(point));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Marcador añadido en ${formatLatLng(point)}')),
      );
  }

  void _showPlace(Place place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: Icon(place.icon, size: 36),
          title: Text(place.name),
          subtitle: Text('${place.description}\n${formatLatLng(place.point)}'),
          isThreeLine: true,
          trailing: IconButton(
            tooltip: 'Centrar aquí',
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {
              Navigator.pop(context);
              _mapController.move(place.point, 16);
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final routePoints = [for (final p in places) p.point];

    return DemoScaffold(
      title: 'Mapas',
      explanation:
          'flutter_map dibuja un mapa de OpenStreetMap sin API key. Toca un '
          'pin para ver su información, toca el mapa para añadir marcadores, '
          'usa ◎ para centrarte en tu ubicación (geolocator) y activa la ruta '
          'para ver la distancia calculada con latlong2.',
      sourceFile: 'lib/features/packages/maps/',
      body: Stack(
        children: [
          // ======================= EL MAPA =======================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: caracas,
              initialZoom: 13,
              // Encuadra TODOS los lugares al abrir (calcula centro y zoom
              // automáticamente). El padding deja sitio a los controles.
              initialCameraFit: CameraFit.coordinates(
                coordinates: routePoints,
                padding: const EdgeInsets.fromLTRB(40, 60, 80, 110),
              ),
              minZoom: 3,
              maxZoom: 19,
              onTap: _onMapTap,
            ),
            // Las capas se dibujan en orden: la primera queda debajo.
            children: [
              // 1. TESELAS: la imagen del mapa.
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Identifica la app ante el servidor (obligatorio en OSM).
                userAgentPackageName: 'com.jeanrondon.mi_primera_app',
              ),

              // 2. RUTA: línea que une los lugares en orden.
              if (_showRoute)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4,
                      color: colors.primary,
                    ),
                  ],
                ),

              // 3. CÍRCULO de precisión alrededor de tu ubicación.
              if (_myLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _myLocation!,
                      radius: 100, // metros (porque useRadiusInMeter: true)
                      useRadiusInMeter: true,
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // 4. MARCADORES: cualquier widget en una coordenada.
              MarkerLayer(
                markers: [
                  for (final place in places)
                    Marker(
                      point: place.point,
                      width: 44,
                      height: 44,
                      // topCenter: la PUNTA inferior del pin queda en el punto.
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _showPlace(place),
                        child: Icon(
                          Icons.location_pin,
                          size: 44,
                          color: colors.error,
                        ),
                      ),
                    ),
                  for (final point in _customMarkers)
                    Marker(
                      point: point,
                      width: 36,
                      height: 36,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.push_pin,
                        size: 36,
                        color: colors.tertiary,
                      ),
                    ),
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                ],
              ),

              // 5. ATRIBUCIÓN (obligatoria con OpenStreetMap).
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ================ CONTROLES SOBRE EL MAPA ================
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  tooltip: 'Acercar',
                  onPressed: () => _zoom(1),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  tooltip: 'Alejar',
                  onPressed: () => _zoom(-1),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.home_outlined,
                  tooltip: 'Ver todos los lugares',
                  onPressed: () => _mapController.fitCamera(
                    CameraFit.coordinates(
                      coordinates: [for (final p in places) p.point],
                      padding: const EdgeInsets.fromLTRB(40, 60, 80, 110),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _locating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      )
                    : _MapButton(
                        icon: Icons.my_location,
                        tooltip: 'Mi ubicación',
                        onPressed: _goToMyLocation,
                      ),
              ],
            ),
          ),

          // ===================== PANEL INFERIOR =====================
          Positioned(
            left: 12,
            right: 12,
            bottom: 28, // deja visible la atribución
            child: Card(
              margin: EdgeInsets.zero,
              color: colors.surface.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _showRoute
                            ? 'Ruta: ${places.length} lugares · '
                                  '${routeDistanceKm(routePoints).toStringAsFixed(1)} km'
                            : 'Toca el mapa para añadir marcadores '
                                  '(${_customMarkers.length})',
                      ),
                    ),
                    if (_customMarkers.isNotEmpty)
                      IconButton(
                        tooltip: 'Borrar mis marcadores',
                        icon: const Icon(Icons.delete_sweep_outlined),
                        onPressed: () => setState(_customMarkers.clear),
                      ),
                    Switch(
                      value: _showRoute,
                      onChanged: (v) => setState(() => _showRoute = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón redondo para los controles del mapa.
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

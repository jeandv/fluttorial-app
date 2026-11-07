// ============================================================================
// test/features/packages/map_data_test.dart — LÓGICA DEL MAPA SIN MAPA
// ============================================================================
// El mapa en sí necesita internet (teselas), pero los cálculos no: se
// prueban como funciones puras con latlong2.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mi_primera_app/features/packages/maps/map_data.dart';

void main() {
  test('routeDistanceKm: 0 km con menos de dos puntos', () {
    expect(routeDistanceKm([]), 0);
    expect(routeDistanceKm([caracas]), 0);
  });

  test('routeDistanceKm: 1° de latitud ≈ 111 km', () {
    final km = routeDistanceKm([const LatLng(0, 0), const LatLng(1, 0)]);
    expect(km, closeTo(110.6, 0.5));
  });

  test('la ruta de ejemplo por Caracas mide entre 5 y 30 km', () {
    final km = routeDistanceKm([for (final p in places) p.point]);
    expect(km, inInclusiveRange(5, 30));
  });

  test('formatLatLng usa 4 decimales', () {
    expect(
      formatLatLng(const LatLng(10.50613, -66.91462)),
      '10.5061, -66.9146',
    );
  });

  test('todos los lugares están cerca de Caracas (±0.2°)', () {
    for (final place in places) {
      expect(place.point.latitude, closeTo(caracas.latitude, 0.2));
      expect(place.point.longitude, closeTo(caracas.longitude, 0.2));
    }
  });
}

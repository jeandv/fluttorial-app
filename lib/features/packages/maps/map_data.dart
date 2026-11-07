// ============================================================================
// lib/features/packages/maps/map_data.dart — DATOS Y CÁLCULOS DEL MAPA
// ============================================================================
//
// QUÉ HACE
//   - Lugares de ejemplo (Caracas) con sus coordenadas.
//   - Cálculo de distancias con el paquete `latlong2`.
//   - LocationService: obtiene la ubicación del teléfono con `geolocator`,
//     gestionando los PERMISOS paso a paso.
//
// POR QUÉ ESTÁ SEPARADO DE LA PANTALLA
//   Los cálculos son funciones puras → se prueban sin dibujar el mapa
//   (test/features/packages/map_data_test.dart).
//
// COORDENADAS
//   LatLng(latitud, longitud). Latitud: norte(+)/sur(−). Longitud: este(+)/
//   oeste(−). Caracas ≈ LatLng(10.50, −66.91). Las de abajo son aproximadas.
//
// 📚 Guía: docs/12-librerias-mas-usadas.md (sección Mapas)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Un punto de interés del mapa.
@immutable
class Place {
  const Place(this.name, this.description, this.point, this.icon);

  final String name;
  final String description;
  final LatLng point;
  final IconData icon;
}

/// Centro inicial del mapa: Caracas, Venezuela.
const caracas = LatLng(10.4980, -66.8800);

/// Lugares de ejemplo (coordenadas aproximadas).
const places = <Place>[
  Place(
    'Plaza Bolívar',
    'Centro histórico de Caracas.',
    LatLng(10.5061, -66.9146),
    Icons.account_balance,
  ),
  Place(
    'Panteón Nacional',
    'Monumento histórico al norte del centro.',
    LatLng(10.5147, -66.9118),
    Icons.museum,
  ),
  Place(
    'Teleférico Warairarepano',
    'Estación Maripérez, subida al Ávila.',
    LatLng(10.5137, -66.8833),
    Icons.terrain,
  ),
  Place(
    'Universidad Central de Venezuela',
    'Ciudad Universitaria, Patrimonio de la UNESCO.',
    LatLng(10.4897, -66.8907),
    Icons.school,
  ),
  Place(
    'Parque del Este',
    'Uno de los parques urbanos más grandes de la ciudad.',
    LatLng(10.4947, -66.8423),
    Icons.park,
  ),
];

/// Distancia total (en km) de una ruta que pasa por [points] en orden.
///
/// `Distance()` de latlong2 calcula la distancia real sobre la superficie de
/// la Tierra (no una línea recta en un plano).
double routeDistanceKm(List<LatLng> points) {
  const distance = Distance();
  var meters = 0.0;
  for (var i = 1; i < points.length; i++) {
    meters += distance.as(LengthUnit.Meter, points[i - 1], points[i]);
  }
  return meters / 1000;
}

/// Formatea una coordenada para mostrarla: "10.5061, -66.9146".
String formatLatLng(LatLng p) =>
    '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';

// ---------------------------------------------------------------------------
// UBICACIÓN DEL USUARIO (geolocator)
// ---------------------------------------------------------------------------

/// Error con un mensaje listo para mostrar al usuario.
class LocationException implements Exception {
  const LocationException(this.message, {this.canOpenSettings = false});

  final String message;

  /// true si el usuario debe ir a Ajustes para dar el permiso.
  final bool canOpenSettings;

  @override
  String toString() => message;
}

/// Envuelve geolocator. El flujo de permisos es el mismo en cualquier app:
///   1. ¿Está el GPS activado?
///   2. ¿Tenemos permiso? → si no, pedirlo.
///   3. ¿Lo negó "para siempre"? → solo se puede activar desde Ajustes.
///   4. Leer la posición.
///
/// ⚠️ Requiere declarar el permiso en cada plataforma:
///   - iOS: NSLocationWhenInUseUsageDescription en ios/Runner/Info.plist
///   - Android: ACCESS_FINE_LOCATION en android/app/src/main/AndroidManifest.xml
class LocationService {
  const LocationService();

  Future<LatLng> getCurrentLocation() async {
    // 1. GPS activado
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'La ubicación está desactivada en el dispositivo.',
      );
    }

    // 2. Permiso (muestra el diálogo del sistema la primera vez)
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Permiso de ubicación denegado.');
      }
    }

    // 3. Negado permanentemente
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'El permiso está bloqueado. Actívalo en los Ajustes del teléfono.',
        canOpenSettings: true,
      );
    }

    // 4. Posición actual (con tiempo máximo de espera)
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// Abre la pantalla de ajustes de la app (para conceder el permiso).
  Future<bool> openSettings() => Geolocator.openAppSettings();
}

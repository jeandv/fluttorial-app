// ============================================================================
// test/features/packages/dio_client_test.dart — PROBAR DIO SIN INTERNET
// ============================================================================
//
// QUÉ ENSEÑA
//   Dio permite cambiar su "adaptador" (la pieza que realmente hace la
//   conexión). _FakeAdapter no usa la red: guarda la petición recibida y
//   devuelve la respuesta que le digamos. Así se prueba que:
//   - AuthInterceptor añade el token,
//   - LogCollectorInterceptor registra cada paso,
//   - los errores HTTP se traducen bien con describeDioError.
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/packages/dio/dio_client.dart';

/// "Servidor" falso: responde siempre [statusCode] con [body].
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200});

  final int statusCode;
  static const Object body = {'ok': true};
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late List<String> log;
  late _FakeAdapter adapter;
  late Dio dio;

  void setUpDio({int statusCode = 200, String? token = 'abc'}) {
    log = [];
    adapter = _FakeAdapter(statusCode: statusCode);
    dio = createDio(
      baseUrl: 'https://fake.api',
      readToken: () => token,
      onLog: log.add,
    )..httpClientAdapter = adapter; // ← sustituye la red real
  }

  test('AuthInterceptor añade la cabecera Authorization', () async {
    setUpDio(token: 'abc');
    await dio.get<Object?>('/users/1');
    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer abc');
  });

  test('sin token no se añade la cabecera', () async {
    setUpDio(token: null);
    await dio.get<Object?>('/users/1');
    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });

  test('Dio decodifica el JSON automáticamente', () async {
    setUpDio();
    final response = await dio.get<Map<String, Object?>>('/users/1');
    expect(response.data, {'ok': true});
  });

  test('LogCollectorInterceptor registra petición y respuesta', () async {
    setUpDio();
    await dio.get<Object?>('/users/1');
    expect(log, ['→ GET https://fake.api/users/1', '← 200 /users/1']);
  });

  test('un 404 lanza DioException badResponse con mensaje claro', () async {
    setUpDio(statusCode: 404);
    try {
      await dio.get<Object?>('/posts/999999');
      fail('Debía lanzar DioException');
    } on DioException catch (e) {
      expect(e.type, DioExceptionType.badResponse);
      expect(describeDioError(e), 'El servidor respondió con error 404.');
      expect(log.last, '✖ badResponse /posts/999999');
    }
  });
}

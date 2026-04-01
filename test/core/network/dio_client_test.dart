import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/core/network/dio_client.dart';

void main() {
  group('createDioClient', () {
    test('returns a Dio instance', () {
      expect(createDioClient(), isA<Dio>());
    });

    test('sets correct baseUrl', () {
      final dio = createDioClient();
      expect(dio.options.baseUrl, 'https://pokeapi.co/api/v2/');
    });

    test('sets connectTimeout to 10 seconds', () {
      final dio = createDioClient();
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
    });

    test('sets receiveTimeout to 10 seconds', () {
      final dio = createDioClient();
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });

    test('adds Content-Type header', () {
      final dio = createDioClient();
      expect(dio.options.headers['Content-Type'], 'application/json');
    });

    test('includes a RetryInterceptor', () {
      final dio = createDioClient();
      expect(
        dio.interceptors.whereType<RetryInterceptor>(),
        isNotEmpty,
      );
    });

    test('RetryInterceptor is configured with 3 retries', () {
      final dio = createDioClient();
      final retryInterceptor =
          dio.interceptors.whereType<RetryInterceptor>().first;
      expect(retryInterceptor.retries, 3);
    });
  });
}

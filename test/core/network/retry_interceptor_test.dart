import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/network/dio_client.dart';

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

RequestOptions _opts({Map<String, dynamic>? extra}) =>
    RequestOptions(path: '/test', extra: extra ?? {});

void main() {
  late RetryInterceptor interceptor;
  late MockDio mockDio;
  late MockErrorInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(_opts());
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );
    registerFallbackValue(
      Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ),
    );
  });

  setUp(() {
    mockDio = MockDio();
    mockHandler = MockErrorInterceptorHandler();
    interceptor = RetryInterceptor(dio: mockDio, retries: 3);
  });

  group('RetryInterceptor - no retry cases', () {
    test('should NOT retry for connectionError type', () async {
      final err = DioException(
        requestOptions: _opts(),
        type: DioExceptionType.connectionError,
      );

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
      verifyNever(() => mockDio.fetch(any()));
    });

    test('should NOT retry for badResponse type', () async {
      final err = DioException(
        requestOptions: _opts(),
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 404, requestOptions: _opts()),
      );

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
      verifyNever(() => mockDio.fetch(any()));
    });

    test('should NOT retry when retryCount has reached max retries', () async {
      final err = DioException(
        requestOptions: _opts(extra: {'retryCount': 3}),
        type: DioExceptionType.connectionTimeout,
      );

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
      verifyNever(() => mockDio.fetch(any()));
    });

    test('should NOT retry when retries is 0', () async {
      interceptor = RetryInterceptor(dio: mockDio, retries: 0);
      final err = DioException(
        requestOptions: _opts(),
        type: DioExceptionType.connectionTimeout,
      );

      interceptor.onError(err, mockHandler);

      verify(() => mockHandler.next(err)).called(1);
      verifyNever(() => mockDio.fetch(any()));
    });
  });

  group('RetryInterceptor - retry cases', () {
    test('should retry on connectionTimeout and resolve on success', () async {
      final opts = _opts();
      final err = DioException(
        requestOptions: opts,
        type: DioExceptionType.connectionTimeout,
      );
      final response =
          Response<dynamic>(data: {}, statusCode: 200, requestOptions: opts);

      when(() => mockDio.fetch(any())).thenAnswer((_) async => response);

      interceptor.onError(err, mockHandler);
      // Wait for the 500ms delay + async operations
      await Future.delayed(const Duration(milliseconds: 700));

      verify(() => mockDio.fetch(any())).called(1);
      verify(() => mockHandler.resolve(response)).called(1);
    });

    test('should retry on sendTimeout', () async {
      final opts = _opts();
      final err = DioException(
        requestOptions: opts,
        type: DioExceptionType.sendTimeout,
      );
      final response =
          Response<dynamic>(data: {}, statusCode: 200, requestOptions: opts);

      when(() => mockDio.fetch(any())).thenAnswer((_) async => response);

      interceptor.onError(err, mockHandler);
      await Future.delayed(const Duration(milliseconds: 700));

      verify(() => mockDio.fetch(any())).called(1);
    });

    test('should retry on receiveTimeout', () async {
      final opts = _opts();
      final err = DioException(
        requestOptions: opts,
        type: DioExceptionType.receiveTimeout,
      );
      final response =
          Response<dynamic>(data: {}, statusCode: 200, requestOptions: opts);

      when(() => mockDio.fetch(any())).thenAnswer((_) async => response);

      interceptor.onError(err, mockHandler);
      await Future.delayed(const Duration(milliseconds: 700));

      verify(() => mockDio.fetch(any())).called(1);
    });

    test('should call super.onError when fetch throws during retry', () async {
      final opts = _opts();
      final err = DioException(
        requestOptions: opts,
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockDio.fetch(any())).thenThrow(Exception('fetch failed'));

      interceptor.onError(err, mockHandler);
      await Future.delayed(const Duration(milliseconds: 700));

      verify(() => mockHandler.next(err)).called(1);
    });

    test('should retry when err.error is an Exception', () async {
      final opts = _opts();
      final err = DioException(
        requestOptions: opts,
        type: DioExceptionType.unknown,
        error: Exception('some exception'),
      );
      final response =
          Response<dynamic>(data: {}, statusCode: 200, requestOptions: opts);

      when(() => mockDio.fetch(any())).thenAnswer((_) async => response);

      interceptor.onError(err, mockHandler);
      await Future.delayed(const Duration(milliseconds: 700));

      verify(() => mockDio.fetch(any())).called(1);
    });
  });

  group('RetryInterceptor - constructor', () {
    test('should use default retries value of 3', () {
      final ri = RetryInterceptor(dio: mockDio);
      expect(ri.retries, 3);
    });

    test('should use custom retries value', () {
      final ri = RetryInterceptor(dio: mockDio, retries: 5);
      expect(ri.retries, 5);
    });
  });
}

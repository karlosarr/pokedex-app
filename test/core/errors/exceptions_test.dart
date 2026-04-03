import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('should have default message when none provided', () {
      final e = ServerException();
      expect(e.message, 'Server Exception');
    });

    test('should use the provided message', () {
      final e = ServerException(message: 'Not Found');
      expect(e.message, 'Not Found');
    });

    group('fromDioError', () {
      test('should return Unexpected Server Error for non-DioException', () {
        final e = ServerException.fromDioError('Some generic error');
        expect(e.message, 'Unexpected Server Error');
      });

      test('should map DioExceptionType.connectionTimeout correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Connection Timeout');
      });

      test('should map DioExceptionType.sendTimeout correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.sendTimeout,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Send Timeout');
      });

      test('should map DioExceptionType.receiveTimeout correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.receiveTimeout,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Receive Timeout');
      });

      test('should map DioExceptionType.badCertificate correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badCertificate,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Bad Certificate');
      });

      test('should map DioExceptionType.badResponse correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Bad Response');
      });

      test('should map DioExceptionType.cancel correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.cancel,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Request Cancelled');
      });

      test('should map DioExceptionType.connectionError correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Connection Error');
      });

      test('should map DioExceptionType.unknown correctly', () {
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.unknown,
        );
        final e = ServerException.fromDioError(dioException);
        expect(e.message, 'Unknown Server Error');
      });
    });

    test('should be throwable and catchable', () {
      expect(
        () => throw ServerException(message: 'Test Error'),
        throwsA(isA<ServerException>()),
      );
    });

    test('should implement Exception interface', () {
      final e = ServerException();
      expect(e, isA<Exception>());
    });
  });
}

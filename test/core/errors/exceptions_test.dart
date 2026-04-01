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

    test('fromDioError should create a ServerException from a dynamic error', () {
      final e = ServerException.fromDioError('DioError: connection failed');
      expect(e, isA<ServerException>());
      expect(e.message, contains('DioError'));
    });

    test('fromDioError uses toString of the error object', () {
      final e = ServerException.fromDioError(Exception('timeout'));
      expect(e.message, Exception('timeout').toString());
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

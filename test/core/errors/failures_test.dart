import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should have default message when none provided', () {
      const f = ServerFailure();
      expect(f.message, 'Server Error');
    });

    test('should use the provided message', () {
      const f = ServerFailure(message: 'Custom server error');
      expect(f.message, 'Custom server error');
    });

    test('should be equal to another ServerFailure with the same message', () {
      expect(const ServerFailure(), const ServerFailure());
    });

    test('should not be equal when messages differ', () {
      expect(
        const ServerFailure(message: 'A'),
        isNot(const ServerFailure(message: 'B')),
      );
    });

    test('props should contain the message', () {
      const f = ServerFailure(message: 'Test');
      expect(f.props, ['Test']);
    });

    test('should be a subtype of Failure', () {
      expect(const ServerFailure(), isA<Failure>());
    });
  });

  group('NetworkFailure', () {
    test('should have default message when none provided', () {
      const f = NetworkFailure();
      expect(f.message, 'Network Error');
    });

    test('should use the provided message', () {
      const f = NetworkFailure(message: 'No internet');
      expect(f.message, 'No internet');
    });

    test('should be equal to another NetworkFailure with the same message', () {
      expect(const NetworkFailure(), const NetworkFailure());
    });

    test('props should contain the message', () {
      const f = NetworkFailure(message: 'offline');
      expect(f.props, ['offline']);
    });

    test('should be a subtype of Failure', () {
      expect(const NetworkFailure(), isA<Failure>());
    });
  });

  group('Failure equality across types', () {
    test('ServerFailure and NetworkFailure with same message are not equal', () {
      expect(
        const ServerFailure(message: 'Error'),
        isNot(const NetworkFailure(message: 'Error')),
      );
    });
  });
}

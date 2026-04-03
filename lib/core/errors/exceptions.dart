import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server Exception'});

  factory ServerException.fromDioError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return ServerException(message: 'Connection Timeout');
        case DioExceptionType.sendTimeout:
          return ServerException(message: 'Send Timeout');
        case DioExceptionType.receiveTimeout:
          return ServerException(message: 'Receive Timeout');
        case DioExceptionType.badCertificate:
          return ServerException(message: 'Bad Certificate');
        case DioExceptionType.badResponse:
          return ServerException(message: 'Bad Response');
        case DioExceptionType.cancel:
          return ServerException(message: 'Request Cancelled');
        case DioExceptionType.connectionError:
          return ServerException(message: 'Connection Error');
        case DioExceptionType.unknown:
          return ServerException(message: 'Unknown Server Error');
      }
    }
    return ServerException(message: 'Unexpected Server Error');
  }
}

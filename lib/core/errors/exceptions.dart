class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server Exception'});

  factory ServerException.fromDioError(dynamic e) {
    return ServerException(message: e.toString());
  }
}

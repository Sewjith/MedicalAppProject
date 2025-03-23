class ServerException implements Exception {
  final String exception;
  const ServerException(this.exception);

  @override
  String toString() => "ServerException: $exception";

}
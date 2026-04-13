class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.details,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

class AuthenticationException extends AppException {
  AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.code,
    super.details,
  });
}

class TimeoutException extends AppException {
  TimeoutException({
    required super.message,
    super.code,
    super.details,
  });
}

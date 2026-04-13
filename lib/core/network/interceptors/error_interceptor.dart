import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'DioError: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
    );

    return handler.next(err);
  }
}

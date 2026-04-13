import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient({Dio? dio}) : _dio = dio ?? Dio() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.instance.fullBaseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.plain, // Get raw response first
    );

    if (AppConfig.instance.enablePrettyLogger) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      // Since we're using ResponseType.plain, manually parse JSON
      if (response.data is String && response.data.isNotEmpty) {
        try {
          final jsonData = jsonDecode(response.data);
          return Response(
            requestOptions: response.requestOptions,
            data: jsonData,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            headers: response.headers,
          );
        } catch (e) {
          // If JSON parsing fails, return as-is
          return response;
        }
      }
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout. Please try again.',
          code: 'TIMEOUT',
          details: error,
        );
      case DioExceptionType.badResponse:
        // Extract error message from API response
        String errorMessage = 'Server error occurred';
        
        if (error.response?.data != null) {
          try {
            final data = error.response!.data;
            if (data is Map<String, dynamic>) {
              // Check for common error message fields
              errorMessage = data['message'] ?? 
                           data['error'] ?? 
                           data['msg'] ?? 
                           'Server error occurred';
            }
          } catch (e) {
            errorMessage = error.response?.statusMessage ?? 'Server error occurred';
          }
        }
        
        return ServerException(
          message: errorMessage,
          code: error.response?.statusCode.toString(),
          details: error.response?.data,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
          details: error,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        // Get more details about the error
        String detailedMessage = 'Network error. Please check your connection.';
        
        if (error.error != null) {
          detailedMessage = '$detailedMessage\nDetails: ${error.error.toString()}';
        }
        
        if (error.message != null) {
          detailedMessage = '$detailedMessage\nMessage: ${error.message}';
        }
        
        return NetworkException(
          message: detailedMessage,
          code: 'NETWORK_ERROR',
          details: {
            'error': error.error,
            'message': error.message,
            'stackTrace': error.stackTrace?.toString(),
          },
        );
      default:
        return NetworkException(
          message: 'An unknown error occurred',
          code: 'UNKNOWN',
          details: error,
        );
    }
  }
}

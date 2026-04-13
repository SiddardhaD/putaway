import 'package:dio/dio.dart';
import '../../utils/storage/secure_storage_service.dart';
import '../../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage = SecureStorageService();

  // List of endpoints that don't need authentication
  final List<String> _publicEndpoints = [
    AppConstants.endpointLogin,
    '/tokenrequest',
    AppConstants.endpointSearchOrders,
    '/v3/orchestrator/ORCH_59_PurchaseOrderLineDetails',
    AppConstants.endpointReceivePurchaseOrder,
    '/v3/orchestrator/ORCH_59_ReceivePurchaseOrder',
  ];

  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for public endpoints like login
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.read(AppConstants.keyAccessToken);
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - could trigger logout or token refresh
    }
    return handler.next(err);
  }
}

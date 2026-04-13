import 'package:logger/logger.dart';
import 'package:putaway/core/utils/storage/secure_storage_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/order_model.dart';
import '../models/search_response_model.dart';
import '../models/purchase_line_detail_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<PurchaseLineDetailModel>> searchOrders({
    required String orderType,
    required String orderNumber,
    String? organization,
  });

  Future<OrderModel> getOrderDetails(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;
  final SecureStorageService secureStorage;
  final Logger _logger = Logger();

  OrderRemoteDataSourceImpl(this.dioClient, this.secureStorage);

  @override
  Future<List<PurchaseLineDetailModel>> searchOrders({
    required String orderType,
    required String orderNumber,
    String? organization,
  }) async {
    try {
      // Get token from secure storage
      final token = await secureStorage.read(AppConstants.keyAccessToken);

      _logger.i(
        'OrderRemoteDataSource: Searching orders - type: $orderType, number: $orderNumber, org: $organization',
      );
      _logger.d(
        'OrderRemoteDataSource: Token retrieved: ${token != null ? "Yes" : "No"}',
      );

      if (token == null || token.isEmpty) {
        _logger.e('OrderRemoteDataSource: No token found in storage');
        throw Exception('Authentication token not found. Please login again.');
      }

      final requestBody = {
        'deviceName': AppConstants.deviceName,
        'token': token,
        'OrderNumber': orderNumber,
        'OrderType': orderType,
        if (organization != null && organization.isNotEmpty)
          'BranchPlant': organization,
      };

      _logger.d('OrderRemoteDataSource: Request body: $requestBody');
      _logger.i('OrderRemoteDataSource: Calling API...');

      final response = await dioClient.post(
        AppConstants.endpointSearchOrders,
        data: requestBody,
      );

      _logger.i('OrderRemoteDataSource: Response received successfully');
      _logger.d('OrderRemoteDataSource: Response status: ${response.statusCode}');
      _logger.d('OrderRemoteDataSource: Response headers: ${response.headers}');
      _logger.d('OrderRemoteDataSource: Response data type: ${response.data.runtimeType}');
      _logger.d('OrderRemoteDataSource: Response data: ${response.data}');

      // Check if response.data is null
      if (response.data == null) {
        _logger.e('OrderRemoteDataSource: Response data is null!');
        throw Exception('Empty response from server');
      }

      // Parse the response
      _logger.i('OrderRemoteDataSource: Parsing response...');
      final searchResponse = SearchResponseModel.fromJson(response.data);

      // Check status
      if (searchResponse.status != 'SUCCESS') {
        _logger.e(
          'OrderRemoteDataSource: Search failed with status: ${searchResponse.status}',
        );
        throw Exception('Search failed: ${searchResponse.status}');
      }

      _logger.i(
        'OrderRemoteDataSource: Found ${searchResponse.purchaseLineDetails.length} line items',
      );
      return searchResponse.purchaseLineDetails;
    } catch (e, stackTrace) {
      _logger.e('OrderRemoteDataSource: Exception occurred!');
      _logger.e('OrderRemoteDataSource: Error type: ${e.runtimeType}');
      _logger.e('OrderRemoteDataSource: Error message: $e');
      _logger.e('OrderRemoteDataSource: Stack trace:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    final response = await dioClient.get(
      '${AppConstants.endpointGetOrderDetails}/$orderId',
    );

    return OrderModel.fromJson(response.data['data']);
  }
}

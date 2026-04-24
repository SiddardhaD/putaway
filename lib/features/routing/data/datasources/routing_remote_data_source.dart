import 'package:logger/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/storage/secure_storage_service.dart';
import '../models/routing_line_detail_model.dart';

abstract class RoutingRemoteDataSource {
  Future<List<RoutingLineDetailModel>> getRoutingLineDetails({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String containerId,
  });

  Future<void> confirmRouting({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String lineNumber,
  });
}

class RoutingRemoteDataSourceImpl implements RoutingRemoteDataSource {
  final DioClient dioClient;
  final SecureStorageService secureStorage;
  final Logger _logger = Logger();

  RoutingRemoteDataSourceImpl(this.dioClient, this.secureStorage);

  @override
  Future<List<RoutingLineDetailModel>> getRoutingLineDetails({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String containerId,
  }) async {
    final token = await secureStorage.read(AppConstants.keyAccessToken);
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final requestBody = {
      'deviceName': AppConstants.deviceName,
      'token': token,
      'OrderNumber': orderNumber,
      'OrderType': orderType,
      'BranchPlant': branchPlant,
      'ContainerId': containerId,
    };

    _logger.i('RoutingRemoteDataSource: RoutingOrderdetails request: $requestBody');

    final response = await dioClient.post(
      AppConstants.endpointRoutingOrderDetails,
      data: requestBody,
    );

    if (response.data == null) {
      throw Exception('Empty response from server');
    }

    final data = response.data as Map<String, dynamic>;
    final status = data['jde__status']?.toString() ?? '';
    if (status != 'SUCCESS') {
      throw Exception('Failed to load routing lines: $status');
    }

    final rawList = data['RoutingLinedetails'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => RoutingLineDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> confirmRouting({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String lineNumber,
  }) async {
    final token = await secureStorage.read(AppConstants.keyAccessToken);
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final requestBody = {
      'deviceName': AppConstants.deviceName,
      'token': token,
      'OrderNumber': orderNumber,
      'OrderType': orderType,
      'BranchPlant': branchPlant,
      'LineNumber': lineNumber,
    };

    _logger.i('RoutingRemoteDataSource: ConfirmRouting request: $requestBody');

    final response = await dioClient.post(
      AppConstants.endpointConfirmRouting,
      data: requestBody,
    );

    if (response.data == null) {
      throw Exception('Empty response from server');
    }

    final data = response.data as Map<String, dynamic>;
    final status = data['jde__status']?.toString() ?? '';
    if (status != 'SUCCESS') {
      throw Exception('Failed to confirm routing: $status');
    }
  }
}

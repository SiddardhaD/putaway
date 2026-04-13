import 'package:logger/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/storage/secure_storage_service.dart';
import '../models/record_model.dart';
import '../models/grid_data_item.dart';
import '../models/submit_receive_response_model.dart';

abstract class RecordRemoteDataSource {
  Future<List<RecordModel>> getRecords(String orderId);
  Future<RecordModel> getRecordById(String recordId);
  Future<RecordModel> addRecord({
    required String orderId,
    required String orderNumber,
    required String subinventory,
    required String locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
  });
  Future<RecordModel> updateRecord({
    required String recordId,
    String? subinventory,
    String? locator,
    int? quantity,
    String? lotNumber,
    String? serialNumber,
  });
  Future<void> submitRecord(String recordId);
  Future<void> deleteRecord(String recordId);
  Future<SubmitReceiveResponseModel> submitReceivePurchaseOrder({
    required String orderNumber,
    required String branch,
    required List<GridDataItem> gridData,
  });
}

class RecordRemoteDataSourceImpl implements RecordRemoteDataSource {
  final DioClient dioClient;
  final SecureStorageService secureStorage;
  final Logger _logger = Logger();

  RecordRemoteDataSourceImpl(this.dioClient, this.secureStorage);

  @override
  Future<List<RecordModel>> getRecords(String orderId) async {
    final response = await dioClient.get(
      AppConstants.endpointGetRecords,
      queryParameters: {'orderId': orderId},
    );

    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => RecordModel.fromJson(json)).toList();
  }

  @override
  Future<RecordModel> getRecordById(String recordId) async {
    final response = await dioClient.get(
      '${AppConstants.endpointGetRecords}/$recordId',
    );

    return RecordModel.fromJson(response.data['data']);
  }

  @override
  Future<RecordModel> addRecord({
    required String orderId,
    required String orderNumber,
    required String subinventory,
    required String locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    final response = await dioClient.post(
      AppConstants.endpointAddRecord,
      data: {
        'orderId': orderId,
        'orderNumber': orderNumber,
        'subinventory': subinventory,
        'locator': locator,
        'quantity': quantity,
        if (lotNumber != null) 'lotNumber': lotNumber,
        if (serialNumber != null) 'serialNumber': serialNumber,
      },
    );

    return RecordModel.fromJson(response.data['data']);
  }

  @override
  Future<RecordModel> updateRecord({
    required String recordId,
    String? subinventory,
    String? locator,
    int? quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    final response = await dioClient.put(
      '${AppConstants.endpointUpdateRecord}/$recordId',
      data: {
        if (subinventory != null) 'subinventory': subinventory,
        if (locator != null) 'locator': locator,
        if (quantity != null) 'quantity': quantity,
        if (lotNumber != null) 'lotNumber': lotNumber,
        if (serialNumber != null) 'serialNumber': serialNumber,
      },
    );

    return RecordModel.fromJson(response.data['data']);
  }

  @override
  Future<void> submitRecord(String recordId) async {
    await dioClient.post('${AppConstants.endpointSubmitRecord}/$recordId');
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    await dioClient.delete('${AppConstants.endpointGetRecords}/$recordId');
  }

  @override
  Future<SubmitReceiveResponseModel> submitReceivePurchaseOrder({
    required String orderNumber,
    required String branch,
    required List<GridDataItem> gridData,
  }) async {
    try {
      final token = await secureStorage.read(AppConstants.keyAccessToken);

      _logger.i(
        'RecordRemoteDataSource: Submitting receive PO - order: $orderNumber, branch: $branch, items: ${gridData.length}',
      );
      _logger.d('RecordRemoteDataSource: Token retrieved: ${token != null ? "Yes" : "No"}');

      if (token == null || token.isEmpty) {
        _logger.e('RecordRemoteDataSource: No token found in storage');
        throw Exception('Authentication token not found. Please login again.');
      }

      final requestBody = {
        'deviceName': AppConstants.deviceName,
        'token': token,
        'Order_Number': orderNumber,
        'Branch': branch,
        'GridData': gridData.map((item) => item.toJson()).toList(),
      };

      _logger.d('RecordRemoteDataSource: Request body: $requestBody');
      _logger.i('RecordRemoteDataSource: Calling submit API...');

      final response = await dioClient.post(
        AppConstants.endpointReceivePurchaseOrder,
        data: requestBody,
      );

      _logger.i('RecordRemoteDataSource: Response received successfully');
      _logger.d('RecordRemoteDataSource: Response data: ${response.data}');

      if (response.data == null) {
        _logger.e('RecordRemoteDataSource: Response data is null!');
        throw Exception('Empty response from server');
      }

      final submitResponse = SubmitReceiveResponseModel.fromJson(response.data);

      _logger.i('RecordRemoteDataSource: Response status: ${submitResponse.status}');
      
      if (submitResponse.status == 'ERROR') {
        final errorMessage = submitResponse.simpleMessage ?? 
                            submitResponse.exception ?? 
                            'Submit failed with unknown error';
        
        _logger.e('RecordRemoteDataSource: API returned ERROR status');
        _logger.e('RecordRemoteDataSource: Error message: $errorMessage');
        
        throw Exception(errorMessage);
      }

      if (submitResponse.status != 'SUCCESS') {
        _logger.e('RecordRemoteDataSource: Unexpected status: ${submitResponse.status}');
        throw Exception('Submit failed with status: ${submitResponse.status}');
      }

      _logger.i('RecordRemoteDataSource: Submit successful');
      return submitResponse;
    } catch (e, stackTrace) {
      _logger.e('RecordRemoteDataSource: Exception occurred!');
      _logger.e('RecordRemoteDataSource: Error type: ${e.runtimeType}');
      _logger.e('RecordRemoteDataSource: Error message: $e');
      _logger.e('RecordRemoteDataSource: Stack trace:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

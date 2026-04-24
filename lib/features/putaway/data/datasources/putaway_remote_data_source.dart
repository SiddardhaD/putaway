import 'package:logger/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/storage/secure_storage_service.dart';
import '../models/putaway_task_detail_model.dart';
import '../models/putaway_response_model.dart';
import '../models/confirm_putaway_request_model.dart';
import '../models/confirm_putaway_response_model.dart';

abstract class PutawayRemoteDataSource {
  Future<List<PutawayTaskDetailModel>> getPutawayTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String version,
  });
  
  Future<ConfirmPutawayResponseModel> confirmPutaway({
    required String task,
    required String trip,
    required String version,
  });
}

class PutawayRemoteDataSourceImpl implements PutawayRemoteDataSource {
  final DioClient dioClient;
  final SecureStorageService secureStorage;
  final Logger _logger = Logger();

  PutawayRemoteDataSourceImpl(this.dioClient, this.secureStorage);

  @override
  Future<List<PutawayTaskDetailModel>> getPutawayTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String version,
  }) async {
    try {
      final token = await secureStorage.read(AppConstants.keyAccessToken);

      _logger.i(
        'PutawayRemoteDataSource: Getting putaway tasks - order: $orderNumber, type: $orderType, branch: $branchPlant',
      );
      _logger.d('PutawayRemoteDataSource: Token retrieved: ${token != null ? "Yes" : "No"}');

      if (token == null || token.isEmpty) {
        _logger.e('PutawayRemoteDataSource: No token found in storage');
        throw Exception('Authentication token not found. Please login again.');
      }

      final requestBody = {
        'deviceName': AppConstants.deviceName,
        'token': token,
        'OrderNumber': orderNumber,
        'OrderType': orderType,
        'BranchPlant': branchPlant,
        'Version': version,
      };

      _logger.d('PutawayRemoteDataSource: Request body: $requestBody');
      _logger.i('PutawayRemoteDataSource: Calling API...');

      final response = await dioClient.post(
        AppConstants.endpointPutawayTaskDetails,
        data: requestBody,
      );

      _logger.i('PutawayRemoteDataSource: Response received successfully');
      _logger.d('PutawayRemoteDataSource: Response data: ${response.data}');

      if (response.data == null) {
        _logger.e('PutawayRemoteDataSource: Response data is null!');
        throw Exception('Empty response from server');
      }

      final putawayResponse = PutawayResponseModel.fromJson(response.data);

      if (putawayResponse.status != 'SUCCESS') {
        _logger.e('PutawayRemoteDataSource: API failed with status: ${putawayResponse.status}');
        throw Exception('Failed to get putaway tasks: ${putawayResponse.status}');
      }

      _logger.i('PutawayRemoteDataSource: Found ${putawayResponse.putawayTaskDetails.length} tasks');
      return putawayResponse.putawayTaskDetails;
    } catch (e, stackTrace) {
      _logger.e('PutawayRemoteDataSource: Exception occurred!');
      _logger.e('PutawayRemoteDataSource: Error type: ${e.runtimeType}');
      _logger.e('PutawayRemoteDataSource: Error message: $e');
      _logger.e('PutawayRemoteDataSource: Stack trace:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ConfirmPutawayResponseModel> confirmPutaway({
    required String task,
    required String trip,
    required String version,
  }) async {
    try {
      final token = await secureStorage.read(AppConstants.keyAccessToken);

      _logger.i('PutawayRemoteDataSource: Confirming putaway - task: $task, trip: $trip');
      _logger.d('PutawayRemoteDataSource: Token retrieved: ${token != null ? "Yes" : "No"}');

      if (token == null || token.isEmpty) {
        _logger.e('PutawayRemoteDataSource: No token found in storage');
        throw Exception('Authentication token not found. Please login again.');
      }

      final requestBody = {
        'deviceName': AppConstants.deviceName,
        'token': token,
        'Task': task,
        'Trip': trip,
        'Version': version,
      };

      _logger.d('PutawayRemoteDataSource: Request body: $requestBody');
      _logger.i('PutawayRemoteDataSource: Calling confirm API...');

      final response = await dioClient.post(
        AppConstants.endpointConfirmPutaway,
        data: requestBody,
      );

      _logger.i('PutawayRemoteDataSource: Confirm response received successfully');
      _logger.d('PutawayRemoteDataSource: Response data: ${response.data}');

      if (response.data == null) {
        _logger.e('PutawayRemoteDataSource: Response data is null!');
        throw Exception('Empty response from server');
      }

      final confirmResponse = ConfirmPutawayResponseModel.fromJson(response.data);

      if (confirmResponse.status != 'SUCCESS') {
        _logger.e('PutawayRemoteDataSource: Confirm failed with status: ${confirmResponse.status}');
        throw Exception('Failed to confirm putaway: ${confirmResponse.status}');
      }

      _logger.i('PutawayRemoteDataSource: Confirm successful');
      return confirmResponse;
    } catch (e, stackTrace) {
      _logger.e('PutawayRemoteDataSource: Exception in confirmPutaway!');
      _logger.e('PutawayRemoteDataSource: Error type: ${e.runtimeType}');
      _logger.e('PutawayRemoteDataSource: Error message: $e');
      _logger.e('PutawayRemoteDataSource: Stack trace:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

import 'package:logger/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
    String? organization,
  });

  Future<void> logout(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final Logger _logger = Logger();

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login({
    required String username,
    required String password,
    String? organization,
  }) async {
    final response = await dioClient.post(
      AppConstants.endpointLogin,
      data: {
        'deviceName': AppConstants.deviceName,
        'username': username,
        'password': password,
      },
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> logout(String token) async {
    try {
      _logger.i('AuthRemoteDataSource: Calling logout API');
      
      final requestBody = {
        'deviceName': AppConstants.deviceName,
        'token': token,
      };

      _logger.d('AuthRemoteDataSource: Logout request body: $requestBody');

      final response = await dioClient.post(
        AppConstants.endpointLogout,
        data: requestBody,
      );

      _logger.i('AuthRemoteDataSource: Logout successful - Status: ${response.statusCode}');
    } catch (e) {
      _logger.e('AuthRemoteDataSource: Logout error - $e');
      rethrow;
    }
  }
}

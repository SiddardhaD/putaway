import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
    String? organization,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

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

    // API returns the data directly, not wrapped in a 'data' field
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await dioClient.post(AppConstants.endpointLogout);
  }
}

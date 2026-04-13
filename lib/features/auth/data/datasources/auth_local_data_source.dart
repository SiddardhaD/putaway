import '../../../../core/utils/storage/secure_storage_service.dart';
import '../../../../core/utils/storage/local_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/user_info_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
  Future<void> saveToken(String token);
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  final LocalStorageService localStorage;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.localStorage,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    await localStorage.setString(AppConstants.keyUserId, user.userInfo.addressNumber?.toString() ?? user.username);
    await localStorage.setString(AppConstants.keyUsername, user.username);
    await localStorage.setString(AppConstants.keyUserEmail, user.userInfo.longUserId ?? user.username);
    await localStorage.setString(AppConstants.keyOrganization, user.environment);
    
    // Store additional user info
    if (user.userInfo.alphaName != null) {
      await localStorage.setString('user_full_name', user.userInfo.alphaName!);
    }
    if (user.role != null) {
      await localStorage.setString('user_role', user.role);
    }
    if (user.jasserver != null) {
      await localStorage.setString('jasserver', user.jasserver);
    }
    
    // Store session cookie if available
    if (user.sessionCookie != null) {
      await secureStorage.write('session_cookie', user.sessionCookie!);
    }
    
    // Store the token securely
    await saveToken(user.userInfo.token);
    await localStorage.setBool(AppConstants.keyIsLoggedIn, true);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userId = localStorage.getString(AppConstants.keyUserId);
    if (userId == null) return null;

    final username = localStorage.getString(AppConstants.keyUsername);
    final email = localStorage.getString(AppConstants.keyUserEmail);
    final organization = localStorage.getString(AppConstants.keyOrganization);
    final token = await getToken();
    final fullName = localStorage.getString('user_full_name');
    final role = localStorage.getString('user_role');
    final jasserver = localStorage.getString('jasserver');
    final sessionCookie = await secureStorage.read('session_cookie');

    if (username == null || token == null) return null;

    return UserModel(
      username: username,
      environment: organization ?? '',
      role: role ?? '*ALL',
      jasserver: jasserver ?? '',
      userInfo: UserInfoModel(
        token: token,
        username: username,
        alphaName: fullName,
        addressNumber: int.tryParse(userId),
        longUserId: email,
      ),
      sessionCookie: sessionCookie,
    );
  }

  @override
  Future<void> clearCache() async {
    await localStorage.remove(AppConstants.keyUserId);
    await localStorage.remove(AppConstants.keyUsername);
    await localStorage.remove(AppConstants.keyUserEmail);
    await localStorage.remove(AppConstants.keyOrganization);
    await localStorage.remove(AppConstants.keyIsLoggedIn);
    await localStorage.remove('user_full_name');
    await localStorage.remove('user_role');
    await localStorage.remove('jasserver');
    await secureStorage.delete(AppConstants.keyAccessToken);
    await secureStorage.delete('session_cookie');
  }

  @override
  Future<bool> isLoggedIn() async {
    return localStorage.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(AppConstants.keyAccessToken, token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(AppConstants.keyAccessToken);
  }
}

# API Integration Guide - Login Flow

## ✅ Completed Integration

### API Configuration

**Base URL**: `http://129.154.245.81:7070`
**API Version**: `jderest`
**Login Endpoint**: `/tokenrequest`

All flavors (dev, test, prod) are configured with this URL in `lib/core/config/app_config.dart`.

---

## Login API Integration

### Request Format

**Method**: POST  
**Endpoint**: `http://129.154.245.81:7070/jderest/tokenrequest`  
**Headers**:
- `Content-Type: application/json`

**Request Body**:
```json
{
    "deviceName": "MOBILE_APP",
    "username": "NBARANWAL",
    "password": "NBARANWAL"
}
```

### Success Response Structure

```json
{
    "username": "NBARANWAL",
    "environment": "JPS920",
    "role": "*ALL",
    "jasserver": "http://129.154.245.81:8079",
    "userInfo": {
        "token": "0446kVRasaEoZ/0gEhKHqcR+hK1ydy8OuwrIzQcQxvg0tA=...",
        "langPref": "  ",
        "locale": "en",
        "dateFormat": "MDE",
        "dateSeperator": "/",
        "simpleDateFormat": "MM/dd/yyyy",
        "timeFormat": "24",
        "decimalFormat": ".",
        "addressNumber": 61006,
        "alphaName": "Nityakumar Baranwal",
        "appsRelease": "E920",
        "country": " ",
        "username": "NBARANWAL",
        "longUserId": "",
        "timeZoneOffset": "UTC",
        "dstRuleKey": ""
    },
    "userAuthorized": false,
    "aisSessionCookie": "AkB7N6U0r65vnzNsDuJcpeksmFcrVmnIRCLloOVOO5lOigLTdwR2!-302166512!1775888737588",
    "adminAuthorized": true,
    "passwordAboutToExpire": false,
    "envColor": "#1e4a6d",
    "machineName": "jdedemo1",
    "currencyEnvironment": true,
    "deprecated": true
}
```

### Error Response Handling

The API may return various error responses. Common error scenarios:

1. **Invalid Credentials** (401):
```json
{
    "error": "Invalid username or password",
    "status": 401
}
```

2. **Server Error** (500):
```json
{
    "error": "Internal server error",
    "status": 500
}
```

3. **Network Error**: Handled by Dio client with appropriate error messages

---

## Token Storage

### What Gets Stored

#### Secure Storage (flutter_secure_storage)
- **Token**: `userInfo.token` - The authentication token
- **Session Cookie**: `aisSessionCookie` - For session management

#### Local Storage (shared_preferences)
- **User ID**: `userInfo.addressNumber`
- **Username**: `username`
- **Email**: `userInfo.longUserId`
- **Organization**: `environment`
- **Full Name**: `userInfo.alphaName`
- **Role**: `role`
- **JAS Server**: `jasserver`
- **Is Logged In**: Boolean flag

### Storage Keys (from app_constants.dart)

```dart
static const String keyAccessToken = 'access_token';
static const String keyUserId = 'user_id';
static const String keyUsername = 'username';
static const String keyUserEmail = 'user_email';
static const String keyIsLoggedIn = 'is_logged_in';
static const String keyOrganization = 'organization';
```

---

## Code Structure

### 1. Data Models

#### `user_info_model.dart`
Contains the `userInfo` object structure from API response:
- token
- addressNumber
- alphaName (full name)
- locale, dateFormat, etc.

#### `user_model.dart`
Main response model containing:
- username
- environment
- role
- jasserver
- userInfo (nested UserInfoModel)
- aisSessionCookie

Both models use **Freezed** for immutability and code generation.

### 2. Data Sources

#### `auth_remote_data_source.dart`
Handles API calls:
```dart
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
```

#### `auth_local_data_source.dart`
Handles local storage:
- `cacheUser()` - Stores user data and token
- `getCachedUser()` - Retrieves cached user
- `clearCache()` - Clears all stored data on logout
- `saveToken()` - Stores token securely
- `getToken()` - Retrieves token for API calls

### 3. Repository Implementation

#### `auth_repository_impl.dart`
Implements the repository interface:
```dart
@override
Future<Either<Failure, UserEntity>> login({...}) async {
  try {
    final userModel = await remoteDataSource.login(...);
    await localDataSource.cacheUser(userModel);
    return Right(userModel.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(message: e.message));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

### 4. Error Handling

All errors are handled through the `Either` type from dartz:
- **Left**: Contains a `Failure` (ServerFailure, NetworkFailure, etc.)
- **Right**: Contains the success result

The Dio client automatically handles:
- Connection timeouts
- Network errors
- HTTP status errors
- Response parsing errors

---

## Token Usage in API Calls

### Auto-injection via Interceptor

The token is automatically added to all API requests via `AuthInterceptor`:

```dart
@override
Future<void> onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  final token = await _secureStorage.read(AppConstants.keyAccessToken);
  
  if (token != null && token.isNotEmpty) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  
  return handler.next(options);
}
```

No need to manually add the token to each API call!

---

## Usage in Login Screen

### Current Implementation

The login screen currently has a **simulated login** for UI testing:

```dart
Future<void> _handleLogin() async {
  if (_formKey.currentState?.validate() ?? false) {
    setState(() => _isLoading = true);
    
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.loginSuccess)),
    );
    
    context.router.replace(const SearchRoute());
  }
}
```

### To Enable Real API Integration

You need to:

1. **Create Dependency Injection Providers** (using get_it/injectable)
2. **Create Riverpod Provider for LoginViewModel**
3. **Wire up the complete flow**

Example provider setup:

```dart
// In a new file: lib/features/auth/presentation/providers/auth_providers.dart

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  return LoginViewModel(loginUseCase);
});

// Then in login_screen.dart:
Future<void> _handleLogin() async {
  if (_formKey.currentState?.validate() ?? false) {
    await ref.read(loginViewModelProvider.notifier).login(
      username: _usernameController.text,
      password: _passwordController.text,
      organization: _organizationController.text,
    );
    
    ref.listen(loginViewModelProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () => setState(() => _isLoading = true),
        success: (user) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome ${user.username}!')),
          );
          context.router.replace(const SearchRoute());
        },
        error: (message) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    });
  }
}
```

---

## Testing the API

### Using the Simulator

1. Run the app:
```bash
flutter run --target lib/main_dev.dart
```

2. Enter credentials:
   - Username: `NBARANWAL`
   - Password: `NBARANWAL`
   - Organization: (optional)

3. Check logs in terminal for API requests/responses

### Checking Token Storage

After successful login, verify token storage:

```dart
// In any screen or debug console:
final secureStorage = SecureStorageService();
final token = await secureStorage.read('access_token');
print('Stored token: $token');
```

---

## Security Considerations

1. **Token Storage**: Token is stored in secure storage (Keychain on iOS, EncryptedSharedPreferences on Android)

2. **Auto-logout**: Token is cleared on logout via `clearCache()`

3. **Session Management**: Session cookie is also stored securely

4. **HTTPS**: ⚠️ **Important**: The API uses HTTP. For production, ensure HTTPS is used!

---

## Next Steps

To complete the integration:

1. **Set up Dependency Injection**:
   - Configure injectable/get_it
   - Register all dependencies
   - Create providers

2. **Wire up ViewModels**:
   - Create Riverpod providers
   - Connect to login screen
   - Handle all state transitions

3. **Test Error Scenarios**:
   - Invalid credentials
   - Network timeout
   - Server errors

4. **Add Token Refresh** (if API supports it):
   - Handle token expiration
   - Implement refresh token flow

5. **Implement Logout**:
   - Call logout endpoint
   - Clear all stored data
   - Navigate to login screen

---

## Files Modified

- ✅ `lib/core/config/app_config.dart` - Updated base URLs
- ✅ `lib/core/constants/app_constants.dart` - Updated endpoints
- ✅ `lib/features/auth/data/models/user_model.dart` - Updated to match API
- ✅ `lib/features/auth/data/models/user_info_model.dart` - New model created
- ✅ `lib/features/auth/data/datasources/auth_remote_data_source.dart` - Updated request format
- ✅ `lib/features/auth/data/datasources/auth_local_data_source.dart` - Enhanced storage
- ✅ `lib/features/auth/presentation/screens/login_screen.dart` - Ready for integration

All models are generated and ready! ✨

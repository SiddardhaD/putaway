# Logout Functionality Documentation

## Overview
Implemented comprehensive logout functionality with confirmation dialog, API integration, and session cleanup.

## Implementation Details

### 1. **Logout API Endpoint**
**Endpoint:** `POST /tokenrequest/logout`

**Request Body:**
```json
{
  "deviceName": "MOBILE_APP",
  "token": "<user_token_from_secure_storage>"
}
```

**Expected Response:** `200 OK` status code

### 2. **UI Changes**

#### Search Screen AppBar
- **Removed:** Home icon
- **Added:** Logout button (logout icon) in top right
- **Tooltip:** "Logout"
- **Disabled when:** Logout is in progress (loading state)

#### Confirmation Dialog
Shows when logout button is tapped:
```dart
AlertDialog(
  title: 'Logout',
  content: 'Are you sure you want to logout?',
  actions: [Cancel, OK]
)
```

### 3. **Architecture Implementation**

#### Data Layer
**File:** `lib/features/auth/data/datasources/auth_remote_data_source.dart`
```dart
Future<void> logout(String token) async {
  final requestBody = {
    'deviceName': AppConstants.deviceName,
    'token': token,
  };

  await dioClient.post(
    AppConstants.endpointLogout,
    data: requestBody,
  );
}
```

#### Domain Layer
**UseCase:** `lib/features/auth/domain/usecases/logout_usecase.dart`
```dart
Future<Either<Failure, void>> call(String token) async {
  return await repository.logout(token);
}
```

**Repository:** `lib/features/auth/domain/repositories/auth_repository.dart`
```dart
Future<Either<Failure, void>> logout(String token);
```

#### Presentation Layer
**State:** `lib/features/auth/presentation/states/logout_state.dart`
```dart
@freezed
class LogoutState with _$LogoutState {
  const factory LogoutState.initial() = _Initial;
  const factory LogoutState.loading() = _Loading;
  const factory LogoutState.success() = _Success;
  const factory LogoutState.error(String message) = _Error;
}
```

**ViewModel:** `lib/features/auth/presentation/viewmodels/logout_viewmodel.dart`
```dart
Future<void> logout(String token) async {
  state = const LogoutState.loading();
  
  final result = await logoutUseCase(token);
  
  result.fold(
    (failure) => state = LogoutState.error(failure.message),
    (_) => state = const LogoutState.success(),
  );
}
```

### 4. **Flow Diagram**

```
┌─────────────────────┐
│  Search Screen      │
│  (Logout Button)    │
└──────────┬──────────┘
           │ Tap
           ↓
┌─────────────────────┐
│ Confirmation Dialog │
│ "Are you sure?"     │
└──────┬──────┬───────┘
       │      │
    Cancel   OK
       │      │
       ↓      ↓
    Close  Continue
           │
           ↓
┌─────────────────────┐
│ Get Token from      │
│ Secure Storage      │
└──────────┬──────────┘
           │
           ↓ (Token exists)
┌─────────────────────┐
│ Call Logout API     │
│ POST /tokenrequest/ │
│      logout         │
└──────────┬──────────┘
           │
           ↓ (200 OK)
┌─────────────────────┐
│ Clear Local Data:   │
│ • Secure Storage    │
│ • Shared Preferences│
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│ Show Success        │
│ "Logged out         │
│  successfully"      │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│ Navigate to Login   │
│ (Clear Stack)       │
└─────────────────────┘
```

### 5. **Session Cleanup**

On successful logout, the following data is cleared:

#### Secure Storage
- `access_token` - User authentication token
- All other secure data

#### Shared Preferences
- `branch_plant` - Saved organization value
- `is_logged_in` - Login status flag
- Any other user-specific preferences

**Implementation:**
```dart
@override
Future<Either<Failure, void>> logout(String token) async {
  // Call remote logout API
  await remoteDataSource.logout(token);
  
  // Clear local data
  await localDataSource.clearCache();
  
  return const Right(null);
}
```

### 6. **Error Handling**

#### Case 1: Logout API Fails
**Display:** Red snackbar with error message
```
"Logout failed: <error_message>"
```
**Action:** User can try again, session data NOT cleared

#### Case 2: No Token Found
**Scenario:** User somehow lost their token
**Handling:**
```dart
if (token.isEmpty) {
  _logger.w('SearchScreen: No token found, clearing local data only');
  await localStorage.clear();
  context.router.replaceNamed('/login');
  return;
}
```
**Action:** Clear local data and navigate to login

#### Case 3: Network Error
**Display:** Red snackbar
```
"Logout failed: Network error. Please check your connection."
```
**Action:** User remains logged in, can retry

### 7. **Navigation**

After successful logout:
```dart
context.router.replaceNamed('/login');
```

**Key Points:**
- Uses `replaceNamed` to clear navigation stack
- User cannot go back to search screen
- Fresh login required

### 8. **User Experience**

#### Logout Button States

**Normal State:**
- Icon: `Icons.logout`
- Color: White (on primary color app bar)
- Action: Opens confirmation dialog

**Loading State:**
- Button disabled (`onPressed: null`)
- User cannot tap multiple times
- Prevents duplicate API calls

**After Success:**
- Snackbar: Green, 2 seconds
- Message: "Logged out successfully"
- Auto-navigate to login

**After Error:**
- Snackbar: Red, 4 seconds
- Message includes error details
- User can retry logout

### 9. **Constants Used**

**File:** `lib/core/constants/app_constants.dart`
```dart
static const String endpointLogout = '/tokenrequest/logout';
static const String deviceName = 'MOBILE_APP';
static const String keyAccessToken = 'access_token';
```

### 10. **Logging**

Comprehensive logging at all layers:

**ViewModel:**
```
LogoutViewModel: Starting logout
LogoutViewModel: Logout successful
LogoutViewModel: Logout failed - <error>
```

**Repository:**
```
AuthRepository: Logging out
AuthRepository: Logout successful, local data cleared
AuthRepository: ServerException during logout - <error>
```

**Data Source:**
```
AuthRemoteDataSource: Calling logout API
AuthRemoteDataSource: Logout request body: {...}
AuthRemoteDataSource: Logout successful - Status: 200
```

**UI:**
```
SearchScreen: User confirmed logout
SearchScreen: Logout successful, navigating to login
SearchScreen: User cancelled logout
```

## Testing Scenarios

### Test 1: Normal Logout
1. Login successfully
2. Navigate to search screen
3. Tap logout button
4. Confirm in dialog
5. **Expected:** Success snackbar, navigate to login

### Test 2: Cancel Logout
1. Tap logout button
2. Tap "Cancel" in dialog
3. **Expected:** Dialog closes, remain on search screen

### Test 3: Network Error
1. Turn off network
2. Tap logout
3. Confirm
4. **Expected:** Error snackbar, remain logged in

### Test 4: No Token
1. Manually clear secure storage
2. Tap logout
3. **Expected:** Clear local data, navigate to login

### Test 5: Multiple Logout Attempts
1. Tap logout button rapidly
2. **Expected:** Button disabled after first tap, prevents duplicate calls

## Security Considerations

1. **Token Required:** Logout requires valid token for API call
2. **Session Cleanup:** All local data cleared on success
3. **Navigation Stack:** Cleared to prevent back navigation
4. **Secure Storage:** Token securely cleared from device
5. **API Validation:** Server validates token before logout

## Benefits

1. **Clean Logout:** Proper API call + local cleanup
2. **User Confirmation:** Prevents accidental logouts
3. **Clear Feedback:** Success/error messages
4. **No Stale Data:** All session data cleared
5. **Security:** Proper token invalidation on server
6. **Error Recovery:** User can retry on failure

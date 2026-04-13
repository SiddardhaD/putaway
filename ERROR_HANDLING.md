# Submit API - Error Handling Documentation

## API Response Structures

### Success Response
```json
{
    "ServiceRequest1": {
        "forms": [...]
    },
    "jde__status": "SUCCESS",
    "jde__startTimestamp": "2026-04-13T05:14:03.619+0000",
    "jde__endTimestamp": "2026-04-13T05:14:05.929+0000",
    "jde__serverExecutionSeconds": 2.31
}
```

### Error Response
```json
{
    "message": {
        "ServiceRequest: FR_59_ReceivePurchaseOrder": {
            "App Stack Form Exception": {...},
            "JAS Response": {
                "fs_P4312_W4312F": {
                    "errors": [
                        {
                            "CODE": "0052",
                            "TITLE": "Error: Business Unit Invalid",
                            "DESC": "CAUSE . . . .  The Business Unit entered does not exist...",
                            "MOBILE": "The Business Unit entered does not exist..."
                        }
                    ]
                }
            }
        }
    },
    "exception": "Exception",
    "jde__status": "ERROR",
    "jde__simpleMessage": "FR_59_ReceivePurchaseOrder failed: App Stack Exception...",
    "exceptionId": "9dd5a5b6-69dc-4e11-a7ee-7ce03da55e92",
    "jde__startTimestamp": "2026-04-13T05:19:01.835+0000",
    "jde__endTimestamp": "2026-04-13T05:19:01.875+0000",
    "jde__serverExecutionSeconds": 0.04
}
```

## Error Handling Flow

### 1. Response Model (`submit_receive_response_model.dart`)
```dart
@freezed
class SubmitReceiveResponseModel with _$SubmitReceiveResponseModel {
  const factory SubmitReceiveResponseModel({
    @JsonKey(name: 'ServiceRequest1') Map<String, dynamic>? serviceRequest,
    @JsonKey(name: 'jde__status') required String status,
    @JsonKey(name: 'jde__simpleMessage') String? simpleMessage,
    @JsonKey(name: 'message') dynamic message,
    @JsonKey(name: 'exception') String? exception,
    @JsonKey(name: 'exceptionId') String? exceptionId,
    @JsonKey(name: 'jde__startTimestamp') String? startTimestamp,
    @JsonKey(name: 'jde__endTimestamp') String? endTimestamp,
    @JsonKey(name: 'jde__serverExecutionSeconds') double? serverExecutionSeconds,
  }) = _SubmitReceiveResponseModel;
}
```

### 2. Data Source Error Detection (`record_remote_data_source.dart`)
```dart
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
```

**Priority for error messages:**
1. `jde__simpleMessage` - User-friendly error description
2. `exception` - Generic exception message
3. Fallback - "Submit failed with unknown error"

### 3. Repository Error Transformation (`record_repository_impl.dart`)
```dart
try {
  final response = await remoteDataSource.submitReceivePurchaseOrder(...);
  return Right(response);
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message, code: e.code));
} on NetworkException catch (e) {
  return Left(NetworkFailure(message: e.message, code: e.code));
} catch (e, stackTrace) {
  return Left(UnknownFailure(message: 'Submit failed: ${e.toString()}', code: 'UNKNOWN'));
}
```

### 4. ViewModel State Management (`submit_viewmodel.dart`)
```dart
result.fold(
  (failure) {
    _logger.e('SubmitViewModel: Submit failed - ${failure.message}');
    state = SubmitState.error(failure.message);
  },
  (response) {
    if (response.status == 'SUCCESS') {
      state = SubmitState.success('Purchase order received successfully! Order #$orderNumber');
    } else {
      state = SubmitState.error('Submit failed with status: ${response.status}');
    }
  },
);
```

### 5. UI Error Display (`item_details_screen.dart`)
```dart
ref.listen<SubmitState>(
  submitViewModelProvider,
  (previous, next) {
    next.when(
      success: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        // Navigate back to search after 500ms
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppStrings.retry,
              textColor: Colors.white,
              onPressed: _handleSubmit,
            ),
          ),
        );
      },
    );
  },
);
```

## Error Types Handled

### 1. **Business Logic Errors** (from API)
- Invalid Business Unit
- No Grid Record Selected
- Invalid Quantity
- etc.

**Display:** Uses `jde__simpleMessage` in red snackbar with retry button

### 2. **Network Errors**
- Connection timeout
- No internet connection
- Server unreachable

**Display:** "Network error. Please check your connection." with retry button

### 3. **Server Errors** (4xx, 5xx)
- 400 Bad Request
- 401 Unauthorized
- 500 Internal Server Error

**Display:** Server error message with retry button

### 4. **Validation Errors** (Client-side)
- Empty quantity
- Quantity exceeds available
- Missing LOT/Serial

**Display:** Form validation errors inline (before API call)

## Example Error Scenarios

### Scenario 1: Invalid Business Unit
**API Response:**
```json
{
  "jde__status": "ERROR",
  "jde__simpleMessage": "FR_59_ReceivePurchaseOrder failed: Error: Business Unit Invalid..."
}
```

**User sees:**
- Red snackbar for 4 seconds
- Message: "FR_59_ReceivePurchaseOrder failed: Error: Business Unit Invalid..."
- Retry button available

### Scenario 2: Network Timeout
**Exception:** `DioException.connectionTimeout`

**User sees:**
- Red snackbar for 4 seconds
- Message: "Network error. Please check your connection."
- Retry button available

### Scenario 3: Success
**API Response:**
```json
{
  "jde__status": "SUCCESS"
}
```

**User sees:**
- Green snackbar for 2 seconds
- Message: "Purchase order received successfully! Order #1071"
- Auto-navigate back to search screen after 500ms

## Logging

All layers provide comprehensive logging:

1. **Data Source:**
   - Request body logged
   - Response status logged
   - Error details logged

2. **Repository:**
   - Exception type logged
   - Error message logged
   - Stack trace logged

3. **ViewModel:**
   - State transitions logged
   - Success/failure logged

4. **Screen:**
   - User interactions logged
   - State changes logged

## Testing Error Handling

To test error handling:

1. **Test Invalid Branch:**
   - Enter non-existent branch code
   - Should see business unit error

2. **Test Network Error:**
   - Turn off network
   - Should see network error message

3. **Test Success:**
   - Enter valid data
   - Should see success message and navigate back

All errors are user-friendly and actionable with retry functionality.

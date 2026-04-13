# Branch/Plant Value Flow Documentation

## Overview
The Branch/Plant value entered in the Search Screen is now properly saved and used in the Submit API, instead of using the `orderCo` value from the API response.

## Implementation Flow

### 1. User Enters Organization/Branch in Search Screen
```
User types "AWH" in Organization field → Searches for orders
```

### 2. On Successful Search - Save Branch Value
**File:** `lib/features/search/presentation/screens/search_screen.dart`

```dart
success: (lineDetails) {
  // Save branch/plant value to local storage for submit API
  final branchValue = _organizationController.text.trim();
  if (branchValue.isNotEmpty) {
    final localStorage = ref.read(localStorageProvider);
    localStorage.setString(AppConstants.keyBranchPlant, branchValue);
    _logger.i('SearchScreen: Saved branch value to storage: $branchValue');
  }
  
  // Navigate to records list
  context.router.pushNamed('/records');
}
```

**Key Points:**
- Branch value is saved to `SharedPreferences` using key `keyBranchPlant`
- Saved only when search is successful
- Saved only if branch value is not empty
- Uses `LocalStorageService.setString()` for persistence

### 3. User Selects Item and Opens Item Details
```
Records List Screen → Tap on item → Item Details Screen
```

### 4. On Submit - Retrieve and Use Branch Value
**File:** `lib/features/records/presentation/screens/item_details_screen.dart`

```dart
Future<void> _handleSubmit() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Get Branch/Plant value from local storage (saved during search)
    final localStorage = ref.read(localStorageProvider);
    final branch = localStorage.getString(AppConstants.keyBranchPlant) ?? '';
    
    _logger.i('ItemDetailsScreen: Retrieved branch from storage: $branch');

    if (branch.isEmpty) {
      _logger.e('ItemDetailsScreen: Branch value not found in storage!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Branch information not found. Please search again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Use the retrieved branch value in submit API
    await ref.read(submitViewModelProvider.notifier).submitReceive(
      orderNumber: widget.lineItem.orderNumber.toString(),
      branch: branch, // Use the saved branch value, not orderCo
      gridData: [gridDataItem],
    );
  }
}
```

**Key Points:**
- Branch value is retrieved from `SharedPreferences`
- Falls back to empty string if not found
- Validates that branch exists before proceeding
- Shows error snackbar if branch not found (user needs to search again)
- Uses retrieved branch value in API call

## API Request Structure

### Before (Incorrect)
```json
{
  "deviceName": "MOBILE_APP",
  "token": "...",
  "Order_Number": "1071",
  "Branch": "00200",  // ❌ Using orderCo from API response
  "GridData": [...]
}
```

### After (Correct)
```json
{
  "deviceName": "MOBILE_APP",
  "token": "...",
  "Order_Number": "1071",
  "Branch": "AWH",  // ✅ Using user-entered organization value
  "GridData": [...]
}
```

## Storage Key

**File:** `lib/core/constants/app_constants.dart`
```dart
static const String keyBranchPlant = 'branch_plant';
```

## Flow Diagram

```
┌─────────────────────┐
│   Search Screen     │
│  User enters "AWH"  │
└──────────┬──────────┘
           │
           ↓ (Search API Success)
    ┌──────────────┐
    │ Save to      │
    │ Local Storage│
    │ key:         │
    │ branch_plant │
    └──────┬───────┘
           │
           ↓ (Navigate to Records)
┌──────────────────────┐
│  Records List Screen │
└──────────┬───────────┘
           │
           ↓ (Tap Item)
┌──────────────────────┐
│ Item Details Screen  │
│ User fills Qty & LOT │
└──────────┬───────────┘
           │
           ↓ (On Submit)
    ┌──────────────┐
    │ Retrieve     │
    │ from Storage │
    │ branch_plant │
    └──────┬───────┘
           │
           ↓ (Use in API)
┌──────────────────────┐
│  Submit API Call     │
│  Branch: "AWH"       │
└──────────────────────┘
```

## Error Handling

### Case 1: Branch Value Not Found
**Scenario:** User navigates directly to Item Details without searching

**Handling:**
```dart
if (branch.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Branch information not found. Please search again.'),
      backgroundColor: AppColors.error,
    ),
  );
  return; // Don't proceed with API call
}
```

### Case 2: User Doesn't Enter Organization
**Scenario:** User leaves organization field empty

**Handling:**
- Branch value is not saved (check: `if (branchValue.isNotEmpty)`)
- On submit, will show "Branch information not found" error
- User must perform a new search with organization value

## Benefits

1. **Correct API Behavior**: Uses the actual branch/plant the user searched with
2. **Data Consistency**: Branch value matches what user entered, not what API returned
3. **User Experience**: Transparent flow - what you search with is what gets submitted
4. **Error Prevention**: Validates branch exists before API call
5. **Session Persistence**: Branch value persists across navigation within the same session

## Testing Scenarios

### Test 1: Normal Flow
1. Enter "AWH" in organization field
2. Search for order "1071"
3. Select an item from results
4. Enter quantity and LOT
5. Submit
6. **Expected:** API called with `Branch: "AWH"`

### Test 2: Empty Organization
1. Leave organization field empty
2. Search for order "1071"
3. Select an item
4. Try to submit
5. **Expected:** Error "Branch information not found. Please search again."

### Test 3: Multiple Searches
1. Search with "AWH"
2. Navigate to records
3. Go back and search with "BWH"
4. Submit item
5. **Expected:** API called with most recent value "BWH"

## Logging

All branch value operations are logged:

**Save:**
```
SearchScreen: Saved branch value to storage: AWH
```

**Retrieve:**
```
ItemDetailsScreen: Retrieved branch from storage: AWH
```

**Error:**
```
ItemDetailsScreen: Branch value not found in storage!
```

# Search API Integration - Complete Implementation

## ✅ What's Been Implemented

### 1. **API Endpoint & Order Type Values Updated**

**Order Type Mappings (API Values):**
```dart
Purchase Order = "OP"
Transfer Order = "OT"
RMA = "RMA"
ASN = "ASN"
Receipt = "RECEIPT"
Intransit Shipment = "INTRANSIT"
```

**Search Endpoint:**
```
POST /searchpurchaseorder
```

---

### 2. **New Models Created**

#### **PurchaseLineDetailEntity** (`lib/features/search/domain/entities/purchase_line_detail_entity.dart`)
Domain entity representing a single purchase order line item.

**Fields:**
- `orderNumber` (int)
- `orderType` (String)
- `orderCo` (String)
- `lineNumber` (int)
- `quantityOpen` (double)
- `amountOpen` (double)
- `curCode` (String)
- `baseCurr` (String)
- `itemNumber` (String)
- `itemDescription` (String)
- `accountNumber` (String)
- `orderDate` (String)

#### **PurchaseLineDetailModel** (`lib/features/search/data/models/purchase_line_detail_model.dart`)
Freezed data model with JSON serialization for API response.

**Key Features:**
- Matches exact API response field names (e.g., `OrderNumber`, `OrderType`)
- Uses `@JsonKey` annotations for proper mapping
- Includes `toEntity()` and `fromEntity()` methods

#### **SearchResponseModel** (`lib/features/search/data/models/search_response_model.dart`)
Wrapper model for the complete API response.

**Fields:**
- `PurchaseLineDetails` - List of line items
- `jde__status` - Status (SUCCESS/ERROR)
- `jde__startTimestamp` - Start time
- `jde__endTimestamp` - End time
- `jde__serverExecutionSeconds` - Execution time

---

### 3. **Request Body Structure**

The search API is called with the following request body:

```json
{
  "deviceName": "MOBILE_APP",
  "token": "<retrieved_from_secure_storage>",
  "OrderNumber": "1071",
  "OrderType": "OP",
  "BranchPlant": "AWH"  // Optional - only if user enters organization
}
```

**Token Retrieval:**
- The token is automatically retrieved from secure storage (saved during login)
- If token is missing, the API call will fail with an authentication error

---

### 4. **Updated Files**

#### **`lib/core/constants/app_constants.dart`**
- Updated `endpointSearchOrders` to `/searchpurchaseorder`
- Updated order type constants to match API values (OP, OT, etc.)

#### **`lib/core/network/interceptors/auth_interceptor.dart`**
- Added `/searchpurchaseorder` to public endpoints list
- This prevents adding `Authorization: Bearer` header (token goes in body instead)

#### **`lib/features/search/data/datasources/order_remote_data_source.dart`**
- Updated to retrieve token from `SecureStorageService`
- Constructs request body with correct field names
- Parses `SearchResponseModel` and validates status
- Returns list of `PurchaseLineDetailModel`
- Comprehensive logging at every step

#### **`lib/features/search/presentation/providers/search_providers.dart`**
- Added `secureStorage` dependency to `orderRemoteDataSourceProvider`

#### **Repository, UseCase, ViewModel, State**
- Updated to use `PurchaseLineDetailEntity` instead of `OrderEntity`
- All layers properly updated to handle the new structure

---

### 5. **Error Handling**

The implementation handles multiple error scenarios:

#### **Authentication Errors:**
```dart
if (token == null || token.isEmpty) {
  throw Exception('Authentication token not found. Please login again.');
}
```

#### **API Status Errors:**
```dart
if (searchResponse.status != 'SUCCESS') {
  throw Exception('Search failed: ${searchResponse.status}');
}
```

#### **Network/Server Errors:**
- 400/404 errors - Caught as `ServerException`
- 500 errors - Caught as `ServerException`
- Network issues - Caught as `NetworkException`
- Timeouts - Caught as `TimeoutException`

All errors are properly converted to `Failure` objects and displayed in the UI.

---

### 6. **UI Flow**

#### **Search Screen (`search_screen.dart`):**

1. **Initial State:**
   - Form ready for input
   - Organization field empty (no default value)
   - Order type defaults to "Purchase Order" (OP)

2. **Loading State (during API call):**
   - Input fields disabled
   - Radio buttons disabled
   - Button shows spinner
   - "Search" text changes to loading indicator

3. **Success State:**
   - Green SnackBar: "Found X line item(s)"
   - Auto-navigation to records list screen
   - Line details data passed to next screen

4. **Empty State (no results):**
   - Orange SnackBar: "No orders found for the given search criteria"
   - User stays on search screen
   - Can modify search and try again

5. **Error State:**
   - Red error box displayed above form
   - Red SnackBar with error message and "Retry" button
   - User can tap retry to re-attempt search
   - Inputs remain enabled for modification

---

### 7. **Response Example**

**Success Response:**
```json
{
  "PurchaseLineDetails": [
    {
      "OrderNumber": 1071,
      "OrderType": "OP",
      "OrderCo": "00200",
      "LineNumber": 1,
      "QuantityOpen": 3,
      "AmountOpen": 48600,
      "CurCode": "USD",
      "BaseCurr": "USD",
      "ItemNumber": "MULTIVIT",
      "ItemDescription": "Multivitamin Tablets",
      "AccountNumber": " ",
      "OrderDate": "2026-04-09"
    }
  ],
  "jde__status": "SUCCESS"
}
```

**Empty Response:**
```json
{
  "PurchaseLineDetails": [],
  "jde__status": "SUCCESS"
}
```

**Error Response (4xx/5xx):**
```json
{
  "message": "Invalid order number",
  "exception": "ValidationException",
  "status": "ERROR"
}
```

---

## 🔧 Next Steps Required

### 1. **Run Build Runner**

Generate the Freezed code for new models:

```bash
cd /Users/nvc/Documents/Sid/putaway
dart run build_runner build --delete-conflicting-outputs
```

This will generate:
- `purchase_line_detail_model.freezed.dart`
- `purchase_line_detail_model.g.dart`
- `search_response_model.freezed.dart`
- `search_response_model.g.dart`
- Updated `search_state.freezed.dart`

### 2. **Update Records List Screen**

The search flow currently navigates to `/records` but needs to:
1. Accept the `List<PurchaseLineDetailEntity>` as parameter or via provider
2. Display the line items in a list
3. Show fields: Line Number, Item Number, Description, Quantity, etc.

**Provider Approach (Recommended):**

Create a provider to hold the search results:

```dart
// lib/features/search/presentation/providers/search_results_provider.dart
final searchResultsProvider = StateProvider<List<PurchaseLineDetailEntity>?>((ref) => null);
```

In `search_screen.dart`, save results after successful search:

```dart
success: (lineDetails) {
  // Save to provider
  ref.read(searchResultsProvider.notifier).state = lineDetails;
  
  // Navigate
  context.router.pushNamed('/records');
}
```

In `records_list_screen.dart`, read from provider:

```dart
final searchResults = ref.watch(searchResultsProvider);

if (searchResults == null || searchResults.isEmpty) {
  return EmptyWidget(message: 'No records found');
}

return ListView.builder(
  itemCount: searchResults.length,
  itemBuilder: (context, index) {
    final item = searchResults[index];
    return ListTile(
      title: Text('${item.itemNumber} - ${item.itemDescription}'),
      subtitle: Text('Line ${item.lineNumber} | Qty: ${item.quantityOpen}'),
      // ... more details
    );
  },
);
```

---

## 📱 Testing Instructions

### Test Case 1: Successful Search with Organization
```
1. Login successfully
2. Navigate to search screen
3. Enter organization: "AWH"
4. Select order type: "Purchase Order"
5. Enter order number: "1071"
6. Tap "Search"

✅ Expected:
- Loading state shows
- Success SnackBar: "Found 2 line item(s)"
- Navigate to records list
- Records list shows 2 items
```

### Test Case 2: Successful Search without Organization
```
1. Leave organization field empty
2. Select order type: "Purchase Order"
3. Enter order number: "1071"
4. Tap "Search"

✅ Expected:
- Request body omits "BranchPlant"
- Search works correctly
```

### Test Case 3: No Results
```
1. Enter non-existent order number: "99999"
2. Tap "Search"

✅ Expected:
- Orange SnackBar: "No orders found..."
- Stay on search screen
```

### Test Case 4: Invalid Order Number (400 Error)
```
1. Enter invalid order number: "ABC"
2. Tap "Search"

✅ Expected:
- Red error box with error message
- Red SnackBar with retry button
- Can modify and retry
```

### Test Case 5: Token Missing (Authentication Error)
```
1. Clear app data (simulate logout)
2. Try to search

✅ Expected:
- Error: "Authentication token not found. Please login again."
```

### Test Case 6: Network Error
```
1. Disable network/WiFi
2. Tap "Search"

✅ Expected:
- Error: "Network error. Please check your connection."
- Retry button available
```

### Test Case 7: Barcode Scanner
```
1. Tap QR code scanner icon
2. Scan barcode with order number
3. Order number field auto-fills
4. Tap "Search"

✅ Expected:
- Works same as manual entry
```

---

## 🔍 Debugging & Logging

Comprehensive logging is added throughout:

### **Search Screen:**
```
SearchScreen: Form validated, calling search
SearchScreen: State changed from <prev> to <next>
SearchScreen: Search successful! Found X line items
SearchScreen: Navigating to records list
```

### **ViewModel:**
```
SearchViewModel: Starting search - orderType: OP, orderNumber: 1071
SearchViewModel: Search successful - found X line items
```

### **Repository:**
```
OrderRepository: Searching orders - type: OP, number: 1071
OrderRepository: Found X line items
```

### **Data Source:**
```
OrderRemoteDataSource: Searching orders - type: OP, number: 1071, org: AWH
OrderRemoteDataSource: Token retrieved: Yes
OrderRemoteDataSource: Request body: {...}
OrderRemoteDataSource: Response received
OrderRemoteDataSource: Found X line items
```

### **Dio (HTTP):**
```
╔╣ Request ║ POST
║ http://129.154.245.81:7070/jderest/searchpurchaseorder
╠═ Body: {...}
╔╣ Response ║ Status: 200 OK
║ { "PurchaseLineDetails": [...] }
```

---

## 📊 Architecture Flow

```
SearchScreen (UI)
    ↓ [User taps Search]
    ↓
SearchViewModel.searchOrders()
    ↓
SearchOrdersUseCase.call()
    ↓
OrderRepository.searchOrders()
    ↓
OrderRemoteDataSource.searchOrders()
    ↓ [Retrieve token from SecureStorage]
    ↓
DioClient.post('/searchpurchaseorder')
    ↓ [AuthInterceptor skips adding Authorization header]
    ↓
API Response (PurchaseLineDetails)
    ↓
Parse SearchResponseModel
    ↓
Convert to PurchaseLineDetailEntity list
    ↓
Return Either<Failure, List<Entity>>
    ↓
Update SearchState (success/error/empty)
    ↓
SearchScreen reacts to state
    ↓ [If success]
    ↓
Navigate to RecordsListScreen
```

---

## ✅ Checklist

- [x] Update order type constants (OP, OT, etc.)
- [x] Create `PurchaseLineDetailEntity`
- [x] Create `PurchaseLineDetailModel` with Freezed
- [x] Create `SearchResponseModel` with Freezed
- [x] Update `order_remote_data_source.dart` to fetch token and call API
- [x] Update auth interceptor to skip search endpoint
- [x] Update repository to use new entity
- [x] Update use case to use new entity
- [x] Update state to use new entity
- [x] Update viewmodel to use new entity
- [x] Update search screen to handle new response
- [x] Add comprehensive logging
- [x] Remove default organization value
- [ ] **Run build_runner** (YOU NEED TO DO THIS)
- [ ] **Update records list screen to display search results** (NEXT TASK)

---

## 🚀 Current Status

**Status:** ✅ **API Integration Complete - Needs Code Generation**

The search API is fully integrated with:
- Proper request body format
- Token retrieval from storage
- Response parsing with new models
- Error handling for all scenarios
- UI states (loading, success, error, empty)
- Comprehensive logging

**Next Action:** Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed code, then implement the records list screen UI.

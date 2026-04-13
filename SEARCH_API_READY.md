# Search API Integration - Ready for Implementation

## ✅ What's Been Done

### 1. **Removed Default Organization Value**
The organization field in the search screen now starts empty instead of having "001" pre-filled.

### 2. **Complete Search Flow Implemented**

Following the same Clean Architecture pattern as login:

```
SearchScreen (UI)
    ↓
SearchViewModel (StateNotifier)
    ↓
SearchOrdersUseCase
    ↓
OrderRepository (Interface)
    ↓
OrderRepositoryImpl
    ↓
OrderRemoteDataSource
    ↓
DioClient → API Call
```

### 3. **Files Created/Updated**

#### **New Files:**
- `lib/features/search/presentation/providers/search_providers.dart`
  - All Riverpod providers for search feature
  - Similar to `auth_providers.dart` structure

#### **Updated Files:**
- `lib/features/search/presentation/screens/search_screen.dart`
  - Integrated with providers and state management
  - Loading states, error handling, success navigation
  - Disabled inputs during API call
  - Comprehensive logging

- `lib/features/search/presentation/viewmodels/search_viewmodel.dart`
  - Added logging for debugging
  - Handles empty results separately

- `lib/features/search/data/repositories/order_repository_impl.dart`
  - Added comprehensive logging
  - Better error handling

---

## 📋 What You Need to Provide

### Search API Endpoint Details

Please provide the following information:

#### 1. **API Endpoint**
```
POST/GET http://your-api-url/search-endpoint
```

#### 2. **Request Format**
What should the request body/parameters look like?

**Example (please confirm):**
```json
{
  "orderType": "PO",
  "orderNumber": "123456",
  "organization": "001"  // optional
}
```

#### 3. **Success Response**
What does the API return when orders are found?

**Example (please provide actual structure):**
```json
{
  "orders": [
    {
      "orderId": "123",
      "orderNumber": "PO-001",
      "orderType": "PO",
      "status": "Open",
      "lineNumber": "1",
      "itemCode": "ITEM-123",
      "itemDescription": "Sample Item",
      "quantity": 100,
      "receivedQuantity": 50,
      "remainingQuantity": 50,
      "uom": "EA",
      "supplier": "Supplier Name",
      // ... other fields
    }
  ]
}
```

#### 4. **Empty/No Results Response**
What does the API return when no orders match?

**Example:**
```json
{
  "orders": [],
  "message": "No orders found"
}
```

#### 5. **Error Response**
What does the API return on error?

**Example:**
```json
{
  "message": "Invalid order type",
  "exception": "ValidationException",
  "status": "ERROR"
}
```

#### 6. **Headers Required**
- Does this endpoint need authentication (Bearer token)?
- Any other specific headers?

---

## 🔧 What Will Be Updated Once You Provide API Details

### 1. **Add Search Endpoint to Constants**
```dart
// lib/core/constants/app_constants.dart
static const String endpointSearchOrders = '/your-search-endpoint';
```

### 2. **Update Remote Data Source**
```dart
// lib/features/search/data/datasources/order_remote_data_source.dart
Future<List<OrderModel>> searchOrders({
  required String orderType,
  required String orderNumber,
  String? organization,
}) async {
  final response = await _dioClient.post(
    AppConstants.endpointSearchOrders,
    data: {
      'orderType': orderType,
      'orderNumber': orderNumber,
      if (organization != null) 'organization': organization,
    },
  );

  // Parse response based on your API structure
  final List<dynamic> ordersJson = response['orders'];
  return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
}
```

### 3. **Update OrderModel**
Update the `OrderModel` to match your API response structure:
- `lib/features/search/domain/entities/order_entity.dart`
- `lib/features/search/data/models/order_model.dart`

### 4. **Test the Flow**
Once implemented, the flow will work exactly like login:
1. User enters search criteria
2. Taps "Search" button
3. UI shows loading state (spinner, disabled inputs)
4. API is called through the clean architecture layers
5. On success: Shows success message, navigates to records list
6. On empty: Shows "No orders found" message
7. On error: Shows error message with retry option

---

## 🎯 Current Search Screen Features

### ✅ Already Implemented:
- Form validation
- Organization field (optional)
- Order type selection (6 types)
- Order number field (required)
- Barcode scanner integration
- Loading states
- Error display
- Success navigation
- Empty state handling
- Comprehensive logging

### 🎨 UI States:
1. **Initial State**: Clean form, ready for input
2. **Loading State**: 
   - Inputs disabled
   - Button shows spinner
   - Radio buttons disabled
3. **Error State**: 
   - Error message box above form
   - Red SnackBar with retry action
4. **Success State**: 
   - Green SnackBar with order count
   - Auto-navigation to records list
5. **Empty State**: 
   - Orange SnackBar with "No orders found"

---

## 🔍 Order Type Mappings

The UI uses these order type values:

| UI Label | Constant Value |
|----------|---------------|
| Purchase Order | `PO` |
| Transfer Order | `TO` |
| RMA | `RMA` |
| ASN | `ASN` |
| Receipt | `RECEIPT` |
| Intransit Shipment | `INTRANSIT` |

**Please confirm these values match your API expectations.**

---

## 🚀 Testing Instructions (Once API is Integrated)

### Test Case 1: Successful Search
1. Enter order number (e.g., "123456")
2. Select order type (e.g., Purchase Order)
3. Tap "Search"
4. ✅ Should see loading state
5. ✅ Should navigate to records list
6. ✅ Should see success message

### Test Case 2: No Results
1. Enter non-existent order number
2. Tap "Search"
3. ✅ Should see "No orders found" message
4. ✅ Should stay on search screen

### Test Case 3: Error Handling
1. Enter invalid data or disconnect network
2. Tap "Search"
3. ✅ Should see error message
4. ✅ Should show retry button
5. ✅ Tap retry should re-attempt search

### Test Case 4: With Organization
1. Enter organization code (e.g., "001")
2. Enter order number
3. Tap "Search"
4. ✅ Should include organization in API request

### Test Case 5: Barcode Scanner
1. Tap barcode scanner icon
2. Scan a barcode
3. ✅ Order number field should auto-fill
4. Tap "Search"
5. ✅ Should work same as manual entry

---

## 📱 Logging

Comprehensive logging is added at every layer:

- **SearchScreen**: UI actions and state changes
- **SearchViewModel**: Business logic flow
- **OrderRepository**: API call results
- **OrderRemoteDataSource**: Request/response details (via DioClient)

Check logs with:
```bash
flutter run --verbose
```

Look for:
- `SearchScreen: ...`
- `SearchViewModel: ...`
- `OrderRepository: ...`

---

## 🎨 UI Preview

### Search Form:
```
┌─────────────────────────────────┐
│  Select Organization (Optional) │
│  [____________] 🗑️ 🔍           │
└─────────────────────────────────┘

Order Type:
○ Purchase Order
○ Transfer Order  
○ RMA
○ ASN
○ Receipt
○ Intransit Shipment

┌─────────────────────────────────┐
│  Scan or Enter Purchase Order   │
│  [____________] 📷               │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│          [ Search ]             │
└─────────────────────────────────┘
```

---

## ⏭️ Next Steps

1. **You Provide**: API endpoint details (see section above)
2. **I Will Update**: 
   - Constants file with endpoint
   - Remote data source with correct request/response
   - Order models to match API structure
3. **We Test**: Complete search flow end-to-end

---

## 💡 Notes

- The search flow is already fully wired up and ready
- Just needs the actual API endpoint and response structure
- State management pattern is identical to login (proven working)
- All UI states are handled (loading, success, error, empty)
- Logging is in place for easy debugging
- Error handling is comprehensive

**Status**: ⏸️ Ready for API details - then 15 minutes to complete integration!

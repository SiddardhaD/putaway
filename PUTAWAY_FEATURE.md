# PutAway Feature Documentation

## Overview
Complete implementation of the PutAway feature following Clean Architecture, integrated with the existing warehouse management app.

## Navigation Flow

```
Login → Dashboard → Two Apps:
                    1. PO Receipt (existing flow)
                    2. PutAway (new flow)
```

### Dashboard Screen
**Location:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Features:**
- Shows two app cards: "PO Receipt" (blue) and "PutAway" (green)
- Beautiful gradient cards with icons
- Logout button in app bar
- No back button (top-level navigation)

**Navigation:**
- Tap "PO Receipt" → `/search` (existing PO flow)
- Tap "PutAway" → `/putaway` (new PutAway flow)

## PutAway Feature Architecture

### 1. **API Endpoint**
**URL:** `POST http://129.154.245.81:7070/jderest/v3/orchestrator/ORCH_59_PutawayTaskDetails`

**Request Body:**
```json
{
  "deviceName": "MOBILE_APP",
  "token": "<from_secure_storage>",
  "OrderNumber": "1071",
  "OrderType": "OP",
  "BranchPlant": "AWH"
}
```

**Default Values:**
- `OrderType`: "OP" (hardcoded)
- `BranchPlant`: "AWH" (hardcoded)
- `deviceName`: "MOBILE_APP" (from AppConstants)

**User Input:**
- `OrderNumber`: Text field or barcode scanner

**Success Response:**
```json
{
  "PutawayTaskDetails": [
    {
      "Trip": 2,
      "FromLocation": "R* * *",
      "ToLocation": "1*A* *",
      "Quantity": 3240,
      "UM": "BT",
      "FromLot": " ",
      "StatusDescription": "Suggestion Printed",
      "Task": 184
    }
  ],
  "jde__status": "SUCCESS",
  "jde__startTimestamp": "2026-04-10T10:09:51.726+0000",
  "jde__endTimestamp": "2026-04-10T10:09:51.769+0000",
  "jde__serverExecutionSeconds": 0.043
}
```

### 2. **Domain Layer**

#### Entity
**File:** `lib/features/putaway/domain/entities/putaway_task_detail_entity.dart`
```dart
class PutawayTaskDetailEntity {
  final int trip;
  final String fromLocation;
  final String toLocation;
  final double quantity;
  final String um;
  final String fromLot;
  final String statusDescription;
  final int task;
}
```

#### Repository Interface
**File:** `lib/features/putaway/domain/repositories/putaway_repository.dart`
```dart
abstract class PutawayRepository {
  Future<Either<Failure, List<PutawayTaskDetailEntity>>> getPutawayTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
  });
}
```

#### Use Case
**File:** `lib/features/putaway/domain/usecases/get_putaway_tasks_usecase.dart`
```dart
class GetPutawayTasksUseCase {
  Future<Either<Failure, List<PutawayTaskDetailEntity>>> call({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
  })
}
```

### 3. **Data Layer**

#### Models
**File:** `lib/features/putaway/data/models/putaway_task_detail_model.dart`
```dart
@freezed
class PutawayTaskDetailModel with _$PutawayTaskDetailModel {
  const factory PutawayTaskDetailModel({
    @JsonKey(name: 'Trip') required int trip,
    @JsonKey(name: 'FromLocation') required String fromLocation,
    @JsonKey(name: 'ToLocation') required String toLocation,
    @JsonKey(name: 'Quantity') required double quantity,
    @JsonKey(name: 'UM') required String um,
    @JsonKey(name: 'FromLot') required String fromLot,
    @JsonKey(name: 'StatusDescription') required String statusDescription,
    @JsonKey(name: 'Task') required int task,
  }) = _PutawayTaskDetailModel;
}
```

**File:** `lib/features/putaway/data/models/putaway_response_model.dart`
```dart
@freezed
class PutawayResponseModel with _$PutawayResponseModel {
  const factory PutawayResponseModel({
    @JsonKey(name: 'PutawayTaskDetails') required List<PutawayTaskDetailModel> putawayTaskDetails,
    @JsonKey(name: 'jde__status') required String status,
  }) = _PutawayResponseModel;
}
```

#### Data Source
**File:** `lib/features/putaway/data/datasources/putaway_remote_data_source.dart`

**Key Features:**
- Retrieves token from secure storage
- Constructs request body with hardcoded OrderType and BranchPlant
- Validates `jde__status == 'SUCCESS'`
- Returns list of `PutawayTaskDetailModel`
- Comprehensive logging at all steps

#### Repository Implementation
**File:** `lib/features/putaway/data/repositories/putaway_repository_impl.dart`

**Key Features:**
- Transforms models to entities
- Handles all exception types (Server, Network, Timeout)
- Returns `Either<Failure, List<PutawayTaskDetailEntity>>`
- Comprehensive logging

### 4. **Presentation Layer**

#### State
**File:** `lib/features/putaway/presentation/states/putaway_state.dart`
```dart
@freezed
class PutawayState with _$PutawayState {
  const factory PutawayState.initial() = _Initial;
  const factory PutawayState.loading() = _Loading;
  const factory PutawayState.success(List<PutawayTaskDetailEntity> tasks) = _Success;
  const factory PutawayState.empty() = _Empty;
  const factory PutawayState.error(String message) = _Error;
}
```

#### ViewModel
**File:** `lib/features/putaway/presentation/viewmodels/putaway_viewmodel.dart`

**Methods:**
- `getPutawayTasks()` - Calls use case and updates state
- `reset()` - Resets to initial state

#### Providers
**File:** `lib/features/putaway/presentation/providers/putaway_providers.dart`

**Providers:**
- `putawayRemoteDataSourceProvider`
- `putawayRepositoryProvider`
- `getPutawayTasksUseCaseProvider`
- `putawayViewModelProvider`
- `putawayResultsProvider` - StateProvider to share results

### 5. **UI Screens**

#### PutAway Search Screen
**File:** `lib/features/putaway/presentation/screens/putaway_screen.dart`

**Features:**
- Single text field for Order Number
- Barcode scanner support
- Info banner showing default values (OrderType: OP, Branch: AWH)
- Home icon in app bar (navigates to dashboard)
- Green theme (to distinguish from PO Receipt blue theme)
- Loading, error, success, and empty states
- Auto-navigates to tasks list on success

**Form Fields:**
- Order Number (required, with barcode scanner)

**Hardcoded Values:**
- OrderType: "OP"
- BranchPlant: "AWH"

#### PutAway Tasks List Screen
**File:** `lib/features/putaway/presentation/screens/putaway_tasks_list_screen.dart`

**Features:**
- Displays list of putaway tasks in card format
- Search/filter functionality
- Shows task count in header
- Home icon in app bar
- Green theme consistent with PutAway branding

**Task Card Display:**
- **Header:** Task number and Trip number badges
- **Location Flow:** From → To with arrow icon
- **Details:** Quantity with unit, LOT/Serial
- **Status:** Status description in info banner

**Displayed Fields:**
- Task # (green badge)
- Trip # (blue badge)
- From Location
- To Location
- Quantity + Unit of Measure (UM)
- LOT/Serial (FromLot)
- Status Description

### 6. **Updated Navigation**

#### Login Flow
**Before:** Login → Search  
**Now:** Login → Dashboard

#### Success Flows
**PO Receipt Submit Success:** Item Details → Dashboard  
**All Screens:** Have Home icon → Dashboard

#### Home Icons Added To:
- Search Screen (PO Receipt)
- Item Details Screen (PO Receipt)
- PutAway Screen
- PutAway Tasks List Screen

### 7. **Router Configuration**

**File:** `lib/core/router/app_router.dart`

**Routes:**
```dart
'/login' - LoginRoute
'/dashboard' - DashboardRoute (new)
'/search' - SearchRoute (PO Receipt)
'/records' - RecordsListRoute (PO Receipt)
'/item-details' - ItemDetailsRoute (PO Receipt)
'/putaway' - PutawayRoute (new)
'/putaway-tasks' - PutawayTasksListRoute (new)
```

### 8. **Constants Updated**

**File:** `lib/core/constants/app_constants.dart`
```dart
static const String endpointPutawayTaskDetails = '/v3/orchestrator/ORCH_59_PutawayTaskDetails';
```

**Auth Interceptor Updated:**
Added `/v3/orchestrator/ORCH_59_PutawayTaskDetails` to public endpoints list.

## Flow Diagram

```
┌─────────────┐
│   Login     │
└──────┬──────┘
       │
       ↓ (Success)
┌─────────────┐
│  Dashboard  │
│             │
│ ┌─────────┐ │
│ │PO Receipt│ ├──→ Search → Records → Item Details → Submit
│ └─────────┘ │                                          │
│             │                                          ↓
│ ┌─────────┐ │                                     Dashboard
│ │ PutAway │ ├──→ PutAway Search → Tasks List ────→ Dashboard
│ └─────────┘ │
└─────────────┘
       ↑
       │ (Home Icons)
       └───────────┘
```

## User Journey - PutAway

### Step 1: Access PutAway
1. Login successfully
2. Dashboard displays
3. Tap "PutAway" card (green)

### Step 2: Search for Tasks
1. PutAway screen opens
2. Enter Order Number (or scan barcode)
3. See default values: OrderType=OP, Branch=AWH
4. Tap Search button

### Step 3: View Tasks
1. API called with token, order number, and defaults
2. On success, tasks list displays
3. Each task shows:
   - Task and Trip numbers
   - From/To locations
   - Quantity and unit
   - LOT information
   - Status description

### Step 4: Navigate
- Tap Home icon → Back to Dashboard
- Tap Back → Return to PutAway search

## Comparison: PO Receipt vs PutAway

| Feature | PO Receipt | PutAway |
|---------|-----------|---------|
| Theme Color | Blue | Green |
| Icon | inventory_2_outlined | move_to_inbox_outlined |
| Search Fields | Order Number + Organization | Order Number only |
| API | ORCH_59_PurchaseOrderLineDetails | ORCH_59_PutawayTaskDetails |
| Results | Purchase line items | Putaway tasks |
| Details Screen | Editable (Qty, LOT) + Submit | Display only (no submit yet) |
| Grid Layout | Line #, Item #, Quantity | Task #, Trip #, Locations, Qty |

## Error Handling

### API Errors
- Network errors → Red snackbar with retry
- Server errors → Red snackbar with error message
- Empty results → "No putaway tasks found" warning snackbar

### Token Missing
- Shows error: "Authentication token not found. Please login again."
- User must login again

### Validation
- Order Number is required
- Empty field shows validation error

## Logging

All layers provide comprehensive logging:

**ViewModel:**
```
PutawayViewModel: Getting tasks - order: 1071
PutawayViewModel: Success - 7 tasks
```

**Repository:**
```
PutawayRepository: Getting putaway tasks - order: 1071
PutawayRepository: Successfully retrieved 7 tasks
```

**Data Source:**
```
PutawayRemoteDataSource: Getting putaway tasks - order: 1071, type: OP, branch: AWH
PutawayRemoteDataSource: Token retrieved: Yes
PutawayRemoteDataSource: Request body: {...}
PutawayRemoteDataSource: Found 7 tasks
```

**UI:**
```
PutawayScreen: Form validated, calling search
PutawayScreen: Success! Found 7 tasks
PutawayScreen: Navigating to putaway tasks list
```

## Testing Scenarios

### Test 1: Normal Flow
1. Login → Dashboard
2. Tap PutAway card
3. Enter order "1071"
4. Tap Search
5. **Expected:** Success snackbar, navigate to tasks list with 7 tasks

### Test 2: Scan Order Number
1. In PutAway screen
2. Tap barcode scanner icon
3. Scan order barcode
4. Tap Search
5. **Expected:** Order number auto-filled, search executes

### Test 3: Empty Results
1. Enter non-existent order number
2. Tap Search
3. **Expected:** Warning snackbar "No putaway tasks found"

### Test 4: Network Error
1. Turn off network
2. Enter order number
3. Tap Search
4. **Expected:** Error snackbar with retry button

### Test 5: Home Navigation
1. From PutAway screen or Tasks List
2. Tap Home icon
3. **Expected:** Navigate back to Dashboard

### Test 6: Search Filtering
1. View tasks list with multiple items
2. Type in search field (e.g., "184")
3. **Expected:** List filters to show only Task 184

## Key Features

### 1. **Consistent Design**
- Green theme for PutAway (vs Blue for PO Receipt)
- Same architecture patterns
- Similar UI/UX flow

### 2. **Home Icons Everywhere**
All feature screens now have Home icon:
- Search Screen (PO Receipt)
- Records List Screen (PO Receipt)
- Item Details Screen (PO Receipt)
- PutAway Screen
- PutAway Tasks List Screen

### 3. **Smart Defaults**
- OrderType: OP (Purchase Order) - hardcoded
- BranchPlant: AWH - hardcoded
- User only enters Order Number

### 4. **Search & Filter**
PutAway Tasks List includes search functionality:
- Filter by Task number
- Filter by Location (From/To)
- Filter by Status Description
- Real-time search as you type

### 5. **Comprehensive Logging**
Every layer logs:
- API requests and responses
- State changes
- User actions
- Errors with stack traces

### 6. **Error Recovery**
All error screens include:
- Clear error messages
- Retry buttons
- Form data preserved

## File Structure

```
lib/features/putaway/
├── data/
│   ├── datasources/
│   │   └── putaway_remote_data_source.dart
│   ├── models/
│   │   ├── putaway_task_detail_model.dart
│   │   └── putaway_response_model.dart
│   └── repositories/
│       └── putaway_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── putaway_task_detail_entity.dart
│   ├── repositories/
│   │   └── putaway_repository.dart
│   └── usecases/
│       └── get_putaway_tasks_usecase.dart
└── presentation/
    ├── providers/
    │   ├── putaway_providers.dart
    │   └── putaway_results_provider.dart
    ├── screens/
    │   ├── putaway_screen.dart
    │   └── putaway_tasks_list_screen.dart
    ├── states/
    │   └── putaway_state.dart
    └── viewmodels/
        └── putaway_viewmodel.dart
```

## Complete App Flow Summary

### Login
User enters credentials → API validates → Navigate to **Dashboard**

### Dashboard
Shows two apps:
1. **PO Receipt** (Blue) - Receiving purchase orders
2. **PutAway** (Green) - Managing putaway tasks

### PO Receipt Flow
Dashboard → Search → Records List → Item Details → Submit → Dashboard

### PutAway Flow
Dashboard → PutAway Search → Tasks List → Dashboard

## Benefits

1. **Modular Architecture**: Each feature is independent and self-contained
2. **Consistent Patterns**: Both flows follow same Clean Architecture
3. **Easy Navigation**: Home icons provide quick access to dashboard
4. **Clear Separation**: Blue (PO Receipt) vs Green (PutAway) themes
5. **Scalable**: Easy to add more apps to dashboard
6. **Maintainable**: Clear folder structure and naming conventions

## Future Enhancements

Possible additions based on business requirements:
1. **PutAway Task Details**: Tap on task to see more details or perform actions
2. **Batch Operations**: Select multiple tasks for bulk actions
3. **Status Updates**: Update task status
4. **Filters**: Filter by trip, status, location
5. **Sorting**: Sort by task, trip, quantity
6. **Refresh**: Pull-to-refresh for latest data

## Constants Summary

**AppConstants additions:**
- `endpointPutawayTaskDetails = '/v3/orchestrator/ORCH_59_PutawayTaskDetails'`

**AuthInterceptor additions:**
- Added PutAway endpoint to public endpoints list
- Token included in request body, not Authorization header

All implementation is complete and ready for use! 🎉

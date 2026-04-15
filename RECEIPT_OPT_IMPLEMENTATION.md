# ReceiptOpt Implementation Guide

## Overview

Implemented the `ReceiptOpt` field to track whether a PO Receipt record has been edited. This field is now included in all API submissions to indicate which records were modified by the user.

## Requirements

- **Default Value**: All records have `ReceiptOpt=""` by default
- **Edited Records**: When a user opens a record and edits quantity or lot number, set `ReceiptOpt="1"`
- **Submit Behavior**: ALL records (edited and non-edited) are sent to the API with appropriate `ReceiptOpt` values

## Changes Made

### 1. Data Models Updated

#### `GridDataItem` Model
**File**: `lib/features/records/data/models/grid_data_item.dart`

Added `receiptOpt` field:
```dart
@freezed
class GridDataItem with _$GridDataItem {
  const factory GridDataItem({
    @JsonKey(name: 'LineNumber') required String lineNumber,
    @JsonKey(name: 'Quantity') required String quantity,
    @JsonKey(name: 'LotSerial') required String lotSerial,
    @JsonKey(name: 'ReceiptOpt') required String receiptOpt,  // NEW FIELD
  }) = _GridDataItem;
}
```

#### `SavedRecordData` Model
**File**: `lib/features/records/presentation/providers/saved_records_provider.dart`

Added `receiptOpt` field to track edited records:
```dart
class SavedRecordData {
  final String lineNumber;
  final String quantity;
  final String lotSerial;
  final String receiptOpt;  // NEW FIELD
  final DateTime savedAt;
  
  // ... constructor and methods
}
```

### 2. Item Details Screen Updated

**File**: `lib/features/records/presentation/screens/item_details_screen.dart`

When a user saves a record (edits quantity or lot), it's now marked with `receiptOpt='1'`:
```dart
Future<void> _handleSave() async {
  // Save data locally with ReceiptOpt="1" (indicating this record was edited)
  final savedRecord = SavedRecordData(
    lineNumber: widget.lineItem.lineNumber.toString(),
    quantity: _quantityController.text.trim(),
    lotSerial: _lotSerialController.text.trim(),
    receiptOpt: '1', // Mark as edited
    savedAt: DateTime.now(),
  );
  
  ref.read(savedRecordsProvider.notifier).saveRecord(savedRecord);
}
```

### 3. Records List Screen Updated

**File**: `lib/features/records/presentation/screens/records_list_screen.dart`

The `_handleSubmitAll()` method now:
1. Sends **ALL records** (not just edited ones)
2. Sets `ReceiptOpt="1"` for edited records
3. Sets `ReceiptOpt=""` for non-edited records

```dart
Future<void> _handleSubmitAll() async {
  final searchResults = ref.read(searchResultsProvider);
  final savedRecords = ref.read(savedRecordsProvider);
  
  // Build GridData for ALL records
  final gridData = searchResults.map((lineItem) {
    final lineNumber = lineItem.lineNumber.toString();
    final savedRecord = savedRecords[lineNumber];
    
    if (savedRecord != null) {
      // This record was edited - use saved data with ReceiptOpt="1"
      return GridDataItem(
        lineNumber: lineNumber,
        quantity: savedRecord.quantity,
        lotSerial: savedRecord.lotSerial,
        receiptOpt: '1', // Edited record
      );
    } else {
      // This record was NOT edited - use original data with ReceiptOpt=""
      return GridDataItem(
        lineNumber: lineNumber,
        quantity: lineItem.quantityOpen.toString(),
        lotSerial: '', // Default empty for non-edited records
        receiptOpt: '', // Not edited
      );
    }
  }).toList();
  
  // Submit all records to API
  await ref.read(submitViewModelProvider.notifier).submitReceive(
    orderNumber: orderNumber,
    branch: branch,
    gridData: gridData,
  );
}
```

## API Request Example

### Before Changes
Only edited records were sent:
```json
{
  "deviceName": "POSTMAN",
  "token": "...",
  "Order_Number": "1071",
  "Branch": "AWH",
  "GridData": [
    {
      "LineNumber": "3",
      "Quantity": "6",
      "LotSerial": ".."
    }
  ]
}
```

### After Changes
ALL records are sent with `ReceiptOpt` indicator:
```json
{
  "deviceName": "POSTMAN",
  "token": "...",
  "Order_Number": "1071",
  "Branch": "AWH",
  "GridData": [
    {
      "LineNumber": "1",
      "Quantity": "10",
      "LotSerial": "",
      "ReceiptOpt": ""
    },
    {
      "LineNumber": "2",
      "Quantity": "5",
      "LotSerial": "",
      "ReceiptOpt": ""
    },
    {
      "LineNumber": "3",
      "Quantity": "6",
      "LotSerial": "LOT123",
      "ReceiptOpt": "1"
    }
  ]
}
```

## Behavior Summary

### When User Edits a Record:
1. User taps on a record in the list
2. User edits quantity and/or lot number
3. User taps "Save"
4. Record is saved locally with `ReceiptOpt="1"`
5. Record appears with gray background and check icon in list

### When User Submits:
1. User taps "Submit All" button
2. System collects ALL records from search results
3. For each record:
   - If edited: Uses saved data with `ReceiptOpt="1"`
   - If not edited: Uses original data with `ReceiptOpt=""`
4. Sends ALL records to API
5. API can now identify which records were edited

## Testing Checklist

- [ ] Load PO with multiple line items
- [ ] Edit only one record (change quantity/lot)
- [ ] Verify edited record shows gray background and check icon
- [ ] Tap "Submit All"
- [ ] Verify API request includes ALL records
- [ ] Verify edited record has `ReceiptOpt="1"`
- [ ] Verify non-edited records have `ReceiptOpt=""`
- [ ] Verify API accepts the request successfully

## Database/Backend Considerations

The backend API should now:
1. Accept the `ReceiptOpt` field for each `GridData` item
2. Use `ReceiptOpt="1"` to identify which records require processing
3. Skip or handle differently records with `ReceiptOpt=""`

## Files Modified

1. `lib/features/records/data/models/grid_data_item.dart` - Added `receiptOpt` field
2. `lib/features/records/presentation/providers/saved_records_provider.dart` - Added `receiptOpt` to SavedRecordData
3. `lib/features/records/presentation/screens/item_details_screen.dart` - Set `receiptOpt="1"` when saving
4. `lib/features/records/presentation/screens/records_list_screen.dart` - Submit ALL records with appropriate `receiptOpt` values

## Freezed Code Generation

After making these changes, Freezed code was regenerated using:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

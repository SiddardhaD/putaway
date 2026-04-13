# Batch Save Implementation - PO Receipt Records

## Overview
Implemented a local save functionality for PO Receipt records where users can save multiple records locally before submitting them all at once via a single API call.

## Changes Made

### 1. Created Saved Records Provider
**File**: `lib/features/records/presentation/providers/saved_records_provider.dart`

- **SavedRecordData Model**: Stores line number, quantity, lot serial, and timestamp
- **SavedRecordsNotifier**: State management for saved records with methods:
  - `saveRecord()`: Save a record locally
  - `isSaved()`: Check if a record is saved
  - `getSavedRecord()`: Get saved record data
  - `getAllGridDataItems()`: Convert all saved records to GridDataItem format
  - `clearAll()`: Clear all saved records
  - `savedCount`: Get count of saved records

### 2. Updated Item Details Screen
**File**: `lib/features/records/presentation/screens/item_details_screen.dart`

**Key Changes:**
- Changed button text from "Submit" to "Save"
- Removed immediate API call on save
- Saves data locally using `savedRecordsProvider`
- Loads previously saved data if available on screen open
- Added quantity validation back: entered quantity cannot exceed available quantity
- Navigates back to list after successful save
- Shows success snackbar on save

**Validation:**
```dart
if (qty > availableQty) {
  return 'Quantity cannot exceed $availableQty';
}
```

### 3. Updated Records List Screen
**File**: `lib/features/records/presentation/screens/records_list_screen.dart`

**Key Changes:**

#### Visual Indicators for Saved Records:
- Gray background (`Colors.grey.shade100`) for saved records
- Green check icon next to line number for saved records
- Gray text color for saved records
- Displays saved quantity instead of original quantity

#### Submit All Button:
- Only appears when at least one record is saved
- Shows count of saved records
- Displays loading state during submission
- Disabled during submission

#### API Integration:
- `_handleSubmitAll()`: Collects all saved records and calls API once
- Validates that at least one record is saved
- Retrieves branch and order number from storage
- Converts saved records to GridDataItem array
- Calls existing submit API with all records at once

#### Success Handling:
- Shows success snackbar
- Clears all saved records
- Navigates to dashboard
- Provides retry action on error

## User Flow

### Saving Records:
1. User searches for PO and sees list of line items
2. User taps on a record to open Item Details
3. User enters Quantity and LOT/Serial Number
4. User taps "Save" button
5. Data is saved locally (not submitted to API yet)
6. User returns to list
7. Saved record shows:
   - Gray background
   - Check icon
   - Updated quantity value
8. User repeats for other records (optional - can save 1, 2, or all records)

### Submitting All:
9. "Submit All" button appears at bottom showing count of saved records
10. User taps "Submit All"
11. Single API call is made with all saved records in GridData array
12. On success:
    - Success message shown
    - All saved records cleared
    - Navigate to dashboard

## API Request Format

The submit API now receives multiple records in one call:

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
    },
    {
      "LineNumber": "2",
      "Quantity": "2",
      "LotSerial": ".."
    },
    {
      "LineNumber": "1",
      "Quantity": "1",
      "LotSerial": ".."
    }
  ]
}
```

## Validation Rules

1. **Quantity Validation**: Must be a positive integer not exceeding available quantity
2. **LOT/Serial Validation**: Required field, cannot be empty
3. **Minimum Records**: At least one record must be saved before "Submit All"
4. **Branch Validation**: Branch information must exist in local storage

## Edge Cases Handled

1. **Partial Saves**: User can save only some records (e.g., 2 out of 3)
   - Only saved records are submitted
   - Unsaved records are not included in API call

2. **Re-editing**: User can tap on already saved record to modify
   - Fields pre-populate with saved data
   - Can update and save again

3. **No Saved Records**: Submit All button hidden if no records saved

4. **API Errors**: Retry action available on submission failure

5. **Duplicate Navigation**: Fixed issue where search results page was being stacked twice

## Benefits

1. **Efficiency**: Single API call for multiple records instead of N calls
2. **User Experience**: Users can review and edit before final submission
3. **Flexibility**: Users can save partial records
4. **Visual Feedback**: Clear indication of which records are saved
5. **Data Integrity**: Quantity validation prevents over-submission
6. **Error Recovery**: Can retry all records on failure without losing data

## Testing Recommendations

1. Save single record and submit
2. Save all records and submit
3. Save partial records (2 out of 3) and submit
4. Edit already saved record
5. Test quantity validation (exceeding available quantity)
6. Test API error scenarios
7. Test navigation flow (search → list → details → list → submit)
8. Verify visual indicators for saved vs unsaved records

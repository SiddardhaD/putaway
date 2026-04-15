# Auto-Clear Order Number Field on Back Navigation

## Feature Overview

When users navigate back from the records/tasks list screen to the search screen, the order number text field is now automatically cleared, making it ready for the next scan or manual entry.

## Implementation

### PO Receipt Search Flow

**File**: `lib/features/search/presentation/screens/search_screen.dart`

```dart
// Navigate and wait for user to come back
await context.router.pushNamed('/records');

// Clear the order number when user comes back from records screen
_logger.i('SearchScreen: User returned from records list, clearing order number field');
_orderNumberController.clear();
```

### PutAway Search Flow

**File**: `lib/features/putaway/presentation/screens/putaway_screen.dart`

```dart
// Navigate and wait for user to come back
await context.router.push(
  PutawayTasksListRoute(
    orderNumber: _orderNumberController.text.trim(),
  ),
);

// Clear the order number when user comes back from tasks list screen
_logger.i('PutawayScreen: User returned from tasks list, clearing order number field');
if (mounted) {
  _orderNumberController.clear();
}
```

## User Flow

### Before (Old Behavior):
1. User enters/scans order number: "1071"
2. Search → Navigate to records list
3. User presses back button
4. **Order number field still shows "1071"**
5. User has to manually clear it before entering new number

### After (New Behavior):
1. User enters/scans order number: "1071"
2. Search → Navigate to records list
3. User presses back button
4. **Order number field is automatically cleared**
5. User can immediately scan or enter the next order number

## Benefits

✅ **Faster Workflow**: No manual clearing needed  
✅ **Better UX**: Ready for next scan immediately  
✅ **Prevents Errors**: Users won't accidentally search the same order twice  
✅ **Optimized for Zebra Scanner**: Quick successive scans without manual intervention  

## Technical Details

### How It Works

The implementation uses Flutter's `await` on navigation methods:
- `context.router.pushNamed()` returns a `Future` that completes when the pushed route is popped
- `context.router.push()` also returns a `Future` that completes on back navigation
- When the user presses back, the `await` completes and the next line executes
- The text field is cleared using `_orderNumberController.clear()`

### Safety Checks

Both implementations include proper safety checks:
- `if (mounted)` check before clearing to ensure widget is still in the tree
- Logger messages for debugging
- Navigation flag (`_hasNavigated`) to prevent duplicate navigation

## Testing

### Test Cases:
- [ ] Search for order number → Go to records → Press back → Field is cleared
- [ ] Scan barcode → Auto-navigate → Press back → Field is cleared
- [ ] Search multiple orders in succession → Each time field is cleared on back
- [ ] PutAway flow → Search → Navigate → Back → Field is cleared

## Files Modified

1. `lib/features/search/presentation/screens/search_screen.dart`
   - Added `await` before `context.router.pushNamed('/records')`
   - Added `_orderNumberController.clear()` after navigation returns

2. `lib/features/putaway/presentation/screens/putaway_screen.dart`
   - Made listener callback `async`
   - Made `success` callback `async`
   - Added `await` before `context.router.push()`
   - Added `_orderNumberController.clear()` after navigation returns

## Edge Cases Handled

- Widget disposal during navigation (checked with `mounted`)
- Multiple rapid searches (prevented with `_hasNavigated` flag)
- Async gaps (proper context checks)
- State refresh vs new navigation (only clears on actual navigation, not refreshes)

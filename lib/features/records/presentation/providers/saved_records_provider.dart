import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/grid_data_item.dart';

/// Model to store locally saved record data
class SavedRecordData {
  final String lineNumber;
  final String quantity;
  final String lotSerial;
  final DateTime savedAt;

  SavedRecordData({
    required this.lineNumber,
    required this.quantity,
    required this.lotSerial,
    required this.savedAt,
  });

  GridDataItem toGridDataItem() {
    return GridDataItem(
      lineNumber: lineNumber,
      quantity: quantity,
      lotSerial: lotSerial,
    );
  }
}

/// State notifier to manage saved records
class SavedRecordsNotifier extends StateNotifier<Map<String, SavedRecordData>> {
  SavedRecordsNotifier() : super({});

  /// Save a record locally
  void saveRecord(SavedRecordData record) {
    state = {
      ...state,
      record.lineNumber: record,
    };
  }

  /// Check if a record is saved
  bool isSaved(String lineNumber) {
    return state.containsKey(lineNumber);
  }

  /// Get saved record data
  SavedRecordData? getSavedRecord(String lineNumber) {
    return state[lineNumber];
  }

  /// Get all saved records as GridDataItems
  List<GridDataItem> getAllGridDataItems() {
    return state.values.map((record) => record.toGridDataItem()).toList();
  }

  /// Clear all saved records
  void clearAll() {
    state = {};
  }

  /// Get count of saved records
  int get savedCount => state.length;
}

/// Provider for saved records
final savedRecordsProvider =
    StateNotifierProvider<SavedRecordsNotifier, Map<String, SavedRecordData>>(
  (ref) => SavedRecordsNotifier(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../search/domain/entities/purchase_line_detail_entity.dart';

// Provider to store the current order context for submission
final currentOrderContextProvider = StateProvider<({
  String orderNumber,
  String branch,
})?>((ref) => null);

// Provider to collect grid data items for batch submission
final gridDataItemsProvider = StateProvider<List<({
  PurchaseLineDetailEntity lineItem,
  String quantity,
  String lotSerial,
})>>((ref) => []);

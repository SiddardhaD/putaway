import 'package:equatable/equatable.dart';

class RecordEntity extends Equatable {
  final String id;
  final String orderId;
  final String orderNumber;
  final int lineNumber;
  final int scheduleNumber;
  final String receiptNumber;
  final String itemCode;
  final String? itemDescription;
  final String? subinventory;
  final String? locator;
  final int quantity;
  final String? lotNumber;
  final String? serialNumber;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecordEntity({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.lineNumber,
    required this.scheduleNumber,
    required this.receiptNumber,
    required this.itemCode,
    this.itemDescription,
    this.subinventory,
    this.locator,
    required this.quantity,
    this.lotNumber,
    this.serialNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        orderNumber,
        lineNumber,
        scheduleNumber,
        receiptNumber,
        itemCode,
        itemDescription,
        subinventory,
        locator,
        quantity,
        lotNumber,
        serialNumber,
        status,
        createdAt,
        updatedAt,
      ];
}

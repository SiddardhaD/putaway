import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/record_entity.dart';

part 'record_model.freezed.dart';
part 'record_model.g.dart';

@freezed
class RecordModel with _$RecordModel {
  const RecordModel._();

  const factory RecordModel({
    required String id,
    required String orderId,
    required String orderNumber,
    required int lineNumber,
    required int scheduleNumber,
    required String receiptNumber,
    required String itemCode,
    String? itemDescription,
    String? subinventory,
    String? locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecordModel;

  factory RecordModel.fromJson(Map<String, dynamic> json) =>
      _$RecordModelFromJson(json);

  RecordEntity toEntity() {
    return RecordEntity(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      lineNumber: lineNumber,
      scheduleNumber: scheduleNumber,
      receiptNumber: receiptNumber,
      itemCode: itemCode,
      itemDescription: itemDescription,
      subinventory: subinventory,
      locator: locator,
      quantity: quantity,
      lotNumber: lotNumber,
      serialNumber: serialNumber,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory RecordModel.fromEntity(RecordEntity entity) {
    return RecordModel(
      id: entity.id,
      orderId: entity.orderId,
      orderNumber: entity.orderNumber,
      lineNumber: entity.lineNumber,
      scheduleNumber: entity.scheduleNumber,
      receiptNumber: entity.receiptNumber,
      itemCode: entity.itemCode,
      itemDescription: entity.itemDescription,
      subinventory: entity.subinventory,
      locator: entity.locator,
      quantity: entity.quantity,
      lotNumber: entity.lotNumber,
      serialNumber: entity.serialNumber,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

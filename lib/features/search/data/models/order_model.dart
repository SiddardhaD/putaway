import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required String id,
    required String orderNumber,
    required String orderType,
    String? organization,
    DateTime? createdAt,
    String? status,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      orderType: orderType,
      organization: organization,
      createdAt: createdAt,
      status: status,
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      orderType: entity.orderType,
      organization: entity.organization,
      createdAt: entity.createdAt,
      status: entity.status,
    );
  }
}

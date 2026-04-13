import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String orderType;
  final String? organization;
  final DateTime? createdAt;
  final String? status;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    this.organization,
    this.createdAt,
    this.status,
  });

  @override
  List<Object?> get props => [id, orderNumber, orderType, organization, createdAt, status];
}

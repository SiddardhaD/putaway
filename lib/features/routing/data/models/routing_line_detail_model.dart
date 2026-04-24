import '../../domain/entities/routing_line_detail_entity.dart';

class RoutingLineDetailModel {
  final int lineNumber;
  final String operationCode;
  final int quantity;
  final String unitMeasure;
  final String supplierName;
  final String lotNumber;
  final String containerId;

  RoutingLineDetailModel({
    required this.lineNumber,
    required this.operationCode,
    required this.quantity,
    required this.unitMeasure,
    required this.supplierName,
    required this.lotNumber,
    required this.containerId,
  });

  factory RoutingLineDetailModel.fromJson(Map<String, dynamic> json) {
    return RoutingLineDetailModel(
      lineNumber: (json['LineNumber'] as num?)?.toInt() ?? 0,
      operationCode: json['OperationCode']?.toString() ?? '',
      quantity: (json['Quantity'] as num?)?.toInt() ?? 0,
      unitMeasure: json['UnitMeasure']?.toString() ?? '',
      supplierName: json['SupplierName']?.toString() ?? '',
      lotNumber: json['LotNumber']?.toString() ?? '',
      containerId: json['ContainerId']?.toString().trim() ?? '',
    );
  }

  RoutingLineDetailEntity toEntity() {
    return RoutingLineDetailEntity(
      lineNumber: lineNumber,
      operationCode: operationCode,
      quantity: quantity,
      unitMeasure: unitMeasure,
      supplierName: supplierName,
      lotNumber: lotNumber,
      containerId: containerId,
    );
  }
}

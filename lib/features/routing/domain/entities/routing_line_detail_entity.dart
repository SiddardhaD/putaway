class RoutingLineDetailEntity {
  final int lineNumber;
  final String operationCode;
  final int quantity;
  final String unitMeasure;
  final String supplierName;
  final String lotNumber;
  final String containerId;

  const RoutingLineDetailEntity({
    required this.lineNumber,
    required this.operationCode,
    required this.quantity,
    required this.unitMeasure,
    required this.supplierName,
    required this.lotNumber,
    required this.containerId,
  });
}

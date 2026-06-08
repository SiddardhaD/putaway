class RoutingLineDetailEntity {
  final int lineNumber;
  final String operationCode;
  final int quantity;
  final String unitMeasure;
  final String supplierName;
  final String lotNumber;
  final String itemNumber;
  final String containerId;
  /// From ORCH_59_FetchLotDetails (display as returned by API).
  final String lotExpirationDate;
  final String manufacturingDate;

  const RoutingLineDetailEntity({
    required this.lineNumber,
    required this.operationCode,
    required this.quantity,
    required this.unitMeasure,
    required this.supplierName,
    required this.lotNumber,
    required this.itemNumber,
    required this.containerId,
    this.lotExpirationDate = '',
    this.manufacturingDate = '',
  });
}

/// Response from ORCH_59_FetchLotDetails (dates as returned by JDE, e.g. dd/MM/yyyy).
class RoutingLotDatesModel {
  final String lotExpirationDate;
  final String manufacturingDate;

  const RoutingLotDatesModel({
    required this.lotExpirationDate,
    required this.manufacturingDate,
  });

  factory RoutingLotDatesModel.fromJson(Map<String, dynamic> json) {
    return RoutingLotDatesModel(
      lotExpirationDate: json['LotExpirationDate']?.toString().trim() ?? '',
      manufacturingDate: json['ManufacturingDate']?.toString().trim() ?? '',
    );
  }
}

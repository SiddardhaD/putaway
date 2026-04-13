class PutawayTaskDetailEntity {
  final int trip;
  final String fromLocation;
  final String toLocation;
  final double quantity;
  final String um;
  final String fromLot;
  final String statusDescription;
  final int task;

  const PutawayTaskDetailEntity({
    required this.trip,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.um,
    required this.fromLot,
    required this.statusDescription,
    required this.task,
  });
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';

part 'putaway_task_detail_model.freezed.dart';
part 'putaway_task_detail_model.g.dart';

@freezed
class PutawayTaskDetailModel with _$PutawayTaskDetailModel {
  const PutawayTaskDetailModel._();

  const factory PutawayTaskDetailModel({
    @JsonKey(name: 'Trip') required int trip,
    @JsonKey(name: 'FromLocation') required String fromLocation,
    @JsonKey(name: 'ToLocation') required String toLocation,
    @JsonKey(name: 'Quantity') required double quantity,
    @JsonKey(name: 'UM') required String um,
    @JsonKey(name: 'FromLot') required String fromLot,
    @JsonKey(name: 'StatusDescription') required String statusDescription,
    @JsonKey(name: 'Task') required int task,
  }) = _PutawayTaskDetailModel;

  factory PutawayTaskDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PutawayTaskDetailModelFromJson(json);

  PutawayTaskDetailEntity toEntity() {
    return PutawayTaskDetailEntity(
      trip: trip,
      fromLocation: fromLocation,
      toLocation: toLocation,
      quantity: quantity,
      um: um,
      fromLot: fromLot,
      statusDescription: statusDescription,
      task: task,
    );
  }
}

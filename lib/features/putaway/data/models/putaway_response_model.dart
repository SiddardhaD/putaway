import 'package:freezed_annotation/freezed_annotation.dart';
import 'putaway_task_detail_model.dart';

part 'putaway_response_model.freezed.dart';
part 'putaway_response_model.g.dart';

@freezed
class PutawayResponseModel with _$PutawayResponseModel {
  const factory PutawayResponseModel({
    @JsonKey(name: 'PutawayTaskDetails') required List<PutawayTaskDetailModel> putawayTaskDetails,
    @JsonKey(name: 'jde__status') required String status,
    @JsonKey(name: 'jde__startTimestamp') String? startTimestamp,
    @JsonKey(name: 'jde__endTimestamp') String? endTimestamp,
    @JsonKey(name: 'jde__serverExecutionSeconds') double? serverExecutionSeconds,
  }) = _PutawayResponseModel;

  factory PutawayResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PutawayResponseModelFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_putaway_response_model.freezed.dart';
part 'confirm_putaway_response_model.g.dart';

@freezed
class ConfirmPutawayResponseModel with _$ConfirmPutawayResponseModel {
  const factory ConfirmPutawayResponseModel({
    @JsonKey(name: 'ServiceRequest1') Map<String, dynamic>? serviceRequest,
    @JsonKey(name: 'jde__status') required String status,
    @JsonKey(name: 'jde__startTimestamp') String? startTimestamp,
    @JsonKey(name: 'jde__endTimestamp') String? endTimestamp,
    @JsonKey(name: 'jde__serverExecutionSeconds') double? serverExecutionSeconds,
  }) = _ConfirmPutawayResponseModel;

  factory ConfirmPutawayResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPutawayResponseModelFromJson(json);
}

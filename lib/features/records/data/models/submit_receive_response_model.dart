import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_receive_response_model.freezed.dart';
part 'submit_receive_response_model.g.dart';

@freezed
class SubmitReceiveResponseModel with _$SubmitReceiveResponseModel {
  const factory SubmitReceiveResponseModel({
    @JsonKey(name: 'ServiceRequest1') Map<String, dynamic>? serviceRequest,
    @JsonKey(name: 'jde__status') required String status,
    @JsonKey(name: 'jde__simpleMessage') String? simpleMessage,
    @JsonKey(name: 'message') dynamic message,
    @JsonKey(name: 'exception') String? exception,
    @JsonKey(name: 'exceptionId') String? exceptionId,
    @JsonKey(name: 'jde__startTimestamp') String? startTimestamp,
    @JsonKey(name: 'jde__endTimestamp') String? endTimestamp,
    @JsonKey(name: 'jde__serverExecutionSeconds') double? serverExecutionSeconds,
  }) = _SubmitReceiveResponseModel;

  factory SubmitReceiveResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubmitReceiveResponseModelFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_putaway_request_model.freezed.dart';
part 'confirm_putaway_request_model.g.dart';

@freezed
class ConfirmPutawayRequestModel with _$ConfirmPutawayRequestModel {
  const factory ConfirmPutawayRequestModel({
    required String deviceName,
    required String token,
    @JsonKey(name: 'Task') required String task,
    @JsonKey(name: 'Trip') required String trip,
    @JsonKey(name: 'Version') required String version,
  }) = _ConfirmPutawayRequestModel;

  factory ConfirmPutawayRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPutawayRequestModelFromJson(json);
}

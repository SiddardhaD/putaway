import 'package:freezed_annotation/freezed_annotation.dart';
import 'grid_data_item.dart';

part 'submit_receive_request_model.freezed.dart';
part 'submit_receive_request_model.g.dart';

@freezed
class SubmitReceiveRequestModel with _$SubmitReceiveRequestModel {
  const factory SubmitReceiveRequestModel({
    @JsonKey(name: 'deviceName') required String deviceName,
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'Order_Number') required String orderNumber,
    @JsonKey(name: 'Branch') required String branch,
    @JsonKey(name: 'GridData') required List<GridDataItem> gridData,
  }) = _SubmitReceiveRequestModel;

  factory SubmitReceiveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SubmitReceiveRequestModelFromJson(json);
}

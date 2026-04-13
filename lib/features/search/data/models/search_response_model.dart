import 'package:freezed_annotation/freezed_annotation.dart';
import 'purchase_line_detail_model.dart';

part 'search_response_model.freezed.dart';
part 'search_response_model.g.dart';

@freezed
class SearchResponseModel with _$SearchResponseModel {
  const SearchResponseModel._();

  const factory SearchResponseModel({
    @JsonKey(name: 'PurchaseLineDetails') required List<PurchaseLineDetailModel> purchaseLineDetails,
    @JsonKey(name: 'jde__status') required String status,
    @JsonKey(name: 'jde__startTimestamp') String? startTimestamp,
    @JsonKey(name: 'jde__endTimestamp') String? endTimestamp,
    @JsonKey(name: 'jde__serverExecutionSeconds') double? serverExecutionSeconds,
  }) = _SearchResponseModel;

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseModelFromJson(json);
}

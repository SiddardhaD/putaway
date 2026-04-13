import 'package:freezed_annotation/freezed_annotation.dart';

part 'grid_data_item.freezed.dart';
part 'grid_data_item.g.dart';

@freezed
class GridDataItem with _$GridDataItem {
  const factory GridDataItem({
    @JsonKey(name: 'LineNumber') required String lineNumber,
    @JsonKey(name: 'Quantity') required String quantity,
    @JsonKey(name: 'LotSerial') required String lotSerial,
  }) = _GridDataItem;

  factory GridDataItem.fromJson(Map<String, dynamic> json) =>
      _$GridDataItemFromJson(json);
}

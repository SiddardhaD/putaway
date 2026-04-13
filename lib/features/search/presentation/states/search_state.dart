import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/purchase_line_detail_entity.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  const factory SearchState.success(List<PurchaseLineDetailEntity> lineDetails) = _Success;
  const factory SearchState.error(String message) = _Error;
  const factory SearchState.empty() = _Empty;
}

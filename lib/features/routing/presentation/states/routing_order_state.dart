import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/routing_line_detail_entity.dart';

part 'routing_order_state.freezed.dart';

@freezed
class RoutingOrderState with _$RoutingOrderState {
  const factory RoutingOrderState.initial() = _RoInitial;
  const factory RoutingOrderState.loading() = _RoLoading;
  const factory RoutingOrderState.success(List<RoutingLineDetailEntity> lines) =
      _RoSuccess;
  const factory RoutingOrderState.empty() = _RoEmpty;
  const factory RoutingOrderState.error(String message) = _RoError;
}

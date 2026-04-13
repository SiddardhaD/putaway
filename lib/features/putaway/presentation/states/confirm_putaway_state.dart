import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_putaway_state.freezed.dart';

@freezed
class ConfirmPutawayState with _$ConfirmPutawayState {
  const factory ConfirmPutawayState.initial() = _Initial;
  const factory ConfirmPutawayState.loading() = _Loading;
  const factory ConfirmPutawayState.success(String message) = _Success;
  const factory ConfirmPutawayState.error(String message) = _Error;
}

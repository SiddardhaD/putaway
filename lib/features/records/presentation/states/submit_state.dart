import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_state.freezed.dart';

@freezed
class SubmitState with _$SubmitState {
  const factory SubmitState.initial() = _Initial;
  const factory SubmitState.loading() = _Loading;
  const factory SubmitState.success(String message) = _Success;
  const factory SubmitState.error(String message) = _Error;
}

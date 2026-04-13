import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/record_entity.dart';

part 'record_action_state.freezed.dart';

@freezed
class RecordActionState with _$RecordActionState {
  const factory RecordActionState.initial() = _Initial;
  const factory RecordActionState.loading() = _Loading;
  const factory RecordActionState.success(RecordEntity record) = _Success;
  const factory RecordActionState.submitted() = _Submitted;
  const factory RecordActionState.error(String message) = _Error;
}

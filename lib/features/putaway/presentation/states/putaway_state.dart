import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';

part 'putaway_state.freezed.dart';

@freezed
class PutawayState with _$PutawayState {
  const factory PutawayState.initial() = _Initial;
  const factory PutawayState.loading() = _Loading;
  const factory PutawayState.success(List<PutawayTaskDetailEntity> tasks) = _Success;
  const factory PutawayState.empty() = _Empty;
  const factory PutawayState.error(String message) = _Error;
}

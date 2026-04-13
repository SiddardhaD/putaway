import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/record_entity.dart';

part 'records_state.freezed.dart';

@freezed
class RecordsState with _$RecordsState {
  const factory RecordsState.initial() = _Initial;
  const factory RecordsState.loading() = _Loading;
  const factory RecordsState.loaded(List<RecordEntity> records) = _Loaded;
  const factory RecordsState.error(String message) = _Error;
  const factory RecordsState.empty() = _Empty;
}

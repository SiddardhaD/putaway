import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/submit_record_usecase.dart';
import '../states/record_action_state.dart';

class SubmitRecordViewModel extends StateNotifier<RecordActionState> {
  final SubmitRecordUseCase submitRecordUseCase;

  SubmitRecordViewModel(this.submitRecordUseCase) : super(const RecordActionState.initial());

  Future<void> submitRecord(String recordId) async {
    state = const RecordActionState.loading();

    final result = await submitRecordUseCase(recordId);

    result.fold(
      (failure) => state = RecordActionState.error(failure.message),
      (_) => state = const RecordActionState.submitted(),
    );
  }

  void reset() {
    state = const RecordActionState.initial();
  }
}

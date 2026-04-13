import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/update_record_usecase.dart';
import '../states/record_action_state.dart';

class UpdateRecordViewModel extends StateNotifier<RecordActionState> {
  final UpdateRecordUseCase updateRecordUseCase;

  UpdateRecordViewModel(this.updateRecordUseCase) : super(const RecordActionState.initial());

  Future<void> updateRecord({
    required String recordId,
    String? subinventory,
    String? locator,
    int? quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    state = const RecordActionState.loading();

    final result = await updateRecordUseCase(
      recordId: recordId,
      subinventory: subinventory,
      locator: locator,
      quantity: quantity,
      lotNumber: lotNumber,
      serialNumber: serialNumber,
    );

    result.fold(
      (failure) => state = RecordActionState.error(failure.message),
      (record) => state = RecordActionState.success(record),
    );
  }

  void reset() {
    state = const RecordActionState.initial();
  }
}

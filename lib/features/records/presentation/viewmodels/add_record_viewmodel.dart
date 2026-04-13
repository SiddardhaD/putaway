import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/add_record_usecase.dart';
import '../states/record_action_state.dart';

class AddRecordViewModel extends StateNotifier<RecordActionState> {
  final AddRecordUseCase addRecordUseCase;

  AddRecordViewModel(this.addRecordUseCase) : super(const RecordActionState.initial());

  Future<void> addRecord({
    required String orderId,
    required String orderNumber,
    required String subinventory,
    required String locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    state = const RecordActionState.loading();

    final result = await addRecordUseCase(
      orderId: orderId,
      orderNumber: orderNumber,
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

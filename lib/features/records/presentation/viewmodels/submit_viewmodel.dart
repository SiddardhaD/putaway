import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/submit_receive_purchase_order_usecase.dart';
import '../../data/models/grid_data_item.dart';
import '../states/submit_state.dart';

class SubmitViewModel extends StateNotifier<SubmitState> {
  final SubmitReceivePurchaseOrderUseCase submitReceivePurchaseOrderUseCase;
  final Logger _logger = Logger();

  SubmitViewModel(this.submitReceivePurchaseOrderUseCase) 
      : super(const SubmitState.initial());

  Future<void> submitReceive({
    required String orderNumber,
    required String branch,
    required List<GridDataItem> gridData,
  }) async {
    _logger.i('SubmitViewModel: Starting submit - order: $orderNumber, items: ${gridData.length}');
    state = const SubmitState.loading();

    final result = await submitReceivePurchaseOrderUseCase(
      orderNumber: orderNumber,
      branch: branch,
      gridData: gridData,
    );

    result.fold(
      (failure) {
        _logger.e('SubmitViewModel: Submit failed - ${failure.message}');
        state = SubmitState.error(failure.message);
      },
      (response) {
        _logger.i('SubmitViewModel: Submit successful - status: ${response.status}');
        
        if (response.status == 'SUCCESS') {
          state = SubmitState.success('Purchase order received successfully! Order #$orderNumber');
        } else {
          _logger.e('SubmitViewModel: Unexpected status - ${response.status}');
          state = SubmitState.error('Submit failed with status: ${response.status}');
        }
      },
    );
  }

  void reset() {
    _logger.d('SubmitViewModel: Resetting state');
    state = const SubmitState.initial();
  }
}

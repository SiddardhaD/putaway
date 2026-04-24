import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/get_routing_order_details_usecase.dart';
import '../states/routing_order_state.dart';

class RoutingOrderViewModel extends StateNotifier<RoutingOrderState> {
  final GetRoutingOrderDetailsUseCase getRoutingOrderDetailsUseCase;
  final Logger _logger = Logger();

  RoutingOrderViewModel(this.getRoutingOrderDetailsUseCase)
      : super(const RoutingOrderState.initial());

  Future<void> getRoutingLineDetails({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String containerId,
  }) async {
    _logger.i('RoutingOrderViewModel: Loading lines for order $orderNumber');
    state = const RoutingOrderState.loading();

    final result = await getRoutingOrderDetailsUseCase(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
      containerId: containerId,
    );

    result.fold(
      (failure) {
        state = RoutingOrderState.error(failure.message);
      },
      (lines) {
        if (lines.isEmpty) {
          state = const RoutingOrderState.empty();
        } else {
          state = RoutingOrderState.success(lines);
        }
      },
    );
  }

  void reset() {
    state = const RoutingOrderState.initial();
  }
}

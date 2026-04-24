import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../putaway/presentation/states/confirm_putaway_state.dart';
import '../../domain/usecases/confirm_routing_usecase.dart';

class ConfirmRoutingViewModel extends StateNotifier<ConfirmPutawayState> {
  final ConfirmRoutingUseCase confirmRoutingUseCase;
  final Future<void> Function() reloadLinesAfterConfirm;
  final Logger _logger = Logger();

  ConfirmRoutingViewModel(
    this.confirmRoutingUseCase, {
    required this.reloadLinesAfterConfirm,
  }) : super(const ConfirmPutawayState.initial());

  Future<void> confirmRouting({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String lineNumber,
  }) async {
    _logger.i('ConfirmRoutingViewModel: line $lineNumber order $orderNumber');
    state = const ConfirmPutawayState.loading();

    final result = await confirmRoutingUseCase(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
      lineNumber: lineNumber,
    );

    await result.fold<Future<void>>(
      (failure) async {
        state = ConfirmPutawayState.error(failure.message);
      },
      (_) async {
        state = const ConfirmPutawayState.success('Routing confirmed successfully!');
        try {
          await reloadLinesAfterConfirm();
        } catch (e, st) {
          _logger.e('ConfirmRoutingViewModel: reload failed', error: e, stackTrace: st);
        }
      },
    );
  }

  void reset() {
    state = const ConfirmPutawayState.initial();
  }
}

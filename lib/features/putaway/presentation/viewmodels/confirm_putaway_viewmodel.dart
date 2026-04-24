import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/confirm_putaway_usecase.dart';
import '../states/confirm_putaway_state.dart';

class ConfirmPutawayViewModel extends StateNotifier<ConfirmPutawayState> {
  final ConfirmPutawayUseCase confirmPutawayUseCase;
  final Logger _logger = Logger();

  ConfirmPutawayViewModel(this.confirmPutawayUseCase)
      : super(const ConfirmPutawayState.initial());

  Future<void> confirmPutaway({
    required String task,
    required String trip,
  }) async {
    _logger.i('ConfirmPutawayViewModel: Confirming - task: $task, trip: $trip');
    state = const ConfirmPutawayState.loading();

    final result = await confirmPutawayUseCase(
      task: task,
      trip: trip,
      version: AppConstants.orchestratorVersionPutaway,
    );

    result.fold(
      (failure) {
        _logger.e('ConfirmPutawayViewModel: Failed - ${failure.message}');
        state = ConfirmPutawayState.error(failure.message);
      },
      (_) {
        _logger.i('ConfirmPutawayViewModel: Success');
        state = const ConfirmPutawayState.success('Putaway confirmed successfully!');
      },
    );
  }

  void reset() {
    _logger.d('ConfirmPutawayViewModel: Resetting state');
    state = const ConfirmPutawayState.initial();
  }
}

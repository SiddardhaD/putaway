import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../putaway/domain/usecases/confirm_putaway_usecase.dart';
import '../../../putaway/presentation/states/confirm_putaway_state.dart';

class ConfirmPickingViewModel extends StateNotifier<ConfirmPutawayState> {
  final ConfirmPutawayUseCase confirmPutawayUseCase;
  final Future<void> Function() reloadTasksFromLastSearch;
  final Logger _logger = Logger();

  ConfirmPickingViewModel(
    this.confirmPutawayUseCase, {
    required this.reloadTasksFromLastSearch,
  }) : super(const ConfirmPutawayState.initial());

  Future<void> confirmPicking({
    required String task,
    required String trip,
  }) async {
    _logger.i('ConfirmPickingViewModel: Confirming - task: $task, trip: $trip');
    state = const ConfirmPutawayState.loading();

    final result = await confirmPutawayUseCase(
      task: task,
      trip: trip,
      version: AppConstants.orchestratorVersionPicking,
    );

    await result.fold<Future<void>>(
      (failure) async {
        _logger.e('ConfirmPickingViewModel: Failed - ${failure.message}');
        state = ConfirmPutawayState.error(failure.message);
      },
      (_) async {
        _logger.i('ConfirmPickingViewModel: Success');
        state = const ConfirmPutawayState.success('Picking confirmed successfully!');
        _logger.i(
          'ConfirmPickingViewModel: Reloading task list (ORCH_59_PutawayTaskDetails) with last search order',
        );
        try {
          await reloadTasksFromLastSearch();
        } catch (e, st) {
          _logger.e(
            'ConfirmPickingViewModel: Reload after confirm failed',
            error: e,
            stackTrace: st,
          );
        }
      },
    );
  }

  void reset() {
    _logger.d('ConfirmPickingViewModel: Resetting state');
    state = const ConfirmPutawayState.initial();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../putaway/domain/usecases/get_putaway_tasks_usecase.dart';
import '../../../putaway/presentation/states/putaway_state.dart';

class PickingViewModel extends StateNotifier<PutawayState> {
  final GetPutawayTasksUseCase getPutawayTasksUseCase;
  final Logger _logger = Logger();

  PickingViewModel(this.getPutawayTasksUseCase) : super(const PutawayState.initial());

  Future<void> getPickingTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
  }) async {
    _logger.i('PickingViewModel: Getting tasks - order: $orderNumber');
    state = const PutawayState.loading();

    final result = await getPutawayTasksUseCase(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
      version: AppConstants.orchestratorVersionPicking,
    );

    result.fold(
      (failure) {
        _logger.e('PickingViewModel: Failed - ${failure.message}');
        state = PutawayState.error(failure.message);
      },
      (tasks) {
        _logger.i('PickingViewModel: Success - ${tasks.length} tasks');
        if (tasks.isEmpty) {
          state = const PutawayState.empty();
        } else {
          state = PutawayState.success(tasks);
        }
      },
    );
  }

  void reset() {
    _logger.d('PickingViewModel: Resetting state');
    state = const PutawayState.initial();
  }
}

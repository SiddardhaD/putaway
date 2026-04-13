import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/get_putaway_tasks_usecase.dart';
import '../states/putaway_state.dart';

class PutawayViewModel extends StateNotifier<PutawayState> {
  final GetPutawayTasksUseCase getPutawayTasksUseCase;
  final Logger _logger = Logger();

  PutawayViewModel(this.getPutawayTasksUseCase) : super(const PutawayState.initial());

  Future<void> getPutawayTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
  }) async {
    _logger.i('PutawayViewModel: Getting tasks - order: $orderNumber');
    state = const PutawayState.loading();

    final result = await getPutawayTasksUseCase(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
    );

    result.fold(
      (failure) {
        _logger.e('PutawayViewModel: Failed - ${failure.message}');
        state = PutawayState.error(failure.message);
      },
      (tasks) {
        _logger.i('PutawayViewModel: Success - ${tasks.length} tasks');
        if (tasks.isEmpty) {
          state = const PutawayState.empty();
        } else {
          state = PutawayState.success(tasks);
        }
      },
    );
  }

  void reset() {
    _logger.d('PutawayViewModel: Resetting state');
    state = const PutawayState.initial();
  }
}

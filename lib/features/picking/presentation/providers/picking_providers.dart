import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../putaway/domain/entities/putaway_task_detail_entity.dart';
import '../../../putaway/presentation/providers/putaway_providers.dart';
import '../viewmodels/picking_viewmodel.dart';
import '../viewmodels/confirm_picking_viewmodel.dart';
import '../../../putaway/presentation/states/putaway_state.dart';
import '../../../putaway/presentation/states/confirm_putaway_state.dart';

/// Reuses putaway repository + use cases; separate UI state for picking ([ZJDE0002]).
final pickingViewModelProvider =
    StateNotifierProvider<PickingViewModel, PutawayState>((ref) {
  final getPutawayTasksUseCase = ref.read(getPutawayTasksUseCaseProvider);
  return PickingViewModel(getPutawayTasksUseCase);
});

final pickingResultsProvider =
    StateProvider<List<PutawayTaskDetailEntity>>((ref) => []);

final pickingSearchParamsProvider =
    StateProvider<Map<String, String>?>((ref) => null);

final confirmPickingViewModelProvider =
    StateNotifierProvider<ConfirmPickingViewModel, ConfirmPutawayState>((ref) {
  final confirmPutawayUseCase = ref.read(confirmPutawayUseCaseProvider);

  Future<void> reloadTasksFromLastSearch() async {
    final params = ref.read(pickingSearchParamsProvider);
    final orderNumber = params?['orderNumber']?.trim() ?? '';
    if (orderNumber.isEmpty) {
      return;
    }
    await ref.read(pickingViewModelProvider.notifier).getPickingTasks(
          orderNumber: orderNumber,
          orderType: params?['orderType'] ?? AppConstants.orderTypePickingTasks,
          branchPlant: params?['branchPlant'] ?? 'AWH',
        );
  }

  return ConfirmPickingViewModel(
    confirmPutawayUseCase,
    reloadTasksFromLastSearch: reloadTasksFromLastSearch,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/routing_remote_data_source.dart';
import '../../data/repositories/routing_repository_impl.dart';
import '../../domain/entities/routing_line_detail_entity.dart';
import '../../domain/repositories/routing_repository.dart';
import '../../domain/usecases/confirm_routing_usecase.dart';
import '../../domain/usecases/get_routing_order_details_usecase.dart';
import '../../../putaway/presentation/states/confirm_putaway_state.dart';
import '../states/routing_order_state.dart';
import '../viewmodels/confirm_routing_viewmodel.dart';
import '../viewmodels/routing_order_viewmodel.dart';

final routingRemoteDataSourceProvider = Provider<RoutingRemoteDataSource>((ref) {
  return RoutingRemoteDataSourceImpl(
    ref.read(dioClientProvider),
    ref.read(secureStorageProvider),
  );
});

final routingRepositoryProvider = Provider<RoutingRepository>((ref) {
  return RoutingRepositoryImpl(
    remoteDataSource: ref.read(routingRemoteDataSourceProvider),
  );
});

final getRoutingOrderDetailsUseCaseProvider =
    Provider<GetRoutingOrderDetailsUseCase>((ref) {
  return GetRoutingOrderDetailsUseCase(ref.read(routingRepositoryProvider));
});

final confirmRoutingUseCaseProvider = Provider<ConfirmRoutingUseCase>((ref) {
  return ConfirmRoutingUseCase(ref.read(routingRepositoryProvider));
});

final routingLinesProvider =
    StateProvider<List<RoutingLineDetailEntity>>((ref) => []);

/// Keys: orderNumber, orderType, branchPlant, containerId
final routingSearchParamsProvider =
    StateProvider<Map<String, String>?>((ref) => null);

final routingOrderViewModelProvider =
    StateNotifierProvider<RoutingOrderViewModel, RoutingOrderState>((ref) {
  return RoutingOrderViewModel(ref.read(getRoutingOrderDetailsUseCaseProvider));
});

final confirmRoutingViewModelProvider =
    StateNotifierProvider<ConfirmRoutingViewModel, ConfirmPutawayState>((ref) {
  Future<void> reload() async {
    final p = ref.read(routingSearchParamsProvider);
    if (p == null) return;
    final order = p['orderNumber']?.trim() ?? '';
    if (order.isEmpty) return;
    await ref.read(routingOrderViewModelProvider.notifier).getRoutingLineDetails(
          orderNumber: order,
          orderType: p['orderType'] ?? '',
          branchPlant: p['branchPlant'] ?? '',
          containerId: p['containerId'] ?? '',
        );
  }

  return ConfirmRoutingViewModel(
    ref.read(confirmRoutingUseCaseProvider),
    reloadLinesAfterConfirm: reload,
  );
});

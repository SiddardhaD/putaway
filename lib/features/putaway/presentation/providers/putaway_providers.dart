import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/putaway_remote_data_source.dart';
import '../../data/repositories/putaway_repository_impl.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';
import '../../domain/repositories/putaway_repository.dart';
import '../../domain/usecases/get_putaway_tasks_usecase.dart';
import '../../domain/usecases/confirm_putaway_usecase.dart';
import '../states/putaway_state.dart';
import '../states/confirm_putaway_state.dart';
import '../viewmodels/putaway_viewmodel.dart';
import '../viewmodels/confirm_putaway_viewmodel.dart';

// Data Source Provider
final putawayRemoteDataSourceProvider = Provider<PutawayRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return PutawayRemoteDataSourceImpl(dioClient, secureStorage);
});

// Repository Provider
final putawayRepositoryProvider = Provider<PutawayRepository>((ref) {
  final remoteDataSource = ref.read(putawayRemoteDataSourceProvider);
  return PutawayRepositoryImpl(remoteDataSource: remoteDataSource);
});

// UseCase Providers
final getPutawayTasksUseCaseProvider = Provider<GetPutawayTasksUseCase>((ref) {
  final repository = ref.read(putawayRepositoryProvider);
  return GetPutawayTasksUseCase(repository);
});

final confirmPutawayUseCaseProvider = Provider<ConfirmPutawayUseCase>((ref) {
  final repository = ref.read(putawayRepositoryProvider);
  return ConfirmPutawayUseCase(repository);
});

// ViewModel Providers
final putawayViewModelProvider = StateNotifierProvider<PutawayViewModel, PutawayState>((ref) {
  final getPutawayTasksUseCase = ref.read(getPutawayTasksUseCaseProvider);
  return PutawayViewModel(getPutawayTasksUseCase);
});

final confirmPutawayViewModelProvider =
    StateNotifierProvider<ConfirmPutawayViewModel, ConfirmPutawayState>((ref) {
  final confirmPutawayUseCase = ref.read(confirmPutawayUseCaseProvider);
  return ConfirmPutawayViewModel(confirmPutawayUseCase);
});

// Provider to store putaway results
final putawayResultsProvider = StateProvider<List<PutawayTaskDetailEntity>>((ref) => []);

// Provider to store last search parameters for refresh
final putawaySearchParamsProvider = StateProvider<Map<String, String>?>((ref) => null);

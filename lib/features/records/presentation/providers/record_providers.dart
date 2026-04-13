import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/record_remote_data_source.dart';
import '../../data/repositories/record_repository_impl.dart';
import '../../domain/repositories/record_repository.dart';
import '../../domain/usecases/submit_receive_purchase_order_usecase.dart';
import '../states/submit_state.dart';
import '../viewmodels/submit_viewmodel.dart';

// Data Source Provider
final recordRemoteDataSourceProvider = Provider<RecordRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return RecordRemoteDataSourceImpl(dioClient, secureStorage);
});

// Repository Provider
final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final remoteDataSource = ref.read(recordRemoteDataSourceProvider);
  return RecordRepositoryImpl(remoteDataSource: remoteDataSource);
});

// UseCase Provider
final submitReceivePurchaseOrderUseCaseProvider = Provider<SubmitReceivePurchaseOrderUseCase>((ref) {
  final repository = ref.read(recordRepositoryProvider);
  return SubmitReceivePurchaseOrderUseCase(repository);
});

// ViewModel Provider
final submitViewModelProvider = StateNotifierProvider<SubmitViewModel, SubmitState>((ref) {
  final submitUseCase = ref.read(submitReceivePurchaseOrderUseCaseProvider);
  return SubmitViewModel(submitUseCase);
});

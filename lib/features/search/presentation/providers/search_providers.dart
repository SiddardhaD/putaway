import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import '../states/search_state.dart';
import '../viewmodels/search_viewmodel.dart';

// Data Source Provider
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return OrderRemoteDataSourceImpl(dioClient, secureStorage);
});

// Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.read(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: remoteDataSource);
});

// UseCase Provider
final searchOrdersUseCaseProvider = Provider<SearchOrdersUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return SearchOrdersUseCase(repository);
});

// ViewModel Provider
final searchViewModelProvider = StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final searchOrdersUseCase = ref.read(searchOrdersUseCaseProvider);
  return SearchViewModel(searchOrdersUseCase);
});

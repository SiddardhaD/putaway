import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/storage/local_storage_service.dart';
import '../../../../core/utils/storage/secure_storage_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../states/login_state.dart';
import '../viewmodels/login_viewmodel.dart';

// Network Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Storage Providers
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Data Source Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final localStorage = ref.read(localStorageProvider);
  return AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    localStorage: localStorage,
  );
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// UseCase Providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LogoutUseCase(repository);
});

// ViewModel Provider
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  return LoginViewModel(loginUseCase);
});

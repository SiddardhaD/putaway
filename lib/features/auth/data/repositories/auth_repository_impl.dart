import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Logger _logger = Logger();

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
    String? organization,
  }) async {
    try {
      _logger.i('AuthRepository: Calling remote data source for login');
      final userModel = await remoteDataSource.login(
        username: username,
        password: password,
        organization: organization,
      );

      _logger.i('AuthRepository: Login API successful, caching user data');
      _logger.d('AuthRepository: User model - username: ${userModel.username}, env: ${userModel.environment}');
      
      await localDataSource.cacheUser(userModel);
      
      _logger.i('AuthRepository: User cached successfully');
      final userEntity = userModel.toEntity();
      _logger.d('AuthRepository: Converted to entity - id: ${userEntity.id}, username: ${userEntity.username}');

      return Right(userEntity);
    } on ServerException catch (e) {
      _logger.e('AuthRepository: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('AuthRepository: NetworkException - ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      _logger.e('AuthRepository: TimeoutException - ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Unknown error - $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Login failed: ${e.toString()}', code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString(), code: 'CACHE_ERROR'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(CacheFailure(message: e.toString(), code: 'CACHE_ERROR'));
    }
  }
}

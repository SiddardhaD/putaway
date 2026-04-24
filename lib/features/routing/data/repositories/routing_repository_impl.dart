import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/routing_line_detail_entity.dart';
import '../../domain/repositories/routing_repository.dart';
import '../datasources/routing_remote_data_source.dart';

class RoutingRepositoryImpl implements RoutingRepository {
  final RoutingRemoteDataSource remoteDataSource;
  final Logger _logger = Logger();

  RoutingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RoutingLineDetailEntity>>> getRoutingLineDetails({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String containerId,
  }) async {
    try {
      final models = await remoteDataSource.getRoutingLineDetails(
        orderNumber: orderNumber,
        orderType: orderType,
        branchPlant: branchPlant,
        containerId: containerId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, st) {
      _logger.e('RoutingRepository: $e', error: e, stackTrace: st);
      return Left(
        UnknownFailure(
          message: 'Failed to load routing lines: $e',
          code: 'UNKNOWN',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> confirmRouting({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String lineNumber,
  }) async {
    try {
      await remoteDataSource.confirmRouting(
        orderNumber: orderNumber,
        orderType: orderType,
        branchPlant: branchPlant,
        lineNumber: lineNumber,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, st) {
      _logger.e('RoutingRepository confirm: $e', error: e, stackTrace: st);
      return Left(
        UnknownFailure(
          message: 'Failed to confirm routing: $e',
          code: 'UNKNOWN',
        ),
      );
    }
  }
}

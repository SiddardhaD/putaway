import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';
import '../../domain/repositories/putaway_repository.dart';
import '../datasources/putaway_remote_data_source.dart';

class PutawayRepositoryImpl implements PutawayRepository {
  final PutawayRemoteDataSource remoteDataSource;
  final Logger _logger = Logger();

  PutawayRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PutawayTaskDetailEntity>>> getPutawayTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String version,
  }) async {
    try {
      _logger.i('PutawayRepository: Getting putaway tasks - order: $orderNumber');
      
      final taskModels = await remoteDataSource.getPutawayTasks(
        orderNumber: orderNumber,
        orderType: orderType,
        branchPlant: branchPlant,
        version: version,
      );

      final taskEntities = taskModels.map((model) => model.toEntity()).toList();

      _logger.i('PutawayRepository: Successfully retrieved ${taskEntities.length} tasks');
      return Right(taskEntities);
    } on ServerException catch (e) {
      _logger.e('PutawayRepository: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('PutawayRepository: NetworkException - ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      _logger.e('PutawayRepository: TimeoutException - ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.e('PutawayRepository: Unknown error - $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Failed to get putaway tasks: ${e.toString()}', code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPutaway({
    required String task,
    required String trip,
    required String version,
  }) async {
    try {
      _logger.i('PutawayRepository: Confirming putaway - task: $task, trip: $trip');
      await remoteDataSource.confirmPutaway(task: task, trip: trip, version: version);
      _logger.i('PutawayRepository: Confirm successful');
      return const Right(null);
    } on ServerException catch (e) {
      _logger.e('PutawayRepository: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('PutawayRepository: NetworkException - ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      _logger.e('PutawayRepository: TimeoutException - ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.e('PutawayRepository: Unknown error - $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Failed to confirm putaway: ${e.toString()}', code: 'UNKNOWN'));
    }
  }
}

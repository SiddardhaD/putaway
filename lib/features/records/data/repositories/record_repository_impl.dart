import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/record_entity.dart';
import '../../domain/repositories/record_repository.dart';
import '../datasources/record_remote_data_source.dart';
import '../models/grid_data_item.dart';
import '../models/submit_receive_response_model.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordRemoteDataSource remoteDataSource;
  final Logger _logger = Logger();

  RecordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RecordEntity>>> getRecords(String orderId) async {
    try {
      final recordModels = await remoteDataSource.getRecords(orderId);
      return Right(recordModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, RecordEntity>> getRecordById(String recordId) async {
    try {
      final recordModel = await remoteDataSource.getRecordById(recordId);
      return Right(recordModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, RecordEntity>> addRecord({
    required String orderId,
    required String orderNumber,
    required String subinventory,
    required String locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    try {
      final recordModel = await remoteDataSource.addRecord(
        orderId: orderId,
        orderNumber: orderNumber,
        subinventory: subinventory,
        locator: locator,
        quantity: quantity,
        lotNumber: lotNumber,
        serialNumber: serialNumber,
      );
      return Right(recordModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, RecordEntity>> updateRecord({
    required String recordId,
    String? subinventory,
    String? locator,
    int? quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    try {
      final recordModel = await remoteDataSource.updateRecord(
        recordId: recordId,
        subinventory: subinventory,
        locator: locator,
        quantity: quantity,
        lotNumber: lotNumber,
        serialNumber: serialNumber,
      );
      return Right(recordModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, void>> submitRecord(String recordId) async {
    try {
      await remoteDataSource.submitRecord(recordId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String recordId) async {
    try {
      await remoteDataSource.deleteRecord(recordId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, SubmitReceiveResponseModel>> submitReceivePurchaseOrder({
    required String orderNumber,
    required String branch,
    required List<GridDataItem> gridData,
  }) async {
    try {
      _logger.i('RecordRepository: Submitting receive PO - order: $orderNumber');
      final response = await remoteDataSource.submitReceivePurchaseOrder(
        orderNumber: orderNumber,
        branch: branch,
        gridData: gridData,
      );

      _logger.i('RecordRepository: Submit successful');
      return Right(response);
    } on ServerException catch (e) {
      _logger.e('RecordRepository: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('RecordRepository: NetworkException - ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      _logger.e('RecordRepository: TimeoutException - ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.e('RecordRepository: Unknown error - $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Submit failed: ${e.toString()}', code: 'UNKNOWN'));
    }
  }
}

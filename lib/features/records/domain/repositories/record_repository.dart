import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/grid_data_item.dart';
import '../../data/models/submit_receive_response_model.dart';
import '../entities/record_entity.dart';

abstract class RecordRepository {
  Future<Either<Failure, List<RecordEntity>>> getRecords(String orderId);

  Future<Either<Failure, RecordEntity>> getRecordById(String recordId);

  Future<Either<Failure, RecordEntity>> addRecord({
    required String orderId,
    required String orderNumber,
    required String subinventory,
    required String locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
  });

  Future<Either<Failure, RecordEntity>> updateRecord({
    required String recordId,
    String? subinventory,
    String? locator,
    int? quantity,
    String? lotNumber,
    String? serialNumber,
  });

  Future<Either<Failure, void>> submitRecord(String recordId);

  Future<Either<Failure, void>> deleteRecord(String recordId);
  
  Future<Either<Failure, SubmitReceiveResponseModel>> submitReceivePurchaseOrder({
    required String orderNumber,
    required String branch,
    required List<GridDataItem> gridData,
  });
}

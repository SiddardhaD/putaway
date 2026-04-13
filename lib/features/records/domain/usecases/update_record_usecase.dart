import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/record_entity.dart';
import '../repositories/record_repository.dart';

class UpdateRecordUseCase {
  final RecordRepository repository;

  UpdateRecordUseCase(this.repository);

  Future<Either<Failure, RecordEntity>> call({
    required String recordId,
    String? subinventory,
    String? locator,
    int? quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    return await repository.updateRecord(
      recordId: recordId,
      subinventory: subinventory,
      locator: locator,
      quantity: quantity,
      lotNumber: lotNumber,
      serialNumber: serialNumber,
    );
  }
}

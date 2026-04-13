import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/record_entity.dart';
import '../repositories/record_repository.dart';

class AddRecordUseCase {
  final RecordRepository repository;

  AddRecordUseCase(this.repository);

  Future<Either<Failure, RecordEntity>> call({
    required String orderId,
    required String orderNumber,
    required String subinventory,
    required String locator,
    required int quantity,
    String? lotNumber,
    String? serialNumber,
  }) async {
    return await repository.addRecord(
      orderId: orderId,
      orderNumber: orderNumber,
      subinventory: subinventory,
      locator: locator,
      quantity: quantity,
      lotNumber: lotNumber,
      serialNumber: serialNumber,
    );
  }
}

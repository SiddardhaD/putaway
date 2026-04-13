import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/record_entity.dart';
import '../repositories/record_repository.dart';

class GetRecordsUseCase {
  final RecordRepository repository;

  GetRecordsUseCase(this.repository);

  Future<Either<Failure, List<RecordEntity>>> call(String orderId) async {
    return await repository.getRecords(orderId);
  }
}

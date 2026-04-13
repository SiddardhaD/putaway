import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/record_repository.dart';

class SubmitRecordUseCase {
  final RecordRepository repository;

  SubmitRecordUseCase(this.repository);

  Future<Either<Failure, void>> call(String recordId) async {
    return await repository.submitRecord(recordId);
  }
}

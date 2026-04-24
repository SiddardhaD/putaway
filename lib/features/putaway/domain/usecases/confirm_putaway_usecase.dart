import 'package:dartz/dartz.dart';
import 'package:putaway/core/error/failures.dart';
import '../repositories/putaway_repository.dart';

class ConfirmPutawayUseCase {
  final PutawayRepository repository;

  ConfirmPutawayUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String task,
    required String trip,
    required String version,
  }) async {
    return await repository.confirmPutaway(task: task, trip: trip, version: version);
  }
}

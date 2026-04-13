import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/putaway_task_detail_entity.dart';
import '../repositories/putaway_repository.dart';

class GetPutawayTasksUseCase {
  final PutawayRepository repository;

  GetPutawayTasksUseCase(this.repository);

  Future<Either<Failure, List<PutawayTaskDetailEntity>>> call({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
  }) async {
    return await repository.getPutawayTasks(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
    );
  }
}

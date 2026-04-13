import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/putaway_task_detail_entity.dart';

abstract class PutawayRepository {
  Future<Either<Failure, List<PutawayTaskDetailEntity>>> getPutawayTasks({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
  });
  
  Future<Either<Failure, void>> confirmPutaway({
    required String task,
    required String trip,
  });
}

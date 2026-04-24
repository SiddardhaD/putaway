import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/routing_line_detail_entity.dart';

abstract class RoutingRepository {
  Future<Either<Failure, List<RoutingLineDetailEntity>>> getRoutingLineDetails({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String containerId,
  });

  Future<Either<Failure, void>> confirmRouting({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String lineNumber,
  });
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/routing_line_detail_entity.dart';
import '../repositories/routing_repository.dart';

class GetRoutingOrderDetailsUseCase {
  final RoutingRepository repository;

  GetRoutingOrderDetailsUseCase(this.repository);

  Future<Either<Failure, List<RoutingLineDetailEntity>>> call({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String containerId,
  }) {
    return repository.getRoutingLineDetails(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
      containerId: containerId,
    );
  }
}

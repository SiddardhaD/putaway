import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/routing_repository.dart';

class ConfirmRoutingUseCase {
  final RoutingRepository repository;

  ConfirmRoutingUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderNumber,
    required String orderType,
    required String branchPlant,
    required String lineNumber,
  }) {
    return repository.confirmRouting(
      orderNumber: orderNumber,
      orderType: orderType,
      branchPlant: branchPlant,
      lineNumber: lineNumber,
    );
  }
}

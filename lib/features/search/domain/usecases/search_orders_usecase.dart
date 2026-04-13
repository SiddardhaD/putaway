import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/purchase_line_detail_entity.dart';
import '../repositories/order_repository.dart';

class SearchOrdersUseCase {
  final OrderRepository repository;

  SearchOrdersUseCase(this.repository);

  Future<Either<Failure, List<PurchaseLineDetailEntity>>> call({
    required String orderType,
    required String orderNumber,
    String? organization,
  }) async {
    return await repository.searchOrders(
      orderType: orderType,
      orderNumber: orderNumber,
      organization: organization,
    );
  }
}

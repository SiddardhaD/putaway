import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../entities/purchase_line_detail_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<PurchaseLineDetailEntity>>> searchOrders({
    required String orderType,
    required String orderNumber,
    String? organization,
  });

  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);
}

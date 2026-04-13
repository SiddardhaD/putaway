import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/purchase_line_detail_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final Logger _logger = Logger();

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PurchaseLineDetailEntity>>> searchOrders({
    required String orderType,
    required String orderNumber,
    String? organization,
  }) async {
    try {
      _logger.i('OrderRepository: Searching orders - type: $orderType, number: $orderNumber');
      final purchaseLineModels = await remoteDataSource.searchOrders(
        orderType: orderType,
        orderNumber: orderNumber,
        organization: organization,
      );

      _logger.i('OrderRepository: Found ${purchaseLineModels.length} line items');
      return Right(purchaseLineModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      _logger.e('OrderRepository: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('OrderRepository: NetworkException - ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      _logger.e('OrderRepository: TimeoutException - ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.e('OrderRepository: Unknown error - $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Search failed: ${e.toString()}', code: 'UNKNOWN'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    try {
      _logger.i('OrderRepository: Getting order details - id: $orderId');
      final orderModel = await remoteDataSource.getOrderDetails(orderId);
      return Right(orderModel.toEntity());
    } on ServerException catch (e) {
      _logger.e('OrderRepository: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      _logger.e('OrderRepository: NetworkException - ${e.message}');
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      _logger.e('OrderRepository: TimeoutException - ${e.message}');
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } catch (e, stackTrace) {
      _logger.e('OrderRepository: Unknown error - $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Failed to get order details: ${e.toString()}', code: 'UNKNOWN'));
    }
  }
}

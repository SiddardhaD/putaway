import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/grid_data_item.dart';
import '../../data/models/submit_receive_response_model.dart';
import '../repositories/record_repository.dart';

class SubmitReceivePurchaseOrderUseCase {
  final RecordRepository repository;

  SubmitReceivePurchaseOrderUseCase(this.repository);

  Future<Either<Failure, SubmitReceiveResponseModel>> call({
    required String orderNumber,
    required String branch,
    required List<GridDataItem> gridData,
  }) async {
    return await repository.submitReceivePurchaseOrder(
      orderNumber: orderNumber,
      branch: branch,
      gridData: gridData,
    );
  }
}

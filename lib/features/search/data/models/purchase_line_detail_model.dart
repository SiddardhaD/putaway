import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/purchase_line_detail_entity.dart';

part 'purchase_line_detail_model.freezed.dart';
part 'purchase_line_detail_model.g.dart';

@freezed
class PurchaseLineDetailModel with _$PurchaseLineDetailModel {
  const PurchaseLineDetailModel._();

  const factory PurchaseLineDetailModel({
    @JsonKey(name: 'OrderNumber') required int orderNumber,
    @JsonKey(name: 'OrderType') required String orderType,
    @JsonKey(name: 'OrderCo') required String orderCo,
    @JsonKey(name: 'LineNumber') required int lineNumber,
    @JsonKey(name: 'QuantityOpen') required double quantityOpen,
    @JsonKey(name: 'AmountOpen') required double amountOpen,
    @JsonKey(name: 'CurCode') required String curCode,
    @JsonKey(name: 'BaseCurr') required String baseCurr,
    @JsonKey(name: 'ItemNumber') required String itemNumber,
    @JsonKey(name: 'ItemDescription') required String itemDescription,
    @JsonKey(name: 'AccountNumber') required String accountNumber,
    @JsonKey(name: 'OrderDate') required String orderDate,
  }) = _PurchaseLineDetailModel;

  factory PurchaseLineDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseLineDetailModelFromJson(json);

  PurchaseLineDetailEntity toEntity() {
    return PurchaseLineDetailEntity(
      orderNumber: orderNumber,
      orderType: orderType,
      orderCo: orderCo,
      lineNumber: lineNumber,
      quantityOpen: quantityOpen,
      amountOpen: amountOpen,
      curCode: curCode,
      baseCurr: baseCurr,
      itemNumber: itemNumber,
      itemDescription: itemDescription,
      accountNumber: accountNumber,
      orderDate: orderDate,
    );
  }

  factory PurchaseLineDetailModel.fromEntity(PurchaseLineDetailEntity entity) {
    return PurchaseLineDetailModel(
      orderNumber: entity.orderNumber,
      orderType: entity.orderType,
      orderCo: entity.orderCo,
      lineNumber: entity.lineNumber,
      quantityOpen: entity.quantityOpen,
      amountOpen: entity.amountOpen,
      curCode: entity.curCode,
      baseCurr: entity.baseCurr,
      itemNumber: entity.itemNumber,
      itemDescription: entity.itemDescription,
      accountNumber: entity.accountNumber,
      orderDate: entity.orderDate,
    );
  }
}

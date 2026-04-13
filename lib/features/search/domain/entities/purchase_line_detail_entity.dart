import 'package:equatable/equatable.dart';

class PurchaseLineDetailEntity extends Equatable {
  final int orderNumber;
  final String orderType;
  final String orderCo;
  final int lineNumber;
  final double quantityOpen;
  final double amountOpen;
  final String curCode;
  final String baseCurr;
  final String itemNumber;
  final String itemDescription;
  final String accountNumber;
  final String orderDate;

  const PurchaseLineDetailEntity({
    required this.orderNumber,
    required this.orderType,
    required this.orderCo,
    required this.lineNumber,
    required this.quantityOpen,
    required this.amountOpen,
    required this.curCode,
    required this.baseCurr,
    required this.itemNumber,
    required this.itemDescription,
    required this.accountNumber,
    required this.orderDate,
  });

  @override
  List<Object?> get props => [
        orderNumber,
        orderType,
        orderCo,
        lineNumber,
        quantityOpen,
        amountOpen,
        curCode,
        baseCurr,
        itemNumber,
        itemDescription,
        accountNumber,
        orderDate,
      ];
}

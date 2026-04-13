import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import '../states/search_state.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  final SearchOrdersUseCase searchOrdersUseCase;
  final Logger _logger = Logger();

  SearchViewModel(this.searchOrdersUseCase)
    : super(const SearchState.initial());

  Future<void> searchOrders({
    required String orderType,
    required String orderNumber,
    String? organization,
  }) async {
    _logger.i(
      'SearchViewModel: Starting search - orderType: $orderType, orderNumber: $orderNumber',
    );
    state = const SearchState.loading();

    final result = await searchOrdersUseCase(
      orderType: orderType,
      orderNumber: orderNumber,
      organization: organization,
    );

    result.fold(
      (failure) {
        _logger.e('SearchViewModel: Search failed - ${failure.message}');
        state = SearchState.error(failure.message);
      },
      (lineDetails) {
        _logger.i(
          'SearchViewModel: Search successful - found ${lineDetails.length} line items',
        );
        if (lineDetails.isEmpty) {
          state = const SearchState.empty();
        } else {
          state = SearchState.success(lineDetails);
        }
      },
    );
  }

  void reset() {
    _logger.d('SearchViewModel: Resetting state');
    state = const SearchState.initial();
  }
}

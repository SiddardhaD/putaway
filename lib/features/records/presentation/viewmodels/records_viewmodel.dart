import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_records_usecase.dart';
import '../states/records_state.dart';

class RecordsViewModel extends StateNotifier<RecordsState> {
  final GetRecordsUseCase getRecordsUseCase;

  RecordsViewModel(this.getRecordsUseCase) : super(const RecordsState.initial());

  Future<void> loadRecords(String orderId) async {
    state = const RecordsState.loading();

    final result = await getRecordsUseCase(orderId);

    result.fold(
      (failure) => state = RecordsState.error(failure.message),
      (records) {
        if (records.isEmpty) {
          state = const RecordsState.empty();
        } else {
          state = RecordsState.loaded(records);
        }
      },
    );
  }

  void reset() {
    state = const RecordsState.initial();
  }
}

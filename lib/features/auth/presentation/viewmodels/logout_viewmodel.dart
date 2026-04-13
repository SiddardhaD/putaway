import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../states/logout_state.dart';

class LogoutViewModel extends StateNotifier<LogoutState> {
  final LogoutUseCase logoutUseCase;
  final Logger _logger = Logger();

  LogoutViewModel(this.logoutUseCase) : super(const LogoutState.initial());

  Future<void> logout(String token) async {
    _logger.i('LogoutViewModel: Starting logout');
    state = const LogoutState.loading();

    final result = await logoutUseCase(token);

    result.fold(
      (failure) {
        _logger.e('LogoutViewModel: Logout failed - ${failure.message}');
        state = LogoutState.error(failure.message);
      },
      (_) {
        _logger.i('LogoutViewModel: Logout successful');
        state = const LogoutState.success();
      },
    );
  }

  void reset() {
    _logger.d('LogoutViewModel: Resetting state');
    state = const LogoutState.initial();
  }
}

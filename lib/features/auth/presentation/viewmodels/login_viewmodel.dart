import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/login_usecase.dart';
import '../states/login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final LoginUseCase loginUseCase;
  final Logger _logger = Logger();

  LoginViewModel(this.loginUseCase) : super(const LoginState.initial());

  Future<void> login({
    required String username,
    required String password,
    String? organization,
  }) async {
    _logger.i('LoginViewModel: Starting login for user: $username');
    state = const LoginState.loading();

    final result = await loginUseCase(
      username: username,
      password: password,
      organization: organization,
    );

    result.fold(
      (failure) {
        _logger.e('LoginViewModel: Login failed - ${failure.message}');
        state = LoginState.error(failure.message);
      },
      (user) {
        _logger.i('LoginViewModel: Login successful - ${user.username}');
        state = LoginState.success(user);
      },
    );
  }

  void reset() {
    _logger.d('LoginViewModel: Resetting state');
    state = const LoginState.initial();
  }
}

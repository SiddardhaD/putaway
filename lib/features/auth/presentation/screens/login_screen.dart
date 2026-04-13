import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_providers.dart';
import '../states/login_state.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _organizationController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // _organizationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      _logger.i('LoginScreen: Form validated, calling login');

      // Reset any previous error state
      ref.read(loginViewModelProvider.notifier).reset();

      // Call the ViewModel login method
      await ref
          .read(loginViewModelProvider.notifier)
          .login(
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            // organization: _organizationController.text.trim().isEmpty
            //     ? null
            //     : _organizationController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    // Listen to state changes and handle side effects
    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      _logger.i('LoginScreen: State changed from $previous to $next');

      next.when(
        initial: () {
          _logger.d('LoginScreen: State is initial');
        },
        loading: () {
          _logger.d('LoginScreen: State is loading');
        },
        success: (user) {
          _logger.i('LoginScreen: Login successful! User: ${user.username}');

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppStrings.loginSuccess}\nWelcome, ${user.username}!',
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate to dashboard instead of search
            _logger.i('LoginScreen: Navigating to dashboard screen');
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                context.router.pushNamed('/dashboard');
              }
            });
          }
        },
        error: (message) {
          _logger.e('LoginScreen: Login error - $message');

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppStrings.retry,
                textColor: Colors.white,
                onPressed: _handleLogin,
              ),
            ),
          );
        },
      );
    });

    // Check loading state using pattern matching
    final isLoading = loginState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // Extract error message if in error state
    final errorMessage = loginState.maybeWhen(
      error: (message) => message,
      orElse: () => null,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Al Baker Group Logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loginToContinue,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Show error message if login failed
                          if (errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withAlpha(76),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // CustomTextField(
                          //   label: AppStrings.selectOrganization,
                          //   hint: 'Enter organization code (optional)',
                          //   controller: _organizationController,
                          //   prefixIcon: const Icon(Icons.business_outlined),
                          //   keyboardType: TextInputType.text,
                          //   enabled: !isLoading,
                          // ),
                          // const SizedBox(height: 20),
                          CustomTextField(
                            label: AppStrings.username,
                            hint: AppStrings.enterUsername,
                            controller: _usernameController,
                            prefixIcon: const Icon(Icons.person_outline),
                            keyboardType: TextInputType.text,
                            validator: Validators.validateUsername,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: AppStrings.password,
                            hint: AppStrings.enterPassword,
                            controller: _passwordController,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                            ),
                            obscureText: _obscurePassword,
                            validator: Validators.validatePassword,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                              ),
                              Text(
                                AppStrings.rememberMe,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: AppStrings.login,
                            onPressed: isLoading ? null : _handleLogin,
                            isLoading: isLoading,
                            height: 56,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Test with your JDE credentials\nUsername: NBARANWAL',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

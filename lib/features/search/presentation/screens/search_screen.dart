import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/states/logout_state.dart';
import '../providers/search_providers.dart';
import '../providers/search_results_provider.dart';
import '../states/search_state.dart';

@RoutePage()
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _organizationController = TextEditingController(text: 'AWH');
  final _orderNumberController = TextEditingController();
  final String _selectedOrderType = 'OP'; // Fixed to OP (Purchase Order)
  bool _hasNavigated = false; // Flag to prevent duplicate navigation

  @override
  void dispose() {
    _organizationController.dispose();
    _orderNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _logger.i('SearchScreen: User confirmed logout');

      // Get token from secure storage
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.read(AppConstants.keyAccessToken) ?? '';

      if (token.isEmpty) {
        _logger.w('SearchScreen: No token found, clearing local data only');
        // Clear local data and navigate to login
        final localStorage = ref.read(localStorageProvider);
        await localStorage.clear();
        if (mounted) {
          context.router.replaceNamed('/login');
        }
        return;
      }

      // Call logout with token
      await ref.read(logoutViewModelProvider.notifier).logout(token);
    } else {
      _logger.d('SearchScreen: User cancelled logout');
    }
  }

  Future<void> _scanBarcode() async {
    final result = await showBarcodeScanner(
      context,
      title: 'Scan Order Number',
    );
    if (result != null && result.isNotEmpty) {
      _logger.i('SearchScreen: Barcode scanned - $result');
      
      setState(() {
        _orderNumberController.text = result;
      });
      
      // Automatically trigger search after barcode scan
      _logger.i('SearchScreen: Auto-triggering search after barcode scan');
      await _handleSearch();
    }
  }

  Future<void> _handleSearch() async {
    if (_formKey.currentState?.validate() ?? false) {
      _logger.i('SearchScreen: Form validated, calling search');

      // Reset navigation flag for new search
      _hasNavigated = false;

      // Reset any previous state
      ref.read(searchViewModelProvider.notifier).reset();

      // Call the ViewModel search method
      await ref
          .read(searchViewModelProvider.notifier)
          .searchOrders(
            orderType: _selectedOrderType,
            orderNumber: _orderNumberController.text.trim(),
            organization: _organizationController.text.trim().isEmpty
                ? null
                : _organizationController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final logoutState = ref.watch(logoutViewModelProvider);

    // Listen to logout state changes
    ref.listen<LogoutState>(logoutViewModelProvider, (previous, next) {
      // Prevent duplicate processing of the same state
      if (previous == next) return;

      _logger.i('SearchScreen: Logout state changed from $previous to $next');

      next.when(
        initial: () {},
        loading: () {
          _logger.d('SearchScreen: Logout is loading');
        },
        success: () {
          _logger.i('SearchScreen: Logout successful, navigating to login');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out successfully'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to login screen and clear navigation stack
            context.router.replaceNamed('/login');
          }
        },
        error: (message) {
          _logger.e('SearchScreen: Logout error - $message');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logout failed: $message'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      );
    });

    // Listen to search state changes
    ref.listen<SearchState>(searchViewModelProvider, (previous, next) {
      // Prevent duplicate processing of the same state
      if (previous == next) return;

      _logger.i('SearchScreen: State changed from $previous to $next');

      next.when(
        initial: () {
          _logger.d('SearchScreen: State is initial');
        },
        loading: () {
          _logger.d('SearchScreen: State is loading');
        },
        success: (lineDetails) {
          _logger.i(
            'SearchScreen: Search successful! Found ${lineDetails.length} line items',
          );

          // Store results in provider for records list screen
          ref.read(searchResultsProvider.notifier).state = lineDetails;

          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found ${lineDetails.length} line item(s)'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );

            // Save branch/plant value to local storage for submit API
            final branchValue = _organizationController.text.trim();
            if (branchValue.isNotEmpty) {
              final localStorage = ref.read(localStorageProvider);
              localStorage.setString(AppConstants.keyBranchPlant, branchValue);
              _logger.i(
                'SearchScreen: Saved branch value to storage: $branchValue',
              );
            }

            // Navigate to records list screen only once
            if (!_hasNavigated) {
              _hasNavigated = true;
              _logger.i('SearchScreen: Navigating to records list');
              Future.delayed(const Duration(milliseconds: 300), () async {
                if (mounted) {
                  // Navigate and wait for user to come back
                  await context.router.pushNamed('/records');
                  
                  // Clear the order number when user comes back from records screen
                  _logger.i('SearchScreen: User returned from records list, clearing order number field');
                  _orderNumberController.clear();
                }
              });
            } else {
              _logger.d('SearchScreen: Navigation already performed, skipping');
            }
          }
        },
        empty: () {
          _logger.i('SearchScreen: No orders found');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.noOrdersFound),
                backgroundColor: AppColors.warning,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        error: (message) {
          _logger.e('SearchScreen: Search error - $message');

          if (mounted) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: AppStrings.retry,
                  textColor: Colors.white,
                  onPressed: _handleSearch,
                ),
              ),
            );
          }
        },
      );
    });

    final isLoading = searchState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final errorMessage = searchState.maybeWhen(
      error: (message) => message,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.search),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.router.pushNamed('/dashboard'),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logoutState.maybeWhen(
              loading: () => null,
              orElse: () => _handleLogout,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show error message if search failed
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
                                  style: Theme.of(context).textTheme.bodySmall
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
                      //   enabled: !isLoading,
                      //   suffixIcon: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       IconButton(
                      //         icon: const Icon(Icons.clear),
                      //         onPressed: isLoading
                      //             ? null
                      //             : () {
                      //                 _organizationController.clear();
                      //               },
                      //       ),
                      //       IconButton(
                      //         icon: const Icon(Icons.search),
                      //         onPressed: isLoading ? null : () {},
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 24),
                      CustomTextField(
                        label: AppStrings.scanOrEnterPurchaseOrder,
                        controller: _orderNumberController,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: isLoading ? null : _scanBarcode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: AppStrings.search,
                        onPressed: isLoading ? null : _handleSearch,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

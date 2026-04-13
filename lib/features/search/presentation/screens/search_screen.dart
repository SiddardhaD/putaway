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
  final _organizationController = TextEditingController();
  final _orderNumberController = TextEditingController();
  final String _selectedOrderType = 'OP'; // Fixed to OP (Purchase Order)

  @override
  void dispose() {
    _organizationController.dispose();
    _orderNumberController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await showBarcodeScanner(
      context,
      title: 'Scan Order Number',
    );
    if (result != null) {
      setState(() {
        _orderNumberController.text = result;
      });
    }
  }

  Future<void> _handleSearch() async {
    if (_formKey.currentState?.validate() ?? false) {
      _logger.i('SearchScreen: Form validated, calling search');

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

    // Listen to state changes
    ref.listen<SearchState>(searchViewModelProvider, (previous, next) {
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

          // Show success message
          if (mounted) {
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
              _logger.i('SearchScreen: Saved branch value to storage: $branchValue');
            }

            // Navigate to records list screen with the line details
            _logger.i('SearchScreen: Navigating to records list');
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                context.router.pushNamed('/records');
              }
            });
          }
        },
        empty: () {
          _logger.i('SearchScreen: No orders found');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.noOrdersFound),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ),
          );
        },
        error: (message) {
          _logger.e('SearchScreen: Search error - $message');

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
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.home_outlined), onPressed: () {}),
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

                      CustomTextField(
                        label: AppStrings.selectOrganization,
                        hint: 'Enter organization code (optional)',
                        controller: _organizationController,
                        enabled: !isLoading,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _organizationController.clear();
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: isLoading ? null : () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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

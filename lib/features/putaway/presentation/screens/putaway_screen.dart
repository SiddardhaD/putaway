import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../providers/putaway_providers.dart';
import '../states/putaway_state.dart';

@RoutePage()
class PutawayScreen extends ConsumerStatefulWidget {
  const PutawayScreen({super.key});

  @override
  ConsumerState<PutawayScreen> createState() => _PutawayScreenState();
}

class _PutawayScreenState extends ConsumerState<PutawayScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();

  @override
  void dispose() {
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
      final orderNumber = _orderNumberController.text.trim();

      _logger.i(
        'PutawayScreen: Form validated, searching for order: $orderNumber',
      );

      // Call the view model to fetch putaway tasks
      await ref
          .read(putawayViewModelProvider.notifier)
          .getPutawayTasks(
            orderNumber: orderNumber,
            orderType: 'OP',
            branchPlant: 'AWH',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to putaway state changes - this is properly scoped
    ref.listen<PutawayState>(putawayViewModelProvider, (previous, next) {
      // Only process if state actually changed
      if (previous == next) return;

      _logger.i('PutawayScreen: State changed from $previous to $next');

      next.when(
        initial: () {},
        loading: () {},
        success: (tasks) {
          _logger.i('PutawayScreen: Success - ${tasks.length} tasks found');

          // Store results in provider
          ref.read(putawayResultsProvider.notifier).state = tasks;

          // Store search parameters for refresh later
          ref.read(putawaySearchParamsProvider.notifier).state = {
            'orderNumber': _orderNumberController.text.trim(),
            'orderType': 'OP',
            'branchPlant': 'AWH',
          };

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found ${tasks.length} tasks'),
                backgroundColor: const Color(0xFF00BCD4), // Professional green
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate to tasks list with order number
            context.router.push(
              PutawayTasksListRoute(
                orderNumber: _orderNumberController.text.trim(),
              ),
            );
          }
        },
        empty: () {
          _logger.i('PutawayScreen: No tasks found');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No tasks found for this order'),
                backgroundColor: AppColors.warning,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        error: (message) {
          _logger.e('PutawayScreen: Error - $message');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _handleSearch,
                ),
              ),
            );
          }
        },
      );
    });

    final putawayState = ref.watch(putawayViewModelProvider);
    final isLoading = putawayState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PutAway Search'),
        backgroundColor: const Color(0xFF008BA3), // Professional dark emerald
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.router.pushNamed('/dashboard'),
            tooltip: 'Home',
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
                      Text(
                        'Search PutAway Tasks',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(
                            0xFF008BA3,
                          ), // Professional dark green
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter order number to view putaway tasks',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Order Number *',
                        controller: _orderNumberController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: _scanBarcode,
                        ),
                        hint: 'Scan or enter order number',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA), // Very light mint
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00BCD4).withAlpha(51),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF00BCD4), // Professional green
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Default: Order Type = OP, Branch = AWH',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(
                                        0xFF008BA3,
                                      ), // Darker green for text
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: isLoading ? 'Searching...' : AppStrings.search,
                          onPressed: isLoading ? null : _handleSearch,
                          isLoading: isLoading,
                          backgroundColor: const Color(
                            0xFF00BCD4,
                          ), // Professional green
                        ),
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

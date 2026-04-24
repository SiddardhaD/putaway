import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../../../putaway/presentation/states/putaway_state.dart';
import '../providers/picking_providers.dart';

@RoutePage()
class PickingScreen extends ConsumerStatefulWidget {
  const PickingScreen({super.key});

  @override
  ConsumerState<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends ConsumerState<PickingScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  bool _hasNavigated = false;

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
    if (result != null && result.isNotEmpty) {
      _logger.i('PickingScreen: Barcode scanned - $result');

      setState(() {
        _orderNumberController.text = result;
      });

      _logger.i('PickingScreen: Auto-triggering search after barcode scan');
      await _handleSearch();
    }
  }

  Future<void> _handleSearch() async {
    if (_formKey.currentState?.validate() ?? false) {
      final orderNumber = _orderNumberController.text.trim();

      _logger.i(
        'PickingScreen: Form validated, searching for order: $orderNumber',
      );

      _hasNavigated = false;

      await ref.read(pickingViewModelProvider.notifier).getPickingTasks(
            orderNumber: orderNumber,
            orderType: AppConstants.orderTypePickingTasks,
            branchPlant: 'AWH',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PutawayState>(pickingViewModelProvider, (previous, next) async {
      if (previous == next) return;

      _logger.i('PickingScreen: State changed from $previous to $next');

      next.when(
        initial: () {},
        loading: () {},
        success: (tasks) async {
          _logger.i('PickingScreen: Success - ${tasks.length} tasks found');

          ref.read(pickingResultsProvider.notifier).state = tasks;

          ref.read(pickingSearchParamsProvider.notifier).state = {
            'orderNumber': _orderNumberController.text.trim(),
            'orderType': AppConstants.orderTypePickingTasks,
            'branchPlant': 'AWH',
          };

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found ${tasks.length} tasks'),
                backgroundColor: const Color(0xFF00BCD4),
                duration: const Duration(seconds: 2),
              ),
            );

            if (!_hasNavigated) {
              _hasNavigated = true;
              _logger.i('PickingScreen: Navigating to tasks list');

              await context.router.push(
                PickingTasksListRoute(
                  orderNumber: _orderNumberController.text.trim(),
                ),
              );

              _logger.i(
                'PickingScreen: User returned from tasks list, clearing order number field',
              );
              if (mounted) {
                _orderNumberController.clear();
              }
            } else {
              _logger.d(
                'PickingScreen: Navigation already performed, skipping (refresh)',
              );
            }
          }
        },
        empty: () {
          _logger.i('PickingScreen: No tasks found');
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
          _logger.e('PickingScreen: Error - $message');
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

    final pickingState = ref.watch(pickingViewModelProvider);
    final isLoading = pickingState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Picking Search'),
        backgroundColor: const Color(0xFF008BA3),
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
                        'Search Picking Tasks',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF008BA3),
                              letterSpacing: 0.3,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter order number to view picking tasks',
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
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00BCD4).withAlpha(51),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF00BCD4),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Default: Order Type = SO, Branch = AWH',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF008BA3),
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
                          backgroundColor: const Color(0xFF00BCD4),
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

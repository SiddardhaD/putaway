import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../providers/routing_providers.dart';
import '../states/routing_order_state.dart';

@RoutePage()
class RoutingSearchScreen extends ConsumerStatefulWidget {
  const RoutingSearchScreen({super.key});

  @override
  ConsumerState<RoutingSearchScreen> createState() => _RoutingSearchScreenState();
}

class _RoutingSearchScreenState extends ConsumerState<RoutingSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderController = TextEditingController();
  final _containerController = TextEditingController();
  bool _hasNavigated = false;

  @override
  void dispose() {
    _orderController.dispose();
    _containerController.dispose();
    super.dispose();
  }

  Future<void> _scanOrder() async {
    final result = await showBarcodeScanner(context, title: 'Scan Order ID');
    if (result != null && result.isNotEmpty) {
      setState(() => _orderController.text = result);
      await _handleSearch();
    }
  }

  Future<void> _scanContainer() async {
    final result = await showBarcodeScanner(context, title: 'Scan Container ID');
    if (result != null && result.isNotEmpty) {
      setState(() => _containerController.text = result);
    }
  }

  Future<void> _handleSearch() async {
    if (_formKey.currentState?.validate() ?? false) {
      final orderNumber = _orderController.text.trim();
      final containerRaw = _containerController.text.trim();
      final containerId = containerRaw.isEmpty ? '' : containerRaw;

      _hasNavigated = false;

      await ref.read(routingOrderViewModelProvider.notifier).getRoutingLineDetails(
            orderNumber: orderNumber,
            orderType: AppConstants.orderTypeRouting,
            branchPlant: 'AWH',
            containerId: containerId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RoutingOrderState>(routingOrderViewModelProvider, (previous, next) async {
      if (previous == next) return;

      next.when(
        initial: () {},
        loading: () {},
        success: (lines) async {
          ref.read(routingLinesProvider.notifier).state = lines;
          ref.read(routingSearchParamsProvider.notifier).state = {
            'orderNumber': _orderController.text.trim(),
            'orderType': AppConstants.orderTypeRouting,
            'branchPlant': 'AWH',
            'containerId': _containerController.text.trim().isEmpty
                ? ''
                : _containerController.text.trim(),
          };

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found ${lines.length} routing line(s)'),
                backgroundColor: AppColors.secondary,
              ),
            );

            if (!_hasNavigated) {
              _hasNavigated = true;
              await context.router.push(
                RoutingLinesListRoute(orderNumber: _orderController.text.trim()),
              );
              if (mounted) {
                _orderController.clear();
                _containerController.clear();
              }
            }
          }
        },
        empty: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No routing lines found for this order'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        },
        error: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
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

    final state = ref.watch(routingOrderViewModelProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receipt Routing'),
        backgroundColor: AppColors.primaryDark,
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
        padding: const EdgeInsets.all(16),
        child: Container(
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
                  'Routing order search',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter order ID (required). Container ID is optional — leave blank to send empty.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Order ID *',
                  controller: _orderController,
                  hint: 'Scan or enter order number',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanOrder,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Container ID (optional)',
                  controller: _containerController,
                  hint: 'Optional — scan or enter, or leave empty',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.putawayLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.secondaryDark, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Default: Order type ${AppConstants.orderTypeRouting}, Branch AWH',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.putawayDark,
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
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

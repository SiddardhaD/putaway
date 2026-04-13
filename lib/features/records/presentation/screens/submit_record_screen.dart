import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';

@RoutePage()
class SubmitRecordScreen extends ConsumerWidget {
  final String id;

  const SubmitRecordScreen({
    super.key,
    @PathParam('id') required this.id,
  });

  void _handleSubmit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmSubmit),
        content: const Text('This action cannot be undone. Do you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.recordSubmitted)),
              );
              context.router.pushNamed('/search');
            },
            child: const Text(AppStrings.submit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.submitRecord),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {},
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Record Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildSummaryItem(
                      context,
                      Icons.shopping_bag_outlined,
                      AppStrings.orderNumber,
                      'UK555955',
                    ),
                    const Divider(height: 32),
                    _buildSummaryItem(
                      context,
                      Icons.inventory_2_outlined,
                      AppStrings.item,
                      'W360_LS',
                    ),
                    const Divider(height: 32),
                    _buildSummaryItem(
                      context,
                      Icons.warehouse_outlined,
                      AppStrings.subinventory,
                      'SUB-001',
                    ),
                    const Divider(height: 32),
                    _buildSummaryItem(
                      context,
                      Icons.location_on_outlined,
                      AppStrings.locator,
                      'LOC-A-01',
                    ),
                    const Divider(height: 32),
                    _buildSummaryItem(
                      context,
                      Icons.numbers_outlined,
                      AppStrings.quantity,
                      '5',
                    ),
                    const Divider(height: 32),
                    _buildSummaryItem(
                      context,
                      Icons.qr_code_outlined,
                      AppStrings.lotNumber,
                      'LOT-12345',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please review all information before submitting.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: AppStrings.submitRecord,
                onPressed: () => _handleSubmit(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

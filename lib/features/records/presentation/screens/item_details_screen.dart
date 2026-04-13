import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../search/domain/entities/purchase_line_detail_entity.dart';
import '../providers/saved_records_provider.dart';

@RoutePage()
class ItemDetailsScreen extends ConsumerStatefulWidget {
  final PurchaseLineDetailEntity lineItem;

  const ItemDetailsScreen({super.key, required this.lineItem});

  @override
  ConsumerState<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends ConsumerState<ItemDetailsScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _lotSerialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Check if there's already saved data for this record
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedRecord = ref.read(savedRecordsProvider.notifier)
          .getSavedRecord(widget.lineItem.lineNumber.toString());
      
      if (savedRecord != null) {
        // Populate fields with saved data
        _quantityController.text = savedRecord.quantity;
        _lotSerialController.text = savedRecord.lotSerial;
      } else {
        // Use original quantity as default
        _quantityController.text = widget.lineItem.quantityOpen.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _lotSerialController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      _logger.i('ItemDetailsScreen: Form validated, saving locally');

      // Save data locally
      final savedRecord = SavedRecordData(
        lineNumber: widget.lineItem.lineNumber.toString(),
        quantity: _quantityController.text.trim(),
        lotSerial: _lotSerialController.text.trim(),
        savedAt: DateTime.now(),
      );

      ref.read(savedRecordsProvider.notifier).saveRecord(savedRecord);

      _logger.i('ItemDetailsScreen: Record saved locally for line ${savedRecord.lineNumber}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record saved successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate back to list after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.router.maybePop();
          }
        });
      }
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(128),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border.withAlpha(128)),
          ),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: AppColors.primary,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      'Order',
                      widget.lineItem.orderNumber.toString(),
                    ),
                    // _buildInfoChip('Type', widget.lineItem.orderType),
                    _buildInfoChip(
                      'Line',
                      widget.lineItem.lineNumber.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Line Item Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReadOnlyField('Item Number', widget.lineItem.itemNumber),
                const SizedBox(height: 12),
                _buildReadOnlyField(
                  'Description',
                  widget.lineItem.itemDescription,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadOnlyField(
                        'Available Qty',
                        widget.lineItem.quantityOpen.toStringAsFixed(0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReadOnlyField(
                        'Amount',
                        _formatAmount(widget.lineItem.amountOpen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadOnlyField(
                        'Order Co',
                        widget.lineItem.orderCo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReadOnlyField(
                        'Currency',
                        widget.lineItem.curCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildReadOnlyField('Order Date', widget.lineItem.orderDate),
                const SizedBox(height: 32),
                Text(
                  'Enter Receiving Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Quantity *',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        hint: 'Enter quantity',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantity is required';
                          }
                          final qty = int.tryParse(value);
                          if (qty == null || qty <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          // Validate against available quantity
                          final availableQty = widget.lineItem.quantityOpen.toInt();
                          if (qty > availableQty) {
                            return 'Quantity cannot exceed $availableQty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'LOT/Serial Number *',
                        controller: _lotSerialController,
                        hint: 'Enter LOT or serial number',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'LOT/Serial number is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

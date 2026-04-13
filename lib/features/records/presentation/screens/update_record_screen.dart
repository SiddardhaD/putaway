import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

@RoutePage()
class UpdateRecordScreen extends ConsumerStatefulWidget {
  final String id;

  const UpdateRecordScreen({super.key, @PathParam('id') required this.id});

  @override
  ConsumerState<UpdateRecordScreen> createState() => _UpdateRecordScreenState();
}

class _UpdateRecordScreenState extends ConsumerState<UpdateRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subinventoryController = TextEditingController(text: 'SUB-001');
  final _locatorController = TextEditingController(text: 'LOC-A-01');
  final _quantityController = TextEditingController(text: '5');
  final _lotNumberController = TextEditingController(text: 'LOT-12345');

  @override
  void dispose() {
    _subinventoryController.dispose();
    _locatorController.dispose();
    _quantityController.dispose();
    _lotNumberController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.recordUpdated)));
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.updateRecord),
        actions: [
          IconButton(icon: const Icon(Icons.home_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(AppStrings.orderNumber, 'UK555955'),
                        const SizedBox(height: 8),
                        _buildInfoRow(AppStrings.item, 'W360_LS'),
                        const SizedBox(height: 8),
                        _buildInfoRow(AppStrings.receipt, '1466'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: AppStrings.subinventory,
                    controller: _subinventoryController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.locator,
                    controller: _locatorController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.quantity,
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.lotNumber,
                    controller: _lotNumberController,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: AppStrings.cancel,
                          onPressed: () => context.router.maybePop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.save,
                          onPressed: _handleUpdate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

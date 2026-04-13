import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';

@RoutePage()
class AddRecordScreen extends ConsumerStatefulWidget {
  const AddRecordScreen({super.key});

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subinventoryController = TextEditingController();
  final _locatorController = TextEditingController();
  final _quantityController = TextEditingController(text: '2');

  @override
  void dispose() {
    _subinventoryController.dispose();
    _locatorController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode(
    TextEditingController controller,
    String title,
  ) async {
    final result = await showBarcodeScanner(context, title: title);
    if (result != null) {
      setState(() {
        controller.text = result;
      });
    }
  }

  void _handleAddRecord() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.recordAdded)));
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.purchaseOrder,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            'UK555955',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: AppStrings.scanOrEnterSubinventory,
                    controller: _subinventoryController,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _scanBarcode(
                            _subinventoryController,
                            'Scan Subinventory',
                          ),
                        ),
                      ],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.scanOrSearchLocator,
                    controller: _locatorController,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.textHint,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.textHint,
                          ),
                          onPressed: () =>
                              _scanBarcode(_locatorController, 'Scan Locator'),
                        ),
                      ],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: AppStrings.enterQuantity,
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            _quantityController.clear();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _scanBarcode(
                            _quantityController,
                            'Scan Quantity',
                          ),
                        ),
                      ],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity < 1) {
                        return AppStrings.invalidQuantity;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: AppStrings.addLotSerial,
                    onPressed: _handleAddRecord,
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

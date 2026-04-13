import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:putaway/core/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../../../search/presentation/providers/search_results_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/saved_records_provider.dart';
import '../providers/record_providers.dart';
import '../states/submit_state.dart';

@RoutePage()
class RecordsListScreen extends ConsumerStatefulWidget {
  const RecordsListScreen({super.key});

  @override
  ConsumerState<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends ConsumerState<RecordsListScreen> {
  final Logger _logger = Logger();
  final _searchController = TextEditingController();
  final _itemCodeController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _itemCodeController.dispose();
    super.dispose();
  }

  Future<void> _scanItemCode() async {
    final result = await showBarcodeScanner(context, title: 'Scan Item Code');
    if (result != null) {
      setState(() {
        _itemCodeController.text = result;
        _searchController.text = result;
        _searchQuery = result;
      });
    }
  }

  Future<void> _handleSubmitAll() async {
    final savedRecords = ref.read(savedRecordsProvider);
    
    if (savedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No records saved. Please save at least one record before submitting.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _logger.i('RecordsListScreen: Submitting ${savedRecords.length} saved records');

    // Get Branch/Plant value from local storage
    final localStorage = ref.read(localStorageProvider);
    final branch = localStorage.getString(AppConstants.keyBranchPlant) ?? '';
    
    if (branch.isEmpty) {
      _logger.e('RecordsListScreen: Branch value not found in storage!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Branch information not found. Please search again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Get order number from first search result
    final searchResults = ref.read(searchResultsProvider);
    if (searchResults == null || searchResults.isEmpty) {
      _logger.e('RecordsListScreen: No search results found!');
      return;
    }

    final orderNumber = searchResults.first.orderNumber.toString();
    
    // Convert saved records to GridDataItems
    final gridData = ref.read(savedRecordsProvider.notifier).getAllGridDataItems();

    // Call submit API
    await ref.read(submitViewModelProvider.notifier).submitReceive(
      orderNumber: orderNumber,
      branch: branch,
      gridData: gridData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final savedRecords = ref.watch(savedRecordsProvider);
    final submitState = ref.watch(submitViewModelProvider);

    // Listen to submit state changes
    ref.listen<SubmitState>(submitViewModelProvider, (previous, next) {
      if (previous == next) return;

      next.when(
        initial: () {},
        loading: () {},
        success: (message) {
          _logger.i('RecordsListScreen: Submit successful!');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );

            // Clear saved records
            ref.read(savedRecordsProvider.notifier).clearAll();

            // Navigate to dashboard after success
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.router.pushNamed('/dashboard');
              }
            });
          }
        },
        error: (message) {
          _logger.e('RecordsListScreen: Submit error - $message');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _handleSubmitAll,
                ),
              ),
            );
          }
        },
      );
    });

    final isSubmitting = submitState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    if (searchResults == null || searchResults.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Purchase Order Details')),
        body: const Center(
          child: EmptyWidget(
            message:
                'No purchase order line items found.\nPlease search for an order first.',
          ),
        ),
      );
    }

    final filteredResults = _searchQuery.isEmpty
        ? searchResults
        : searchResults.where((item) {
            final query = _searchQuery.toLowerCase();
            return item.itemNumber.toLowerCase().contains(query) ||
                item.itemDescription.toLowerCase().contains(query) ||
                item.lineNumber.toString().contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Purchase Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.router.pushNamed('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Item Code Scanner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white,
            child: CustomTextField(
              controller: _itemCodeController,
              label: 'Scan or Enter Item Code',
              hint: 'Scan or enter item code',
              prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanItemCode,
              ),
              onChanged: (value) {
                setState(() {
                  _searchController.text = value;
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Colors.white,
            child: CustomTextField(
              controller: _searchController,
              label: 'Search',
              hint: 'Search by line, item, or description',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _itemCodeController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  if (_itemCodeController.text != value) {
                    _itemCodeController.text = value;
                  }
                });
              },
            ),
          ),

          // Order header - Purchase Order UK55955
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchase Order',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${searchResults.first.orderNumber}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Results count and info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredResults.length} of ${searchResults.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${searchResults.first.orderType} • ${_formatDate(searchResults.first.orderDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Line #',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Item #',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Space for arrow icon
              ],
            ),
          ),

          // Grid Items
          Expanded(
            child: filteredResults.isEmpty
                ? const Center(
                    child: EmptyWidget(
                      message:
                          'No matching items found.\nTry a different search term.',
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filteredResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) {
                        final item = filteredResults[index];
                        final lineNumber = item.lineNumber.toString();
                        final isSaved = savedRecords.containsKey(lineNumber);
                        final savedRecord = savedRecords[lineNumber];
                        
                        // Use saved quantity if available, otherwise use original
                        final displayQuantity = isSaved && savedRecord != null
                            ? savedRecord.quantity
                            : item.quantityOpen.toStringAsFixed(0);

                        return InkWell(
                          onTap: isSubmitting ? null : () {
                            context.router.push(
                              ItemDetailsRoute(lineItem: item),
                            );
                          },
                          child: Container(
                            color: isSaved 
                                ? Colors.grey.shade100 
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                // Line Number
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Text(
                                        '${item.lineNumber}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSaved 
                                                  ? Colors.grey.shade700 
                                                  : null,
                                            ),
                                      ),
                                      if (isSaved) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: AppColors.success,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Item Number
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    item.itemNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isSaved 
                                              ? Colors.grey.shade700 
                                              : null,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Quantity
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    displayQuantity,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSaved 
                                              ? Colors.grey.shade700 
                                              : AppColors.success,
                                        ),
                                  ),
                                ),
                                // Arrow Icon
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: isSaved 
                                      ? Colors.grey.shade400 
                                      : AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // Submit All button
          if (savedRecords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${savedRecords.length} record(s) saved',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Submit All',
                    onPressed: isSubmitting ? null : _handleSubmitAll,
                    isLoading: isSubmitting,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

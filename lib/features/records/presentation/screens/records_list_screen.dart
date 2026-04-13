import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:putaway/core/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../../../search/presentation/providers/search_results_provider.dart';

@RoutePage()
class RecordsListScreen extends ConsumerStatefulWidget {
  const RecordsListScreen({super.key});

  @override
  ConsumerState<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends ConsumerState<RecordsListScreen> {
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

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

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
                        return InkWell(
                          onTap: () {
                            context.router.push(
                              ItemDetailsRoute(lineItem: item),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                // Line Number
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item.lineNumber}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                // Item Number
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    item.itemNumber,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Quantity
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item.quantityOpen.toStringAsFixed(0)}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                  ),
                                ),
                                // Arrow Icon
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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

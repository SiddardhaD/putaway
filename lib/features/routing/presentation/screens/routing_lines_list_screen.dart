import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/routing_line_detail_entity.dart';
import '../../../putaway/presentation/states/confirm_putaway_state.dart';
import '../providers/routing_providers.dart';
import '../states/routing_order_state.dart';

@RoutePage()
class RoutingLinesListScreen extends ConsumerStatefulWidget {
  final String? orderNumber;

  const RoutingLinesListScreen({super.key, this.orderNumber});

  @override
  ConsumerState<RoutingLinesListScreen> createState() =>
      _RoutingLinesListScreenState();
}

class _RoutingLinesListScreenState extends ConsumerState<RoutingLinesListScreen> {
  final Logger _logger = Logger();
  RoutingLineDetailEntity? _currentConfirmingLine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final params = ref.read(routingSearchParamsProvider);
      final hasOrder = (params?['orderNumber'] ?? '').trim().isNotEmpty;
      final routeOrder = widget.orderNumber?.trim() ?? '';
      if (!hasOrder && routeOrder.isNotEmpty) {
        ref.read(routingSearchParamsProvider.notifier).state = {
          'orderNumber': routeOrder,
          'orderType': AppConstants.orderTypeRouting,
          'branchPlant': 'AWH',
          'containerId': '',
        };
      }
    });
  }

  Future<void> _showConfirmationDialog(RoutingLineDetailEntity line) async {
    _currentConfirmingLine = line;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfirmRoutingDialog(line: line),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(routingLinesProvider);

    ref.listen<RoutingOrderState>(routingOrderViewModelProvider, (previous, next) {
      if (previous == next) return;
      next.when(
        initial: () {},
        loading: () {},
        success: (refreshed) {
          _logger.i('RoutingLinesListScreen: refreshed ${refreshed.length} lines');
          ref.read(routingLinesProvider.notifier).state = refreshed;
        },
        empty: () {
          _logger.i('RoutingLinesListScreen: no lines remaining');
          ref.read(routingLinesProvider.notifier).state = [];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No more routing lines for this order.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        error: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to refresh: $message'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    });

    ref.listen<ConfirmPutawayState>(confirmRoutingViewModelProvider, (previous, next) {
      if (previous == next) return;
      next.when(
        initial: () {},
        loading: () {},
        success: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.secondary,
                duration: const Duration(seconds: 1),
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
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    if (_currentConfirmingLine != null) {
                      _showConfirmationDialog(_currentConfirmingLine!);
                    }
                  },
                ),
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Routing lines (${lines.length})'),
            if (widget.orderNumber != null && widget.orderNumber!.isNotEmpty)
              Text(
                'Order: ${widget.orderNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
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
      body: lines.isEmpty
          ? Center(
              child: Text(
                'No routing lines',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final line = lines[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showConfirmationDialog(line),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.putawayLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.alt_route,
                              color: AppColors.secondaryDark,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Line ${line.lineNumber} • ${line.operationCode}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${line.quantity} ${line.unitMeasure}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.secondaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (line.itemNumber.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Item: ${line.itemNumber}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                                if (line.lotNumber.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lot: ${line.lotNumber}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                                // if (line.manufacturingDate.trim().isNotEmpty) ...[
                                //   const SizedBox(height: 4),
                                //   Text(
                                //     'Mfg: ${line.manufacturingDate}',
                                //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                //           color: AppColors.textSecondary,
                                //         ),
                                //   ),
                                // ],
                                // if (line.lotExpirationDate.trim().isNotEmpty) ...[
                                //   Text(
                                //     'Expiry: ${line.lotExpirationDate}',
                                //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                //           color: AppColors.secondaryDark,
                                //           fontWeight: FontWeight.w600,
                                //         ),
                                //   ),
                                // ],
                                if (line.containerId.trim().isNotEmpty) ...[
                                  Text(
                                    'Container: ${line.containerId}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ConfirmRoutingDialog extends ConsumerStatefulWidget {
  final RoutingLineDetailEntity line;

  const _ConfirmRoutingDialog({required this.line});

  @override
  ConsumerState<_ConfirmRoutingDialog> createState() => _ConfirmRoutingDialogState();
}

class _ConfirmRoutingDialogState extends ConsumerState<_ConfirmRoutingDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(confirmRoutingViewModelProvider.notifier).reset();
    });
  }

  void _handleConfirm() {
    final p = ref.read(routingSearchParamsProvider);
    if (p == null) return;
    ref.read(confirmRoutingViewModelProvider.notifier).confirmRouting(
          orderNumber: p['orderNumber'] ?? '',
          orderType: p['orderType'] ?? AppConstants.orderTypeRouting,
          branchPlant: p['branchPlant'] ?? 'AWH',
          lineNumber: widget.line.lineNumber.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final confirmState = ref.watch(confirmRoutingViewModelProvider);
    final isLoading = confirmState.maybeWhen(loading: () => true, orElse: () => false);

    ref.listen<ConfirmPutawayState>(confirmRoutingViewModelProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (_) {
          if (mounted) Navigator.of(context).pop();
        },
        error: (_) {
          if (mounted) Navigator.of(context).pop();
        },
      );
    });

    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF00BCD4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Please Confirm Routing Line #${widget.line.lineNumber}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.line.operationCode} • Review details before confirming',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(230),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00BCD4).withAlpha(77),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.alt_route,
                                    color: Color(0xFF008BA3),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Line Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF008BA3),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildRoutingDetailRow(
                                'Line Number',
                                widget.line.lineNumber.toString(),
                                Icons.tag,
                              ),
                              const SizedBox(height: 8),
                              _buildRoutingDetailRow(
                                'Operation',
                                widget.line.operationCode,
                                Icons.settings_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _routingDetailsTwoColumnGrid(widget.line),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00BCD4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Processing...',
                        style: TextStyle(
                          color: Color(0xFF008BA3),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF00BCD4),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF008BA3),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact field for two-column rows in the confirmation dialog.
  Widget _buildRoutingDetailHalf(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF008BA3)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF008BA3),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _routingDetailsTwoColumnGrid(RoutingLineDetailEntity line) {
    final quantity = '${line.quantity} ${line.unitMeasure}';
    final supplier =
        line.supplierName.isEmpty ? 'N/A' : line.supplierName;
    final item =
        line.itemNumber.trim().isEmpty ? 'N/A' : line.itemNumber.trim();
    final lot =
        line.lotNumber.trim().isEmpty ? 'N/A' : line.lotNumber.trim();
    final mfg = line.manufacturingDate.trim().isEmpty
        ? 'N/A'
        : line.manufacturingDate.trim();
    final exp = line.lotExpirationDate.trim().isEmpty
        ? 'N/A'
        : line.lotExpirationDate.trim();
    final container = line.containerId.trim().isEmpty
        ? 'N/A'
        : line.containerId.trim();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildRoutingDetailHalf(
                'Quantity',
                quantity,
                Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoutingDetailHalf(
                'Supplier',
                supplier,
                Icons.business_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildRoutingDetailHalf(
                'Item',
                item,
                Icons.inventory_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoutingDetailHalf(
                'LOT/Serial',
                lot,
                Icons.qr_code_2_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildRoutingDetailHalf(
                'Manufacturing date',
                mfg,
                Icons.factory_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoutingDetailHalf(
                'Lot expiry',
                exp,
                Icons.event_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _buildRoutingDetailHalf(
            'Container',
            container,
            Icons.local_shipping_outlined,
          ),
        ),
      ],
    );
  }

  /// Matches putaway task confirmation dialog row styling.
  Widget _buildRoutingDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF008BA3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF008BA3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

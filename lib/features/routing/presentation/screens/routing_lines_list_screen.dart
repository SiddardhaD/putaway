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
                                if (line.lotNumber.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lot: ${line.lotNumber}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
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
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Confirm routing line ${widget.line.lineNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.line.operationCode} • Review before confirming',
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
                            color: AppColors.putawayLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withAlpha(77),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow(
                                'Operation',
                                widget.line.operationCode,
                                Icons.settings_outlined,
                              ),
                              const SizedBox(height: 8),
                              _detailRow(
                                'Quantity',
                                '${widget.line.quantity} ${widget.line.unitMeasure}',
                                Icons.inventory_2_outlined,
                              ),
                              const SizedBox(height: 8),
                              _detailRow(
                                'Supplier',
                                widget.line.supplierName.isEmpty ? '—' : widget.line.supplierName,
                                Icons.business_outlined,
                              ),
                              const SizedBox(height: 8),
                              _detailRow(
                                'Lot',
                                widget.line.lotNumber.trim().isEmpty ? '—' : widget.line.lotNumber,
                                Icons.qr_code_2_outlined,
                              ),
                              const SizedBox(height: 8),
                              _detailRow(
                                'Container',
                                widget.line.containerId.trim().isEmpty ? '—' : widget.line.containerId,
                                Icons.local_shipping_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          color: AppColors.putawayDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.putawayDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.putawayDark),
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
                  color: AppColors.putawayDark,
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

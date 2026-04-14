import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';
import '../providers/putaway_providers.dart';
import '../states/confirm_putaway_state.dart';
import '../states/putaway_state.dart';

@RoutePage()
class PutawayTasksListScreen extends ConsumerStatefulWidget {
  final String? orderNumber;

  const PutawayTasksListScreen({super.key, this.orderNumber});

  @override
  ConsumerState<PutawayTasksListScreen> createState() =>
      _PutawayTasksListScreenState();
}

class _PutawayTasksListScreenState
    extends ConsumerState<PutawayTasksListScreen> {
  final Logger _logger = Logger();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  PutawayTaskDetailEntity? _currentConfirmingTask;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog(PutawayTaskDetailEntity task) async {
    _currentConfirmingTask = task;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfirmPutawayDialog(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(putawayResultsProvider);

    // Listen to putaway state changes (for refresh results)
    ref.listen<PutawayState>(putawayViewModelProvider, (previous, next) {
      if (previous == next) return;

      next.when(
        initial: () {},
        loading: () {},
        success: (refreshedTasks) {
          _logger.i('PutawayTasksListScreen: List refreshed - ${refreshedTasks.length} tasks');
          // Update the results provider with refreshed data
          ref.read(putawayResultsProvider.notifier).state = refreshedTasks;
        },
        empty: () {
          _logger.i('PutawayTasksListScreen: No tasks remaining after refresh');
          
          // Clear the results provider
          ref.read(putawayResultsProvider.notifier).state = [];
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All tasks completed! No pending tasks.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        error: (message) {
          _logger.e('PutawayTasksListScreen: Refresh error - $message');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to refresh: $message'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
    });

    // Listen to confirm putaway state changes
    ref.listen<ConfirmPutawayState>(confirmPutawayViewModelProvider, (
      previous,
      next,
    ) {
      if (previous == next) return;

      next.when(
        initial: () {},
        loading: () {},
        success: (message) {
          _logger.i('PutawayTasksListScreen: Confirm successful!');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: const Color(0xFF00BCD4),
                duration: const Duration(seconds: 1),
              ),
            );

            // Refresh the tasks list after a short delay
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                final searchParams = ref.read(putawaySearchParamsProvider);
                if (searchParams != null) {
                  final orderNumber = searchParams['orderNumber'] ?? '';
                  final orderType = searchParams['orderType'] ?? 'OP';
                  final branchPlant = searchParams['branchPlant'] ?? 'AWH';

                  ref
                      .read(putawayViewModelProvider.notifier)
                      .getPutawayTasks(
                        orderNumber: orderNumber,
                        orderType: orderType,
                        branchPlant: branchPlant,
                      );
                }
              }
            });
          }
        },
        error: (message) {
          _logger.e('PutawayTasksListScreen: Confirm error - $message');

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
                    if (_currentConfirmingTask != null) {
                      _showConfirmationDialog(_currentConfirmingTask!);
                    }
                  },
                ),
              ),
            );
          }
        },
      );
    });

    final filteredTasks = tasks.where((task) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return task.fromLocation.toLowerCase().contains(query) ||
          task.toLocation.toLowerCase().contains(query) ||
          task.task.toString().contains(query) ||
          task.statusDescription.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PutAway Tasks (${filteredTasks.length})'),
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
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF00BCD4),
                ), // Professional green
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: const Color(0xFF00BCD4).withAlpha(51),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF00BCD4),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Grid Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA), // Very light mint background
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00BCD4).withAlpha(51),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'From',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006064), // Deep forest green
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'To',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006064), // Deep forest green
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006064), // Deep forest green
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Space for icon
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F7FA), // Light cyan
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tasks.isEmpty 
                                  ? Icons.task_alt // All tasks completed
                                  : Icons.search_off, // Search filter empty
                              size: 64,
                              color: const Color(0xFF00BCD4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            tasks.isEmpty 
                                ? 'All Tasks Completed!' 
                                : 'No tasks found',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF008BA3),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tasks.isEmpty
                                ? 'All PutAway tasks have been successfully confirmed.'
                                : 'No tasks match your search criteria.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return InkWell(
                        onTap: () => _showConfirmationDialog(task),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  task.fromLocation,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  task.toLocation,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${task.quantity} ${task.um}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF008BA3),
                                      ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: const Color(0xFF00BCD4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Confirmation Dialog Widget
class _ConfirmPutawayDialog extends ConsumerStatefulWidget {
  final PutawayTaskDetailEntity task;

  const _ConfirmPutawayDialog({required this.task});

  @override
  ConsumerState<_ConfirmPutawayDialog> createState() =>
      _ConfirmPutawayDialogState();
}

class _ConfirmPutawayDialogState extends ConsumerState<_ConfirmPutawayDialog> {
  @override
  void initState() {
    super.initState();
    // Reset state when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(confirmPutawayViewModelProvider.notifier).reset();
    });
  }

  void _handleConfirm() {
    // Call the API directly
    ref
        .read(confirmPutawayViewModelProvider.notifier)
        .confirmPutaway(
          task: widget.task.task.toString(),
          trip: widget.task.trip.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final confirmState = ref.watch(confirmPutawayViewModelProvider);
    final isLoading = confirmState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // Listen to state changes to close dialog
    ref.listen<ConfirmPutawayState>(confirmPutawayViewModelProvider, (
      previous,
      next,
    ) {
      next.when(
        initial: () {},
        loading: () {},
        success: (_) {
          // Close dialog on success
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        error: (_) {
          // Close dialog on error
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
    });

    return WillPopScope(
      onWillPop: () async => !isLoading, // Prevent closing while loading
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF00BCD4),
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
                    const Text(
                      'Confirm PutAway',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please review the details before confirming',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(230),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task & Trip (Highlighted section)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA), // Light mint
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00BCD4).withAlpha(77),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.task_outlined,
                                color: Color(0xFF008BA3),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Task Details',
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
                          _buildDetailRow(
                            'Task Number',
                            widget.task.task.toString(),
                            Icons.tag,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Trip Number',
                            widget.task.trip.toString(),
                            Icons.route,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Other details
                    _buildDetailRow(
                      'From Location',
                      widget.task.fromLocation,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'To Location',
                      widget.task.toLocation,
                      Icons.location_on,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Quantity',
                      '${widget.task.quantity} ${widget.task.um}',
                      Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'LOT/Serial',
                      widget.task.fromLot.trim().isEmpty
                          ? 'N/A'
                          : widget.task.fromLot,
                      Icons.qr_code_2_outlined,
                    ),
                  ],
                ),
              ),

              // Actions
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00BCD4),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
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

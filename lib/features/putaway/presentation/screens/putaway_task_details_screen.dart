import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';
import '../providers/putaway_providers.dart';
import '../states/confirm_putaway_state.dart';

@RoutePage()
class PutawayTaskDetailsScreen extends ConsumerStatefulWidget {
  final PutawayTaskDetailEntity taskDetail;

  const PutawayTaskDetailsScreen({super.key, required this.taskDetail});

  @override
  ConsumerState<PutawayTaskDetailsScreen> createState() =>
      _PutawayTaskDetailsScreenState();
}

class _PutawayTaskDetailsScreenState
    extends ConsumerState<PutawayTaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskController;
  late final TextEditingController _tripController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: '${widget.taskDetail.task}');
    _tripController = TextEditingController(text: '${widget.taskDetail.trip}');
  }

  @override
  void dispose() {
    _taskController.dispose();
    _tripController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final task = _taskController.text.trim();
      final trip = _tripController.text.trim();

      // Show professional confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                    color: Color(0xFF10B981), // Professional emerald
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
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
                      // Task & Trip (Editable values)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4), // Light mint
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withAlpha(77),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF047857),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated Values',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF047857),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildConfirmDetailRow(
                              'Task Number',
                              task,
                              Icons.tag,
                            ),
                            const SizedBox(height: 8),
                            _buildConfirmDetailRow(
                              'Trip Number',
                              trip,
                              Icons.route,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Other details
                      _buildConfirmDetailRow(
                        'From Location',
                        widget.taskDetail.fromLocation,
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildConfirmDetailRow(
                        'To Location',
                        widget.taskDetail.toLocation,
                        Icons.location_on,
                      ),
                      const SizedBox(height: 8),
                      _buildConfirmDetailRow(
                        'Quantity',
                        '${widget.taskDetail.quantity} ${widget.taskDetail.um}',
                        Icons.inventory_2_outlined,
                      ),
                    ],
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF10B981),
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
                              color: Color(0xFF047857),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
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

      if (confirm == true && mounted) {
        await ref
            .read(confirmPutawayViewModelProvider.notifier)
            .confirmPutaway(task: task, trip: trip);
      }
    }
  }

  Widget _buildConfirmDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF047857)),
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
                  color: Color(0xFF047857),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to confirm state changes
    ref.listen<ConfirmPutawayState>(confirmPutawayViewModelProvider, (
      previous,
      next,
    ) {
      if (previous == next) return;

      next.when(
        initial: () {},
        loading: () {},
        success: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: const Color(0xFF10B981), // Professional green
                duration: const Duration(seconds: 1),
              ),
            );

            // Refresh the tasks list with original search parameters
            final searchParams = ref.read(putawaySearchParamsProvider);
            if (searchParams != null) {
              final orderNumber = searchParams['orderNumber'] ?? '';
              final orderType = searchParams['orderType'] ?? 'OP';
              final branchPlant = searchParams['branchPlant'] ?? 'AWH';

              // Refresh tasks
              ref
                  .read(putawayViewModelProvider.notifier)
                  .getPutawayTasks(
                    orderNumber: orderNumber,
                    orderType: orderType,
                    branchPlant: branchPlant,
                  );
            }

            // Navigate back after refresh
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.router.popUntilRouteWithName('PutawayTasksListRoute');
              }
            });
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
                  onPressed: _handleConfirm,
                ),
              ),
            );
          }
        },
      );
    });

    final confirmState = ref.watch(confirmPutawayViewModelProvider);
    final isLoading = confirmState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PutAway Task Details'),
        backgroundColor: const Color(0xFF047857), // Professional darker green
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
                // Task Information Section
                _buildSection(
                  'Task Information',
                  [
                    _buildReadOnlyRow(
                      'Task Number',
                      '${widget.taskDetail.task}',
                    ),
                    _buildReadOnlyRow(
                      'Trip Number',
                      '${widget.taskDetail.trip}',
                    ),
                    _buildReadOnlyRow(
                      'Status',
                      widget.taskDetail.statusDescription,
                    ),
                  ],
                  const Color(0xFFF0FDF4), // Very light green background
                ),

                const SizedBox(height: 16),

                // Location Details Section
                _buildSection(
                  'Location Details',
                  [
                    _buildReadOnlyRow(
                      'From Location',
                      widget.taskDetail.fromLocation,
                    ),
                    _buildReadOnlyRow(
                      'To Location',
                      widget.taskDetail.toLocation,
                    ),
                  ],
                  const Color(0xFFF0FDF4), // Very light green background
                ),

                const SizedBox(height: 16),

                // Quantity Information Section
                _buildSection(
                  'Quantity Information',
                  [
                    _buildReadOnlyRow(
                      'Quantity',
                      '${widget.taskDetail.quantity}',
                    ),
                    _buildReadOnlyRow('Unit of Measure', widget.taskDetail.um),
                    _buildReadOnlyRow(
                      'From LOT',
                      widget.taskDetail.fromLot.trim().isEmpty
                          ? 'N/A'
                          : widget.taskDetail.fromLot,
                    ),
                  ],
                  const Color(0xFFF0FDF4), // Very light green background
                ),

                const SizedBox(height: 16),

                // Editable Fields Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(
                        0xFF10B981,
                      ).withAlpha(77), // Subtle green border
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF047857),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Update Task Details',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF047857),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verify and update the task and trip numbers below',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Task Number *',
                        controller: _taskController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Task number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Trip Number *',
                        controller: _tripController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Trip number is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF10B981,
                      ), // Professional green
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF10B981,
                      ).withAlpha(128),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Confirm PutAway',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF065F46), // Darker green for headers
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280), // Professional gray
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1F2937), // Dark gray for values
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

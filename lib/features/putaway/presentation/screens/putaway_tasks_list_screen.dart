import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:putaway/core/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/putaway_task_detail_entity.dart';
import '../providers/putaway_providers.dart';

@RoutePage()
class PutawayTasksListScreen extends ConsumerStatefulWidget {
  const PutawayTasksListScreen({super.key});

  @override
  ConsumerState<PutawayTasksListScreen> createState() =>
      _PutawayTasksListScreenState();
}

class _PutawayTasksListScreenState
    extends ConsumerState<PutawayTasksListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTaskDetails(PutawayTaskDetailEntity task) {
    context.router.push(PutawayTaskDetailsRoute(taskDetail: task));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(putawayResultsProvider);

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
        title: Text('PutAway Tasks (${filteredTasks.length})'),
        backgroundColor: const Color(0xFF047857), // Professional dark emerald
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
                prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)), // Professional green
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
                  borderSide: BorderSide(color: const Color(0xFF10B981).withAlpha(51)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
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
              color: const Color(0xFFF0FDF4), // Very light mint background
              border: Border(
                bottom: BorderSide(color: const Color(0xFF10B981).withAlpha(51)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'S.No',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF065F46), // Deep forest green
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Trip',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF065F46), // Deep forest green
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF065F46), // Deep forest green
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                const SizedBox(width: 40), // Space for arrow icon
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final serialNumber = index + 1;

                      return InkWell(
                        onTap: () => _openTaskDetails(task),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
                                flex: 1,
                                child: Text(
                                  '$serialNumber',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${task.trip}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${task.quantity} ${task.um}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade600,
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

// Task Details Modal Widget
class _TaskDetailsModal extends StatelessWidget {
  final PutawayTaskDetailEntity task;

  const _TaskDetailsModal({required this.task});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  border: Border(
                    bottom: BorderSide(color: Colors.green.withAlpha(51)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Task Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.green.shade800,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailSection(
                        title: 'Task Information',
                        items: [
                          _DetailItem(
                            label: 'Task Number',
                            value: '${task.task}',
                          ),
                          _DetailItem(label: 'Trip', value: '${task.trip}'),
                          _DetailItem(
                            label: 'Status',
                            value: task.statusDescription,
                            valueColor: _getStatusColor(task.statusDescription),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _DetailSection(
                        title: 'Location Details',
                        items: [
                          _DetailItem(
                            label: 'From Location',
                            value: task.fromLocation,
                          ),
                          _DetailItem(
                            label: 'To Location',
                            value: task.toLocation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _DetailSection(
                        title: 'Quantity Information',
                        items: [
                          _DetailItem(
                            label: 'Quantity',
                            value: '${task.quantity}',
                            valueColor: Colors.green.shade700,
                            valueWeight: FontWeight.bold,
                          ),
                          _DetailItem(label: 'Unit of Measure', value: task.um),
                          _DetailItem(
                            label: 'From LOT',
                            value: task.fromLot.trim().isEmpty
                                ? 'N/A'
                                : task.fromLot,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('printed')) {
      return Colors.blue.shade700;
    } else if (status.toLowerCase().contains('complete')) {
      return Colors.green.shade700;
    } else if (status.toLowerCase().contains('pending')) {
      return Colors.orange.shade700;
    }
    return Colors.grey.shade700;
  }
}

// Detail Section Widget
class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;

  const _DetailSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: items
                .map(
                  (item) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.label,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.value,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight:
                                          item.valueWeight ?? FontWeight.w500,
                                      color:
                                          item.valueColor ??
                                          AppColors.textPrimary,
                                    ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item != items.last)
                        Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// Detail Item Data Class
class _DetailItem {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueWeight;

  _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight,
  });
}

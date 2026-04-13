import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:putaway/features/records/presentation/screens/add_record_screen.dart';
import 'package:putaway/features/records/presentation/screens/submit_record_screen.dart';
import 'package:putaway/features/records/presentation/screens/update_record_screen.dart';
import 'package:putaway/features/search/domain/entities/purchase_line_detail_entity.dart';
import 'package:putaway/features/putaway/domain/entities/putaway_task_detail_entity.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/records/presentation/screens/records_list_screen.dart';
import '../../features/records/presentation/screens/item_details_screen.dart';
import '../../features/putaway/presentation/screens/putaway_screen.dart';
import '../../features/putaway/presentation/screens/putaway_tasks_list_screen.dart';
import '../../features/putaway/presentation/screens/putaway_task_details_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true, path: '/login'),
    AutoRoute(page: DashboardRoute.page, path: '/dashboard'),
    AutoRoute(page: SearchRoute.page, path: '/search'),
    AutoRoute(page: RecordsListRoute.page, path: '/records'),
    AutoRoute(page: ItemDetailsRoute.page, path: '/item-details'),
    AutoRoute(page: PutawayRoute.page, path: '/putaway'),
    AutoRoute(page: PutawayTasksListRoute.page, path: '/putaway-tasks'),
    AutoRoute(page: PutawayTaskDetailsRoute.page, path: '/putaway-task-details'),
  ];
}

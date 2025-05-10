import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/admin_provider.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_dashboard_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_notice_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_user_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_board_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_popup_manage_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return MaterialApp(
      title: 'PeopleJob',
      debugShowCheckedModeBanner: false,
      initialRoute: isAdmin ? '/admin/dashboard' : '/unauthorized',
      routes: {
        '/admin/dashboard':
            (_) =>
                isAdmin ? const AdminDashboardPage() : const UnauthorizedPage(),
        '/admin/notice':
            (_) =>
                isAdmin
                    ? const AdminNoticeManagePage()
                    : const UnauthorizedPage(),
        '/admin/user':
            (_) =>
                isAdmin
                    ? const AdminUserManagePage()
                    : const UnauthorizedPage(),
        '/admin/board':
            (_) =>
                isAdmin
                    ? const AdminBoardManagePage()
                    : const UnauthorizedPage(),
        '/admin/popup':
            (_) =>
                isAdmin
                    ? const AdminPopupManagePage()
                    : const UnauthorizedPage(),
        '/unauthorized': (_) => const UnauthorizedPage(),
      },
    );
  }
}

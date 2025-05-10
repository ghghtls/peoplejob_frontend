import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 페이지 import
import 'package:peoplejob_frontend/ui/pages/home/home_page.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/company_mypage_page.dart';

import 'package:peoplejob_frontend/ui/pages/admin/admin_dashboard_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_notice_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_user_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_board_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_popup_manage_page.dart';

import 'package:peoplejob_frontend/ui/pages/error/unauthorized_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/login_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/register_page.dart';
import 'package:peoplejob_frontend/ui/pages/mypage/my_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// 관리자 여부 Provider
final isAdminProvider = StateProvider<bool>((ref) => false); // 기본 false

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return MaterialApp(
      title: 'PeopleJob',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // 기본 홈페이지
        '/': (_) => const HomePage(),

        // 유저 로그인/회원가입
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),

        // 일반 유저 마이페이지
        '/mypage/user': (_) => const MyPage(),

        // 기업회원 마이페이지
        '/mypage/company': (_) => const CompanyMyPage(),

        // 관리자 페이지들 (로그인 후 진입 판단은 로그인 로직에서 처리)
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

        // 권한 없음
        '/unauthorized': (_) => const UnauthorizedPage(),
      },
    );
  }
}

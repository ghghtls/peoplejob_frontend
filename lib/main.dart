import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/ui/pages/board/board_detail_page.dart';

import 'package:peoplejob_frontend/ui/pages/board/board_edit_page.dart';
import 'package:peoplejob_frontend/ui/pages/board/board_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/company_mypage_page.dart';

import 'package:peoplejob_frontend/ui/pages/home/home_page.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/login_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/register_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/find_id_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/find_password_page.dart';

import 'package:peoplejob_frontend/ui/pages/job/job_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/job/job_detail_page.dart';
import 'package:peoplejob_frontend/ui/pages/mypage/my_page.dart';
import 'package:peoplejob_frontend/ui/pages/resources/resource_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/resume/resume_edit_page.dart';
import 'package:peoplejob_frontend/ui/pages/resume/resume_list_page.dart';

import 'package:peoplejob_frontend/ui/pages/notice/notice_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/notice/notice_detail_page.dart';

import 'package:peoplejob_frontend/ui/pages/board/board_write_page.dart';

import 'package:peoplejob_frontend/ui/pages/payment/payment_page.dart';
import 'package:peoplejob_frontend/ui/pages/search/search_page.dart';
import 'package:peoplejob_frontend/ui/pages/search/talent_search_page.dart';
import 'package:peoplejob_frontend/ui/pages/tools/word_count_page.dart';
import 'package:peoplejob_frontend/ui/pages/user/user_home_page.dart';

import 'package:peoplejob_frontend/ui/pages/admin/admin_dashboard_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_notice_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_user_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_board_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_popup_manage_page.dart';

import 'package:peoplejob_frontend/ui/pages/error/unauthorized_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// 관리자 여부 Provider
final isAdminProvider = StateProvider<bool>((ref) => false);

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
        '/': (context) => const HomePage(),

        // 로그인/회원가입
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/find-id': (context) => const FindIdPage(),
        '/find-password': (context) => const FindPasswordPage(),

        // 마이페이지
        '/mypage/user': (context) => const MyPage(),
        '/mypage/company': (context) => const CompanyMyPage(),

        // 공고
        '/job': (context) => const JobListPage(),
        '/job/detail': (context) => const JobDetailPage(),

        // 이력서
        '/resume': (context) => const ResumeListPage(),
        '/resume/register': (context) => const ResumeEditPage(),

        // 공지사항
        '/notice': (context) => const NoticeListPage(),

        // 게시판
        '/board/write': (context) => const BoardWritePage(),
        '/board/detail':
            (context) =>
                const BoardDetailPage(title: '', content: '', date: ''),
        '/board': (context) => const BoardListPage(),

        // 문의사항
        '/inquiry/list': (context) => const InquiryListPage(),

        // 검색
        '/search': (context) => const SearchPage(),
        '/search/talentSearchPage': (context) => const TalentSearchPage(),

        // 결제
        '/payment': (context) => const PaymentPage(),

        // 자료실
        '/resources/list': (context) => const ResourceListPage(),

        // 도구
        '/tools/wordcount': (context) => const WordCountPage(),

        // 관리자
        '/admin/dashboard':
            (context) =>
                isAdmin ? const AdminDashboardPage() : const UnauthorizedPage(),
        '/admin/notice':
            (context) =>
                isAdmin
                    ? const AdminNoticeManagePage()
                    : const UnauthorizedPage(),
        '/admin/user':
            (context) =>
                isAdmin
                    ? const AdminUserManagePage()
                    : const UnauthorizedPage(),
        '/admin/board':
            (context) =>
                isAdmin
                    ? const AdminBoardManagePage()
                    : const UnauthorizedPage(),
        '/admin/popup':
            (context) =>
                isAdmin
                    ? const AdminPopupManagePage()
                    : const UnauthorizedPage(),

        // 권한 없음
        '/unauthorized': (context) => const UnauthorizedPage(),
      },

      /// ✨ onGenerateRoute → 동적 라우팅 처리
      onGenerateRoute: (settings) {
        if (settings.name == '/board/edit') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder:
                (_) => BoardEditPage(
                  initialTitle: args['title'] as String,
                  initialContent: args['content'] as quill.Document,
                  onSave:
                      args['onSave'] as void Function(String, quill.Document),
                ),
          );
        }

        if (settings.name == '/notice/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => NoticeDetailPage(
                  title: args['title'] as String,
                  content: args['content'] as String,
                  date: args['date'] as String,
                ),
          );
        }
        if (settings.name == '/resume/register') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder:
                (_) => ResumeEditPage(
                  initialTitle: args['title'] as String?,
                  initialDescription: args['description'] as String?,
                ),
          );
        }
        return null;
      },
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:peoplejob_frontend/config/theme/app_theme.dart';
import 'package:peoplejob_frontend/data/model/inquiry.dart';
import 'package:peoplejob_frontend/ui/pages/board/board_detail_page.dart';
import 'package:peoplejob_frontend/ui/pages/board/board_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/board/board_write_page.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/company_mypage_page.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/job_management_page.dart';

import 'package:peoplejob_frontend/ui/pages/home/home_page.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_detail_page.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_form_page.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/login_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/register_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/find_id_page.dart';
import 'package:peoplejob_frontend/ui/pages/login/find_password_page.dart';

import 'package:peoplejob_frontend/ui/pages/job/job_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/job/job_detail_page.dart';
import 'package:peoplejob_frontend/ui/pages/job/job_post_register_page.dart';
import 'package:peoplejob_frontend/ui/pages/mypage/my_page.dart';
import 'package:peoplejob_frontend/ui/pages/mypage/scrap/scrap_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/mypage/apply/apply_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/company/job_applications_page.dart';
import 'package:peoplejob_frontend/ui/pages/company/company_applicants_page.dart';
import 'package:peoplejob_frontend/ui/pages/payment/payment_product_selection_page.dart';
import 'package:peoplejob_frontend/ui/pages/payment/payment_result_page.dart';
import 'package:peoplejob_frontend/ui/pages/payment/payment_schedule_page.dart';
import 'package:peoplejob_frontend/ui/pages/payment/payment_history_page.dart';
import 'package:peoplejob_frontend/ui/pages/payment/payment_target_selection_page.dart';
import 'package:peoplejob_frontend/ui/pages/resources/job_news_page.dart';
import 'package:peoplejob_frontend/ui/pages/resources/resource_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/resume/resume_detail_page.dart';
import 'package:peoplejob_frontend/ui/pages/resume/resume_edit_page.dart';
import 'package:peoplejob_frontend/ui/pages/resume/resume_list_page.dart';

import 'package:peoplejob_frontend/ui/pages/notice/notice_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/notice/notice_detail_page.dart';

import 'package:peoplejob_frontend/ui/pages/payment/payment_page.dart';
import 'package:peoplejob_frontend/ui/pages/search/search_page.dart';
import 'package:peoplejob_frontend/ui/pages/search/talent_search_page.dart';
import 'package:peoplejob_frontend/ui/pages/tools/word_count_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as fr;
import 'package:peoplejob_frontend/ui/pages/admin/admin_dashboard_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_notice_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_user_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_board_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_popup_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_home_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_inquiry_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_faq_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_file_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_applicant_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/admin_job_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/service_product_list_page.dart';
import 'package:peoplejob_frontend/ui/pages/mypage/profile/profile_edit_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/board/board_edit_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/board/board_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/board/board_register_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/popup/popup_edit_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/popup/popup_manage_page.dart';
import 'package:peoplejob_frontend/ui/pages/admin/popup/popup_register_page.dart';
import 'package:peoplejob_frontend/data/model/job.dart';

import 'package:peoplejob_frontend/ui/pages/error/unauthorized_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    // Web은 수동 초기화 필요
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
      ),
    );
  } else {
    // Android/iOS는 설정파일로 자동 처리, 절대 중복 초기화 금지
    await Firebase.initializeApp();
  }

  runApp(
    const fr.ProviderScope(
      child: MyApp(),
    ),
  );
}

// 관리자 여부 Provider (Riverpod)
final isAdminProvider = fr.StateProvider<bool>((ref) => false);

class MyApp extends fr.ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, fr.WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return MaterialApp(
      title: 'PeopleJob',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),

        // 로그인/회원가입
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/find-id': (context) => const FindIdPage(),
        '/find-password': (context) => const FindPasswordPage(),

        // 마이페이지
        '/mypage': (context) => const MyPage(),
        '/companymypage': (context) => const CompanyMyPage(),
        '/job-manage': (context) => const JobManagementPage(),
        '/company-applicants': (context) => const CompanyApplicantsPage(),

        // 채용공고
        '/job-list': (context) => const JobListPage(),
        '/job-register': (context) => const JobPostRegisterPage(),
        '/job': (context) => const JobListPage(),

        // 이력서
        '/resume': (context) => const ResumeListPage(),
        '/resume-list': (context) => const ResumeListPage(),
        '/resume-register': (context) => const ResumeEditPage(),

        // 지원 관리
        '/apply-list': (context) => const ApplyListPage(),

        // 게시판
        '/board': (context) => const BoardListPage(),
        '/board-write': (context) => const BoardWritePage(),

        // 공지사항
        '/notice': (context) => const NoticeListPage(),
        '/notice-list': (context) => const NoticeListPage(),

        // 문의사항
        '/inquiry/list': (context) => const InquiryListPage(),
        '/inquiry/write': (context) => const InquiryFormPage(),

        // 검색
        '/search': (context) => const SearchPage(),
        '/talent-search': (context) => const TalentSearchPage(),
        '/search/talentSearchPage': (context) => const TalentSearchPage(),

        // 결제
        '/payment': (context) => const PaymentPage(),
        '/payment/target': (context) => const PaymentTargetSelectionPage(),
        '/payment/product': (context) => const PaymentProductSelectionPage(),
        '/payment/schedule': (context) => const PaymentSchedulePage(),
        '/payment/result': (context) => const PaymentResultPage(),
        '/payment/history': (context) => const PaymentHistoryPage(),

        // 자료실
        '/resources/list': (context) => const ResourceListPage(),

        // 도구
        '/tools/wordcount': (context) => const WordCountPage(),

        // 내정보 수정
        '/profile-edit': (context) => const ProfileEditPage(),

        // 스크랩
        '/scrap': (context) => const ScrapListPage(),

        // 취업뉴스
        '/resources/news': (context) => const JobNewsPage(),

        // 관리자
        '/admin': (context) => const AdminHomePage(),
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
        '/admin/inquiry':
            (context) =>
                isAdmin
                    ? const AdminInquiryManagePage()
                    : const UnauthorizedPage(),
        '/admin/faq':
            (context) =>
                isAdmin ? const AdminFaqManagePage() : const UnauthorizedPage(),
        '/admin/files':
            (context) =>
                isAdmin
                    ? const AdminFileManagePage()
                    : const UnauthorizedPage(),
        '/admin/jobs':
            (context) =>
                isAdmin
                    ? const AdminJobManagePage()
                    : const UnauthorizedPage(),
        '/admin/applicants':
            (context) =>
                isAdmin
                    ? const AdminApplicantListPage()
                    : const UnauthorizedPage(),
        '/admin/products':
            (context) =>
                isAdmin
                    ? const ServiceProductListPage()
                    : const UnauthorizedPage(),
        '/admin/board/manage':
            (context) =>
                isAdmin ? const BoardManagePage() : const UnauthorizedPage(),
        '/admin/board/register':
            (context) =>
                isAdmin ? const BoardRegisterPage() : const UnauthorizedPage(),
        '/admin/popup/manage':
            (context) =>
                isAdmin ? const PopupManagePage() : const UnauthorizedPage(),
        '/admin/popup/register':
            (context) =>
                isAdmin ? const PopupRegisterPage() : const UnauthorizedPage(),

        // 권한 없음
        '/unauthorized': (context) => const UnauthorizedPage(),
      },

      /// ✨ onGenerateRoute → 동적 라우팅 처리
      onGenerateRoute: (settings) {
        // 채용공고 동적 라우트
        switch (settings.name) {
          case '/job-detail':
            final jobId = settings.arguments;
            final resolvedJobId = jobId is int ? jobId : int.tryParse(jobId?.toString() ?? '') ?? 0;
            return MaterialPageRoute(
              builder: (context) => JobDetailPage(jobId: resolvedJobId),
            );
          case '/job-edit':
            final jobId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => JobPostRegisterPage(jobId: jobId),
            );

          // 이력서 동적 라우트
          case '/resume-detail':
            final resumeId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => ResumeDetailPage(resumeId: resumeId),
            );
          case '/resume-edit':
            final resumeId = settings.arguments as int?;
            return MaterialPageRoute(
              builder: (context) => ResumeEditPage(resumeId: resumeId),
            );

          // 지원 관리 동적 라우트
          case '/job-applications':
            final jobOpeningNo = settings.arguments as int;
            return MaterialPageRoute(
              builder:
                  (context) => JobApplicationsPage(jobOpeningNo: jobOpeningNo),
            );

          // 게시판 동적 라우트
          case '/board-detail':
            final boardNo = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => BoardDetailPage(boardNo: boardNo),
            );
          case '/board-edit':
            final boardNo = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => BoardWritePage(boardNo: boardNo),
            );

          // 공지사항 동적 라우트
          case '/notice-detail':
            final noticeId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => NoticeDetailPage(noticeId: noticeId),
            );

          // 문의사항 동적 라우트
          case '/inquiry-detail':
            final inquiryNo = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => InquiryDetailPage(inquiryNo: inquiryNo),
            );
          case '/inquiry-edit':
            final inquiry = settings.arguments as Inquiry;
            return MaterialPageRoute(
              builder: (context) => InquiryFormPage(inquiry: inquiry),
            );

          // 채용공고 등록/수정 폼 (Job 객체 전달 방식)
          case '/job-form':
            final job = settings.arguments as Job?;
            return MaterialPageRoute(
              builder: (context) => JobPostRegisterPage(jobId: job?.jobNo),
            );
        }

        // 어드민 게시판 수정 동적 라우트: /admin/board/edit/123
        final boardEditMatch = RegExp(r'^/admin/board/edit/(\d+)$').firstMatch(settings.name ?? '');
        if (boardEditMatch != null) {
          final boardId = int.parse(boardEditMatch.group(1)!);
          return MaterialPageRoute(
            builder: (_) => BoardEditPage(boardId: boardId),
          );
        }

        // 어드민 팝업 수정 동적 라우트: /admin/popup/edit/123
        final popupEditMatch = RegExp(r'^/admin/popup/edit/(\d+)$').firstMatch(settings.name ?? '');
        if (popupEditMatch != null) {
          final popupId = int.parse(popupEditMatch.group(1)!);
          return MaterialPageRoute(
            builder: (_) => PopupEditPage(popupId: popupId),
          );
        }

        // 기존 공지사항 라우트 (호환성 유지)
        if (settings.name == '/notice/detail') {
          final args = settings.arguments as Map<String, dynamic>;

          if (args.containsKey('noticeId')) {
            return MaterialPageRoute(
              builder:
                  (context) =>
                      NoticeDetailPage(noticeId: args['noticeId'] as int),
            );
          } else {
            // 임시로 ID 0 사용 (실제에선 적절한 ID 조회 필요)
            return MaterialPageRoute(
              builder: (context) => NoticeDetailPage(noticeId: 0),
            );
          }
        }

        // 기존 이력서 라우트 (호환성 유지)
        if (settings.name == '/resume/register') {
          if (settings.arguments != null) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => ResumeEditPage(resumeId: args['resumeId'] as int?),
            );
          } else {
            return MaterialPageRoute(builder: (_) => const ResumeEditPage());
          }
        }

        if (settings.name == '/resume/detail') {
          if (settings.arguments != null) {
            final args = settings.arguments as Map<String, dynamic>;
            if (args.containsKey('resumeId')) {
              final resumeId = args['resumeId'] as int;
              return MaterialPageRoute(
                builder: (context) => ResumeDetailPage(resumeId: resumeId),
              );
            }
          }
          return MaterialPageRoute(
            builder: (_) => const ResumeDetailPage(resumeId: 0),
          );
        }

        // 기존 job/detail 라우트 (호환성 유지)
        if (settings.name == '/job/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          if (args.containsKey('jobId')) {
            final jobId = args['jobId'] as int;
            return MaterialPageRoute(
              builder: (context) => JobDetailPage(jobId: jobId),
            );
          } else {
            return MaterialPageRoute(builder: (_) => JobDetailPage(jobId: 0));
          }
        }

        // 기존 게시판 라우트 (호환성 유지)
        if (settings.name == '/board/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BoardDetailPage(boardNo: args['boardNo'] as int),
          );
        }

        return null;
      },
    );
  }
}

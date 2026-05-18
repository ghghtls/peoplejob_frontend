import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../main.dart' show isAdminProvider;
import 'widgets/admin_section_title.dart';
import '../../widgets/app_bar.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _bg = Color(0xFFF2F2F7);

  @override
  void initState() {
    super.initState();
    _ensureAdminProvider();
  }

  Future<void> _ensureAdminProvider() async {
    const storage = FlutterSecureStorage();
    final userType = await storage.read(key: 'userType');
    final role = await storage.read(key: 'role');
    final isAdmin = userType == 'admin' || role == 'ADMIN' || role == 'ROLE_ADMIN';
    if (isAdmin && mounted) {
      ref.read(isAdminProvider.notifier).state = true;
    } else if (mounted) {
      Navigator.pushReplacementNamed(context, '/unauthorized');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '관리자 페이지', showHomeButton: false),
      body: Column(
        children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  AdminSectionTitle(title: '대시보드'),
                  _menuItem(context, Icons.dashboard_rounded, '관리 요약 / 통계', '/admin/dashboard', _blue),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '회원 관리'),
                  _menuItem(context, Icons.people_rounded, '일반 · 기업회원 목록 및 관리', '/admin/user', const Color(0xFFAF52DE)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '채용공고 관리'),
                  _menuItem(context, Icons.work_rounded, '채용공고 목록 / 승인 · 중단 처리', '/admin/jobs', const Color(0xFF0B5FFF)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '지원자 관리'),
                  _menuItem(context, Icons.assignment_ind_rounded, '지원자 목록 조회', '/admin/applicants', const Color(0xFF5AC8FA)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '광고 · 결제 관리'),
                  _menuItem(context, Icons.payments_rounded, '광고 상품 목록 / 결제 내역', '/admin/products', const Color(0xFFFF9500)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '문의사항 관리'),
                  _menuItem(context, Icons.help_outline_rounded, '문의사항 목록 / 답변 처리', '/admin/inquiry', const Color(0xFF34C759)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '공지사항 관리'),
                  _menuItem(context, Icons.campaign_rounded, '공지사항 등록 / 수정 / 삭제', '/admin/notice', const Color(0xFFFF2D55)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: 'FAQ 관리'),
                  _menuItem(context, Icons.quiz_rounded, 'FAQ 등록 / 수정 / 삭제', '/admin/faq', const Color(0xFF64D2FF)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '게시판 관리'),
                  _menuItem(context, Icons.forum_rounded, '게시판 카테고리 / 게시물 관리', '/admin/board', const Color(0xFF5856D6)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '팝업 관리'),
                  _menuItem(context, Icons.web_asset_rounded, '팝업 등록 / 노출 설정', '/admin/popup', const Color(0xFFFF6B35)),
                  const SizedBox(height: 20),

                  AdminSectionTitle(title: '파일 관리'),
                  _menuItem(context, Icons.folder_rounded, '업로드 파일 목록 / 삭제', '/admin/files', const Color(0xFF8E8E93)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String route, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _label))),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE5E5EA)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

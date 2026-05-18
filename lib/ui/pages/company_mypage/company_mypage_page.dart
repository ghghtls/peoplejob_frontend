import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../pages/login/login_page.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_bar.dart';

class CompanyMyPage extends StatefulWidget {
  const CompanyMyPage({super.key});

  @override
  State<CompanyMyPage> createState() => _CompanyMyPageState();
}

class _CompanyMyPageState extends State<CompanyMyPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  Map<String, String?> _userInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await _authService.getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = Map<String, String?>.from(info);
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('로그아웃', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _storage.deleteAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _userInfo['name'] ?? '기업회원';
    final email = _userInfo['email'] ?? '';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '기업 마이페이지',
        onBack: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                        const SizedBox(height: 16),

                        // 프로필 카드
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B5FFF), Color(0xFF5A99FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _blue.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(initial,
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                              color: Colors.white, letterSpacing: -0.4)),
                                      const SizedBox(height: 4),
                                      Text(email,
                                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text('기업회원',
                                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 채용 관리 메뉴
                        _menuGroup('채용 관리', [
                          _MenuItem(icon: Icons.add_box_rounded, label: '채용공고 등록', route: '/job-form'),
                          _MenuItem(icon: Icons.work_outline_rounded, label: '채용공고 관리', route: '/job-manage'),
                          _MenuItem(icon: Icons.people_outline_rounded, label: '지원자 관리', route: '/company-applicants'),
                        ]),
                        const SizedBox(height: 12),

                        // 기업 서비스 메뉴
                        _menuGroup('기업 서비스', [
                          _MenuItem(icon: Icons.campaign_rounded, label: '광고 신청하기', route: '/payment'),
                          _MenuItem(icon: Icons.receipt_long_rounded, label: '광고 결제 내역', route: '/payment/history'),
                          _MenuItem(icon: Icons.search_rounded, label: '인재정보 검색', route: '/search/talentSearchPage'),
                        ]),
                        const SizedBox(height: 12),

                        // 정보/지원 메뉴
                        _menuGroup('정보 및 지원', [
                          _MenuItem(icon: Icons.question_answer_rounded, label: '문의사항', route: '/inquiry/list'),
                          _MenuItem(icon: Icons.folder_outlined, label: '자료실', route: '/resources/list'),
                          _MenuItem(icon: Icons.forum_rounded, label: '게시판', route: '/board'),
                        ]),
                        const SizedBox(height: 12),

                        // 계정 설정 메뉴
                        _menuGroup('계정 설정', [
                          _MenuItem(icon: Icons.manage_accounts_rounded, label: '내정보 수정', route: '/profile-edit'),
                          _MenuItem(icon: Icons.lock_outline_rounded, label: '비밀번호 변경', route: '/find-password'),
                        ]),
                        const SizedBox(height: 12),

                        // 로그아웃
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _logout,
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                          color: _red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.logout_rounded, size: 18, color: _red),
                                      ),
                                      const SizedBox(width: 14),
                                      const Expanded(
                                        child: Text('로그아웃',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _red, letterSpacing: -0.3)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _menuGroup(String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: _secondary, letterSpacing: -0.2)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, item.route),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(i == 0 ? 14 : 0),
                          topRight: Radius.circular(i == 0 ? 14 : 0),
                          bottomLeft: Radius.circular(isLast ? 14 : 0),
                          bottomRight: Radius.circular(isLast ? 14 : 0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: _blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.icon, size: 18, color: _blue),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(item.label,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                                        color: _label, letterSpacing: -0.3)),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE5E5EA)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 66, endIndent: 0, color: Color(0xFFF2F2F7)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem({required this.icon, required this.label, required this.route});
}

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/auth_service.dart';
import '../../../services/apply_service.dart';
import '../../../services/scrap_service.dart';
import '../../../services/resume_service.dart';
import '../../widgets/app_bar.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  static const Color _blue      = Color(0xFF0B5FFF);
  static const Color _label     = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg        = Color(0xFFF2F2F7);
  static const Color _red       = Color(0xFFE5342F);
  static const Color _separator = Color(0xFFD1D1D6);

  final AuthService _authService = AuthService();
  final ApplyService _applyService = ApplyService();
  final ScrapService _scrapService = ScrapService();
  final ResumeService _resumeService = ResumeService();
  final _storage = const FlutterSecureStorage();

  String _name     = '';
  String _email    = '';
  String _userid   = '';
  String _userType = '';
  int?   _userNo;

  int _applyCount  = 0;
  int _scrapCount  = 0;
  int _resumeCount = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await _authService.refreshUserInfoFromServer();
    final info = await _authService.getUserInfo();
    final type = info['userType'] ?? '';

    if (type == 'admin' && mounted) {
      Navigator.pushReplacementNamed(context, '/admin');
      return;
    }

    if (mounted) {
      setState(() {
        _name     = info['name'] ?? info['userid'] ?? '사용자';
        _email    = info['email'] ?? '';
        _userid   = info['userid'] ?? '';
        _userType = type;
        _userNo   = int.tryParse(info['userNo'] ?? '');
      });
    }

    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final results = await Future.wait([
        _applyService.getMyApplications(),
        _scrapService.getMyScrapList(),
        if (_userNo != null) _resumeService.getUserResumes(_userNo!) else Future.value(<Map<String, dynamic>>[]),
      ]);
      if (mounted) {
        setState(() {
          _applyCount  = results[0].length;
          _scrapCount  = results[1].length;
          _resumeCount = results[2].length;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
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
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('로그아웃', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _storage.deleteAll();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserInfo,
          color: _blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 헤더 AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        '마이페이지',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.7),
                      ),
                      const Spacer(),
                      const HomeButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 프로필 카드
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile-edit'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B5FFF), Color(0xFF4DA3FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(11, 95, 255, 0.32),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 아바타
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.4),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email.isNotEmpty ? _email : '@$_userid',
                                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), letterSpacing: -0.2),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _userType == 'company' ? '기업회원' : _userType == 'admin' ? '관리자' : '개인회원',
                                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white60, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 통계 그리드
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(child: _statCell('지원', _statsLoading ? '–' : '$_applyCount')),
                          VerticalDivider(width: 1, color: _separator),
                          Expanded(child: _statCell('스크랩', _statsLoading ? '–' : '$_scrapCount')),
                          VerticalDivider(width: 1, color: _separator),
                          Expanded(child: _statCell('이력서', _statsLoading ? '–' : '$_resumeCount')),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 프리미엄 배너
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/job-list'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC8A96A), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B5FFF), Color(0xFF4DA3FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'PREMIUM',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFC8A96A), letterSpacing: 1.5),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '프리미엄 채용공고 확인하기',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0B1220), letterSpacing: -0.2),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFC8A96A), size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 취업 활동
                _sectionTitle('취업 활동'),
                _menuGroup([
                  _MenuItem(icon: Icons.send_rounded,       color: _blue,                        label: '지원 내역',   route: '/apply-list'),
                  _MenuItem(icon: Icons.bookmark_rounded,   color: const Color(0xFFFF9500),      label: '스크랩 공고', route: '/scrap'),
                  _MenuItem(icon: Icons.description_rounded,color: const Color(0xFF34C759),      label: '이력서 관리', route: '/resume'),
                  _MenuItem(icon: Icons.add_circle_rounded, color: const Color(0xFF5856D6),      label: '이력서 등록', route: '/resume-register'),
                ]),
                const SizedBox(height: 12),

                // 정보 / 지원
                _sectionTitle('정보 / 지원'),
                _menuGroup([
                  _MenuItem(icon: Icons.question_answer_rounded, color: const Color(0xFF5856D6),  label: '문의사항', route: '/inquiry/list'),
                  _MenuItem(icon: Icons.folder_rounded,          color: const Color(0xFFFF2D55),  label: '자료실',   route: '/resources/list'),
                  _MenuItem(icon: Icons.article_rounded,         color: const Color(0xFF34C759),  label: '게시판',   route: '/board'),
                ]),
                const SizedBox(height: 12),

                // 설정
                _sectionTitle('설정'),
                _menuGroup([
                  _MenuItem(icon: Icons.manage_accounts_rounded, color: _blue,                   label: '내정보 수정',   route: '/profile-edit'),
                  _MenuItem(icon: Icons.notifications_rounded,   color: const Color(0xFF5AC8FA), label: '알림 설정',     route: '/settings/notifications'),
                  _MenuItem(icon: Icons.lock_outline_rounded,    color: _secondary,              label: '비밀번호 변경', route: '/find-password'),
                ]),
                const SizedBox(height: 20),

                // 로그아웃
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _red,
                        side: const BorderSide(color: _separator),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B5FFF),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.1),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _secondary, letterSpacing: -0.2),
      ),
    );
  }

  Widget _menuGroup(List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i    = entry.key;
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft:     i == 0 ? const Radius.circular(16) : Radius.zero,
                    topRight:    i == 0 ? const Radius.circular(16) : Radius.zero,
                    bottomLeft:  i == items.length - 1 ? const Radius.circular(16) : Radius.zero,
                    bottomRight: i == items.length - 1 ? const Radius.circular(16) : Radius.zero,
                  ),
                  onTap: () => Navigator.pushNamed(context, item.route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _label, letterSpacing: -0.3),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: _separator, size: 20),
                      ],
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 66, color: _separator),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final String label;
  final String route;
  const _MenuItem({required this.icon, required this.color, required this.label, required this.route});
}

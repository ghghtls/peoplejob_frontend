import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peoplejob_frontend/services/auth_service.dart';
import '../../widgets/app_bar.dart';
import 'widgets/job_random_section.dart';
import 'widgets/job_recommend_section.dart';
import 'widgets/notice_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String? _userName;
  String? _userType;

  static const Color _blue      = Color(0xFF0B5FFF); // sapphire-500
  static const Color _bg        = Color(0xFFF2F2F7); // ink-50
  static const Color _label     = Color(0xFF0B1220); // ink-900
  static const Color _secondary = Color(0xFF8E8E93); // ink-300
  static const Color _separator = Color(0xFFD1D1D6); // ink-75

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final token = await _authService.getToken();
      final userInfo = await _authService.getUserInfo();
      if (!mounted) return;
      setState(() {
        _isLoggedIn = token != null;
        _userName = userInfo['name'];
        _userType = userInfo['userType'];
      });
    } catch (_) {
      if (mounted) setState(() => _isLoggedIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildHeroSection()),
          SliverToBoxAdapter(child: _buildQuickMenu()),
          const SliverToBoxAdapter(child: JobRandomSection()),
          SliverToBoxAdapter(child: _buildPremiumBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(child: JobRecommendSection()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildSectionTitle('공지사항'),
            ),
          ),
          const SliverToBoxAdapter(child: NoticePreview()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: _separator,
      surfaceTintColor: Colors.white,
      expandedHeight: 56,
      collapsedHeight: 56,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: _blue, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const PeopleJobLogo(height: 28),
      centerTitle: false,
      actions: [
        if (_isLoggedIn)
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              _userType == 'admin'
                  ? '/admin'
                  : _userType == 'company'
                      ? '/companymypage'
                      : '/mypage',
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _userType == 'admin'
                        ? Icons.admin_panel_settings_rounded
                        : _userType == 'company'
                            ? Icons.business_rounded
                            : Icons.person_rounded,
                    size: 14,
                    color: _blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _userName ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: TextButton.styleFrom(
              foregroundColor: _blue,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              '로그인',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.3),
            ),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.search_rounded, color: _blue, size: 24),
          onPressed: () => Navigator.pushNamed(context, '/search'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Hero ─────────────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    final greeting = _isLoggedIn
        ? '$_userName님,\n오늘도 좋은 하루 되세요 ☀️'
        : '원하는 일자리를\n지금 찾아보세요';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B5FFF), Color(0xFF4DA3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(11, 95, 255, 0.38),
            blurRadius: 32,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Color.fromRGBO(11, 95, 255, 0.20),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 장식 원 1 (대형, 우상단)
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // 장식 원 2 (소형, 샴페인)
            Positioned(
              top: 20,
              right: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC8A96A).withValues(alpha: 0.22),
                ),
              ),
            ),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODAY 라벨
                  Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.65),
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontFamily: 'Ownglyph',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/job-list'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '채용공고 보기',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Premium Banner ────────────────────────────────────────────────────────

  Widget _buildPremiumBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/job-list'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6EC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC8A96A), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC8A96A).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B5FFF), Color(0xFF4DA3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC8A96A),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '프리미엄 채용공고를 확인해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1220),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC8A96A), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Quick Menu ───────────────────────────────────────────────────────────

  Widget _buildQuickMenu() {
    final items = [
      _MenuItem(icon: Icons.work_rounded, label: '채용공고', color: _blue, route: '/job-list'),
      _MenuItem(icon: Icons.description_rounded, label: '이력서', color: const Color(0xFF34C759), route: '/resume-list'),
      _MenuItem(icon: Icons.person_search_rounded, label: '인재검색', color: const Color(0xFFFF9500), route: '/talent-search'),
      _MenuItem(icon: Icons.campaign_rounded, label: '공지사항', color: const Color(0xFFAF52DE), route: '/notice'),
      _MenuItem(icon: Icons.forum_rounded, label: '게시판', color: const Color(0xFFFF2D55), route: '/board'),
      _MenuItem(icon: Icons.folder_open_rounded, label: '자료실', color: const Color(0xFF5AC8FA), route: '/resources/list'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('빠른 메뉴'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _buildMenuItem(items[i]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequired(String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그인 필요',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text('$feature 기능은 로그인 후 이용하실 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('로그인하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    const authRoutes = {'/resume-list', '/talent-search'};
    return GestureDetector(
      onTap: () {
        if (authRoutes.contains(item.route) && !_isLoggedIn) {
          _showLoginRequired(item.label);
          return;
        }
        Navigator.pushNamed(context, item.route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _label,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Ownglyph',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: _label,
      ),
    );
  }

  // ─── Drawer ───────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      width: screenWidth * 0.78,
      backgroundColor: _bg,
      child: SafeArea(
        child: Column(
          children: [
            // 프로필 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoggedIn) ...[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B5FFF), Color(0xFF5A99FF)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          (_userName?.isNotEmpty == true) ? _userName![0] : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_userName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: _label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _userType == 'admin' ? '관리자' : _userType == 'company' ? '기업회원' : '개인회원',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _blue,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'PeopleJob',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '로그인하고 더 많은 서비스를 이용하세요',
                      style: TextStyle(fontSize: 13, color: _secondary, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _blue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('로그인', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/register');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _blue,
                                side: const BorderSide(color: _blue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('회원가입', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 메뉴 목록
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                children: [
                  if (_isLoggedIn)
                    _drawerTile(
                      icon: Icons.person_outline_rounded,
                      label: '마이페이지',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          _userType == 'admin'
                              ? '/admin'
                              : _userType == 'company'
                                  ? '/companymypage'
                                  : '/mypage',
                        );
                      },
                    ),
                  _drawerTile(
                    icon: Icons.work_outline_rounded,
                    label: '채용공고',
                    onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/job-list'); },
                  ),
                  _drawerTile(
                    icon: Icons.description_outlined,
                    label: '이력서',
                    onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/resume'); },
                  ),
                  _drawerTile(
                    icon: Icons.forum_outlined,
                    label: '게시판',
                    onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/board'); },
                  ),
                  _drawerTile(
                    icon: Icons.campaign_outlined,
                    label: '공지사항',
                    onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/notice'); },
                  ),
                  _drawerTile(
                    icon: Icons.folder_outlined,
                    label: '자료실',
                    onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/resources/list'); },
                  ),
                  if (_isLoggedIn) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: _separator),
                    const SizedBox(height: 8),
                    _drawerTile(
                      icon: Icons.logout_rounded,
                      label: '로그아웃',
                      color: const Color(0xFFE5342F),
                      onTap: () async {
                        final nav = Navigator.of(context);
                        await _authService.logout();
                        if (mounted) nav.pushReplacementNamed('/');
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? _label;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: c, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
            color: c,
          ),
        ),
        trailing: color == null
            ? const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7C7CC), size: 20)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _MenuItem({required this.icon, required this.label, required this.color, required this.route});
}

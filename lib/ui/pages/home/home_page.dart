import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/resources/job_news_page.dart';
import 'package:peoplejob_frontend/services/auth_service.dart';
import 'widgets/job_rolling_banner.dart';
import 'widgets/job_random_section.dart';
import 'widgets/job_recommend_section.dart';
import 'widgets/company_ads_section.dart';
import 'widgets/notice_preview.dart';
import 'widgets/resource_shortcuts.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _authService.getToken();
    final userInfo = await _authService.getUserInfo();

    setState(() {
      _isLoggedIn = token != null;
      _userName = userInfo['name'];
      _userType = userInfo['userType'];
    });
  }

  Widget _buildQuickMenuSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 메뉴',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickMenuCard(
                  icon: Icons.work,
                  title: '채용공고',
                  subtitle: '채용정보 확인',
                  onTap: () => Navigator.pushNamed(context, '/job-list'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickMenuCard(
                  icon: Icons.person_search,
                  title: '인재검색',
                  subtitle: '인재 찾기',
                  onTap: () => Navigator.pushNamed(context, '/talent-search'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickMenuCard(
                  icon: Icons.description,
                  title: '이력서',
                  subtitle: '이력서 관리',
                  onTap: () => Navigator.pushNamed(context, '/resume-list'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickMenuCard(
                  icon: Icons.announcement,
                  title: '공지사항',
                  subtitle: '최신 소식',
                  onTap: () => Navigator.pushNamed(context, '/notice-list'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? const Color(0xFFFF3B30)
              : isPrimary
                  ? const Color(0xFF007AFF)
                  : const Color(0xFF8E8E93),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.4,
            color: isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF000000),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: const Color(0xFFC7C7CC),
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildQuickMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFF007AFF),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFFF2F2F7),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    if (_isLoggedIn) ...[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Center(
                          child: Text(
                            _userName?.substring(0, 1) ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$_userName님',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _userType == 'company' ? '기업회원' : '개인회원',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 48,
                        color: Color(0xFF007AFF),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '환영합니다',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 메뉴 리스트
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (_isLoggedIn) ...[
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        title: '마이페이지',
                        onTap: () {
                          Navigator.pop(context);
                          if (_userType == 'company') {
                            Navigator.pushNamed(context, '/companymypage');
                          } else {
                            Navigator.pushNamed(context, '/mypage');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      _buildDrawerItem(
                        icon: Icons.login_rounded,
                        title: '로그인',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        isPrimary: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_add_outlined,
                        title: '회원가입',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/register');
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    _buildDrawerItem(
                      icon: Icons.article_outlined,
                      title: '게시판',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/board');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.description_outlined,
                      title: '이력서',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/resume');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.work_outline,
                      title: '채용공고',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/job-list');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.folder_outlined,
                      title: '자료실',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/resources/list');
                      },
                    ),
                    if (_isLoggedIn) ...[
                      const SizedBox(height: 8),
                      _buildDrawerItem(
                        icon: Icons.logout_rounded,
                        title: '로그아웃',
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await _authService.logout();
                          if (mounted) {
                            navigator.pushReplacementNamed('/');
                          }
                        },
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            expandedHeight: 56,
            collapsedHeight: 56,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF007AFF),
                  size: 28,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: '메뉴',
              ),
            ),
            title: const Text(
              '피플잡',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: Color(0xFF007AFF),
              ),
            ),
            centerTitle: false,
            actions: [
              // 로그인 상태 표시
              if (_isLoggedIn) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _userType == 'company' ? Icons.business : Icons.person,
                        size: 16,
                        color: const Color(0xFF007AFF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_userName님',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: '로그아웃',
                  color: const Color(0xFF8E8E93),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await _authService.logout();
                    if (mounted) {
                      navigator.pushReplacementNamed('/');
                    }
                  },
                ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF007AFF),
                      side: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: '검색',
                color: const Color(0xFF007AFF),
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 빠른 메뉴 섹션 추가
                _buildQuickMenuSection(),
                const SizedBox(height: 24),
                const JobRollingBanner(),
                const SizedBox(height: 24),
                const JobRandomSection(),
                const SizedBox(height: 16),
                const JobRecommendSection(),
                const SizedBox(height: 24),
                const CompanyAdsSection(),
                const SizedBox(height: 24),
                const NoticePreview(),
                const SizedBox(height: 24),
                const ResourceShortcuts(),
                const SizedBox(height: 24),
                const JobNewsPage(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

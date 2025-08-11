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

  Widget _buildQuickMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue[600]),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          children: [
            // 로그인 상태에 따른 헤더
            if (_isLoggedIn) ...[
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  _userName?.substring(0, 1) ?? 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_userName님',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _userType == 'company' ? '기업회원' : '개인회원',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
            ] else ...[
              const Text(
                "🔗 바로가기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 16),

            // 로그인/로그아웃 버튼
            if (_isLoggedIn) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await _authService.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('회원가입'),
              ),
            ],
            const SizedBox(height: 12),

            // 마이페이지 (로그인 시에만 표시)
            if (_isLoggedIn) ...[
              ElevatedButton(
                onPressed: () {
                  if (_userType == 'company') {
                    Navigator.pushNamed(context, '/companymypage');
                  } else {
                    Navigator.pushNamed(context, '/mypage');
                  }
                },
                child: const Text('마이페이지'),
              ),
              const SizedBox(height: 12),
            ],

            // 공통 메뉴
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/board'),
              child: const Text('📋 게시판'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/resume'),
              child: const Text('📄 이력서 보기'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/job-list'),
              child: const Text('📢 채용공고 보기'),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('자료실'),
              onTap: () => Navigator.pushNamed(context, '/resources/list'),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            expandedHeight: 80,
            title: const Text('PeopleJob'),
            actions: [
              // 로그인 상태 표시
              if (_isLoggedIn) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Chip(
                      label: Text(
                        '$_userName님',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.white,
                      avatar: Icon(
                        _userType == 'company' ? Icons.business : Icons.person,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: '로그아웃',
                  onPressed: () async {
                    await _authService.logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    '로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: '검색',
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
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

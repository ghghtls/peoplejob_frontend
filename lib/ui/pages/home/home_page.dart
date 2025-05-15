import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/resources/job_news_page.dart';
import 'widgets/job_rolling_banner.dart';
import 'widgets/job_random_section.dart';
import 'widgets/job_recommend_section.dart';
import 'widgets/company_ads_section.dart';
import 'widgets/notice_preview.dart';
import 'widgets/resource_shortcuts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          children: [
            const Text(
              "🔗 바로가기",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('로그인'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('회원가입'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                const userType = 'user';
                if (userType == 'company') {
                  Navigator.pushNamed(context, '/companymypage');
                } else {
                  Navigator.pushNamed(context, '/mypage');
                }
              },
              child: const Text('마이페이지'),
            ),
            const SizedBox(height: 12),
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
              onPressed: () => Navigator.pushNamed(context, '/job'),
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
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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

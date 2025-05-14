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
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📢 공채 롤링 배너
              const JobRollingBanner(),
              const SizedBox(height: 24),

              // 🎯 랜덤 공고 + 맞춤 공고
              const JobRandomSection(),
              const SizedBox(height: 16),
              const JobRecommendSection(),
              const SizedBox(height: 24),

              // 💼 기업 광고 공고
              const CompanyAdsSection(),
              const SizedBox(height: 24),

              // 📌 공지사항 요약
              const NoticePreview(),
              const SizedBox(height: 24),

              // 🗂 자료실 바로가기
              const ResourceShortcuts(),
              const SizedBox(height: 24),

              // 📰 취업 뉴스
              const JobNewsPage(),
              const SizedBox(height: 40),

              // 🔗 빠른 이동 버튼들
              const Text(
                "바로가기",
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
                  const userType = 'user'; // TODO: 로그인 정보 기반 분기
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
              const SizedBox(height: 20),

              const Divider(height: 32),

              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('자료실'),
                onTap: () => Navigator.pushNamed(context, '/resources/list'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

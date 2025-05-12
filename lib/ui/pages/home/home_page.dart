import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('피플잡'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const JobRollingBanner(),
            const SizedBox(height: 16),
            const JobRandomSection(),
            const SizedBox(height: 16),
            const JobRecommendSection(),
            const SizedBox(height: 16),
            const CompanyAdsSection(),
            const SizedBox(height: 16),
            const NoticePreview(),
            const SizedBox(height: 16),
            const ResourceShortcuts(),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
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
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/*
home_page.dart	Scaffold 전체 구조
job_rolling_banner.dart	공채정보 롤링배너
job_random_section.dart	랜덤 채용공고 리스트
job_recommend_section.dart	맞춤 채용공고 리스트
company_ads_section.dart	기업 광고공고
notice_preview.dart	공지사항 요약
resource_shortcuts.dart	자료실 바로가기
 */

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
      body: const SingleChildScrollView(
        child: Column(
          children: [
            JobRollingBanner(),
            SizedBox(height: 16),
            JobRandomSection(),
            SizedBox(height: 16),
            JobRecommendSection(),
            SizedBox(height: 16),
            CompanyAdsSection(),
            SizedBox(height: 16),
            NoticePreview(),
            SizedBox(height: 16),
            ResourceShortcuts(),
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

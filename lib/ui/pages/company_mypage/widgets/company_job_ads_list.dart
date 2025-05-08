// lib/ui/pages/company_mypage/widgets/company_job_ads_list.dart
import 'package:flutter/material.dart';

class CompanyJobAdsList extends StatelessWidget {
  const CompanyJobAdsList({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final List<Map<String, String>> jobAds = [
      {
        'title': '백엔드 개발자 모집',
        'status': '공고중',
        'date': '2025-05-01 ~ 2025-06-01',
      },
      {
        'title': '프론트엔드 신입 채용',
        'status': '마감',
        'date': '2025-04-01 ~ 2025-04-30',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '채용공고 목록',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...jobAds.map(
          (ad) => Card(
            child: ListTile(
              title: Text(ad['title']!),
              subtitle: Text('기간: ${ad['date']}'),
              trailing: Text(
                ad['status']!,
                style: TextStyle(
                  color: ad['status'] == '공고중' ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// lib/ui/pages/company_mypage/widgets/company_profile_card.dart
import 'package:flutter/material.dart';

class CompanyProfileCard extends StatelessWidget {
  const CompanyProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '홍길동 테크 주식회사',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('사업자번호: 123-45-67890'),
            Text('담당자: 김개발'),
            Text('이메일: contact@dong.com'),
            Text('승인상태: 승인완료'),
          ],
        ),
      ),
    );
  }
}

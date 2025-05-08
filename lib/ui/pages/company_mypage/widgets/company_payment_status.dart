// lib/ui/pages/company_mypage/widgets/company_payment_status.dart
import 'package:flutter/material.dart';

class CompanyPaymentStatus extends StatelessWidget {
  const CompanyPaymentStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 결제 데이터
    final List<Map<String, String>> payments = [
      {'service': '광고 프리미엄 1개월', 'status': '결제완료', 'date': '2025-04-28'},
      {'service': '일반 광고 2주', 'status': '결제취소', 'date': '2025-04-20'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '결제 내역',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...payments.map(
          (item) => Card(
            child: ListTile(
              title: Text(item['service']!),
              subtitle: Text('결제일: ${item['date']}'),
              trailing: Text(
                item['status']!,
                style: TextStyle(
                  color: item['status'] == '결제완료' ? Colors.blue : Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

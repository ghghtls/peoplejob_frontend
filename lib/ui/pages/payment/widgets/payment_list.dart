import 'package:flutter/material.dart';

class PaymentList extends StatelessWidget {
  const PaymentList({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = [
      {'type': '메인 배너 광고', 'status': '승인 대기', 'date': '2025-05-01'},
      {'type': '상단 노출 광고', 'status': '승인 완료', 'date': '2025-04-28'},
    ];

    return Column(
      children:
          payments.map((p) {
            return ListTile(
              title: Text(p['type']!),
              subtitle: Text('신청일: ${p['date']}'),
              trailing: Text(
                p['status']!,
                style: TextStyle(
                  color: p['status'] == '승인 완료' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
    );
  }
}

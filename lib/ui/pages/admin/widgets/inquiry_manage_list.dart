import 'package:flutter/material.dart';

class InquiryManageList extends StatelessWidget {
  const InquiryManageList({super.key});

  @override
  Widget build(BuildContext context) {
    final inquiries = [
      {'title': '결제 오류', 'status': '대기'},
      {'title': '채용공고 신고', 'status': '완료'},
    ];

    return Column(
      children:
          inquiries.map((q) {
            return ListTile(
              title: Text(q['title']!),
              trailing: Text(
                q['status']!,
                style: TextStyle(
                  color: q['status'] == '완료' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
    );
  }
}

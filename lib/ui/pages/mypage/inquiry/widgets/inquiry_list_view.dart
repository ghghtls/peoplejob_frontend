import 'package:flutter/material.dart';

class InquiryListView extends StatelessWidget {
  const InquiryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyInquiries = [
      {'title': '결제 오류 문의', 'date': '2025-05-01', 'status': '답변 대기'},
      {'title': '채용 공고 신고', 'date': '2025-04-28', 'status': '답변 완료'},
    ];

    return ListView.separated(
      itemCount: dummyInquiries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = dummyInquiries[index];
        return Card(
          child: ListTile(
            title: Text(item['title']!),
            subtitle: Text('작성일: ${item['date']}'),
            trailing: Text(
              item['status']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item['status'] == '답변 완료' ? Colors.green : Colors.orange,
              ),
            ),
            onTap: () {
              // TODO: 상세 페이지 이동
              print("문의 클릭: ${item['title']}");
            },
          ),
        );
      },
    );
  }
}

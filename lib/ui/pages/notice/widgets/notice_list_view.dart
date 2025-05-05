import 'package:flutter/material.dart';

class NoticeListView extends StatelessWidget {
  const NoticeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyNotices = [
      {
        'title': '5월 시스템 점검 안내',
        'date': '2025-05-03',
        'content': '서버 점검이 예정되어 있습니다.',
      },
      {
        'title': '신규 기능 안내',
        'date': '2025-04-30',
        'content': '채용공고 알림 기능이 추가되었습니다.',
      },
    ];

    return ListView.separated(
      itemCount: dummyNotices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notice = dummyNotices[index];
        return Card(
          child: ListTile(
            title: Text(notice['title']!),
            subtitle: Text('작성일: ${notice['date']}'),
            onTap: () {
              // TODO: 상세 페이지로 이동
              print("공지 클릭: ${notice['title']}");
            },
          ),
        );
      },
    );
  }
}

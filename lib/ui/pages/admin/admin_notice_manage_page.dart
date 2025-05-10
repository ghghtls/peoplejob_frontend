import 'package:flutter/material.dart';

class AdminNoticeManagePage extends StatefulWidget {
  const AdminNoticeManagePage({super.key});

  @override
  State<AdminNoticeManagePage> createState() => _AdminNoticeManagePageState();
}

class _AdminNoticeManagePageState extends State<AdminNoticeManagePage> {
  final List<Notice> notices = [
    Notice(id: 1, title: '서비스 점검 안내', date: '2025-05-01'),
    Notice(id: 2, title: '5월 업데이트 공지', date: '2025-05-05'),
  ];

  void _deleteNotice(int id) {
    setState(() {
      notices.removeWhere((notice) => notice.id == id);
    });
  }

  void _addNotice() {
    // TODO: 공지 추가 폼 또는 라우트로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: _addNotice, child: const Text('공지 추가')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: notices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  return ListTile(
                    title: Text(notice.title),
                    subtitle: Text(notice.date),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteNotice(notice.id),
                    ),
                    onTap: () {
                      // TODO: 상세보기 또는 수정으로 이동
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Notice {
  final int id;
  final String title;
  final String date;

  Notice({required this.id, required this.title, required this.date});
}

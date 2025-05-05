import 'package:flutter/material.dart';
import 'widgets/notice_list_view.dart';
import 'widgets/empty_notice_message.dart';

class NoticeListPage extends StatelessWidget {
  const NoticeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasNotice = true; // TODO: 상태 관리 연동

    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasNotice ? const NoticeListView() : const EmptyNoticeMessage(),
      ),
    );
  }
}

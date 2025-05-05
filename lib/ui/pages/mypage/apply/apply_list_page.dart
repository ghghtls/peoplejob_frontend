import 'package:flutter/material.dart';
import 'widgets/apply_list_view.dart';
import 'widgets/empty_apply_message.dart';

class ApplyListPage extends StatelessWidget {
  const ApplyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasApplyData = true; // TODO: 리버팟 상태로 변경 예정

    return Scaffold(
      appBar: AppBar(title: const Text('지원 내역')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasApplyData ? const ApplyListView() : const EmptyApplyMessage(),
      ),
    );
  }
}

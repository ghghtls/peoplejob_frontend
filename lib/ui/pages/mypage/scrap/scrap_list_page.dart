import 'package:flutter/material.dart';
import 'widgets/scrap_list_view.dart';
import 'widgets/empty_scrap_message.dart';

class ScrapListPage extends StatelessWidget {
  const ScrapListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasScrap = true; // TODO: Riverpod 상태에 따라 변경

    return Scaffold(
      appBar: AppBar(title: const Text('스크랩한 공고')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasScrap ? const ScrapListView() : const EmptyScrapMessage(),
      ),
    );
  }
}

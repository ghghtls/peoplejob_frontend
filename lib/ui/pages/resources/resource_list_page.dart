import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/tools/widgets/word_count_box.dart';
import 'widgets/resource_list_view.dart';

class ResourceListPage extends StatelessWidget {
  const ResourceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자료실')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ResourceListView(),
            Divider(height: 40),
            Text(
              '📌 유용한 도구',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            WordCountBox(), // 글자 수 세기 도구 삽입
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'widgets/job_detail_header.dart';
import 'widgets/job_detail_content.dart';
import 'widgets/apply_button.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채용공고 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            JobDetailHeader(),
            SizedBox(height: 16),
            JobDetailContent(),
            SizedBox(height: 80), // 하단 버튼 공간 확보
          ],
        ),
      ),
      bottomSheet: const ApplyButton(),
    );
  }
}

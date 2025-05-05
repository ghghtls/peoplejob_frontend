import 'package:flutter/material.dart';
import 'widgets/resume_summary.dart';
import 'widgets/resume_list_view.dart';
import 'widgets/add_resume_button.dart';

class ResumeListPage extends StatelessWidget {
  const ResumeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이력서 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            ResumeSummary(),
            SizedBox(height: 16),
            Expanded(child: ResumeListView()),
          ],
        ),
      ),
      floatingActionButton: const AddResumeButton(),
    );
  }
}

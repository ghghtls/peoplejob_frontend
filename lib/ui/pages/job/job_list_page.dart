import 'package:flutter/material.dart';
import 'widgets/job_search_bar.dart';
import 'widgets/job_filter_bar.dart';
import 'widgets/job_list_view.dart';
import 'widgets/empty_jobs_message.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasJobs = true; // TODO: Riverpod 연결 후 상태에 따라 변경

    return Scaffold(
      appBar: AppBar(title: const Text('채용공고 리스트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const JobSearchBar(),
            const SizedBox(height: 12),
            const JobFilterBar(),
            const SizedBox(height: 12),
            Expanded(
              child: hasJobs ? const JobListView() : const EmptyJobsMessage(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/provider/job_provider.dart';

class JobRandomSection extends ConsumerWidget {
  const JobRandomSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobList = ref.watch(jobListProvider);

    return jobList.when(
      data: (jobs) {
        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(8),
                  child: Center(child: Text(job.title)),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('에러 발생: $e')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/provider/job_provider.dart';

class JobDraftFab extends ConsumerWidget {
  final VoidCallback onPressed;

  const JobDraftFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftCount = ref.watch(draftCountProvider);

    return Stack(
      children: [
        FloatingActionButton.extended(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('채용공고 작성'),
          backgroundColor: Theme.of(context).primaryColor,
        ),

        // 임시저장 개수 배지
        if (draftCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                draftCount > 99 ? '99+' : draftCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

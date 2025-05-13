import 'package:flutter/material.dart';
import 'apply_now_sheet.dart';

class ApplyButton extends StatelessWidget {
  final String jobTitle;

  const ApplyButton({super.key, required this.jobTitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder:
                  (_) => ApplyNowSheet(
                    jobTitle: jobTitle,
                    resumeList: ['개발자 이력서 1', '풀스택 이력서 2', 'AI 포지션 이력서'],
                  ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('즉시지원'),
        ),
      ),
    );
  }
}

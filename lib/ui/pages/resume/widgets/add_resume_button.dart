import 'package:flutter/material.dart';

class AddResumeButton extends StatelessWidget {
  const AddResumeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: 이력서 등록 페이지로 이동
        print("새 이력서 등록 페이지 이동");
      },
      child: const Icon(Icons.add),
    );
  }
}

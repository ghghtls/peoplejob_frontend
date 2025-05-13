import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AddResumeButton extends StatelessWidget {
  const AddResumeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/resume/register',
          arguments: {
            'title': '',
            'content': quill.Document(),
            'onSave': (String title, quill.Document content) {
              debugPrint('새 이력서 저장됨: $title');
            },
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

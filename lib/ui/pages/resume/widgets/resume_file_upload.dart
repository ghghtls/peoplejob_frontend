import 'package:flutter/material.dart';

class ResumeFileUpload extends StatelessWidget {
  const ResumeFileUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: 파일 선택 다이얼로그
            print("파일 업로드 클릭");
          },
          icon: const Icon(Icons.attach_file),
          label: const Text('파일 첨부'),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('선택된 파일 없음', overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

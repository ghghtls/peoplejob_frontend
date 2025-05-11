import 'package:flutter/material.dart';

class ApplyNowSheet extends StatefulWidget {
  final List<String> resumeList;

  const ApplyNowSheet({super.key, required this.resumeList});

  @override
  State<ApplyNowSheet> createState() => _ApplyNowSheetState();
}

class _ApplyNowSheetState extends State<ApplyNowSheet> {
  String? _selectedResume;

  void _submit() {
    if (_selectedResume == null) return;

    // TODO: 지원 API 요청
    Navigator.pop(context); // 모달 닫기
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('지원이 완료되었습니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('사용할 이력서를 선택하세요', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ...widget.resumeList.map((resume) {
            return RadioListTile<String>(
              title: Text(resume),
              value: resume,
              groupValue: _selectedResume,
              onChanged: (value) {
                setState(() {
                  _selectedResume = value;
                });
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _submit, child: const Text('지원하기')),
        ],
      ),
    );
  }
}

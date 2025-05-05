import 'package:flutter/material.dart';

class ApplyButton extends StatelessWidget {
  const ApplyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 지원하기 로직 연결
          print("지원하기 버튼 클릭");
        },
        child: const Text('지원하기'),
      ),
    );
  }
}

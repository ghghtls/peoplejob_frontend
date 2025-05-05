import 'package:flutter/material.dart';

class EmptyInquiryMessage extends StatelessWidget {
  const EmptyInquiryMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '보낸 문의가 없습니다.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

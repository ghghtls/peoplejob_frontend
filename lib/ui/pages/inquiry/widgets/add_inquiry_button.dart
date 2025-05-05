import 'package:flutter/material.dart';

class AddInquiryButton extends StatelessWidget {
  const AddInquiryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: 문의 작성 페이지로 이동
        print("문의 작성 페이지 이동");
      },
      child: const Icon(Icons.edit),
    );
  }
}

import 'package:flutter/material.dart';

class AddInquiryButton extends StatelessWidget {
  const AddInquiryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/inquiry/write');
      },
      child: const Icon(Icons.edit),
    );
  }
}

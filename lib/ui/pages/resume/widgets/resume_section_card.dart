import 'package:flutter/material.dart';

class ResumeSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ResumeSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
        const Divider(height: 32),
      ],
    );
  }
}

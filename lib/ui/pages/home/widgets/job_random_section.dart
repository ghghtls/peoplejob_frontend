import 'package:flutter/material.dart';

class JobRandomSection extends StatelessWidget {
  const JobRandomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.green[100],
      child: const Center(child: Text('랜덤 채용공고')),
    );
  }
}

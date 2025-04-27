import 'package:flutter/material.dart';

class JobRecommendSection extends StatelessWidget {
  const JobRecommendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.orange[100],
      child: const Center(child: Text('맞춤 채용공고')),
    );
  }
}

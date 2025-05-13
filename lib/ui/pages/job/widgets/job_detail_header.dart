import 'package:flutter/material.dart';

class JobDetailHeader extends StatelessWidget {
  final String title;
  final String company;
  final String location;

  const JobDetailHeader({
    super.key,
    required this.title,
    required this.company,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('$company • $location'),
      ],
    );
  }
}

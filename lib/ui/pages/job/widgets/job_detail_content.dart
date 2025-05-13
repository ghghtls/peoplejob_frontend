import 'package:flutter/material.dart';

class JobDetailContent extends StatelessWidget {
  final String description;

  const JobDetailContent({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(description);
  }
}

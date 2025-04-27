import 'package:flutter/material.dart';

class ResourceShortcuts extends StatelessWidget {
  const ResourceShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.teal[100],
      child: const Center(child: Text('자료실 링크 모음')),
    );
  }
}

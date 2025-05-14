import 'package:flutter/material.dart';

class ResourceShortcuts extends StatelessWidget {
  const ResourceShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.teal[100],
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '자료실 링크 모음',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

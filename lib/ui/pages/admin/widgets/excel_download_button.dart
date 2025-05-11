import 'package:flutter/material.dart';

class ExcelDownloadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExcelDownloadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.download),
      label: const Text('Excel 다운로드'),
    );
  }
}

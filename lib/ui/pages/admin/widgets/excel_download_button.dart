import 'package:flutter/material.dart';

class ExcelDownloadButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isLoading;

  const ExcelDownloadButton({
    super.key,
    required this.onPressed,
    this.label = 'Excel 다운로드',
    this.icon = Icons.download,
    this.isLoading = false,
  });

  @override
  State<ExcelDownloadButton> createState() => _ExcelDownloadButtonState();
}

class _ExcelDownloadButtonState extends State<ExcelDownloadButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.isLoading ? null : widget.onPressed,
      icon:
          widget.isLoading
              ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Icon(widget.icon),
      label: Text(widget.isLoading ? '다운로드 중...' : widget.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

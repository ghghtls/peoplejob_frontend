import 'package:flutter/material.dart';

class WordCountBox extends StatefulWidget {
  const WordCountBox({super.key});

  @override
  State<WordCountBox> createState() => _WordCountBoxState();
}

class _WordCountBoxState extends State<WordCountBox> {
  final TextEditingController _controller = TextEditingController();
  int totalLength = 0;
  int noSpaceLength = 0;

  void _updateCount(String text) {
    setState(() {
      totalLength = text.length;
      noSpaceLength = text.replaceAll(RegExp(r'\\s+'), '').length;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _updateCount(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('텍스트 입력', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 6,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: '여기에 텍스트를 입력하세요...',
          ),
        ),
        const SizedBox(height: 16),
        Text('공백 포함: $totalLength 자'),
        Text('공백 제외: $noSpaceLength 자'),
      ],
    );
  }
}

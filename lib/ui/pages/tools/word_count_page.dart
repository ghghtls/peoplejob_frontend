import 'package:flutter/material.dart';
import 'widgets/word_count_box.dart';

class WordCountPage extends StatelessWidget {
  const WordCountPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('글자 수 세기',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: WordCountBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'widgets/word_count_box.dart';

class WordCountPage extends StatelessWidget {
  const WordCountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('글자 수 세기')),
      body: const Padding(padding: EdgeInsets.all(16.0), child: WordCountBox()),
    );
  }
}

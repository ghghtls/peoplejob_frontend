import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      home: Scaffold(
        appBar: AppBar(title: const Text('Quill Editor')),
        body: const QuillEditorWidget(),
      ),
    );
  }
}

class QuillEditorWidget extends StatefulWidget {
  const QuillEditorWidget({super.key});

  @override
  State<QuillEditorWidget> createState() => _QuillEditorWidgetState();
}

class _QuillEditorWidgetState extends State<QuillEditorWidget> {
  late final quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        quill.QuillSimpleToolbar(
          controller: _controller,
          config: const quill.QuillSimpleToolbarConfig(),
        ),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: quill.QuillEditor.basic(
            controller: _controller,
            config: quill.QuillEditorConfig(
              scrollable: true,
              padding: const EdgeInsets.all(8),
              autoFocus: false,
            ),
          ),
        ),
      ],
    );
  }
}

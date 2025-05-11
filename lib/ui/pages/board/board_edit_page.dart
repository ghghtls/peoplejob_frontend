import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class BoardEditPage extends StatefulWidget {
  final String initialTitle;
  final quill.Document initialContent;

  const BoardEditPage({
    super.key,
    required this.initialTitle,
    required this.initialContent,
  });

  @override
  State<BoardEditPage> createState() => _BoardEditPageState();
}

class _BoardEditPageState extends State<BoardEditPage> {
  late final TextEditingController _titleController;
  late final quill.QuillController _contentController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = quill.QuillController(
      document: widget.initialContent,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _handleSave() {
    final editedTitle = _titleController.text;
    final editedContent = _contentController.document.toPlainText();

    // TODO: 서버로 PUT 요청 등 처리

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다.')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 16),
            quill.QuillSimpleToolbar(
              controller: _contentController,
              config: const quill.QuillSimpleToolbarConfig(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor.basic(
                  controller: _contentController,
                  config: quill.QuillEditorConfig(
                    //  scrollController: _scrollController,
                    // focusNode: _focusNode,
                    scrollable: true,
                    autoFocus: false,
                    //  readOnly: false,
                    expands: false,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('수정 완료'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

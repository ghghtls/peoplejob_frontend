import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class BoardWriteForm extends StatefulWidget {
  const BoardWriteForm({super.key});

  @override
  State<BoardWriteForm> createState() => _BoardWriteFormState();
}

class _BoardWriteFormState extends State<BoardWriteForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final content = _quillController.document.toPlainText();

      // TODO: 서버 전송
      print('제목: $title');
      print('내용: $content');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
              validator: (v) => v == null || v.isEmpty ? '제목을 입력하세요' : null,
            ),
            const SizedBox(height: 16),
            quill.QuillSimpleToolbar(
              controller: _quillController,
              config: const quill.QuillSimpleToolbarConfig(),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              padding: const EdgeInsets.all(8),
              child: quill.QuillEditor.basic(
                controller: _quillController,
                config: quill.QuillEditorConfig(
                  //   scrollController: _scrollController,
                  //  focusNode: _focusNode,
                  scrollable: true,
                  autoFocus: false,
                  //  readOnly: false,
                  expands: false,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: const Text('등록')),
          ],
        ),
      ),
    );
  }
}

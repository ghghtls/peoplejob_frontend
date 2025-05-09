import 'package:flutter/material.dart';

class BoardWriteForm extends StatefulWidget {
  const BoardWriteForm({super.key});

  @override
  State<BoardWriteForm> createState() => _BoardWriteFormState();
}

class _BoardWriteFormState extends State<BoardWriteForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

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
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
              validator: (v) => v == null || v.isEmpty ? '제목을 입력하세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: '내용',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? '내용을 입력하세요' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: const Text('등록')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BoardRegisterForm extends StatefulWidget {
  const BoardRegisterForm({super.key});

  @override
  State<BoardRegisterForm> createState() => _BoardRegisterFormState();
}

class _BoardRegisterFormState extends State<BoardRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  bool allowUpload = false;
  bool allowComment = false;
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: '게시판 이름'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? '필수 입력 항목입니다' : null,
            onSaved: (value) => title = value!,
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('파일 업로드 허용'),
            value: allowUpload,
            onChanged: (val) => setState(() => allowUpload = val),
          ),
          SwitchListTile(
            title: const Text('댓글 허용'),
            value: allowComment,
            onChanged: (val) => setState(() => allowComment = val),
          ),
          SwitchListTile(
            title: const Text('사용 여부'),
            value: isActive,
            onChanged: (val) => setState(() => isActive = val),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // TODO: API 연동 또는 등록 처리
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('게시판 등록 완료')));
              }
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }
}

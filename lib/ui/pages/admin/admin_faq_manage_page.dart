import 'package:flutter/material.dart';

class AdminFaqManagePage extends StatefulWidget {
  const AdminFaqManagePage({super.key});

  @override
  State<AdminFaqManagePage> createState() => _AdminFaqManagePageState();
}

class _AdminFaqManagePageState extends State<AdminFaqManagePage> {
  final List<Map<String, String>> _faqList = [
    {
      'question': '이력서는 어떻게 등록하나요?',
      'answer': '로그인 후 마이페이지에서 이력서 등록 메뉴를 이용하세요.',
    },
    {'question': '비밀번호를 잊었어요. 어떻게 하나요?', 'answer': '로그인 화면에서 비밀번호 찾기를 눌러주세요.'},
    {'question': '채용공고를 수정하고 싶어요.', 'answer': '기업회원 로그인 후 공고 관리에서 수정할 수 있습니다.'},
  ];

  void _showAddFaqDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('FAQ 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: '질문'),
                ),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: '답변'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (questionController.text.isNotEmpty &&
                      answerController.text.isNotEmpty) {
                    setState(() {
                      _faqList.add({
                        'question': questionController.text,
                        'answer': answerController.text,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('등록'),
              ),
            ],
          ),
    );
  }

  void _removeFaq(int index) {
    setState(() {
      _faqList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ 관리')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqList.length,
        itemBuilder: (context, index) {
          final faq = _faqList[index];
          return Card(
            child: ExpansionTile(
              title: Text(faq['question']!),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(faq['answer']!),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: 수정 기능
                      },
                      child: const Text('수정'),
                    ),
                    TextButton(
                      onPressed: () => _removeFaq(index),
                      child: const Text(
                        '삭제',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFaqDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class AdminFaqManagePage extends StatefulWidget {
  const AdminFaqManagePage({super.key});

  @override
  State<AdminFaqManagePage> createState() => _AdminFaqManagePageState();
}

class _AdminFaqManagePageState extends State<AdminFaqManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final List<Map<String, String>> _faqList = [
    {'question': '이력서는 어떻게 등록하나요?', 'answer': '로그인 후 마이페이지에서 이력서 등록 메뉴를 이용하세요.'},
    {'question': '비밀번호를 잊었어요. 어떻게 하나요?', 'answer': '로그인 화면에서 비밀번호 찾기를 눌러주세요.'},
    {'question': '채용공고를 수정하고 싶어요.', 'answer': '기업회원 로그인 후 공고 관리에서 수정할 수 있습니다.'},
  ];

  void _showAddFaqDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('FAQ 추가', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                hintText: '질문을 입력하세요',
                hintStyle: const TextStyle(color: _secondary, fontSize: 13),
                filled: true, fillColor: _bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _blue, width: 1.5)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '답변을 입력하세요',
                hintStyle: const TextStyle(color: _secondary, fontSize: 13),
                filled: true, fillColor: _bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _blue, width: 1.5)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () {
              if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                setState(() => _faqList.add({
                  'question': questionController.text,
                  'answer': answerController.text,
                }));
                Navigator.pop(ctx);
              }
            },
            child: const Text('등록', style: TextStyle(color: _blue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _removeFaq(int index) {
    setState(() => _faqList.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: 'FAQ 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: _showAddFaqDialog,
            icon: const Icon(Icons.add_rounded, size: 22, color: _blue),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
            const SizedBox(height: 8),

            Expanded(
              child: _faqList.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.quiz_outlined, size: 36, color: _secondary)),
                      const SizedBox(height: 16),
                      const Text('등록된 FAQ가 없습니다', style: TextStyle(fontSize: 15, color: _secondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _faqList.length,
                      itemBuilder: (context, index) {
                        final faq = _faqList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              childrenPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: _blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(child: Text('Q', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _blue))),
                              ),
                              title: Text(faq['question']!,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                              children: [
                                const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32, height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF34C759).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(child: Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF34C759)))),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(faq['answer']!,
                                          style: const TextStyle(fontSize: 13, color: _label, height: 1.5))),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(foregroundColor: _blue, minimumSize: Size.zero,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                      child: const Text('수정', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ),
                                    TextButton(
                                      onPressed: () => _removeFaq(index),
                                      style: TextButton.styleFrom(foregroundColor: _red, minimumSize: Size.zero,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                      child: const Text('삭제', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';
import '../../../data/model/inquiry.dart';

class AdminInquiryManagePage extends ConsumerStatefulWidget {
  const AdminInquiryManagePage({super.key});

  @override
  ConsumerState<AdminInquiryManagePage> createState() =>
      _AdminInquiryManagePageState();
}

class _AdminInquiryManagePageState
    extends ConsumerState<AdminInquiryManagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadInquiries());
  }

  void _showAnswerDialog(Inquiry inquiry) {
    final answerController = TextEditingController(text: inquiry.answer ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('문의 답변'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제목: ${inquiry.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '문의 내용:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(inquiry.content),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: '답변 내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (answerController.text.trim().isNotEmpty &&
                      inquiry.inquiryNo != null) {
                    final success = await ref
                        .read(adminProvider.notifier)
                        .answerInquiry(
                          inquiry.inquiryNo!,
                          answerController.text.trim(),
                        );
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('답변이 등록되었습니다.')),
                      );
                    }
                  }
                },
                child: const Text('답변 등록'),
              ),
            ],
          ),
    );
  }

  void _deleteInquiry(Inquiry inquiry) {
    if (inquiry.inquiryNo == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('문의 삭제'),
            content: Text('정말로 "${inquiry.title}" 문의를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final success = await ref
                      .read(adminProvider.notifier)
                      .deleteInquiry(inquiry.inquiryNo!);
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('문의가 삭제되었습니다.')),
                    );
                  }
                },
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의사항 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProvider.notifier).loadInquiries(),
          ),
        ],
      ),
      body:
          adminState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : adminState.error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('오류: ${adminState.error}'),
                    ElevatedButton(
                      onPressed:
                          () =>
                              ref.read(adminProvider.notifier).loadInquiries(),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
              : adminState.inquiries.isEmpty
              ? const Center(child: Text('문의사항이 없습니다.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: adminState.inquiries.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final inquiry = adminState.inquiries[index];
                  return Card(
                    child: ListTile(
                      title: Text(inquiry.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('사용자 번호: ${inquiry.userNo ?? "알 수 없음"}'),
                          Text('등록일: ${inquiry.regdate ?? "알 수 없음"}'),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  inquiry.isAnswered
                                      ? Colors.green
                                      : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              inquiry.statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.reply, color: Colors.blue),
                            onPressed: () => _showAnswerDialog(inquiry),
                            tooltip: '답변',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteInquiry(inquiry),
                            tooltip: '삭제',
                          ),
                        ],
                      ),
                      onTap: () => _showAnswerDialog(inquiry),
                    ),
                  );
                },
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/inquiry_provider.dart';
import '../../../data/model/inquiry.dart';
import 'inquiry_form_page.dart';

class InquiryDetailPage extends ConsumerStatefulWidget {
  final int inquiryNo;

  const InquiryDetailPage({super.key, required this.inquiryNo});

  @override
  ConsumerState<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends ConsumerState<InquiryDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInquiryDetail();
    });
  }

  Future<void> _loadInquiryDetail() async {
    await ref
        .read(inquiryProvider.notifier)
        .loadInquiryDetail(widget.inquiryNo);
  }

  Future<void> _navigateToEdit(Inquiry inquiry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryFormPage(inquiry: inquiry),
      ),
    );

    if (result == true) {
      if (mounted) {
        Navigator.pop(context, true); // 수정 완료시 이전 화면으로
      }
    }
  }

  Future<void> _showDeleteDialog(Inquiry inquiry) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('문의 삭제'),
            content: const Text('정말로 이 문의를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _deleteInquiry(inquiry);
    }
  }

  Future<void> _deleteInquiry(Inquiry inquiry) async {
    final success = await ref
        .read(inquiryProvider.notifier)
        .deleteInquiry(inquiry.inquiryNo!);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('문의가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        final errorMessage =
            ref.read(inquiryProvider).errorMessage ?? '문의 삭제에 실패했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inquiryState = ref.watch(inquiryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('문의 상세')),
      body: Builder(
        builder: (context) {
          if (inquiryState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inquiryState.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    inquiryState.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(inquiryProvider.notifier).clearError();
                      _loadInquiryDetail();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final inquiry = inquiryState.selectedInquiry;
          if (inquiry == null) {
            return const Center(child: Text('문의를 찾을 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상태 및 날짜 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        inquiry.isAnswered
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          inquiry.isAnswered
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            inquiry.isAnswered
                                ? Icons.check_circle
                                : Icons.schedule,
                            color:
                                inquiry.isAnswered
                                    ? Colors.green
                                    : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            inquiry.statusText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  inquiry.isAnswered
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '작성일: ${inquiry.regdate ?? '알 수 없음'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (inquiry.answerDate != null)
                        Text(
                          '답변일: ${inquiry.answerDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 제목
                const Text(
                  '제목',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inquiry.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // 내용
                const Text(
                  '문의 내용',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inquiry.content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),

                // 답변 (있는 경우)
                if (inquiry.answer != null && inquiry.answer!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '답변',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      inquiry.answer!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // 액션 버튼들 (답변 전 문의만)
                if (inquiry.status == 'WAIT') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToEdit(inquiry),
                          icon: const Icon(Icons.edit),
                          label: const Text('수정'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(inquiry),
                          icon: const Icon(Icons.delete),
                          label: const Text('삭제'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

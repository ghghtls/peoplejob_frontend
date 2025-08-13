import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/ui/pages/admin/widgets/excel_download_button.dart';
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
  bool _isDownloading = false;
  String _filterStatus = 'ALL'; // ALL, PENDING, ANSWERED

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadInquiries());
  }

  Future<void> _downloadInquiriesExcel() async {
    setState(() => _isDownloading = true);
    try {
      final filePath =
          await ref.read(adminProvider.notifier).downloadInquiriesExcel();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Excel 파일이 다운로드되었습니다'),
            action: SnackBarAction(label: '확인', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('다운로드 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showAnswerDialog(Inquiry inquiry) {
    final answerController = TextEditingController(text: inquiry.answer ?? '');

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          inquiry.isAnswered ? Icons.reply : Icons.help_outline,
                          color:
                              inquiry.isAnswered ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            inquiry.isAnswered ? '답변 수정' : '문의 답변',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 문의 정보
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '문의 제목',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inquiry.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '문의 내용',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              inquiry.content,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '문의자: ${inquiry.userNo ?? "알 수 없음"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '등록일: ${inquiry.regdate ?? "알 수 없음"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 답변 입력
                    Text(
                      '답변 내용',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: answerController,
                      decoration: InputDecoration(
                        hintText: '문의에 대한 답변을 입력해주세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 5,
                      minLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // 버튼
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
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
                                    SnackBar(
                                      content: Text(
                                        inquiry.isAnswered
                                            ? '답변이 수정되었습니다.'
                                            : '답변이 등록되었습니다.',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('답변 내용을 입력해주세요.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(inquiry.isAnswered ? '답변 수정' : '답변 등록'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _deleteInquiry(Inquiry inquiry) {
    if (inquiry.inquiryNo == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('문의 삭제'),
              ],
            ),
            content: Text(
              '정말로 "${inquiry.title}" 문의를 삭제하시겠습니까?\n\n삭제된 문의는 복구할 수 없습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final success = await ref
                      .read(adminProvider.notifier)
                      .deleteInquiry(inquiry.inquiryNo!);
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('문의가 삭제되었습니다.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  List<Inquiry> _getFilteredInquiries(List<Inquiry> inquiries) {
    switch (_filterStatus) {
      case 'PENDING':
        return inquiries.where((inquiry) => !inquiry.isAnswered).toList();
      case 'ANSWERED':
        return inquiries.where((inquiry) => inquiry.isAnswered).toList();
      default:
        return inquiries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final filteredInquiries = _getFilteredInquiries(adminState.inquiries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의사항 관리'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProvider.notifier).loadInquiries(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 컨트롤
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Excel 다운로드 버튼
                SizedBox(
                  width: double.infinity,
                  child: ExcelDownloadButton(
                    onPressed: _downloadInquiriesExcel,
                    label: '문의사항 Excel 다운로드',
                    icon: Icons.download,
                    isLoading: _isDownloading,
                  ),
                ),

                const SizedBox(height: 16),

                // 필터 버튼
                Row(
                  children: [
                    const Text(
                      '필터: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'ALL',
                              '전체',
                              adminState.inquiries.length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'PENDING',
                              '답변 대기',
                              adminState.inquiries
                                  .where((q) => !q.isAnswered)
                                  .length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'ANSWERED',
                              '답변 완료',
                              adminState.inquiries
                                  .where((q) => q.isAnswered)
                                  .length,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 문의사항 목록
          Expanded(
            child:
                adminState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : adminState.error != null
                    ? Center(
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
                            '오류: ${adminState.error}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                () =>
                                    ref
                                        .read(adminProvider.notifier)
                                        .loadInquiries(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                    : filteredInquiries.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filterStatus == 'ALL'
                                ? '등록된 문의사항이 없습니다.'
                                : _filterStatus == 'PENDING'
                                ? '답변 대기 중인 문의사항이 없습니다.'
                                : '답변 완료된 문의사항이 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(adminProvider.notifier).loadInquiries();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredInquiries.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final inquiry = filteredInquiries[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _showAnswerDialog(inquiry),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            inquiry.statusText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'answer':
                                                _showAnswerDialog(inquiry);
                                                break;
                                              case 'delete':
                                                _deleteInquiry(inquiry);
                                                break;
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                PopupMenuItem(
                                                  value: 'answer',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        inquiry.isAnswered
                                                            ? Icons.edit
                                                            : Icons.reply,
                                                        color: Colors.blue,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        inquiry.isAnswered
                                                            ? '답변 수정'
                                                            : '답변하기',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('삭제'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      inquiry.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      inquiry.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '문의자: ${inquiry.userNo ?? "알 수 없음"}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.schedule,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '등록일: ${inquiry.regdate ?? "알 수 없음"}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (inquiry.isAnswered &&
                                        inquiry.answer != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.shade200,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.reply,
                                                  size: 16,
                                                  color: Colors.green.shade700,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '답변 내용',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              inquiry.answer!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (inquiry.answerDate != null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                '답변일: ${inquiry.answerDate}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green.shade600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterStatus = value);
        }
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

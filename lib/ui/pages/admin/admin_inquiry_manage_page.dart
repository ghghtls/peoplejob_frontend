import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/ui/pages/admin/widgets/excel_download_button.dart';
import '../../../data/provider/admin_provider.dart';
import '../../../data/model/inquiry.dart';
import '../../widgets/app_bar.dart';

class AdminInquiryManagePage extends ConsumerStatefulWidget {
  const AdminInquiryManagePage({super.key});

  @override
  ConsumerState<AdminInquiryManagePage> createState() => _AdminInquiryManagePageState();
}

class _AdminInquiryManagePageState extends ConsumerState<AdminInquiryManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _red = Color(0xFFE5342F);
  static const Color _orange = Color(0xFFFF9500);

  bool _isDownloading = false;
  String _filterStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadInquiries());
  }

  Future<void> _downloadInquiriesExcel() async {
    setState(() => _isDownloading = true);
    try {
      final filePath = await ref.read(adminProvider.notifier).downloadInquiriesExcel();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Excel 파일이 다운로드되었습니다'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('다운로드 실패: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) { setState(() => _isDownloading = false); }
    }
  }

  void _showAnswerDialog(Inquiry inquiry) {
    final answerController = TextEditingController(text: inquiry.answer ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                Row(children: [
                  Icon(inquiry.isAnswered ? Icons.edit_rounded : Icons.reply_rounded,
                      color: inquiry.isAnswered ? _blue : _orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(inquiry.isAnswered ? '답변 수정' : '문의 답변',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _label))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (inquiry.isAnswered ? _green : _orange).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(inquiry.statusText,
                        style: TextStyle(fontSize: 12, color: inquiry.isAnswered ? _green : _orange,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 16),

                // 문의 내용
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _blue.withValues(alpha: 0.15)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('문의 제목', style: TextStyle(fontSize: 11, color: _blue.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(inquiry.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label)),
                    const SizedBox(height: 10),
                    Text('문의 내용', style: TextStyle(fontSize: 11, color: _blue.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text(inquiry.content, style: const TextStyle(fontSize: 13, height: 1.5)),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: _secondary),
                      const SizedBox(width: 4),
                      Text('문의자: ${inquiry.userNo ?? "알 수 없음"}',
                          style: const TextStyle(fontSize: 12, color: _secondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule_rounded, size: 13, color: _secondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text('등록일: ${inquiry.regdate ?? "알 수 없음"}',
                          style: const TextStyle(fontSize: 12, color: _secondary))),
                    ]),
                  ]),
                ),

                const SizedBox(height: 16),
                const Text('답변 내용', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _label)),
                const SizedBox(height: 8),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    hintText: '문의에 대한 답변을 입력해주세요...',
                    hintStyle: const TextStyle(color: _secondary, fontSize: 13),
                    filled: true, fillColor: const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _blue, width: 1.5)),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  maxLines: 5, minLines: 3,
                  style: const TextStyle(fontSize: 14, color: _label),
                ),

                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E5EA)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('취소', style: TextStyle(color: _secondary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (answerController.text.trim().isNotEmpty && inquiry.inquiryNo != null) {
                          final success = await ref.read(adminProvider.notifier)
                              .answerInquiry(inquiry.inquiryNo!, answerController.text.trim());
                          if (success && ctx.mounted) {
                            Navigator.pop(ctx);
                            messenger.showSnackBar(SnackBar(
                              content: Text(inquiry.isAnswered ? '답변이 수정되었습니다.' : '답변이 등록되었습니다.'),
                              backgroundColor: _green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ));
                          }
                        } else {
                          messenger.showSnackBar(SnackBar(
                            content: const Text('답변 내용을 입력해주세요.'),
                            backgroundColor: _orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(inquiry.isAnswered ? '답변 수정' : '답변 등록',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('문의 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('정말로 "${inquiry.title}" 문의를 삭제하시겠습니까?\n삭제된 문의는 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref.read(adminProvider.notifier).deleteInquiry(inquiry.inquiryNo!);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(
                  content: const Text('문의가 삭제되었습니다.'),
                  backgroundColor: _green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  List<Inquiry> _filtered(List<Inquiry> list) {
    if (_filterStatus == 'PENDING') { return list.where((q) => !q.isAnswered).toList(); }
    if (_filterStatus == 'ANSWERED') { return list.where((q) => q.isAnswered).toList(); }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final filtered = _filtered(adminState.inquiries);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '문의사항 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadInquiries(),
            icon: const Icon(Icons.refresh_rounded, size: 20, color: _secondary),
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
            // Excel + 필터
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  ExcelDownloadButton(
                    onPressed: _downloadInquiriesExcel,
                    label: '문의사항 Excel 다운로드',
                    icon: Icons.download_rounded,
                    isLoading: _isDownloading,
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _filterChip('ALL', '전체', adminState.inquiries.length),
                      const SizedBox(width: 8),
                      _filterChip('PENDING', '답변 대기', adminState.inquiries.where((q) => !q.isAnswered).length),
                      const SizedBox(width: 8),
                      _filterChip('ANSWERED', '답변 완료', adminState.inquiries.where((q) => q.isAnswered).length),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: adminState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : adminState.error != null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: _secondary),
                      const SizedBox(height: 12),
                      Text('오류: ${adminState.error}', style: const TextStyle(color: _secondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(adminProvider.notifier).loadInquiries(),
                        style: ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
                      ),
                    ]))
                  : filtered.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.help_outline_rounded, size: 36, color: _secondary)),
                      const SizedBox(height: 16),
                      Text(_filterStatus == 'PENDING' ? '답변 대기 중인 문의사항이 없습니다.'
                          : _filterStatus == 'ANSWERED' ? '답변 완료된 문의사항이 없습니다.'
                          : '등록된 문의사항이 없습니다.',
                          style: const TextStyle(fontSize: 15, color: _secondary)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminProvider.notifier).loadInquiries(),
                      color: _blue,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final inquiry = filtered[index];
                          final statusColor = inquiry.isAnswered ? _green : _orange;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent, borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showAnswerDialog(inquiry),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        child: Text(inquiry.statusText,
                                            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w700)),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        onSelected: (v) {
                                          if (v == 'answer') { _showAnswerDialog(inquiry); }
                                          if (v == 'delete') { _deleteInquiry(inquiry); }
                                        },
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        itemBuilder: (ctx) => [
                                          PopupMenuItem(value: 'answer',
                                              child: Row(children: [
                                                Icon(inquiry.isAnswered ? Icons.edit_rounded : Icons.reply_rounded,
                                                    color: _blue, size: 17),
                                                const SizedBox(width: 8),
                                                Text(inquiry.isAnswered ? '답변 수정' : '답변하기'),
                                              ])),
                                          const PopupMenuItem(value: 'delete',
                                              child: Row(children: [
                                                Icon(Icons.delete_outline_rounded, color: _red, size: 17),
                                                SizedBox(width: 8), Text('삭제'),
                                              ])),
                                        ],
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    Text(inquiry.title,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label)),
                                    const SizedBox(height: 6),
                                    Text(inquiry.content,
                                        style: const TextStyle(fontSize: 13, color: _secondary, height: 1.4),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      const Icon(Icons.person_outline_rounded, size: 13, color: _secondary),
                                      const SizedBox(width: 4),
                                      Text('문의자: ${inquiry.userNo ?? "알 수 없음"}',
                                          style: const TextStyle(fontSize: 12, color: _secondary)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.schedule_rounded, size: 13, color: _secondary),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text('등록일: ${inquiry.regdate ?? "알 수 없음"}',
                                          style: const TextStyle(fontSize: 12, color: _secondary))),
                                    ]),
                                    if (inquiry.isAnswered && inquiry.answer != null) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _green.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: _green.withValues(alpha: 0.2)),
                                        ),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Row(children: [
                                            const Icon(Icons.reply_rounded, size: 14, color: _green),
                                            const SizedBox(width: 4),
                                            const Text('답변 내용',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _green)),
                                          ]),
                                          const SizedBox(height: 6),
                                          Text(inquiry.answer!,
                                              style: const TextStyle(fontSize: 13, height: 1.4),
                                              maxLines: 3, overflow: TextOverflow.ellipsis),
                                          if (inquiry.answerDate != null) ...[
                                            const SizedBox(height: 4),
                                            Text('답변일: ${inquiry.answerDate}',
                                                style: const TextStyle(fontSize: 11, color: _green)),
                                          ],
                                        ]),
                                      ),
                                    ],
                                  ]),
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

  Widget _filterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
        ),
        child: Text('$label ($count)',
            style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : _secondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}

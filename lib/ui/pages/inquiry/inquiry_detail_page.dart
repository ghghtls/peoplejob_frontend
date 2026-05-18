import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/inquiry_provider.dart';
import '../../../data/model/inquiry.dart';
import 'inquiry_form_page.dart';
import '../../widgets/app_bar.dart';

class InquiryDetailPage extends ConsumerStatefulWidget {
  final int inquiryNo;
  const InquiryDetailPage({super.key, required this.inquiryNo});

  @override
  ConsumerState<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends ConsumerState<InquiryDetailPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    await ref.read(inquiryProvider.notifier).loadInquiryDetail(widget.inquiryNo);
  }

  Future<void> _navigateToEdit(Inquiry inquiry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => InquiryFormPage(inquiry: inquiry)),
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _showDeleteDialog(Inquiry inquiry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('문의 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('정말로 이 문의를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteInquiry(inquiry);
  }

  Future<void> _deleteInquiry(Inquiry inquiry) async {
    final success = await ref.read(inquiryProvider.notifier).deleteInquiry(inquiry.inquiryNo!);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('문의가 삭제되었습니다.'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      final msg = ref.read(inquiryProvider).errorMessage ?? '문의 삭제에 실패했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: _red,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inquiryProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '문의 상세'),
      body: Column(
        children: [
            Expanded(
              child: Builder(builder: (context) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
                }

                if (state.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: _red),
                        const SizedBox(height: 12),
                        Text(state.errorMessage!, style: const TextStyle(color: _secondary), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            ref.read(inquiryProvider.notifier).clearError();
                            _loadDetail();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: _blue, side: const BorderSide(color: _blue, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                final inquiry = state.selectedInquiry;
                if (inquiry == null) {
                  return const Center(child: Text('문의를 찾을 수 없습니다.', style: TextStyle(color: _secondary)));
                }

                final answered = inquiry.isAnswered;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상태 배지
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (answered ? _green : _orange).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(answered ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                color: answered ? _green : _orange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inquiry.statusText,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                          color: answered ? _green : _orange)),
                                  if (inquiry.regdate != null)
                                    Text('작성일: ${inquiry.regdate}',
                                        style: const TextStyle(fontSize: 12, color: _secondary)),
                                  if (inquiry.answerDate != null)
                                    Text('답변일: ${inquiry.answerDate}',
                                        style: const TextStyle(fontSize: 12, color: _secondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 제목
                      _section('제목'),
                      const SizedBox(height: 8),
                      _contentBox(inquiry.title, fontSize: 16, fontWeight: FontWeight.w600),
                      const SizedBox(height: 16),

                      // 내용
                      _section('문의 내용'),
                      const SizedBox(height: 8),
                      _contentBox(inquiry.content),
                      const SizedBox(height: 16),

                      // 답변
                      if (inquiry.answer != null && inquiry.answer!.isNotEmpty) ...[
                        _section('답변', color: _green),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(inquiry.answer!,
                              style: const TextStyle(fontSize: 15, height: 1.6, color: _label, letterSpacing: -0.2)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 액션 버튼 (대기 중만)
                      if (!inquiry.isAnswered) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _navigateToEdit(inquiry),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _blue,
                                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('수정', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showDeleteDialog(inquiry),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _red,
                                  side: BorderSide(color: _red.withValues(alpha: 0.4)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('삭제', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
    );
  }

  Widget _section(String text, {Color? color}) {
    return Text(text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: color ?? _secondary, letterSpacing: -0.2));
  }

  Widget _contentBox(String text, {double fontSize = 15, FontWeight fontWeight = FontWeight.w400}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Text(text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, height: 1.6, color: _label, letterSpacing: -0.2)),
    );
  }
}

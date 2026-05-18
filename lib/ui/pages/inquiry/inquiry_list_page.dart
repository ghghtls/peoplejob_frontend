import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_detail_page.dart';
import '../../../data/provider/inquiry_provider.dart';
import 'inquiry_form_page.dart';
import '../../widgets/app_bar.dart';

class InquiryListPage extends ConsumerStatefulWidget {
  const InquiryListPage({super.key});

  @override
  ConsumerState<InquiryListPage> createState() => _InquiryListPageState();
}

class _InquiryListPageState extends ConsumerState<InquiryListPage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInquiries());
  }

  Future<void> _loadInquiries() async {
    await ref.read(inquiryProvider.notifier).loadMyInquiries();
  }

  Future<void> _navigateToForm([inquiry]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => InquiryFormPage(inquiry: inquiry)),
    );
    if (result == true) await _loadInquiries();
  }

  Future<void> _navigateToDetail(int inquiryNo) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => InquiryDetailPage(inquiryNo: inquiryNo)),
    );
    if (result == true) await _loadInquiries();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inquiryProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '문의 내역',
        actions: [
          IconButton(
            onPressed: _loadInquiries,
            icon: const Icon(Icons.refresh_rounded, color: _secondary),
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
            // 본문
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
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.error_outline_rounded, size: 36, color: _red),
                        ),
                        const SizedBox(height: 16),
                        Text(state.errorMessage!,
                            style: const TextStyle(fontSize: 15, color: _secondary), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            ref.read(inquiryProvider.notifier).clearError();
                            _loadInquiries();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _blue,
                            side: const BorderSide(color: _blue, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('다시 시도', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                }

                if (!state.hasInquiries) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.question_answer_rounded, size: 36, color: _secondary),
                        ),
                        const SizedBox(height: 16),
                        const Text('아직 문의 내역이 없습니다',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
                        const SizedBox(height: 6),
                        const Text('궁금한 점이 있으시면 문의해주세요',
                            style: TextStyle(fontSize: 14, color: _secondary)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _navigateToForm(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('문의 작성하기',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadInquiries,
                  color: _blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: state.inquiries.length,
                    itemBuilder: (context, i) {
                      final inquiry = state.inquiries[i];
                      final answered = inquiry.isAnswered;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _navigateToDetail(inquiry.inquiryNo!),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: (answered ? _green : _orange).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      answered ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                      color: answered ? _green : _orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(inquiry.title,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.3),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 3),
                                        Text(inquiry.statusText,
                                            style: TextStyle(fontSize: 12, color: answered ? _green : _orange, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFE5E5EA), size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: _blue,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

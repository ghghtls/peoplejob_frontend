import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_detail_page.dart';
import '../../../data/provider/inquiry_provider.dart';
import 'inquiry_form_page.dart';
import 'widgets/inquiry_list_view.dart';
import 'widgets/empty_inquiry_message.dart';

class InquiryListPage extends ConsumerStatefulWidget {
  const InquiryListPage({super.key});

  @override
  ConsumerState<InquiryListPage> createState() => _InquiryListPageState();
}

class _InquiryListPageState extends ConsumerState<InquiryListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInquiries();
    });
  }

  Future<void> _loadInquiries() async {
    await ref.read(inquiryProvider.notifier).loadMyInquiries();
  }

  Future<void> _navigateToInquiryForm([inquiry]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryFormPage(inquiry: inquiry),
      ),
    );

    // 등록/수정 성공시 목록 새로고침
    if (result == true) {
      await _loadInquiries();
    }
  }

  Future<void> _navigateToInquiryDetail(int inquiryNo) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryDetailPage(inquiryNo: inquiryNo),
      ),
    );

    // 수정/삭제 발생시 목록 새로고침
    if (result == true) {
      await _loadInquiries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inquiryState = ref.watch(inquiryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInquiries,
          ),
        ],
      ),
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
                      _loadInquiries();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (!inquiryState.hasInquiries) {
            return const EmptyInquiryMessage();
          }

          return RefreshIndicator(
            onRefresh: _loadInquiries,
            child: InquiryListView(
              inquiries: inquiryState.inquiries,
              onInquiryTap: _navigateToInquiryDetail,
              onEditTap: _navigateToInquiryForm,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToInquiryForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

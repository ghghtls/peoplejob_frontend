import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';
import 'widgets/excel_download_button.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  Map<String, bool> _downloadStates = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadDashboard());
  }

  Future<void> _downloadExcel(
    String type,
    String label,
    Future<String?> Function() downloadFunction,
  ) async {
    setState(() => _downloadStates[type] = true);
    try {
      final filePath = await downloadFunction();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label Excel 파일이 다운로드되었습니다'),
            action: SnackBarAction(label: '확인', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label 다운로드 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _downloadStates[type] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('관리자 대시보드')),
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
                              ref.read(adminProvider.notifier).loadDashboard(),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '관리 요약',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        AdminSummaryCard(
                          title: '총 회원 수',
                          value: '${adminState.dashboard['totalUsers'] ?? 0}명',
                        ),
                        AdminSummaryCard(
                          title: '총 채용공고',
                          value: '${adminState.dashboard['totalJobs'] ?? 0}건',
                        ),
                        AdminSummaryCard(
                          title: '결제 내역',
                          value:
                              '${adminState.dashboard['totalPayments'] ?? 0}건',
                        ),
                        AdminSummaryCard(
                          title: '문의사항',
                          value:
                              '${adminState.dashboard['totalInquiries'] ?? 0}건',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Excel 다운로드',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          ExcelDownloadButton(
                            onPressed:
                                () => _downloadExcel(
                                  'users',
                                  '회원 목록',
                                  () =>
                                      ref
                                          .read(adminProvider.notifier)
                                          .downloadUsersExcel(),
                                ),
                            label: '회원 목록',
                            isLoading: _downloadStates['users'] ?? false,
                          ),
                          ExcelDownloadButton(
                            onPressed:
                                () => _downloadExcel(
                                  'jobs',
                                  '채용공고',
                                  () =>
                                      ref
                                          .read(adminProvider.notifier)
                                          .downloadJobsExcel(),
                                ),
                            label: '채용공고',
                            isLoading: _downloadStates['jobs'] ?? false,
                          ),
                          ExcelDownloadButton(
                            onPressed:
                                () => _downloadExcel(
                                  'inquiries',
                                  '문의사항',
                                  () =>
                                      ref
                                          .read(adminProvider.notifier)
                                          .downloadInquiriesExcel(),
                                ),
                            label: '문의사항',
                            isLoading: _downloadStates['inquiries'] ?? false,
                          ),
                          ExcelDownloadButton(
                            onPressed:
                                () => _downloadExcel(
                                  'payments',
                                  '결제 내역',
                                  () =>
                                      ref
                                          .read(adminProvider.notifier)
                                          .downloadPaymentsExcel(),
                                ),
                            label: '결제 내역',
                            isLoading: _downloadStates['payments'] ?? false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class AdminSummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const AdminSummaryCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

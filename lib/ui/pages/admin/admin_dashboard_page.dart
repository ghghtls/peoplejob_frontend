import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';
import '../../widgets/app_bar.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _red = Color(0xFFE5342F);

  Map<String, bool> _downloadStates = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadDashboard());
  }

  Future<void> _downloadExcel(String type, String label, Future<String?> Function() fn) async {
    setState(() => _downloadStates[type] = true);
    try {
      final filePath = await fn();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$label Excel 파일이 다운로드되었습니다'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$label 다운로드 실패: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) { setState(() => _downloadStates[type] = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '관리자 대시보드',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadDashboard(),
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
            Expanded(
              child: adminState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : adminState.error != null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: _secondary),
                      const SizedBox(height: 16),
                      Text('오류: ${adminState.error}', style: const TextStyle(color: _secondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(adminProvider.notifier).loadDashboard(),
                        style: ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
                      ),
                    ]))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('관리 요약',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            children: [
                              _summaryCard('총 회원 수', '${adminState.dashboard['totalUsers'] ?? 0}명',
                                  Icons.people_rounded, _blue),
                              _summaryCard('총 채용공고', '${adminState.dashboard['totalJobs'] ?? 0}건',
                                  Icons.work_rounded, _green),
                              _summaryCard('결제 내역', '${adminState.dashboard['totalPayments'] ?? 0}건',
                                  Icons.payment_rounded, const Color(0xFFFF9500)),
                              _summaryCard('문의사항', '${adminState.dashboard['totalInquiries'] ?? 0}건',
                                  Icons.help_rounded, const Color(0xFFAF52DE)),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Text('Excel 다운로드',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              children: [
                                _excelRow('회원 목록', Icons.people_rounded, _blue, () => _downloadExcel(
                                    'users', '회원 목록', () => ref.read(adminProvider.notifier).downloadUsersExcel()),
                                    _downloadStates['users'] ?? false, false),
                                const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                                _excelRow('채용공고', Icons.work_rounded, _green, () => _downloadExcel(
                                    'jobs', '채용공고', () => ref.read(adminProvider.notifier).downloadJobsExcel()),
                                    _downloadStates['jobs'] ?? false, false),
                                const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                                _excelRow('문의사항', Icons.help_rounded, const Color(0xFFAF52DE), () => _downloadExcel(
                                    'inquiries', '문의사항', () => ref.read(adminProvider.notifier).downloadInquiriesExcel()),
                                    _downloadStates['inquiries'] ?? false, false),
                                const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                                _excelRow('결제 내역', Icons.payment_rounded, const Color(0xFFFF9500), () => _downloadExcel(
                                    'payments', '결제 내역', () => ref.read(adminProvider.notifier).downloadPaymentsExcel()),
                                    _downloadStates['payments'] ?? false, true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: _secondary)),
        ],
      ),
    );
  }

  Widget _excelRow(String label, IconData icon, Color color, VoidCallback onTap, bool isLoading, bool isLast) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _label))),
            if (isLoading)
              const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: _blue, strokeWidth: 2))
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_rounded, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text('다운로드', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

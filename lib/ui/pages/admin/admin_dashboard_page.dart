import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadDashboard());
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
                      '빠른 액션',
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
                        children: [
                          _buildActionCard(
                            '문의사항 관리',
                            Icons.help_outline,
                            Colors.orange,
                            () =>
                                Navigator.pushNamed(context, '/admin/inquiry'),
                          ),
                          _buildActionCard(
                            '회원 관리',
                            Icons.people_outline,
                            Colors.blue,
                            () => Navigator.pushNamed(context, '/admin/user'),
                          ),
                          _buildActionCard(
                            '공지사항 관리',
                            Icons.announcement_outlined,
                            Colors.green,
                            () => Navigator.pushNamed(context, '/admin/notice'),
                          ),
                          _buildActionCard(
                            '결제 내역',
                            Icons.payment_outlined,
                            Colors.purple,
                            () =>
                                Navigator.pushNamed(context, '/admin/payment'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

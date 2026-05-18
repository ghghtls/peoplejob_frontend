import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/job_service.dart';
import '../../widgets/app_bar.dart';

class PaymentTargetSelectionPage extends StatefulWidget {
  const PaymentTargetSelectionPage({super.key});

  @override
  State<PaymentTargetSelectionPage> createState() => _PaymentTargetSelectionPageState();
}

class _PaymentTargetSelectionPageState extends State<PaymentTargetSelectionPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);

  final JobService _jobService = JobService();
  final _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final userNoStr = await _storage.read(key: 'userNo');
      final userNo = int.tryParse(userNoStr ?? '');
      if (userNo == null) throw Exception('로그인이 필요합니다.');

      final result = await _jobService.getUserJobsByStatus(userNo, null);
      final list = result['jobs'] as List? ?? [];
      setState(() {
        _jobs = list
            .map((e) => (e as Map).cast<String, dynamic>())
            .where((j) {
              final status = j['status'] as String? ?? '';
              return status != 'EXPIRED' && status != 'REJECTED';
            })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _selectJob(Map<String, dynamic> job) {
    Navigator.pushNamed(
      context,
      '/payment/product',
      arguments: {
        'jobNo': job['jobNo'],
        'jobTitle': job['title'] ?? '제목 없음',
        'company': job['company'] ?? '',
        'status': job['status'] ?? '',
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PUBLISHED': return '게시 중';
      case 'DRAFT': return '임시저장';
      case 'PENDING': return '승인대기';
      case 'SUSPENDED': return '중단';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED': return _green;
      case 'DRAFT': return _secondary;
      case 'PENDING': return _orange;
      default: return _secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '광고할 채용공고 선택'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text('광고를 진행할 채용공고를 선택해주세요',
                style: TextStyle(fontSize: 13, color: _secondary.withValues(alpha: 0.8))),
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('공고를 불러올 수 없습니다', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadJobs,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('다시 시도'),
              style: OutlinedButton.styleFrom(foregroundColor: _blue, side: const BorderSide(color: _blue)),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('등록된 채용공고가 없습니다', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text('채용공고를 먼저 등록해주세요', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          final status = job['status'] as String? ?? '';
          final statusColor = _statusColor(status);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _selectJob(job),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.work_outline_rounded, size: 22, color: _blue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job['title'] as String? ?? '제목 없음',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(_statusLabel(status),
                                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                                ),
                                if (job['location'] != null) ...[
                                  const SizedBox(width: 6),
                                  Text(job['location'] as String, style: const TextStyle(fontSize: 12, color: _secondary)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(10)),
                        child: const Text('선택', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

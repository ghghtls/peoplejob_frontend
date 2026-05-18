import 'package:flutter/material.dart';
import '../../../services/job_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_bar.dart';
import 'job_applications_page.dart';

class CompanyApplicantsPage extends StatefulWidget {
  const CompanyApplicantsPage({super.key});

  @override
  State<CompanyApplicantsPage> createState() => _CompanyApplicantsPageState();
}

class _CompanyApplicantsPageState extends State<CompanyApplicantsPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);

  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();

  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) throw Exception('로그인이 필요합니다.');
      final result = await _jobService.getUserJobsByStatus(userNo, null);
      setState(() {
        _jobs = result['success'] == true ? (result['jobs'] as List? ?? []) : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'DRAFT': return '임시저장';
      case 'PUBLISHED': return '게시중';
      case 'EXPIRED': return '마감';
      case 'SUSPENDED': return '게시중단';
      default: return status ?? '';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'PUBLISHED': return const Color(0xFF34C759);
      case 'EXPIRED': return const Color(0xFFE5342F);
      case 'DRAFT': return _secondary;
      default: return _secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('지원자 관리',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                  const HomeButton(),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _jobs.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _loadJobs,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _jobs.length,
                            itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('등록된 채용공고가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('채용공고를 등록하면 지원자를 확인할 수 있습니다',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final jobNo = job['jobNo'];
    final status = job['status'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (jobNo != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobApplicationsPage(
                    jobOpeningNo: jobNo is int ? jobNo : int.tryParse(jobNo.toString()) ?? 0,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? '',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status)),
                            ),
                          ),
                          if (job['deadline'] != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '마감: ${job['deadline']}',
                              style: TextStyle(fontSize: 12, color: _secondary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Icon(Icons.people_rounded, color: _blue, size: 20),
                    const SizedBox(height: 2),
                    const Text('지원자 보기', style: TextStyle(fontSize: 10, color: _blue, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

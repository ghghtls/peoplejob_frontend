import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/apply_service.dart';
import '../../../services/job_service.dart';
import '../../widgets/app_bar.dart';

class JobApplicationsPage extends StatefulWidget {
  final int jobOpeningNo;
  const JobApplicationsPage({super.key, required this.jobOpeningNo});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final ApplyService _applyService = ApplyService();
  final JobService _jobService = JobService();

  List<dynamic> _applications = [];
  Map<String, dynamic>? _jobDetail;
  bool _isLoading = true;
  bool _isLoadingJob = true;

  @override
  void initState() {
    super.initState();
    _loadJobDetail();
    _loadApplications();
  }

  Future<void> _loadJobDetail() async {
    try {
      final jobDetail = await _jobService.getJobDetail(widget.jobOpeningNo);
      if (mounted) setState(() { _jobDetail = jobDetail; _isLoadingJob = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingJob = false);
    }
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final applications = await _applyService.getJobApplications(widget.jobOpeningNo);
      if (mounted) setState(() { _applications = applications; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: _red,
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  int _getRecentApplications(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _applications.where((app) {
      try { return DateTime.parse(app['regdate']).isAfter(cutoff); }
      catch (_) { return false; }
    }).length;
  }

  void _showStats() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('지원 통계', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow(Icons.people_rounded, '총 지원자', '${_applications.length}명'),
            _statRow(Icons.today_rounded, '최근 7일', '${_getRecentApplications(7)}명'),
            _statRow(Icons.date_range_rounded, '최근 30일', '${_getRecentApplications(30)}명'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인', style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: _blue),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: _secondary))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _label)),
      ]),
    );
  }

  void _contactApplicant(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('지원자 연락', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${application['applicantName']}님에게 연락하시겠습니까?'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이메일: ${application['applicantEmail'] ?? '정보 없음'}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('연락처: ${application['applicantPhone'] ?? '정보 없음'}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${application['applicantName']}님에게 연락을 보냈습니다'),
                backgroundColor: _green, behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: const Text('연락하기', style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '지원자 관리',
        actions: [
          IconButton(
            onPressed: _showStats,
            icon: const Icon(Icons.analytics_outlined, color: _blue, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: _loadApplications,
            icon: const Icon(Icons.refresh_rounded, color: _secondary, size: 20),
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

            // 채용공고 정보 배너
            if (!_isLoadingJob && _jobDetail != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.work_rounded, color: _blue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_jobDetail!['title'] ?? '채용공고',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${_jobDetail!['jobType'] ?? ''} • ${_jobDetail!['location'] ?? ''}',
                                style: const TextStyle(fontSize: 12, color: _secondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: _blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_applications.length}명',
                            style: const TextStyle(fontSize: 13, color: _blue, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),

            // 지원자 목록
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : _applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.people_outline_rounded, size: 36, color: _secondary),
                              ),
                              const SizedBox(height: 16),
                              const Text('아직 지원자가 없습니다',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
                              const SizedBox(height: 6),
                              const Text('채용공고를 홍보하여 지원자를 모집해보세요',
                                  style: TextStyle(fontSize: 14, color: _secondary)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadApplications,
                          color: _blue,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: _applications.length,
                            itemBuilder: (context, i) {
                              final app = _applications[i];
                              final nameText = app['applicantName'] ?? '지원자';
                              final initial = nameText.isNotEmpty ? nameText.substring(0, 1).toUpperCase() : 'U';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44, height: 44,
                                            decoration: BoxDecoration(
                                              color: _blue.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(initial,
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _blue)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(nameText,
                                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.3)),
                                                const SizedBox(height: 2),
                                                Text(app['resumeTitle'] ?? '이력서 제목 없음',
                                                    style: const TextStyle(fontSize: 13, color: _secondary),
                                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _green.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text('신규', style: TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _infoRow(Icons.work_outline_rounded, '희망직종', app['hopeJobtype'] ?? '정보 없음'),
                                      _infoRow(Icons.location_on_outlined, '희망지역', app['hopeLocation'] ?? '정보 없음'),
                                      _infoRow(Icons.school_outlined, '학력', app['education'] ?? '정보 없음'),
                                      _infoRow(Icons.business_center_outlined, '경력', app['career'] ?? '정보 없음'),
                                      _infoRow(Icons.calendar_today_rounded, '지원일시', _formatDate(app['regdate'])),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => Navigator.pushNamed(context, '/resume-detail', arguments: app['resumeNo']),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: _blue,
                                                side: const BorderSide(color: Color(0xFFE5E5EA)),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(vertical: 11),
                                              ),
                                              child: const Text('이력서 보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _contactApplicant(app),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _blue,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(vertical: 11),
                                              ),
                                              child: const Text('연락하기',
                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _secondary),
          const SizedBox(width: 8),
          SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 12, color: _secondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: _label, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

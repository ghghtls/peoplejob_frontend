import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/apply_service.dart';
import '../../../services/job_service.dart';

class JobApplicationsPage extends StatefulWidget {
  final int jobOpeningNo;

  const JobApplicationsPage({super.key, required this.jobOpeningNo});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
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
    setState(() {
      _isLoadingJob = true;
    });

    try {
      final jobDetail = await _jobService.getJobDetail(widget.jobOpeningNo);
      setState(() {
        _jobDetail = jobDetail;
        _isLoadingJob = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingJob = false;
      });
    }
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final applications = await _applyService.getJobApplications(
        widget.jobOpeningNo,
      );
      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy.MM.dd HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _viewResume(int resumeNo, String applicantName) {
    Navigator.pushNamed(context, '/resume-detail', arguments: resumeNo);
  }

  void _contactApplicant(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.email, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text('지원자 연락'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${application['applicantName']}님에게 연락하시겠습니까?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이메일: ${application['applicantEmail'] ?? '이메일 정보 없음'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '연락처: ${application['applicantPhone'] ?? '연락처 정보 없음'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 실제 이메일 발송 기능 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${application['applicantName']}님에게 연락을 보냈습니다',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('연락하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showApplicationStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text('지원 통계'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem(
                '총 지원자 수',
                '${_applications.length}명',
                Icons.people,
              ),
              _buildStatItem(
                '최근 7일 지원',
                '${_getRecentApplications(7)}명',
                Icons.today,
              ),
              _buildStatItem(
                '최근 30일 지원',
                '${_getRecentApplications(30)}명',
                Icons.date_range,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  int _getRecentApplications(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _applications.where((app) {
      try {
        final appDate = DateTime.parse(app['regdate']);
        return appDate.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).length;
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지원자 관리'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showApplicationStats,
            tooltip: '통계',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 채용공고 정보
          if (!_isLoadingJob && _jobDetail != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _jobDetail!['title'] ?? '채용공고 제목',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_jobDetail!['jobtype']} • ${_jobDetail!['location']}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '총 ${_applications.length}명 지원',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 지원자 목록
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _applications.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 지원자가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '채용공고를 홍보하여 더 많은 지원자를 모집해보세요',
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadApplications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _applications.length,
                        itemBuilder: (context, index) {
                          final application = _applications[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 지원자 정보 헤더
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.green[100],
                                        child: Text(
                                          (application['applicantName'] ?? 'U')
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              application['applicantName'] ??
                                                  '지원자',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              application['resumeTitle'] ??
                                                  '이력서 제목 없음',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '신규',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // 지원자 세부 정보
                                  _buildInfoRow(
                                    Icons.work,
                                    '희망직종',
                                    application['hopeJobtype'] ?? '정보 없음',
                                  ),
                                  _buildInfoRow(
                                    Icons.location_on,
                                    '희망지역',
                                    application['hopeLocation'] ?? '정보 없음',
                                  ),
                                  _buildInfoRow(
                                    Icons.school,
                                    '학력',
                                    application['education'] ?? '정보 없음',
                                  ),
                                  _buildInfoRow(
                                    Icons.business_center,
                                    '경력',
                                    application['career'] ?? '정보 없음',
                                  ),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    '지원일시',
                                    _formatDate(application['regdate']),
                                  ),

                                  const SizedBox(height: 16),

                                  // 액션 버튼들
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed:
                                              () => _viewResume(
                                                application['resumeNo'],
                                                application['applicantName'] ??
                                                    '지원자',
                                              ),
                                          icon: const Icon(
                                            Icons.description,
                                            size: 16,
                                          ),
                                          label: const Text('이력서 보기'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.green[600],
                                            side: BorderSide(
                                              color: Colors.green[600]!,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              () => _contactApplicant(
                                                application,
                                              ),
                                          icon: const Icon(
                                            Icons.email,
                                            size: 16,
                                          ),
                                          label: const Text('연락하기'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[600],
                                            foregroundColor: Colors.white,
                                          ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';
import '../../../services/auth_service.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _jobDetail;
  bool _isLoading = true;
  bool _isScraped = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadJobDetail();
    _loadUserRole();
  }

  Future<void> _loadJobDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobDetail = await _jobService.getJobDetail(widget.jobId);
      setState(() {
        _jobDetail = jobDetail;
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

  Future<void> _loadUserRole() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _userRole = userInfo['role'];
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  bool _isDeadlinePassed(String? deadlineStr) {
    if (deadlineStr == null) return false;
    try {
      final deadline = DateTime.parse(deadlineStr);
      return deadline.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  int _getDaysRemaining(String? deadlineStr) {
    if (deadlineStr == null) return 0;
    try {
      final deadline = DateTime.parse(deadlineStr);
      final now = DateTime.now();
      return deadline.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  void _toggleScrap() {
    setState(() {
      _isScraped = !_isScraped;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isScraped ? '스크랩에 추가되었습니다' : '스크랩에서 제거되었습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showApplyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('지원하기'),
          content: const Text('이 채용공고에 지원하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyToJob();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('지원하기'),
            ),
          ],
        );
      },
    );
  }

  void _applyToJob() {
    // TODO: 실제 지원 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('지원이 완료되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editJob() {
    Navigator.pushNamed(context, '/job-edit', arguments: widget.jobId);
  }

  void _deleteJob() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('채용공고 삭제'),
          content: const Text('정말로 이 채용공고를 삭제하시겠습니까?\n삭제된 공고는 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _jobService.deleteJob(widget.jobId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('채용공고가 삭제되었습니다')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('채용공고'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_jobDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('채용공고'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('채용공고를 찾을 수 없습니다')),
      );
    }

    final isExpired = _isDeadlinePassed(_jobDetail!['deadline']);
    final daysRemaining = _getDaysRemaining(_jobDetail!['deadline']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('채용공고'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_userRole == 'company') ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: _editJob),
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteJob),
          ] else ...[
            IconButton(
              icon: Icon(_isScraped ? Icons.bookmark : Icons.bookmark_border),
              onPressed: _toggleScrap,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _jobDetail!['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isExpired) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            daysRemaining <= 3
                                ? Colors.red[100]
                                : Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        daysRemaining <= 0 ? '오늘 마감' : 'D-$daysRemaining',
                        style: TextStyle(
                          color:
                              daysRemaining <= 3
                                  ? Colors.red[700]
                                  : Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '모집 마감',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 상세 정보
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('기본 정보', [
                    _buildInfoRow(Icons.work, '고용형태', _jobDetail!['jobtype']),
                    _buildInfoRow(
                      Icons.location_on,
                      '근무지역',
                      _jobDetail!['location'],
                    ),
                    _buildInfoRow(
                      Icons.school,
                      '학력요건',
                      _jobDetail!['education'],
                    ),
                    _buildInfoRow(
                      Icons.timeline,
                      '경력요건',
                      _jobDetail!['career'],
                    ),
                    if (_jobDetail!['salary'] != null &&
                        _jobDetail!['salary'].toString().isNotEmpty)
                      _buildInfoRow(
                        Icons.attach_money,
                        '급여조건',
                        _jobDetail!['salary'],
                      ),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('모집 기간', [
                    _buildInfoRow(
                      Icons.calendar_today,
                      '등록일',
                      _formatDate(_jobDetail!['regdate']),
                    ),
                    _buildInfoRow(
                      Icons.event,
                      '마감일',
                      _formatDate(_jobDetail!['deadline']),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildContentSection('상세 내용', _jobDetail!['content']),
                  if (_jobDetail!['originalFilename'] != null) ...[
                    const SizedBox(height: 24),
                    _buildAttachmentSection(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _userRole != 'company' && !isExpired
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showApplyDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '지원하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content ?? '상세 내용이 없습니다.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '첨부파일',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_file, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _jobDetail!['originalFilename'] ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 파일 다운로드 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('파일 다운로드 기능은 준비 중입니다')),
                  );
                },
                child: const Text('다운로드'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

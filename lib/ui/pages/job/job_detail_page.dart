import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/apply_service.dart';
import '../../../services/scrap_service.dart';
import '../../widgets/apply_dialog.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  final ApplyService _applyService = ApplyService();
  final ScrapService _scrapService = ScrapService();
  Map<String, dynamic>? _jobDetail;
  bool _isLoading = true;
  bool _isScraped = false;
  bool _hasApplied = false;
  String? _userRole;
  String? _userType;

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

      // 개인회원인 경우 지원/스크랩 여부 확인
      if (_userType == 'user') {
        _checkApplicationStatus();
        _checkScrapStatus();
      }
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
      _userType = userInfo['userType'];
    });
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final hasApplied = await _applyService.hasAppliedToJob(widget.jobId);
      setState(() {
        _hasApplied = hasApplied;
      });
    } catch (e) {
      // 에러 시 기본값 유지
    }
  }

  Future<void> _checkScrapStatus() async {
    try {
      final isScraped = await _scrapService.isScraped(widget.jobId);
      setState(() {
        _isScraped = isScraped;
      });
    } catch (e) {
      // 에러 시 기본값 유지
    }
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

  Future<void> _toggleScrap() async {
    try {
      if (_isScraped) {
        await _scrapService.removeScrap(widget.jobId);
        setState(() {
          _isScraped = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스크랩에서 제거되었습니다'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await _scrapService.addScrap(widget.jobId);
        setState(() {
          _isScraped = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스크랩에 추가되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showApplyDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ApplyDialog(
          jobOpeningNo: widget.jobId,
          jobTitle: _jobDetail!['title'] ?? '채용공고',
        );
      },
    );

    // 지원 성공 시 상태 업데이트
    if (result == true) {
      setState(() {
        _hasApplied = true;
      });
    }
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

  void _viewApplications() {
    Navigator.pushNamed(context, '/job-applications', arguments: widget.jobId);
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
          if (_userType == 'company') ...[
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: _viewApplications,
              tooltip: '지원자 목록',
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: _editJob),
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteJob),
          ] else ...[
            IconButton(
              icon: Icon(
                _isScraped ? Icons.bookmark : Icons.bookmark_border,
                color: _isScraped ? Colors.orange : Colors.white,
              ),
              onPressed: _toggleScrap,
              tooltip: _isScraped ? '스크랩 해제' : '스크랩 추가',
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // 마감일 상태
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

                      // 지원 상태 표시
                      if (_userType == 'user' && _hasApplied) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '지원완료',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 스크랩 상태 표시
                      if (_userType == 'user' && _isScraped) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark,
                                size: 16,
                                color: Colors.purple[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '스크랩됨',
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
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
          _userType == 'user' && !isExpired
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
                  child: Row(
                    children: [
                      // 스크랩 버튼
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: _toggleScrap,
                          icon: Icon(
                            _isScraped ? Icons.bookmark : Icons.bookmark_border,
                            color:
                                _isScraped
                                    ? Colors.orange[600]
                                    : Colors.grey[600],
                          ),
                          label: Text(
                            _isScraped ? '스크랩됨' : '스크랩',
                            style: TextStyle(
                              color:
                                  _isScraped
                                      ? Colors.orange[600]
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  _isScraped
                                      ? Colors.orange[600]!
                                      : Colors.grey[400]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 지원하기 버튼
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _hasApplied ? null : _showApplyDialog,
                          icon: Icon(_hasApplied ? Icons.check : Icons.send),
                          label: Text(
                            _hasApplied ? '지원완료' : '지원하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _hasApplied
                                    ? Colors.grey[400]
                                    : Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ),
                    ],
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

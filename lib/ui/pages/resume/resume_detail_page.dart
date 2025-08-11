import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/resume_service.dart';
import '../../../services/auth_service.dart';

class ResumeDetailPage extends StatefulWidget {
  final int resumeId;

  const ResumeDetailPage({super.key, required this.resumeId});

  @override
  State<ResumeDetailPage> createState() => _ResumeDetailPageState();
}

class _ResumeDetailPageState extends State<ResumeDetailPage> {
  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _resumeDetail;
  bool _isLoading = true;
  String? _userType;
  int? _currentUserNo;
  bool _isMyResume = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _userType = userInfo['userType'];
      _currentUserNo = int.tryParse(
        userInfo['userid'] ?? '0',
      ); // TODO: userNo 필드로 변경 필요
    });
    _loadResumeDetail();
  }

  Future<void> _loadResumeDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final resumeDetail = await _resumeService.getResumeDetail(
        widget.resumeId,
      );
      setState(() {
        _resumeDetail = resumeDetail;
        _isMyResume = _currentUserNo == resumeDetail['userNo'];
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
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _editResume() {
    Navigator.pushNamed(context, '/resume-edit', arguments: widget.resumeId);
  }

  void _deleteResume() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이력서 삭제'),
          content: const Text('정말로 이 이력서를 삭제하시겠습니까?\n삭제된 이력서는 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _resumeService.deleteResume(widget.resumeId);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('이력서가 삭제되었습니다')));
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

  void _sendScoutOffer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('스카우트 제안'),
          content: const Text('이 지원자에게 스카우트 제안을 보내시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 실제 스카우트 제안 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('스카우트 제안이 전송되었습니다')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('제안하기'),
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
          title: const Text('이력서'),
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_resumeDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('이력서'),
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('이력서를 찾을 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('이력서'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isMyResume) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editResume,
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteResume,
              tooltip: '삭제',
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
                  colors: [Colors.green[50]!, Colors.green[100]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 이미지와 제목
                  Row(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child:
                            _resumeDetail!['imagePath'] != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    _resumeDetail!['imagePath'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.green[700],
                                      );
                                    },
                                  ),
                                )
                                : Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.green[700],
                                ),
                      ),
                      const SizedBox(width: 16),
                      // 제목과 기본 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _resumeDetail!['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '등록일: ${_formatDate(_resumeDetail!['regdate'])}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  _buildInfoSection('희망 조건', [
                    _buildInfoRow(
                      Icons.work,
                      '희망직종',
                      _resumeDetail!['hopeJobtype'],
                    ),
                    _buildInfoRow(
                      Icons.location_on,
                      '희망지역',
                      _resumeDetail!['hopeLocation'],
                    ),
                    _buildInfoRow(
                      Icons.schedule,
                      '근무형태',
                      _resumeDetail!['workType'],
                    ),
                    if (_resumeDetail!['salary'] != null &&
                        _resumeDetail!['salary'].toString().isNotEmpty)
                      _buildInfoRow(
                        Icons.attach_money,
                        '희망연봉',
                        _resumeDetail!['salary'],
                      ),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('학력 및 경력', [
                    _buildInfoRow(
                      Icons.school,
                      '학력사항',
                      _resumeDetail!['education'],
                    ),
                    _buildInfoRow(
                      Icons.business_center,
                      '경력사항',
                      _resumeDetail!['career'],
                    ),
                    if (_resumeDetail!['certificate'] != null &&
                        _resumeDetail!['certificate'].toString().isNotEmpty)
                      _buildInfoRow(
                        Icons.verified,
                        '자격증',
                        _resumeDetail!['certificate'],
                      ),
                  ]),
                  const SizedBox(height: 24),
                  _buildContentSection('자기소개서', _resumeDetail!['content']),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _userType == 'company' && !_isMyResume
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
                    child: ElevatedButton.icon(
                      onPressed: _sendScoutOffer,
                      icon: const Icon(Icons.email),
                      label: const Text(
                        '스카우트 제안',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
          Icon(icon, size: 20, color: Colors.green[600]),
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
            content ?? '자기소개서가 작성되지 않았습니다.',
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
}

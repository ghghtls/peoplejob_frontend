import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/apply_service.dart';
import '../../../../services/auth_service.dart';

class ApplyListPage extends StatefulWidget {
  const ApplyListPage({super.key});

  @override
  State<ApplyListPage> createState() => _ApplyListPageState();
}

class _ApplyListPageState extends State<ApplyListPage> {
  final ApplyService _applyService = ApplyService();
  final AuthService _authService = AuthService();
  List<dynamic> _applications = [];
  bool _isLoading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _userType = userInfo['userType'];
    });
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> applications;

      if (_userType == 'company') {
        applications = await _applyService.getAllApplications();
      } else {
        applications = await _applyService.getMyApplications();
      }

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
      return DateFormat('yyyy.MM.dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _cancelApplication(int applyNo, String jobTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('지원 취소'),
          content: Text('$jobTitle 지원을 취소하시겠습니까?\n취소된 지원은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _applyService.cancelApplication(applyNo);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('지원이 취소되었습니다')));
                  _loadApplications();
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
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _viewResume(int resumeNo) {
    Navigator.pushNamed(context, '/resume-detail', arguments: resumeNo);
  }

  void _viewJobDetail(int jobOpeningNo) {
    Navigator.pushNamed(context, '/job-detail', arguments: jobOpeningNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userType == 'company' ? '지원자 관리' : '지원 내역'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: Column(
        children: [
          // 통계 정보
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple[50],
            child: Row(
              children: [
                Icon(Icons.assessment, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  '총 ${_applications.length}건의 ${_userType == 'company' ? '지원' : '지원 내역'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
          ),

          // 지원 내역 목록
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
                            _userType == 'company'
                                ? Icons.people_outline
                                : Icons.send_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userType == 'company'
                                ? '아직 지원자가 없습니다'
                                : '지원한 채용공고가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userType == 'company'
                                ? '채용공고를 등록하여 지원자를 모집해보세요'
                                : '관심있는 채용공고에 지원해보세요',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_userType == 'company') {
                                Navigator.pushNamed(context, '/job-register');
                              } else {
                                Navigator.pushNamed(context, '/job-list');
                              }
                            },
                            icon: Icon(
                              _userType == 'company' ? Icons.add : Icons.search,
                            ),
                            label: Text(
                              _userType == 'company' ? '채용공고 등록' : '채용공고 보기',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              foregroundColor: Colors.white,
                            ),
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
                                  // 헤더 (채용공고 제목 또는 지원자명)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _userType == 'company'
                                              ? application['resumeTitle'] ??
                                                  '이력서 제목 없음'
                                              : application['jobTitle'] ??
                                                  '채용공고 제목 없음',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '지원완료',
                                          style: TextStyle(
                                            color: Colors.purple[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // 세부 정보
                                  if (_userType == 'company') ...[
                                    // 기업회원용: 지원자 정보
                                    _buildInfoRow(
                                      Icons.person,
                                      '지원자',
                                      application['applicantName'] ?? '이름 없음',
                                    ),
                                    _buildInfoRow(
                                      Icons.work,
                                      '채용공고',
                                      application['jobTitle'] ?? '제목 없음',
                                    ),
                                    _buildInfoRow(
                                      Icons.description,
                                      '지원 이력서',
                                      application['resumeTitle'] ?? '제목 없음',
                                    ),
                                  ] else ...[
                                    // 개인회원용: 지원 정보
                                    _buildInfoRow(
                                      Icons.work,
                                      '채용공고',
                                      application['jobTitle'] ?? '제목 없음',
                                    ),
                                    _buildInfoRow(
                                      Icons.business,
                                      '회사명',
                                      application['companyName'] ?? '회사명 없음',
                                    ),
                                    _buildInfoRow(
                                      Icons.description,
                                      '지원 이력서',
                                      application['resumeTitle'] ?? '제목 없음',
                                    ),
                                  ],

                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    '지원일',
                                    _formatDate(application['regdate']),
                                  ),

                                  const SizedBox(height: 16),

                                  // 액션 버튼들
                                  Row(
                                    children: [
                                      if (_userType == 'company') ...[
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                () => _viewResume(
                                                  application['resumeNo'],
                                                ),
                                            icon: const Icon(
                                              Icons.description,
                                              size: 16,
                                            ),
                                            label: const Text('이력서 보기'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.purple[600],
                                              side: BorderSide(
                                                color: Colors.purple[600]!,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              // TODO: 연락하기 기능
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '연락하기 기능은 준비 중입니다',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.email,
                                              size: 16,
                                            ),
                                            label: const Text('연락하기'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.purple[600],
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                () => _viewJobDetail(
                                                  application['jobopeningNo'],
                                                ),
                                            icon: const Icon(
                                              Icons.work,
                                              size: 16,
                                            ),
                                            label: const Text('공고 보기'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.purple[600],
                                              side: BorderSide(
                                                color: Colors.purple[600]!,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed:
                                                () => _cancelApplication(
                                                  application['applyNo'],
                                                  application['jobTitle'] ??
                                                      '채용공고',
                                                ),
                                            icon: const Icon(
                                              Icons.cancel,
                                              size: 16,
                                            ),
                                            label: const Text('지원 취소'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red[600],
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

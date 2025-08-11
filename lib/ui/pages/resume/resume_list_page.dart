import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/resume_service.dart';
import '../../../services/auth_service.dart';

class ResumeListPage extends StatefulWidget {
  const ResumeListPage({super.key});

  @override
  State<ResumeListPage> createState() => _ResumeListPageState();
}

class _ResumeListPageState extends State<ResumeListPage> {
  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();
  List<dynamic> _resumes = [];
  List<dynamic> _filteredResumes = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  String _selectedJobType = '전체';
  String _selectedLocation = '전체';
  String? _userType;
  int? _currentUserNo;

  final List<String> _jobTypes = [
    '전체',
    '개발자',
    '디자이너',
    '기획자',
    '마케터',
    '영업',
    '경영지원',
    '기타',
  ];
  final List<String> _locations = [
    '전체',
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '대전',
    '광주',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

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
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> resumes;

      // 개인회원이면 본인 이력서만, 기업회원이면 전체 이력서
      if (_userType == 'user' && _currentUserNo != null) {
        resumes = await _resumeService.getUserResumes(_currentUserNo!);
      } else {
        resumes = await _resumeService.getAllResumes();
      }

      setState(() {
        _resumes = resumes;
        _filteredResumes = resumes;
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

  void _filterResumes() {
    setState(() {
      _filteredResumes =
          _resumes.where((resume) {
            final matchesKeyword =
                _searchKeyword.isEmpty ||
                resume['title'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                ) ||
                resume['content'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                );

            final matchesJobType =
                _selectedJobType == '전체' ||
                resume['hopeJobtype'] == _selectedJobType;
            final matchesLocation =
                _selectedLocation == '전체' ||
                resume['hopeLocation'] == _selectedLocation;

            return matchesKeyword && matchesJobType && matchesLocation;
          }).toList();
    });
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

  void _deleteResume(int resumeId) {
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
                  await _resumeService.deleteResume(resumeId);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('이력서가 삭제되었습니다')));
                  _loadResumes();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_userType == 'user' ? '내 이력서' : '이력서 목록'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadResumes),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // 검색창
                TextField(
                  decoration: InputDecoration(
                    hintText: '이력서를 검색하세요',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    _searchKeyword = value;
                    _filterResumes();
                  },
                ),
                if (_userType == 'company') ...[
                  const SizedBox(height: 12),
                  // 필터 영역 (기업회원만)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedJobType,
                          decoration: InputDecoration(
                            labelText: '희망직종',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _jobTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedJobType = value!;
                            });
                            _filterResumes();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLocation,
                          decoration: InputDecoration(
                            labelText: '희망지역',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _locations.map((location) {
                                return DropdownMenuItem(
                                  value: location,
                                  child: Text(location),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value!;
                            });
                            _filterResumes();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 결과 개수 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '총 ${_filteredResumes.length}개의 이력서',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (_userType == 'user')
                  Text(
                    '내 이력서만 표시됩니다',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          // 이력서 목록
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredResumes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userType == 'user'
                                ? '등록된 이력서가 없습니다'
                                : '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userType == 'user'
                                ? '새 이력서를 작성해보세요'
                                : '다른 키워드로 검색해보세요',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadResumes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredResumes.length,
                        itemBuilder: (context, index) {
                          final resume = _filteredResumes[index];
                          final isMyResume = _userType == 'user';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/resume-detail',
                                  arguments: resume['resumeNo'],
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 제목과 액션 버튼
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            resume['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isMyResume) ...[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/resume-edit',
                                                arguments: resume['resumeNo'],
                                              );
                                            },
                                            tooltip: '수정',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _deleteResume(
                                                  resume['resumeNo'],
                                                ),
                                            tooltip: '삭제',
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // 기본 정보
                                    Row(
                                      children: [
                                        _buildInfoChip(
                                          Icons.work,
                                          resume['hopeJobtype'] ?? '',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(
                                          Icons.location_on,
                                          resume['hopeLocation'] ?? '',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildInfoChip(
                                          Icons.school,
                                          resume['education'] ?? '',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(
                                          Icons.timeline,
                                          resume['career'] ?? '',
                                        ),
                                      ],
                                    ),
                                    if (resume['salary'] != null &&
                                        resume['salary']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildInfoChip(
                                        Icons.attach_money,
                                        resume['salary'],
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    // 등록일
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '등록일: ${_formatDate(resume['regdate'])}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (_userType == 'company')
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              // TODO: 스카우트 제안 기능
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '스카우트 제안 기능은 준비 중입니다',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.email,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              '제안하기',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green[600],
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton:
          _userType == 'user'
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/resume-register');
                },
                backgroundColor: Colors.green[600],
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

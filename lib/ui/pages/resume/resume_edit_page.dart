import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/resume_service.dart';
import '../../../services/auth_service.dart';

class ResumeEditPage extends StatefulWidget {
  final int? resumeId; // 수정 모드일 때 사용

  const ResumeEditPage({super.key, this.resumeId});

  @override
  State<ResumeEditPage> createState() => _ResumeEditPageState();
}

class _ResumeEditPageState extends State<ResumeEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();

  // 폼 컨트롤러들
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _educationController = TextEditingController();
  final _careerController = TextEditingController();
  final _certificateController = TextEditingController();
  final _salaryController = TextEditingController();

  // 드롭다운 선택값들
  String? _selectedHopeJobtype;
  String? _selectedHopeLocation;
  String? _selectedWorkType;

  bool _isLoading = false;
  bool _isEditMode = false;
  int? _currentUserNo;

  // 드롭다운 옵션들
  final List<String> _jobTypes = [
    '개발자',
    '디자이너',
    '기획자',
    '마케터',
    '영업',
    '경영지원',
    '기타',
  ];
  final List<String> _locations = [
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
  final List<String> _workTypes = ['정규직', '계약직', '인턴', '프리랜서', '파트타임'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.resumeId != null;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _currentUserNo = int.tryParse(
        userInfo['userid'] ?? '0',
      ); // TODO: userNo 필드로 변경 필요
    });

    if (_isEditMode) {
      _loadResumeData();
    }
  }

  Future<void> _loadResumeData() async {
    if (widget.resumeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resumeDetail = await _resumeService.getResumeDetail(
        widget.resumeId!,
      );
      _titleController.text = resumeDetail['title'] ?? '';
      _contentController.text = resumeDetail['content'] ?? '';
      _educationController.text = resumeDetail['education'] ?? '';
      _careerController.text = resumeDetail['career'] ?? '';
      _certificateController.text = resumeDetail['certificate'] ?? '';
      _salaryController.text = resumeDetail['salary'] ?? '';
      _selectedHopeJobtype = resumeDetail['hopeJobtype'];
      _selectedHopeLocation = resumeDetail['hopeLocation'];
      _selectedWorkType = resumeDetail['workType'];

      setState(() {
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resumeData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'education': _educationController.text,
        'career': _careerController.text,
        'certificate': _certificateController.text,
        'hopeJobtype': _selectedHopeJobtype,
        'hopeLocation': _selectedHopeLocation,
        'salary': _salaryController.text,
        'workType': _selectedWorkType,
        'regdate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'userNo': _currentUserNo,
      };

      if (_isEditMode) {
        await _resumeService.updateResume(widget.resumeId!, resumeData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이력서가 수정되었습니다')));
      } else {
        await _resumeService.createResume(resumeData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이력서가 등록되었습니다')));
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _educationController.dispose();
    _careerController.dispose();
    _certificateController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '이력서 수정' : '이력서 등록'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: Text(
                _isEditMode ? '수정' : '등록',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body:
          _isLoading && _isEditMode
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 사진 영역
                      _buildSectionTitle('프로필 사진'),
                      const SizedBox(height: 16),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[500],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: 이미지 선택 기능 구현
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('이미지 업로드 기능은 준비 중입니다'),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 기본 정보
                      _buildSectionTitle('기본 정보'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '이력서 제목 *',
                          hintText: '예: 신입 프론트엔드 개발자 김철수입니다',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이력서 제목을 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),
                      const SizedBox(height: 32),

                      // 희망 조건
                      _buildSectionTitle('희망 조건'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedHopeJobtype,
                              decoration: InputDecoration(
                                labelText: '희망직종 *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.work),
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
                                  _selectedHopeJobtype = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '희망직종을 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedHopeLocation,
                              decoration: InputDecoration(
                                labelText: '희망지역 *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
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
                                  _selectedHopeLocation = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '희망지역을 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedWorkType,
                              decoration: InputDecoration(
                                labelText: '근무형태 *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.schedule),
                              ),
                              items:
                                  _workTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedWorkType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '근무형태를 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _salaryController,
                              decoration: InputDecoration(
                                labelText: '희망연봉',
                                hintText: '예: 3000-4000만원',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              maxLength: 50,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 학력 및 경력
                      _buildSectionTitle('학력 및 경력'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _educationController,
                        decoration: InputDecoration(
                          labelText: '학력사항 *',
                          hintText: '예: OO대학교 컴퓨터공학과 졸업 (2020.03)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.school),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '학력사항을 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 500,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _careerController,
                        decoration: InputDecoration(
                          labelText: '경력사항 *',
                          hintText: '신입의 경우 "신입"이라고 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.business_center),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '경력사항을 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 500,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _certificateController,
                        decoration: InputDecoration(
                          labelText: '자격증',
                          hintText: '보유한 자격증이 있다면 입력해주세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.verified),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 32),

                      // 자기소개서
                      _buildSectionTitle('자기소개서'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: '자기소개서 *',
                          hintText: '''자신의 성격, 경험, 능력, 지원 동기 등을 자세히 작성해주세요.

예시:
안녕하세요. 프론트엔드 개발자를 꿈꾸는 김철수입니다.

[성격 및 장점]
- 새로운 기술에 대한 호기심이 많습니다
- 팀워크를 중시하며 소통을 잘합니다

[경험 및 능력]
- React, Vue.js를 활용한 웹 개발 경험
- 반응형 웹 디자인 구현 가능

[지원 동기]
- 귀사의 혁신적인 서비스에 기여하고 싶습니다''',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 15,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '자기소개서를 입력해주세요';
                          }
                          if (value.trim().length < 100) {
                            return '자기소개서를 100자 이상 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 2000,
                      ),
                      const SizedBox(height: 32),

                      // 등록 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    _isEditMode ? '수정 완료' : '등록하기',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';
import '../../../services/auth_service.dart';

class JobPostRegisterPage extends StatefulWidget {
  final int? jobId; // 수정 모드일 때 사용

  const JobPostRegisterPage({super.key, this.jobId});

  @override
  State<JobPostRegisterPage> createState() => _JobPostRegisterPageState();
}

class _JobPostRegisterPageState extends State<JobPostRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();

  // 폼 컨트롤러들
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime? _selectedDeadline;

  // 드롭다운 선택값들
  String? _selectedJobType;
  String? _selectedLocation;
  String? _selectedEducation;
  String? _selectedCareer;

  bool _isLoading = false;
  bool _isEditMode = false;

  // 드롭다운 옵션들
  final List<String> _jobTypes = ['정규직', '계약직', '인턴', '프리랜서', '파트타임'];
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
  final List<String> _educations = [
    '학력무관',
    '고등학교졸업',
    '전문대졸업',
    '대학교졸업',
    '석사졸업',
    '박사졸업',
  ];
  final List<String> _careers = [
    '신입',
    '경력무관',
    '1년이상',
    '2년이상',
    '3년이상',
    '5년이상',
    '10년이상',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.jobId != null;
    if (_isEditMode) {
      _loadJobData();
    }
  }

  Future<void> _loadJobData() async {
    if (widget.jobId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final jobDetail = await _jobService.getJobDetail(widget.jobId!);
      _titleController.text = jobDetail['title'] ?? '';
      _contentController.text = jobDetail['content'] ?? '';
      _salaryController.text = jobDetail['salary'] ?? '';
      _selectedJobType = jobDetail['jobtype'];
      _selectedLocation = jobDetail['location'];
      _selectedEducation = jobDetail['education'];
      _selectedCareer = jobDetail['career'];

      if (jobDetail['deadline'] != null) {
        _selectedDeadline = DateTime.parse(jobDetail['deadline']);
      }

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

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('마감일을 선택해주세요')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jobData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'jobtype': _selectedJobType,
        'location': _selectedLocation,
        'education': _selectedEducation,
        'career': _selectedCareer,
        'salary': _salaryController.text,
        'deadline': DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
        'regdate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'companyNo': 1, // TODO: 실제 로그인한 회사 번호로 변경
      };

      if (_isEditMode) {
        await _jobService.updateJob(widget.jobId!, jobData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('채용공고가 수정되었습니다')));
      } else {
        await _jobService.createJob(jobData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('채용공고가 등록되었습니다')));
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
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '채용공고 수정' : '채용공고 등록'),
        backgroundColor: Colors.blue[600],
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
                      // 제목
                      _buildSectionTitle('기본 정보'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '채용공고 제목 *',
                          hintText: '예: 프론트엔드 개발자 모집',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),
                      const SizedBox(height: 20),

                      // 고용형태와 지역
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedJobType,
                              decoration: InputDecoration(
                                labelText: '고용형태 *',
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
                                  _selectedJobType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '고용형태를 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLocation,
                              decoration: InputDecoration(
                                labelText: '근무지역 *',
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
                                  _selectedLocation = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '근무지역을 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 학력과 경력
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedEducation,
                              decoration: InputDecoration(
                                labelText: '학력요건 *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.school),
                              ),
                              items:
                                  _educations.map((education) {
                                    return DropdownMenuItem(
                                      value: education,
                                      child: Text(education),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEducation = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '학력요건을 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCareer,
                              decoration: InputDecoration(
                                labelText: '경력요건 *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.timeline),
                              ),
                              items:
                                  _careers.map((career) {
                                    return DropdownMenuItem(
                                      value: career,
                                      child: Text(career),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCareer = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return '경력요건을 선택해주세요';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 급여조건
                      TextFormField(
                        controller: _salaryController,
                        decoration: InputDecoration(
                          labelText: '급여조건',
                          hintText: '예: 연봉 3000-4000만원',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        maxLength: 50,
                      ),
                      const SizedBox(height: 20),

                      // 마감일
                      InkWell(
                        onTap: _selectDeadline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDeadline == null
                                    ? '마감일 선택 *'
                                    : '마감일: ${DateFormat('yyyy년 MM월 dd일').format(_selectedDeadline!)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      _selectedDeadline == null
                                          ? Colors.grey[600]
                                          : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 상세 내용
                      _buildSectionTitle('상세 내용'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: '채용공고 상세 내용 *',
                          hintText: '''담당 업무, 자격 요건, 우대 사항 등을 자세히 작성해주세요.

예시:
[담당업무]
- 웹 프론트엔드 개발
- UI/UX 구현 및 최적화

[자격요건]
- React, Vue.js 등 프레임워크 경험
- HTML, CSS, JavaScript 숙련

[우대사항]
- TypeScript 경험
- 반응형 웹 개발 경험''',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 15,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '상세 내용을 입력해주세요';
                          }
                          if (value.trim().length < 50) {
                            return '상세 내용을 50자 이상 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 2000,
                      ),
                      const SizedBox(height: 32),

                      // 파일 첨부 (향후 구현)
                      _buildSectionTitle('첨부파일 (선택)'),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '파일 첨부 기능은 준비 중입니다',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PDF, DOC, DOCX 파일만 업로드 가능 (최대 10MB)',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 등록 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
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

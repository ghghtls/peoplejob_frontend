import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/file_upload_service.dart';
import '../../widgets/app_bar.dart';

class JobPostRegisterPage extends StatefulWidget {
  final int? jobId;

  const JobPostRegisterPage({super.key, this.jobId});

  @override
  State<JobPostRegisterPage> createState() => _JobPostRegisterPageState();
}

class _JobPostRegisterPageState extends State<JobPostRegisterPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFE5342F);

  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime? _selectedDeadline;

  String? _selectedJobType;
  String? _selectedLocation;
  String? _selectedEducation;
  String? _selectedCareer;

  bool _isLoading = false;
  bool _isEditMode = false;
  int? _userNo;
  bool _isAuthorized = false;

  String? _attachedFileName;
  String? _uploadedFileUrl;
  bool _isUploading = false;
  final FileUploadService _fileService = FileUploadService();

  final List<String> _jobTypes = ['정규직', '계약직', '인턴', '프리랜서', '파트타임'];
  final List<String> _locations = [
    '서울', '경기', '인천', '부산', '대구', '대전', '광주', '울산', '세종',
    '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];
  final List<String> _educations = [
    '학력무관', '고등학교졸업', '전문대졸업', '대학교졸업', '석사졸업', '박사졸업',
  ];
  final List<String> _careers = [
    '신입', '경력무관', '1년이상', '2년이상', '3년이상', '5년이상', '10년이상',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.jobId != null;
    _loadUserNo();
    if (_isEditMode) { _loadJobData(); }
  }

  Future<void> _loadUserNo() async {
    final info = await _authService.getUserInfo();
    final userType = (info['userType'] ?? '').toLowerCase();
    if (mounted && userType != 'company' && userType != 'admin') {
      Navigator.pushReplacementNamed(context, '/unauthorized');
      return;
    }
    setState(() {
      _userNo = int.tryParse(info['userNo'] ?? '');
      _isAuthorized = true;
    });
  }

  Future<void> _loadJobData() async {
    if (widget.jobId == null) return;
    setState(() { _isLoading = true; });
    try {
      final jobDetail = await _jobService.getJobDetail(widget.jobId!);
      _titleController.text = jobDetail['title'] ?? '';
      _contentController.text = jobDetail['content'] ?? '';
      _salaryController.text = _toFormattedSalary(jobDetail['salary'] ?? '');
      _selectedJobType = jobDetail['jobType'];
      _selectedLocation = jobDetail['location'];
      _selectedEducation = jobDetail['education'];
      _selectedCareer = jobDetail['experience'];
      if (jobDetail['deadline'] != null) {
        _selectedDeadline = DateTime.parse(jobDetail['deadline']);
      }
      setState(() {
        _uploadedFileUrl = jobDetail['filename'] as String?;
        _attachedFileName = jobDetail['originalFilename'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (result == null) return;

      final picked = result.files.single;
      final bytes = picked.bytes;
      final name = picked.name;

      if (bytes == null) return;

      if (bytes.length > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('파일 크기는 10MB를 초과할 수 없습니다'),
            backgroundColor: _red, behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
        return;
      }

      setState(() { _attachedFileName = name; _uploadedFileUrl = null; _isUploading = true; });

      final res = await _fileService.uploadJobAttachment(bytes, name);
      if (mounted) {
        setState(() {
          _isUploading = false;
          if (res != null) {
            _uploadedFileUrl = res['fileUrl'];
          } else {
            _attachedFileName = null;
          }
        });
        if (res == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('파일 업로드에 실패했습니다'), backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('파일 선택 실패: $e'), backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _removeFile() => setState(() { _attachedFileName = null; _uploadedFileUrl = null; });

  // 숫자 문자열 → 콤마 포맷 (예: "3000" → "3,000")
  String _toFormattedSalary(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final n = int.tryParse(digits);
    if (n == null) return raw;
    return NumberFormat('#,###').format(n);
  }

  // 콤마 포맷 → 순수 숫자 문자열 (서버 전송용)
  String _toRawSalary(String formatted) => formatted.replaceAll(',', '');

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() { _selectedDeadline = picked; });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_selectedJobType == null || _selectedLocation == null ||
        _selectedEducation == null || _selectedCareer == null) {
      messenger.showSnackBar(SnackBar(
        content: const Text('모든 선택 항목을 선택해주세요'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (_selectedDeadline == null) {
      messenger.showSnackBar(SnackBar(
        content: const Text('마감일을 선택해주세요'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (_userNo == null) {
      messenger.showSnackBar(SnackBar(
        content: const Text('로그인 정보를 확인해주세요 (userNo 없음)'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final jobData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'jobType': _selectedJobType,
        'location': _selectedLocation,
        'education': _selectedEducation,
        'experience': _selectedCareer,
        'salary': _toRawSalary(_salaryController.text),
        'deadline': DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
        'regdate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'userNo': _userNo,
        if (_uploadedFileUrl != null) 'filename': _uploadedFileUrl,
        if (_attachedFileName != null) 'originalFilename': _attachedFileName,
      };

      if (_isEditMode) {
        await _jobService.updateJob(widget.jobId!, jobData);
        messenger.showSnackBar(SnackBar(
          content: const Text('채용공고가 수정되었습니다'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      } else {
        await _jobService.createJob(jobData);
        messenger.showSnackBar(SnackBar(
          content: const Text('채용공고가 등록되었습니다'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }

      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
    if (!_isAuthorized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0B5FFF), strokeWidth: 2.5)),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: _isEditMode ? '채용공고 수정' : '채용공고 등록',
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _blue)),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: Text(
                _isEditMode ? '수정' : '등록',
                style: const TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isLoading && _isEditMode
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCard([
                              _buildSectionLabel('기본 정보'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                decoration: _inputDec('채용공고 제목 *', hint: '예: 프론트엔드 개발자 모집'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? '제목을 입력해주세요' : null,
                                maxLength: 100,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('고용형태 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_jobTypes, _selectedJobType,
                                  (v) => setState(() => _selectedJobType = v)),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('근무지역 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_locations, _selectedLocation,
                                  (v) => setState(() => _selectedLocation = v)),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('학력요건 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_educations, _selectedEducation,
                                  (v) => setState(() => _selectedEducation = v)),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('경력요건 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_careers, _selectedCareer,
                                  (v) => setState(() => _selectedCareer = v)),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('급여조건'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _salaryController,
                                decoration: _inputDec('급여조건', hint: '예: 3000').copyWith(suffixText: '만원'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorFormatter(),
                                ],
                                maxLength: 10,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('마감일 *'),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _selectDeadline,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18, color: _blue),
                                      const SizedBox(width: 10),
                                      Text(
                                        _selectedDeadline == null
                                            ? '날짜 선택'
                                            : DateFormat('yyyy년 MM월 dd일').format(_selectedDeadline!),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: _selectedDeadline == null ? _secondary : _label,
                                          fontWeight: _selectedDeadline != null ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right_rounded, size: 20, color: _secondary),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('상세 내용 *'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _contentController,
                                decoration: _inputDec('채용공고 상세 내용').copyWith(
                                  alignLabelWithHint: true,
                                  hintText: '담당 업무, 자격 요건, 우대 사항 등을 자세히 작성해주세요.',
                                ),
                                maxLines: 12,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return '상세 내용을 입력해주세요';
                                  if (v.trim().length < 50) return '상세 내용을 50자 이상 입력해주세요';
                                  return null;
                                },
                                maxLength: 2000,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('첨부파일',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                                  const SizedBox(height: 10),
                                  if (_attachedFileName != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _blue.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isUploading ? Icons.hourglass_empty_rounded : Icons.attach_file_rounded,
                                            size: 18,
                                            color: _isUploading ? _secondary : _blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _attachedFileName!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _isUploading ? _secondary : _blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (_isUploading)
                                            const SizedBox(width: 16, height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: _secondary))
                                          else
                                            GestureDetector(
                                              onTap: _removeFile,
                                              child: const Icon(Icons.close_rounded, size: 18, color: _secondary),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  GestureDetector(
                                    onTap: _isUploading ? null : _pickFile,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _isUploading ? _secondary.withValues(alpha: 0.3) : _blue.withValues(alpha: 0.4),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload_file_rounded, size: 18,
                                              color: _isUploading ? _secondary : _blue),
                                          const SizedBox(width: 6),
                                          Text(
                                            _attachedFileName != null ? '파일 변경' : '파일 선택',
                                            style: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w600,
                                              color: _isUploading ? _secondary : _blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '이미지(jpg, png), 문서(pdf, docx, hwp) · 최대 10MB',
                                    style: TextStyle(fontSize: 11, color: _secondary.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                    : Text(
                                        _isEditMode ? '수정 완료' : '등록하기',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _secondary, letterSpacing: 0.2));
  }

  Widget _buildChipRow(List<String> options, String? selected, void Function(String?) onTap) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(isSelected ? null : opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _blue : _bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : _label,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  InputDecoration _inputDec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
      labelStyle: const TextStyle(color: _secondary),
      counterStyle: const TextStyle(color: _secondary, fontSize: 11),
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = NumberFormat('#,###').format(n);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

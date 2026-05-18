import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/resume_service.dart';
import '../../../services/auth_service.dart';
import '../../../data/provider/file_upload_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/file_picker_widget.dart';

class ResumeEditPage extends ConsumerStatefulWidget {
  final int? resumeId;

  const ResumeEditPage({super.key, this.resumeId});

  @override
  ConsumerState<ResumeEditPage> createState() => _ResumeEditPageState();
}

class _ResumeEditPageState extends ConsumerState<ResumeEditPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFE5342F);

  final _formKey = GlobalKey<FormState>();
  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _educationController = TextEditingController();
  final _careerController = TextEditingController();
  final _certificateController = TextEditingController();
  final _salaryController = TextEditingController();

  String? _selectedHopeJobtype;
  String? _selectedHopeLocation;
  String? _selectedWorkType;

  String? _profileImageUrl;
  File? _selectedProfileImage;
  File? _selectedResumeFile;
  String? _existingResumeFileName;

  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isSubmitting = false;
  int? _currentUserNo;

  final List<String> _jobTypes = ['개발자', '디자이너', '기획자', '마케터', '영업', '경영지원', '기타'];
  final List<String> _locations = [
    '서울', '경기', '인천', '부산', '대구', '대전', '광주', '울산', '세종',
    '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
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
      _currentUserNo = int.tryParse(userInfo['userNo'] ?? '0');
    });
    if (_isEditMode) { _loadResumeData(); }
  }

  Future<void> _loadResumeData() async {
    if (widget.resumeId == null) return;
    setState(() { _isLoading = true; });
    try {
      final resumeDetail = await _resumeService.getResumeDetail(widget.resumeId!);
      _titleController.text = resumeDetail['title'] ?? '';
      _contentController.text = resumeDetail['content'] ?? '';
      _educationController.text = resumeDetail['education'] ?? '';
      _careerController.text = resumeDetail['career'] ?? '';
      _certificateController.text = resumeDetail['certificate'] ?? '';
      _salaryController.text = resumeDetail['salary'] ?? '';
      _selectedHopeJobtype = resumeDetail['hopeJobtype'];
      _selectedHopeLocation = resumeDetail['hopeLocation'];
      _selectedWorkType = resumeDetail['workType'];
      _profileImageUrl = resumeDetail['profileImageUrl'];
      _existingResumeFileName = resumeDetail['originalFileName'];
      setState(() { _isLoading = false; });
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

  void _onProfileImageSelected(String? imagePath) {
    if (imagePath != null) {
      setState(() {
        _selectedProfileImage = File(imagePath);
        _profileImageUrl = null;
      });
    } else {
      setState(() {
        _selectedProfileImage = null;
        _profileImageUrl = null;
      });
    }
  }

  void _onResumeFileSelected(File? file) {
    setState(() {
      _selectedResumeFile = file;
      if (file != null) { _existingResumeFileName = null; }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_selectedHopeJobtype == null || _selectedHopeLocation == null || _selectedWorkType == null) {
      messenger.showSnackBar(SnackBar(
        content: const Text('희망직종, 희망지역, 근무형태를 선택해주세요'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() { _isSubmitting = true; });

    try {
      String? uploadedImageUrl = _profileImageUrl;
      if (_selectedProfileImage != null && widget.resumeId != null) {
        final imageUrl = await ref.read(fileUploadProvider.notifier)
            .uploadResumeImage(_selectedProfileImage!, widget.resumeId!);
        if (imageUrl != null) {
          uploadedImageUrl = imageUrl;
        } else {
          throw Exception('프로필 이미지 업로드 실패');
        }
      }

      Map<String, String>? uploadedFileInfo;
      if (_selectedResumeFile != null && widget.resumeId != null) {
        uploadedFileInfo = await ref.read(fileUploadProvider.notifier)
            .uploadResumeFile(_selectedResumeFile!, widget.resumeId!);
        if (uploadedFileInfo == null) {
          throw Exception('이력서 파일 업로드 실패');
        }
      }

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
        if (uploadedImageUrl != null) 'imagePath': uploadedImageUrl,
        if (uploadedFileInfo != null) 'originalImage': uploadedFileInfo['originalName'],
      };

      if (uploadedImageUrl != null) { resumeData['profileImageUrl'] = uploadedImageUrl; }
      if (uploadedFileInfo != null) {
        resumeData['fileUrl'] = uploadedFileInfo['fileUrl']!;
        resumeData['originalFileName'] = uploadedFileInfo['originalName']!;
      }

      if (_isEditMode) {
        await _resumeService.updateResume(widget.resumeId!, resumeData);
        messenger.showSnackBar(SnackBar(
          content: const Text('이력서가 수정되었습니다'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      } else {
        final newResumeId = await _resumeService.createResume(resumeData);
        if (newResumeId != null) {
          if (_selectedProfileImage != null) {
            final imageUrl = await ref.read(fileUploadProvider.notifier)
                .uploadResumeImage(_selectedProfileImage!, newResumeId);
            if (imageUrl != null) {
              await _resumeService.updateResume(newResumeId, {...resumeData, 'profileImageUrl': imageUrl});
            }
          }
          if (_selectedResumeFile != null) {
            final fileInfo = await ref.read(fileUploadProvider.notifier)
                .uploadResumeFile(_selectedResumeFile!, newResumeId);
            if (fileInfo != null) {
              await _resumeService.updateResume(newResumeId, {
                ...resumeData,
                'fileUrl': fileInfo['fileUrl']!,
                'originalFileName': fileInfo['originalName']!,
              });
            }
          }
        }
        messenger.showSnackBar(SnackBar(
          content: const Text('이력서가 등록되었습니다'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }

      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('오류가 발생했습니다: ${e.toString()}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
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
    final fileUploadState = ref.watch(fileUploadProvider);
    final isBusy = _isSubmitting || fileUploadState.isUploading;

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: _isEditMode ? '이력서 수정' : '이력서 등록',
        actions: [
          if (isBusy)
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
                              _buildSectionLabel('프로필 사진'),
                              const SizedBox(height: 16),
                              Center(
                                child: ImagePickerWidget(
                                  initialImageUrl: _profileImageUrl,
                                  onImageSelected: _onProfileImageSelected,
                                  size: 110,
                                  placeholderText: '프로필 사진 추가',
                                ),
                              ),
                              const SizedBox(height: 4),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('기본 정보'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                decoration: _inputDec('이력서 제목 *', hint: '예: 신입 프론트엔드 개발자 김철수입니다'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? '이력서 제목을 입력해주세요' : null,
                                maxLength: 100,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('희망직종 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_jobTypes, _selectedHopeJobtype,
                                  (v) => setState(() => _selectedHopeJobtype = v)),
                              const SizedBox(height: 16),
                              _buildSectionLabel('희망지역 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_locations, _selectedHopeLocation,
                                  (v) => setState(() => _selectedHopeLocation = v)),
                              const SizedBox(height: 16),
                              _buildSectionLabel('근무형태 *'),
                              const SizedBox(height: 12),
                              _buildChipRow(_workTypes, _selectedWorkType,
                                  (v) => setState(() => _selectedWorkType = v)),
                              const SizedBox(height: 16),
                              _buildSectionLabel('희망연봉'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _salaryController,
                                decoration: _inputDec('희망연봉', hint: '예: 3000-4000만원'),
                                maxLength: 50,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('학력 및 경력'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _educationController,
                                decoration: _inputDec('학력사항 *', hint: '예: OO대학교 컴퓨터공학과 졸업 (2020.03)')
                                    .copyWith(alignLabelWithHint: true),
                                maxLines: 3,
                                validator: (v) => (v == null || v.trim().isEmpty) ? '학력사항을 입력해주세요' : null,
                                maxLength: 500,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _careerController,
                                decoration: _inputDec('경력사항 *', hint: '신입의 경우 "신입"이라고 입력하세요')
                                    .copyWith(alignLabelWithHint: true),
                                maxLines: 3,
                                validator: (v) => (v == null || v.trim().isEmpty) ? '경력사항을 입력해주세요' : null,
                                maxLength: 500,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _certificateController,
                                decoration: _inputDec('자격증', hint: '보유한 자격증이 있다면 입력해주세요')
                                    .copyWith(alignLabelWithHint: true),
                                maxLines: 3,
                                maxLength: 500,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('이력서 파일 (선택사항)'),
                              const SizedBox(height: 12),
                              FilePickerWidget(
                                initialFileName: _existingResumeFileName,
                                onFileSelected: _onResumeFileSelected,
                                allowedExtensions: const ['pdf', 'doc', 'docx', 'hwp'],
                                fileType: FileType.custom,
                                buttonText: '이력서 파일 선택',
                                helpText: 'PDF, DOC, DOCX, HWP 파일만 업로드 가능 (최대 10MB)',
                                maxSizeMB: 10.0,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildCard([
                              _buildSectionLabel('자기소개서 *'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _contentController,
                                decoration: _inputDec('자기소개서').copyWith(
                                  alignLabelWithHint: true,
                                  hintText: '자신의 성격, 경험, 능력, 지원 동기 등을 자세히 작성해주세요.',
                                ),
                                maxLines: 12,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return '자기소개서를 입력해주세요';
                                  if (v.trim().length < 100) return '자기소개서를 100자 이상 입력해주세요';
                                  return null;
                                },
                                maxLength: 2000,
                              ),
                            ]),
                            if (fileUploadState.isUploading) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4FD),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 20, height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: _blue)),
                                    SizedBox(width: 12),
                                    Text('파일 업로드 중...', style: TextStyle(color: _label, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                            if (fileUploadState.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: _red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        fileUploadState.errorMessage!,
                                        style: const TextStyle(color: _red, fontSize: 13),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => ref.read(fileUploadProvider.notifier).clearError(),
                                      child: const Icon(Icons.close_rounded, size: 18, color: _secondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isBusy ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: isBusy
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

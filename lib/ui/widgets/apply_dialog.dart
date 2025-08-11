import 'package:flutter/material.dart';
import '../../services/apply_service.dart';
import '../../services/resume_service.dart';
import '../../services/auth_service.dart';

class ApplyDialog extends StatefulWidget {
  final int jobOpeningNo;
  final String jobTitle;

  const ApplyDialog({
    super.key,
    required this.jobOpeningNo,
    required this.jobTitle,
  });

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {
  final ApplyService _applyService = ApplyService();
  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();

  List<dynamic> _resumes = [];
  int? _selectedResumeNo;
  bool _isLoading = true;
  bool _isApplying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyResumes();
  }

  Future<void> _loadMyResumes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userInfo = await _authService.getUserInfo();
      final userNo = int.tryParse(userInfo['userid'] ?? '0');

      if (userNo != null && userNo > 0) {
        final resumes = await _resumeService.getUserResumes(userNo);
        setState(() {
          _resumes = resumes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '사용자 정보를 찾을 수 없습니다';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_selectedResumeNo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지원할 이력서를 선택해주세요')));
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      await _applyService.applyToJob(
        jobOpeningNo: widget.jobOpeningNo,
        resumeNo: _selectedResumeNo!,
      );

      Navigator.of(context).pop(true); // 성공 결과 반환

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.jobTitle}에 지원이 완료되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isApplying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.send, color: Colors.blue[600]),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '지원하기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 채용공고 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.work, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.jobTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 이력서 선택
            const Text(
              '지원할 이력서를 선택해주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // 로딩 또는 에러 상태
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              )
            else if (_resumes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Colors.orange[600],
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '등록된 이력서가 없습니다',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text('먼저 이력서를 작성해주세요'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/resume-register');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('이력서 작성'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              // 이력서 목록
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        _resumes.map((resume) {
                          final resumeNo = resume['resumeNo'] as int;
                          final isSelected = _selectedResumeNo == resumeNo;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedResumeNo = resumeNo;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.blue[50]
                                        : Colors.grey[50],
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue[300]!
                                          : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: resumeNo,
                                    groupValue: _selectedResumeNo,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedResumeNo = value;
                                      });
                                    },
                                    activeColor: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resume['title'] ?? '제목 없음',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isSelected
                                                    ? Colors.blue[800]
                                                    : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (resume['hopeJobtype'] !=
                                                null) ...[
                                              Icon(
                                                Icons.work,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                resume['hopeJobtype'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                            ],
                                            if (resume['hopeLocation'] !=
                                                null) ...[
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                resume['hopeLocation'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isApplying ? null : () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed:
              _isApplying || _resumes.isEmpty ? null : _submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          child:
              _isApplying
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('지원하기'),
        ),
      ],
    );
  }
}

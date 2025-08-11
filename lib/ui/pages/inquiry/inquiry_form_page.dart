import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/inquiry_provider.dart';
import '../../../data/model/inquiry.dart';

class InquiryFormPage extends ConsumerStatefulWidget {
  final Inquiry? inquiry; // 수정시 전달받을 문의

  const InquiryFormPage({super.key, this.inquiry});

  @override
  ConsumerState<InquiryFormPage> createState() => _InquiryFormPageState();
}

class _InquiryFormPageState extends ConsumerState<InquiryFormPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 수정 모드인 경우 기존 데이터로 초기화
    if (widget.inquiry != null) {
      _titleController.text = widget.inquiry!.title;
      _contentController.text = widget.inquiry!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.inquiry != null;

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    bool success;
    if (_isEditMode) {
      // 수정 모드
      success = await ref
          .read(inquiryProvider.notifier)
          .updateInquiry(widget.inquiry!.inquiryNo!, title, content);
    } else {
      // 등록 모드
      success = await ref
          .read(inquiryProvider.notifier)
          .createInquiry(title, content);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? '문의가 수정되었습니다.' : '문의가 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 성공시 true 반환
      }
    } else {
      if (mounted) {
        final errorMessage =
            ref.read(inquiryProvider).errorMessage ??
            (_isEditMode ? '문의 수정에 실패했습니다.' : '문의 등록에 실패했습니다.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '문의 수정' : '문의 작성'),
        actions: [
          if (_isEditMode && widget.inquiry!.status == 'WAIT')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 답변 완료된 문의는 수정 불가 안내
              if (_isEditMode && widget.inquiry!.status == 'ANSWERED')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '답변이 완료된 문의는 수정할 수 없습니다.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),

              // 제목 입력
              TextFormField(
                controller: _titleController,
                enabled: !_isEditMode || widget.inquiry!.status == 'WAIT',
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                  hintText: '문의 제목을 입력해주세요',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  if (value.trim().length < 2) {
                    return '제목은 2자 이상 입력해주세요';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // 내용 입력
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  enabled: !_isEditMode || widget.inquiry!.status == 'WAIT',
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                    hintText: '문의 내용을 자세히 입력해주세요',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '내용을 입력해주세요';
                    }
                    if (value.trim().length < 10) {
                      return '내용은 10자 이상 입력해주세요';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 제출 버튼
              if (!_isEditMode || widget.inquiry!.status == 'WAIT')
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitInquiry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('처리 중...'),
                              ],
                            )
                            : Text(_isEditMode ? '수정하기' : '제출하기'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('문의 삭제'),
            content: const Text('정말로 이 문의를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _deleteInquiry();
    }
  }

  Future<void> _deleteInquiry() async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref
        .read(inquiryProvider.notifier)
        .deleteInquiry(widget.inquiry!.inquiryNo!);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('문의가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        final errorMessage =
            ref.read(inquiryProvider).errorMessage ?? '문의 삭제에 실패했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/inquiry_provider.dart';
import '../../../data/model/inquiry.dart';
import '../../widgets/app_bar.dart';

class InquiryFormPage extends ConsumerStatefulWidget {
  final Inquiry? inquiry;
  const InquiryFormPage({super.key, this.inquiry});

  @override
  ConsumerState<InquiryFormPage> createState() => _InquiryFormPageState();
}

class _InquiryFormPageState extends ConsumerState<InquiryFormPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  bool get _isEditMode => widget.inquiry != null;
  bool get _canEdit => !_isEditMode || !widget.inquiry!.isAnswered;

  @override
  void initState() {
    super.initState();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    final success = _isEditMode
        ? await ref.read(inquiryProvider.notifier).updateInquiry(widget.inquiry!.inquiryNo!, title, content)
        : await ref.read(inquiryProvider.notifier).createInquiry(title, content);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? '문의가 수정되었습니다.' : '문의가 등록되었습니다.'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      final msg = ref.read(inquiryProvider).errorMessage ??
          (_isEditMode ? '수정에 실패했습니다.' : '등록에 실패했습니다.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: _red,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('문의 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('정말로 이 문의를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed == true) await _deleteInquiry();
  }

  Future<void> _deleteInquiry() async {
    setState(() => _isSubmitting = true);
    final success = await ref.read(inquiryProvider.notifier).deleteInquiry(widget.inquiry!.inquiryNo!);
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('문의가 삭제되었습니다.'), backgroundColor: _green,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
      Navigator.pop(context, true);
    } else {
      final msg = ref.read(inquiryProvider).errorMessage ?? '삭제에 실패했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(
        title: _isEditMode ? '문의 수정' : '문의 작성',
        actions: [
          if (_isEditMode && !widget.inquiry!.isAnswered)
            TextButton(
              onPressed: _showDeleteDialog,
              style: TextButton.styleFrom(foregroundColor: _red),
              child: const Text('삭제', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
            // 답변완료 안내
            if (_isEditMode && !_canEdit)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: _orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('답변이 완료된 문의는 수정할 수 없습니다.',
                            style: TextStyle(color: _orange, fontSize: 13, letterSpacing: -0.2)),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // 폼 카드
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 제목 필드
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextFormField(
                          controller: _titleController,
                          enabled: _canEdit,
                          maxLength: 100,
                          style: const TextStyle(fontSize: 16, color: _label, letterSpacing: -0.3),
                          decoration: InputDecoration(
                            hintText: '문의 제목을 입력해주세요',
                            hintStyle: const TextStyle(color: _secondary, fontSize: 15),
                            prefixIcon: const Icon(Icons.title_rounded, color: _secondary, size: 20),
                            filled: true,
                            fillColor: _fieldBg,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.5)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
                            errorStyle: const TextStyle(color: _red, fontSize: 12),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '제목을 입력해주세요';
                            if (v.trim().length < 2) return '제목은 2자 이상 입력해주세요';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 내용 필드
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: TextFormField(
                            controller: _contentController,
                            enabled: _canEdit,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(fontSize: 15, color: _label, height: 1.6, letterSpacing: -0.2),
                            decoration: InputDecoration(
                              hintText: '문의 내용을 자세히 입력해주세요 (10자 이상)',
                              hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                              filled: true,
                              fillColor: _fieldBg,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.5)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
                              errorStyle: const TextStyle(color: _red, fontSize: 12),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '내용을 입력해주세요';
                              if (v.trim().length < 10) return '내용은 10자 이상 입력해주세요';
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 제출 버튼
            if (_canEdit)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      disabledBackgroundColor: _blue.withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Text(_isEditMode ? '수정하기' : '문의 제출하기',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

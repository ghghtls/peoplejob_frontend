import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/board_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/file_upload_service.dart';
import '../../widgets/app_bar.dart';

class BoardWritePage extends StatefulWidget {
  final int? boardNo;
  const BoardWritePage({super.key, this.boardNo});

  @override
  State<BoardWritePage> createState() => _BoardWritePageState();
}

class _BoardWritePageState extends State<BoardWritePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final _formKey = GlobalKey<FormState>();
  final BoardService _boardService = BoardService();
  final AuthService _authService = AuthService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _currentWriter;

  String? _attachedFileName;
  String? _uploadedFileUrl;
  bool _isUploading = false;

  final FileUploadService _fileService = FileUploadService();

  static const List<String> _categories = ['공지사항', '자유게시판', '질문게시판', '취업정보', '후기'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.boardNo != null;
    _loadCurrentUser();
    if (_isEditMode) _loadBoardData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final info = await _authService.getUserInfo();
    if (mounted) setState(() => _currentWriter = info['name'] ?? info['userid']);
  }

  Future<void> _loadBoardData() async {
    setState(() => _isLoading = true);
    try {
      final board = await _boardService.getBoardDetail(widget.boardNo!);
      if (mounted) {
        setState(() {
          _titleController.text = board['title'] ?? '';
          _contentController.text = board['content'] ?? '';
          _selectedCategory = board['category'];
          _uploadedFileUrl = board['filename'] as String?;
          _attachedFileName = board['originalFilename'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: _red));
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('카테고리를 선택해주세요'),
        backgroundColor: _red, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final boardData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _selectedCategory,
        'writer': _currentWriter,
        'regdate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'viewCount': 0,
        if (_uploadedFileUrl != null) 'filename': _uploadedFileUrl,
        if (_attachedFileName != null) 'originalFilename': _attachedFileName,
      };
      if (_isEditMode) {
        await _boardService.updateBoard(widget.boardNo!, boardData);
      } else {
        await _boardService.createBoard(boardData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditMode ? '게시글이 수정되었습니다' : '게시글이 등록되었습니다'),
          backgroundColor: _green, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: _red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('파일 크기는 10MB를 초과할 수 없습니다'), backgroundColor: _red,
                behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        }
        return;
      }

      setState(() {
        _attachedFileName = name;
        _uploadedFileUrl = null;
        _isUploading = true;
      });

      final res = await _fileService.uploadBoardFile(bytes, name);
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('파일 업로드에 실패했습니다'), backgroundColor: _red,
                behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일 선택 실패: $e'), backgroundColor: _red,
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    }
  }

  void _removeFile() {
    setState(() {
      _attachedFileName = null;
      _uploadedFileUrl = null;
    });
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case '공지사항': return _red;
      case '자유게시판': return _blue;
      case '질문게시판': return const Color(0xFFFF9500);
      case '취업정보': return _green;
      case '후기': return const Color(0xFF5856D6);
      default: return _secondary;
    }
  }

  void _showPreview() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미리볼 내용이 없습니다')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('미리보기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _label)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20, color: _secondary),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(4)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedCategory != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor(_selectedCategory!).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_selectedCategory!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _categoryColor(_selectedCategory!))),
                ),
                const SizedBox(height: 10),
              ],
              Text(_titleController.text.isEmpty ? '제목 없음' : _titleController.text,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.4)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: _secondary),
                const SizedBox(width: 4),
                Text(_currentWriter ?? '작성자', style: const TextStyle(fontSize: 12, color: _secondary)),
                const SizedBox(width: 12),
                Text(DateFormat('MM.dd HH:mm').format(DateTime.now()),
                    style: const TextStyle(fontSize: 12, color: _secondary)),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _contentController.text.isEmpty ? '내용 없음' : _contentController.text,
                      style: const TextStyle(fontSize: 15, height: 1.6, color: _label),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(
        title: _isEditMode ? '게시글 수정' : '게시글 작성',
        actions: [
          TextButton(
            onPressed: _showPreview,
            style: TextButton.styleFrom(foregroundColor: _secondary, minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
            child: const Text('미리보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            style: TextButton.styleFrom(foregroundColor: _blue, minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
            child: _isLoading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(_blue)))
                : Text(_isEditMode ? '수정' : '등록',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // 폼
          Expanded(
              child: (_isLoading && _isEditMode)
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 작성자 정보
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: _blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                    child: Center(
                                      child: Text(
                                        (_currentWriter ?? 'U').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _blue),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_currentWriter ?? '작성자',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: _label)),
                                      Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                                          style: const TextStyle(color: _secondary, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 카테고리 선택 (칩)
                            Container(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('카테고리',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: _categories.map((cat) {
                                      final selected = _selectedCategory == cat;
                                      final color = _categoryColor(cat);
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedCategory = cat),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: selected ? color : color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(cat,
                                              style: TextStyle(
                                                  fontSize: 13, fontWeight: FontWeight.w600,
                                                  color: selected ? Colors.white : color)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 제목
                            Container(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('제목',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _titleController,
                                    maxLength: 100,
                                    style: const TextStyle(fontSize: 15, color: _label, letterSpacing: -0.3),
                                    decoration: InputDecoration(
                                      hintText: '제목을 입력하세요',
                                      hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                                      filled: true,
                                      fillColor: _fieldBg,
                                      counterText: '',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blue, width: 1.5)),
                                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _red, width: 1.5)),
                                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _red, width: 1.5)),
                                      errorStyle: const TextStyle(color: _red, fontSize: 12),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return '제목을 입력해주세요';
                                      if (v.trim().length < 2) return '제목을 2자 이상 입력해주세요';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 내용
                            Container(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('내용',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _contentController,
                                    maxLines: 12,
                                    maxLength: 2000,
                                    style: const TextStyle(fontSize: 15, color: _label, height: 1.6, letterSpacing: -0.2),
                                    decoration: InputDecoration(
                                      hintText: '내용을 입력하세요 (10자 이상)',
                                      hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                                      filled: true,
                                      fillColor: _fieldBg,
                                      contentPadding: const EdgeInsets.all(14),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blue, width: 1.5)),
                                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _red, width: 1.5)),
                                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _red, width: 1.5)),
                                      errorStyle: const TextStyle(color: _red, fontSize: 12),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return '내용을 입력해주세요';
                                      if (v.trim().length < 10) return '내용을 10자 이상 입력해주세요';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 첨부파일
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
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
                                                letterSpacing: -0.2,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (_isUploading)
                                            const SizedBox(
                                              width: 16, height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: _secondary),
                                            )
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
                                          strokeAlign: BorderSide.strokeAlignInside,
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
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '이미지(jpg, png, gif), 문서(pdf, docx, hwp, xlsx) · 최대 10MB',
                                    style: TextStyle(fontSize: 11, color: _secondary.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 등록 버튼
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _blue,
                                  disabledBackgroundColor: _blue.withValues(alpha: 0.4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                    : Text(_isEditMode ? '수정 완료' : '게시글 등록',
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.3)),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
    );
  }
}

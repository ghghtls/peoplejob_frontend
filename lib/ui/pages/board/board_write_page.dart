import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/board_service.dart';
import '../../../services/auth_service.dart';

class BoardWritePage extends StatefulWidget {
  final int? boardNo; // 수정 모드일 때 사용

  const BoardWritePage({super.key, this.boardNo});

  @override
  State<BoardWritePage> createState() => _BoardWritePageState();
}

class _BoardWritePageState extends State<BoardWritePage> {
  final _formKey = GlobalKey<FormState>();
  final BoardService _boardService = BoardService();
  final AuthService _authService = AuthService();

  // 폼 컨트롤러들
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 상태 변수들
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _currentWriter;

  // 카테고리 옵션
  final List<String> _categories = ['공지사항', '자유게시판', '질문게시판', '취업정보', '후기'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.boardNo != null;
    _loadCurrentUser();

    if (_isEditMode) {
      _loadBoardData();
    }
  }

  Future<void> _loadCurrentUser() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _currentWriter = userInfo['name'] ?? userInfo['userid'];
    });
  }

  Future<void> _loadBoardData() async {
    if (widget.boardNo == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final boardDetail = await _boardService.getBoardDetail(widget.boardNo!);

      setState(() {
        _titleController.text = boardDetail['title'] ?? '';
        _contentController.text = boardDetail['content'] ?? '';
        _selectedCategory = boardDetail['category'];
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
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final boardData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _selectedCategory,
        'writer': _currentWriter,
        'regdate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'viewCount': 0,
      };

      if (_isEditMode) {
        await _boardService.updateBoard(widget.boardNo!, boardData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 수정되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _boardService.createBoard(boardData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 등록되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case '공지사항':
        return Colors.red;
      case '자유게시판':
        return Colors.blue;
      case '질문게시판':
        return Colors.orange;
      case '취업정보':
        return Colors.green;
      case '후기':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showPreview() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('미리볼 내용이 없습니다')));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.indigo[600]),
                    const SizedBox(width: 8),
                    const Text(
                      '미리보기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 카테고리
                if (_selectedCategory != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_selectedCategory!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedCategory!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 제목
                Text(
                  _titleController.text.isEmpty
                      ? '제목 없음'
                      : _titleController.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 작성자 정보
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _currentWriter ?? '작성자',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MM.dd HH:mm').format(DateTime.now()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 내용
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        _contentController.text.isEmpty
                            ? '내용 없음'
                            : _contentController.text,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '게시글 수정' : '게시글 작성'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          // 미리보기 버튼
          TextButton(
            onPressed: _showPreview,
            child: const Text(
              '미리보기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 등록/수정 버튼
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
                      // 작성자 정보 표시
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo[200]!),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo[100],
                              child: Text(
                                (_currentWriter ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Colors.indigo[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentWriter ?? '작성자',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'yyyy년 MM월 dd일',
                                  ).format(DateTime.now()),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 카테고리 선택
                      const Text(
                        '카테고리 *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: const Text('카테고리를 선택하세요'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(category),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 제목 입력
                      const Text(
                        '제목 *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '제목을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          if (value.trim().length < 2) {
                            return '제목을 2자 이상 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),
                      const SizedBox(height: 24),

                      // 내용 입력
                      const Text(
                        '내용 *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: '''내용을 입력하세요.

팁:
- 정확하고 구체적인 정보를 제공해주세요
- 다른 사용자에게 도움이 되는 내용을 작성해주세요
- 개인정보나 연락처는 공개하지 마세요''',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 15,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '내용을 입력해주세요';
                          }
                          if (value.trim().length < 10) {
                            return '내용을 10자 이상 입력해주세요';
                          }
                          return null;
                        },
                        maxLength: 2000,
                      ),
                      const SizedBox(height: 24),

                      // 첨부파일 (향후 구현)
                      const Text(
                        '첨부파일 (선택)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                              '이미지, 문서 파일 등을 첨부할 수 있습니다 (최대 10MB)',
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
                            backgroundColor: Colors.indigo[600],
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
                                    _isEditMode ? '수정 완료' : '게시글 등록',
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/board_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_bar.dart';

class BoardListPage extends StatefulWidget {
  const BoardListPage({super.key});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final BoardService _boardService = BoardService();
  final AuthService _authService = AuthService();
  final _searchController = TextEditingController();

  List<dynamic> _boards = [];
  List<dynamic> _filteredBoards = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  String _selectedCategory = '전체';
  String? _currentUser;

  final List<String> _categories = ['전체', '공지사항', '자유게시판', '질문게시판', '취업정보', '후기'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadBoards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final info = await _authService.getUserInfo();
    setState(() => _currentUser = info['name'] ?? info['userid']);
  }

  Future<void> _loadBoards() async {
    setState(() => _isLoading = true);
    try {
      final boards = _selectedCategory == '전체'
          ? await _boardService.getAllBoards()
          : await _boardService.getBoardsByCategory(_selectedCategory);
      setState(() {
        _boards = boards;
        _filteredBoards = boards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  void _filterBoards() {
    setState(() {
      _filteredBoards = _boards.where((b) =>
          _searchKeyword.isEmpty ||
          b['title'].toString().toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          b['writer'].toString().toLowerCase().contains(_searchKeyword.toLowerCase())).toList();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays == 0) return DateFormat('HH:mm').format(date);
      if (diff.inDays < 7) return '${diff.inDays}일 전';
      return DateFormat('MM.dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Color _categoryColor(String? cat) {
    switch (cat) {
      case '공지사항': return _red;
      case '자유게시판': return _blue;
      case '질문게시판': return const Color(0xFFFF9500);
      case '취업정보': return const Color(0xFF34C759);
      case '후기': return const Color(0xFF5856D6);
      default: return _secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '게시판',
        actions: [
          IconButton(
            onPressed: _loadBoards,
            icon: const Icon(Icons.refresh_rounded, color: _secondary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildResultCount(),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/board-write'),
        backgroundColor: _blue,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15, color: _label),
          decoration: InputDecoration(
            hintText: '제목, 작성자로 검색',
            hintStyle: const TextStyle(color: _secondary, fontSize: 15),
            prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 20),
            suffixIcon: _searchKeyword.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: _secondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchKeyword = '';
                      _filterBoards();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (v) {
            _searchKeyword = v;
            _filterBoards();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final selected = cat == _selectedCategory;
            final color = _categoryColor(cat == '전체' ? null : cat);
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
                _loadBoards();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: selected ? 0.0 : 0.05), blurRadius: 4)],
                ),
                child: Text(cat,
                    style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? Colors.white : _secondary)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Text('${_filteredBoards.length}개',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _blue, letterSpacing: -0.3)),
          const Text('의 게시글', style: TextStyle(fontSize: 15, color: _secondary, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));

    if (_filteredBoards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.article_outlined, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            Text(_boards.isEmpty ? '아직 게시글이 없습니다' : '검색 결과가 없습니다',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
            const SizedBox(height: 6),
            Text(_boards.isEmpty ? '첫 번째 게시글을 작성해보세요' : '다른 키워드로 검색해보세요',
                style: const TextStyle(fontSize: 14, color: _secondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBoards,
      color: _blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
        itemCount: _filteredBoards.length,
        itemBuilder: (context, i) => _buildCard(_filteredBoards[i]),
      ),
    );
  }

  Widget _buildCard(dynamic board) {
    final isNotice = board['category'] == '공지사항';
    final isMyBoard = _currentUser != null && board['writer'] == _currentUser;
    final catColor = _categoryColor(board['category']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isNotice ? _red.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isNotice ? Border.all(color: _red.withValues(alpha: 0.2)) : null,
        boxShadow: isNotice ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, '/board-detail', arguments: board['boardNo']),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(board['category'] ?? '일반',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catColor)),
                    ),
                    if (isMyBoard) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('내글',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFF9500))),
                      ),
                    ],
                    if (board['originalFilename'] != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.attach_file_rounded, size: 13, color: _secondary),
                    ],
                    const Spacer(),
                    Text(_formatDate(board['regdate']),
                        style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.2)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(board['title'] ?? '',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isNotice ? _red : _label,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                if ((board['content'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(board['content'].toString().replaceAll('\n', ' '),
                      style: const TextStyle(fontSize: 13, color: _secondary, height: 1.4),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 13, color: _secondary),
                    const SizedBox(width: 4),
                    Text(board['writer'] ?? '익명',
                        style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.2)),
                    const SizedBox(width: 12),
                    const Icon(Icons.visibility_outlined, size: 13, color: _secondary),
                    const SizedBox(width: 4),
                    Text('${board['viewCount'] ?? 0}',
                        style: const TextStyle(fontSize: 12, color: _secondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

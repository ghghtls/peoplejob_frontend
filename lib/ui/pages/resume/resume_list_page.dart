import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/resume_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_bar.dart';

class ResumeListPage extends StatefulWidget {
  const ResumeListPage({super.key});

  @override
  State<ResumeListPage> createState() => _ResumeListPageState();
}

class _ResumeListPageState extends State<ResumeListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final ResumeService _resumeService = ResumeService();
  final AuthService _authService = AuthService();
  final _searchController = TextEditingController();

  List<dynamic> _resumes = [];
  List<dynamic> _filteredResumes = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  int? _currentUserNo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _currentUserNo = int.tryParse(userInfo['userNo'] ?? '0');
    });
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    setState(() => _isLoading = true);
    try {
      final resumes = (_currentUserNo != null)
          ? await _resumeService.getUserResumes(_currentUserNo!)
          : <dynamic>[];
      setState(() {
        _resumes = resumes;
        _filteredResumes = resumes;
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

  void _filterResumes() {
    setState(() {
      _filteredResumes = _resumes.where((resume) {
        return _searchKeyword.isEmpty ||
            resume['title'].toString().toLowerCase().contains(_searchKeyword.toLowerCase());
      }).toList();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return DateFormat('yyyy.MM.dd').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void _deleteResume(int resumeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('이력서 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('이 이력서를 삭제하시겠습니까?\n삭제된 이력서는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _resumeService.deleteResume(resumeId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('이력서가 삭제되었습니다'),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  _loadResumes();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '내 이력서',
        actions: [
          IconButton(
            onPressed: _loadResumes,
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
          _buildResultCount(),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/resume-register'),
        backgroundColor: _green,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
            hintText: '이력서 제목으로 검색',
            hintStyle: const TextStyle(color: _secondary, fontSize: 15),
            prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 20),
            suffixIcon: _searchKeyword.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: _secondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchKeyword = '';
                      _filterResumes();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (v) {
            _searchKeyword = v;
            _filterResumes();
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
          Text('${_filteredResumes.length}개',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _green, letterSpacing: -0.3)),
          const Text('의 이력서', style: TextStyle(fontSize: 15, color: _secondary, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));

    if (_filteredResumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.description_outlined, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            const Text('등록된 이력서가 없습니다',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
            const SizedBox(height: 6),
            const Text('새 이력서를 작성해보세요',
                style: TextStyle(fontSize: 14, color: _secondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResumes,
      color: _blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredResumes.length,
        itemBuilder: (context, i) => _buildCard(_filteredResumes[i]),
      ),
    );
  }

  Widget _buildCard(dynamic resume) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, '/resume-detail', arguments: resume['resumeNo']),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(resume['title'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.4)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/resume-edit', arguments: resume['resumeNo']),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: _blue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.edit_outlined, color: _blue, size: 16),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _deleteResume(resume['resumeNo']),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: _red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.delete_outline_rounded, color: _red, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    if ((resume['hopeJobtype'] ?? '').toString().isNotEmpty)
                      _tag(Icons.work_outline_rounded, resume['hopeJobtype']),
                    if ((resume['hopeLocation'] ?? '').toString().isNotEmpty)
                      _tag(Icons.location_on_outlined, resume['hopeLocation']),
                    if ((resume['career'] ?? '').toString().isNotEmpty)
                      _tag(Icons.timeline_rounded, resume['career']),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF2F2F7)),
                const SizedBox(height: 10),
                Text('등록 ${_formatDate(resume['regdate'])}',
                    style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _secondary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: _secondary)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/scrap_service.dart';
import '../../../widgets/app_bar.dart';

class ScrapListPage extends StatefulWidget {
  const ScrapListPage({super.key});

  @override
  State<ScrapListPage> createState() => _ScrapListPageState();
}

class _ScrapListPageState extends State<ScrapListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _orange = Color(0xFFFF9500);

  final ScrapService _scrapService = ScrapService();
  final _searchController = TextEditingController();
  List<dynamic> _scraps = [];
  List<dynamic> _filteredScraps = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  String _selectedJobType = '전체';

  final List<String> _jobTypes = ['전체', '정규직', '계약직', '인턴', '프리랜서', '파트타임'];

  @override
  void initState() {
    super.initState();
    _loadScraps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScraps() async {
    setState(() => _isLoading = true);
    try {
      final scraps = await _scrapService.getMyScrapList();
      if (!mounted) return;
      setState(() {
        _scraps = scraps;
        _isLoading = false;
      });
      _filterScraps();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _filterScraps() {
    setState(() {
      _filteredScraps = _scraps.where((scrap) {
        final job = scrap['jobopening'];
        if (job == null) return false;
        final matchesKeyword = _searchKeyword.isEmpty ||
            (job['title'] ?? '').toString().toLowerCase().contains(_searchKeyword.toLowerCase());
        final matchesType = _selectedJobType == '전체' || job['jobType'] == _selectedJobType;
        return matchesKeyword && matchesType;
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

  bool _isExpired(String? d) {
    if (d == null) return false;
    try {
      return DateTime.parse(d).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  int _daysLeft(String? d) {
    if (d == null) return -1;
    try {
      return DateTime.parse(d).difference(DateTime.now()).inDays;
    } catch (_) {
      return -1;
    }
  }

  void _removeScrap(int scrapNo, String jobTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('스크랩 제거', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('$jobTitle을(를) 스크랩에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _scrapService.deleteScrapById(scrapNo);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('스크랩에서 제거되었습니다'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  _loadScraps();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('제거', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _clearAllScraps() {
    if (_scraps.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('전체 스크랩 제거', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('모든 스크랩(${_scraps.length}개)을 제거하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);
              try {
                for (var scrap in _scraps) {
                  await _scrapService.deleteScrapById(scrap['scrapNo']);
                }
                if (mounted) _loadScraps();
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('전체 제거', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
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
        title: '스크랩 공고',
        actions: [
          if (_scraps.isNotEmpty)
            TextButton(
              onPressed: _clearAllScraps,
              style: TextButton.styleFrom(foregroundColor: _red, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              child: const Text('전체 삭제', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          IconButton(
            onPressed: _loadScraps,
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
          _buildFilterChips(),
          _buildResultCount(),
          Expanded(child: _buildList()),
        ],
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
            hintText: '스크랩한 채용공고 검색',
            hintStyle: const TextStyle(color: _secondary, fontSize: 15),
            prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 20),
            suffixIcon: _searchKeyword.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: _secondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchKeyword = '';
                      _filterScraps();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (v) {
            _searchKeyword = v;
            _filterScraps();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _jobTypes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final item = _jobTypes[i];
            final selected = item == _selectedJobType;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedJobType = item);
                _filterScraps();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? _orange : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: selected ? 0.0 : 0.05), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Text(item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : _secondary,
                    )),
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
          Text('${_filteredScraps.length}개',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _orange, letterSpacing: -0.3)),
          const Text('의 스크랩', style: TextStyle(fontSize: 15, color: _secondary, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));

    if (_filteredScraps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.bookmark_border_rounded, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            Text(_scraps.isEmpty ? '스크랩한 채용공고가 없습니다' : '검색 결과가 없습니다',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
            const SizedBox(height: 6),
            Text(_scraps.isEmpty ? '관심있는 채용공고를 스크랩해보세요' : '다른 키워드로 검색해보세요',
                style: const TextStyle(fontSize: 14, color: _secondary)),
            if (_scraps.isEmpty) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/job-list'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _orange, side: const BorderSide(color: _orange, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('채용공고 보기', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScraps,
      color: _blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredScraps.length,
        itemBuilder: (context, i) => _buildCard(_filteredScraps[i]),
      ),
    );
  }

  Widget _buildCard(dynamic scrap) {
    final job = scrap['jobopening'] as Map?;
    if (job == null) return const SizedBox.shrink();
    final expired = _isExpired(job['deadline'] as String?);
    final days = _daysLeft(job['deadline'] as String?);

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
          onTap: () => Navigator.pushNamed(context, '/job-detail', arguments: job['jobopeningNo']),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(job['title'] ?? '',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: expired ? _secondary : _label,
                            decoration: expired ? TextDecoration.lineThrough : null,
                            letterSpacing: -0.4,
                          )),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (expired)
                          _badge('마감', _red.withValues(alpha: 0.12), _red)
                        else if (days >= 0 && days <= 7)
                          _badge('D-$days', _orange.withValues(alpha: 0.12), _orange),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeScrap(scrap['scrapNo'], job['title'] ?? '채용공고'),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bookmark_remove_rounded, color: _red, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    if ((job['jobType'] ?? '').toString().isNotEmpty) _tag(Icons.work_outline_rounded, job['jobType']),
                    if ((job['location'] ?? '').toString().isNotEmpty) _tag(Icons.location_on_outlined, job['location']),
                    if ((job['career'] ?? '').toString().isNotEmpty) _tag(Icons.timeline_rounded, job['career']),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF2F2F7)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('스크랩 ${_formatDate(scrap['regdate'])}',
                        style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.2)),
                    Text('마감 ${_formatDate(job['deadline'])}',
                        style: TextStyle(fontSize: 12, color: expired ? _red : _secondary,
                            fontWeight: expired ? FontWeight.w600 : FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
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

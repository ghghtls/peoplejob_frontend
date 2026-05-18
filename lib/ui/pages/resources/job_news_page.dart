import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../../services/board_service.dart';

class JobNewsPage extends StatefulWidget {
  const JobNewsPage({super.key});

  @override
  State<JobNewsPage> createState() => _JobNewsPageState();
}

class _JobNewsPageState extends State<JobNewsPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _orange = Color(0xFFFF9500);

  final BoardService _boardService = BoardService();
  List<Map<String, dynamic>> _newsList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final items = await _boardService.getBoardsByCategory('취업뉴스');
      setState(() {
        _newsList = items.map((e) => (e as Map).cast<String, dynamic>()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '취업 뉴스'),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('뉴스를 불러올 수 없습니다', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('다시 시도'),
              style: OutlinedButton.styleFrom(foregroundColor: _blue, side: const BorderSide(color: _blue)),
            ),
          ],
        ),
      );
    }

    if (_newsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('등록된 뉴스가 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: _orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.newspaper_rounded, size: 20, color: _orange),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('최신 취업 정보와 채용 트렌드를 확인하세요.',
                      style: TextStyle(fontSize: 13, color: _orange, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: _newsList.asMap().entries.map((entry) {
                final i = entry.key;
                final news = entry.value;
                final isLast = i == _newsList.length - 1;
                final title = news['title'] as String? ?? '';
                final content = news['content'] as String? ?? '';
                final date = (news['regdate'] as String? ?? '').split('T').first;
                final summary = content.replaceAll('\n', ' ');

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: isLast
                            ? const BorderRadius.vertical(bottom: Radius.circular(14))
                            : BorderRadius.zero,
                        onTap: () => _showDetail(title, content, date),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: _orange.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.article_outlined, size: 20, color: _orange),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                            color: _label, letterSpacing: -0.3)),
                                    const SizedBox(height: 4),
                                    Text(summary,
                                        style: const TextStyle(fontSize: 12, color: _secondary, height: 1.4),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 11, color: _secondary),
                                        const SizedBox(width: 3),
                                        Text(date, style: const TextStyle(fontSize: 11, color: _secondary)),
                                        const Spacer(),
                                        const Icon(Icons.chevron_right_rounded, size: 16, color: _secondary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(String title, String content, String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _NewsDetailPage(title: title, content: content, date: date),
      ),
    );
  }
}

class _NewsDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);

  const _NewsDetailPage({required this.title, required this.content, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('취업 뉴스',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                  color: _label, letterSpacing: -0.5, height: 1.3)),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: _secondary),
                            const SizedBox(width: 5),
                            Text(date, style: const TextStyle(fontSize: 13, color: _secondary)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('내용',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Text(content,
                          style: const TextStyle(fontSize: 15, height: 1.7, color: _label, letterSpacing: -0.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

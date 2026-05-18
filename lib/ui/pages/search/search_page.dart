import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);

  final _searchController = TextEditingController();
  String _keyword = '';
  bool _hasSearched = false;

  final _dummyJobs = [
    {'title': '백엔드 개발자', 'company': '피플잡', 'jobType': '정규직', 'location': '서울'},
    {'title': '앱 개발자 (Flutter)', 'company': '잡앤조이', 'jobType': '계약직', 'location': '경기'},
    {'title': '프론트엔드 개발자', 'company': '테크스타', 'jobType': '정규직', 'location': '서울'},
  ];

  final _dummyResumes = [
    {'name': '홍길동', 'title': '신입 백엔드 개발자 이력서', 'job': '백엔드 개발자'},
    {'name': '이순신', 'title': '경력 앱 개발자 포트폴리오', 'job': '모바일 앱 개발자'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final kw = _searchController.text.trim();
    if (kw.isEmpty) return;
    setState(() { _keyword = kw; _hasSearched = true; });
  }

  List<Map<String, String>> get _filteredJobs => _keyword.isEmpty ? _dummyJobs
      : _dummyJobs.where((j) => j['title']!.contains(_keyword) || j['company']!.contains(_keyword)).toList();

  List<Map<String, String>> get _filteredResumes => _keyword.isEmpty ? _dummyResumes
      : _dummyResumes.where((r) => r['title']!.contains(_keyword) || r['job']!.contains(_keyword)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '통합 검색'),
      body: Column(
        children: [
            const SizedBox(height: 10),

            // 검색 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 15, color: _label),
                        decoration: InputDecoration(
                          hintText: '직무, 회사명, 이름으로 검색',
                          hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('검색', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 결과
            Expanded(
              child: !_hasSearched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.search_rounded, size: 36, color: _secondary),
                          ),
                          const SizedBox(height: 16),
                          const Text('검색어를 입력해주세요',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _label)),
                          const SizedBox(height: 6),
                          const Text('채용공고와 이력서를 한 번에 검색합니다',
                              style: TextStyle(fontSize: 14, color: _secondary)),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        // 채용공고 결과
                        _sectionHeader('채용공고', _filteredJobs.length),
                        const SizedBox(height: 8),
                        if (_filteredJobs.isEmpty)
                          _emptySection('채용공고 검색 결과가 없습니다')
                        else
                          ..._filteredJobs.map((job) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent, borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(color: _blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.work_outline_rounded, size: 20, color: _blue),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(job['title']!,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                                            const SizedBox(height: 3),
                                            Text('${job['company']} • ${job['jobType']} • ${job['location']}',
                                                style: const TextStyle(fontSize: 12, color: _secondary)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE5E5EA)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),

                        const SizedBox(height: 16),

                        // 이력서 결과
                        _sectionHeader('이력서', _filteredResumes.length),
                        const SizedBox(height: 8),
                        if (_filteredResumes.isEmpty)
                          _emptySection('이력서 검색 결과가 없습니다')
                        else
                          ..._filteredResumes.map((resume) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent, borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                        child: Center(
                                          child: Text(resume['name']!.substring(0, 1),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _green)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(resume['title']!,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label),
                                                maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 3),
                                            Text('${resume['name']} • ${resume['job']}',
                                                style: const TextStyle(fontSize: 12, color: _secondary)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE5E5EA)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                      ],
                    ),
            ),
          ],
        ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: _blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$count건', style: const TextStyle(fontSize: 12, color: _blue, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _emptySection(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(message, style: const TextStyle(fontSize: 14, color: _secondary)),
    );
  }
}

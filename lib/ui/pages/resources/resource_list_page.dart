import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'resource_detail_page.dart';
import '../../widgets/app_bar.dart';
import '../../../services/board_service.dart';

class ResourceListPage extends StatefulWidget {
  const ResourceListPage({super.key});

  @override
  State<ResourceListPage> createState() => _ResourceListPageState();
}

class _ResourceListPageState extends State<ResourceListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);

  final BoardService _boardService = BoardService();
  List<Map<String, dynamic>> _boardResources = [];
  bool _isLoading = true;

  static const _staticResources = [
    {
      'title': '2025 채용 설명회 자료집',
      'date': '2025-04-29',
      'fileUrl': '',
      'content': '채용 설명회 발표자료 및 기업 정보가 포함되어 있습니다.',
      'icon': Icons.event_note_rounded,
    },
    {
      'title': '자소서 작성 가이드',
      'date': '2025-04-22',
      'fileUrl': '',
      'content': '자기소개서 작성 꿀팁과 샘플 양식을 제공합니다.',
      'icon': Icons.edit_note_rounded,
    },
    {
      'title': '면접 준비 체크리스트',
      'date': '2025-04-15',
      'fileUrl': '',
      'content': '면접 전 준비사항과 자주 묻는 질문 모음입니다.',
      'icon': Icons.checklist_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBoardResources();
  }

  Future<void> _loadBoardResources() async {
    try {
      final items = await _boardService.getBoardsByCategory('자료실');
      setState(() {
        _boardResources = items.map((e) => (e as Map).cast<String, dynamic>()).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = _boardResources.isNotEmpty
        ? _boardResources.map((b) => {
              'title': b['title'] as String? ?? '제목 없음',
              'date': (b['regdate'] as String? ?? '').split('T').first,
              'fileUrl': b['fileUrl'] as String? ?? '',
              'content': b['content'] as String? ?? '',
              'icon': Icons.description_rounded,
            }).toList()
        : _staticResources;

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '자료실'),
      body: Column(
        children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBoardResources,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    // 취업 자료 섹션
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('취업 자료',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    ),
                    if (_isLoading)
                      Container(
                        height: 120,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else
                      ...resources.map((item) => _buildResourceCard(context, item)),

                    const SizedBox(height: 16),

                    // 유용한 도구 섹션
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('유용한 도구',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          _buildToolTile(
                            icon: Icons.text_fields_rounded,
                            color: _blue,
                            title: '글자 수 세기',
                            subtitle: '자기소개서 글자 수를 실시간으로 확인',
                            onTap: () => Navigator.pushNamed(context, '/tools/wordcount'),
                            trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE5E5EA)),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 취업 정보 섹션
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('취업 정보',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          _buildToolTile(
                            icon: Icons.newspaper_rounded,
                            color: _orange,
                            title: '취업 뉴스',
                            subtitle: '최신 취업 트렌드 및 채용 소식',
                            onTap: () => Navigator.pushNamed(context, '/resources/news'),
                            trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE5E5EA)),
                            isLast: false,
                          ),
                          _buildToolTile(
                            icon: Icons.open_in_new_rounded,
                            color: _secondary,
                            title: '워크넷 바로가기',
                            subtitle: '고용노동부 공식 취업포털',
                            onTap: () async {
                              final uri = Uri.parse('https://www.work.go.kr/');
                              if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFFE5E5EA)),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildResourceCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResourceDetailPage(
                title: item['title'] as String,
                content: item['content'] as String,
                date: item['date'] as String,
                fileUrl: item['fileUrl'] as String,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, size: 22, color: _green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                              color: _label, letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.calendar_today_rounded, size: 11, color: _secondary),
                        const SizedBox(width: 3),
                        Text(item['date'] as String,
                            style: const TextStyle(fontSize: 12, color: _secondary)),
                        if ((item['fileUrl'] as String).isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.attach_file_rounded, size: 11, color: _secondary),
                          const SizedBox(width: 2),
                          const Text('첨부파일', style: TextStyle(fontSize: 12, color: _secondary)),
                        ],
                      ]),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE5E5EA)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Widget trailing,
    required bool isLast,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(14))
                : BorderRadius.zero,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.3)),
                        const SizedBox(height: 3),
                        Text(subtitle, style: const TextStyle(fontSize: 12, color: _secondary)),
                      ],
                    ),
                  ),
                  trailing,
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
      ],
    );
  }
}

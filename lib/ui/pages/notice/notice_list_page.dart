import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/notice_provider.dart';
import 'notice_detail_page.dart';
import 'widgets/notice_list_view.dart';
import '../../widgets/app_bar.dart';

class NoticeListPage extends ConsumerStatefulWidget {
  const NoticeListPage({super.key});

  @override
  ConsumerState<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends ConsumerState<NoticeListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotices());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotices() async {
    await ref.read(noticeProvider.notifier).loadNotices(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(noticeProvider.notifier).loadMoreNotices();
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      ref.read(noticeProvider.notifier).searchNotices(keyword);
    } else {
      ref.read(noticeProvider.notifier).clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(noticeProvider.notifier).clearSearch();
  }

  Future<void> _navigateToDetail(int noticeId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoticeDetailPage(noticeId: noticeId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);

    return Scaffold(
      backgroundColor: _fieldBg,
      appBar: buildCommonAppBar(
        title: '공지사항',
        actions: [
          IconButton(
            onPressed: _loadNotices,
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
            const SizedBox(height: 10),

            // 검색 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 14, color: _label),
                        decoration: InputDecoration(
                          hintText: '공지사항 검색',
                          hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 18),
                          suffixIcon: noticeState.isSearching
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16, color: _secondary),
                                  onPressed: _clearSearch,
                                  style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('검색', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // 검색 결과 배너
            if (noticeState.isSearching) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 14, color: _blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text("'${noticeState.searchKeyword}' 검색 결과 (${noticeState.notices.length}건)",
                            style: const TextStyle(fontSize: 13, color: _blue, fontWeight: FontWeight.w500)),
                      ),
                      TextButton(
                        onPressed: _clearSearch,
                        style: TextButton.styleFrom(foregroundColor: _blue, minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                        child: const Text('전체보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),

            // 목록
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadNotices,
                color: _blue,
                child: Builder(builder: (context) {
                  if (noticeState.isLoading && noticeState.notices.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
                  }

                  if (noticeState.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.error_outline_rounded, size: 36, color: _red),
                          ),
                          const SizedBox(height: 16),
                          Text(noticeState.errorMessage!,
                              style: const TextStyle(fontSize: 15, color: _secondary), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(noticeProvider.notifier).clearError();
                              _loadNotices();
                            },
                            style: OutlinedButton.styleFrom(foregroundColor: _blue,
                                side: const BorderSide(color: _blue, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('다시 시도', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!noticeState.hasNotices) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.notifications_none_rounded, size: 36, color: _secondary),
                          ),
                          const SizedBox(height: 16),
                          const Text('공지사항이 없습니다',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
                        ],
                      ),
                    );
                  }

                  return NoticeListView(
                    notices: noticeState.notices,
                    scrollController: _scrollController,
                    onNoticeTap: _navigateToDetail,
                    isLoading: noticeState.isLoading,
                    hasMore: noticeState.hasMore,
                  );
                }),
              ),
            ),
          ],
        ),
    );
  }
}

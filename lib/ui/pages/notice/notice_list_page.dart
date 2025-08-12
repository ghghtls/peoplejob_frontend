import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/notice_provider.dart';
import 'notice_detail_page.dart';
import 'widgets/notice_list_view.dart';
import 'widgets/empty_notice_message.dart';

class NoticeListPage extends ConsumerStatefulWidget {
  const NoticeListPage({super.key});

  @override
  ConsumerState<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends ConsumerState<NoticeListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotices();
    });

    // 무한 스크롤 설정
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
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
      MaterialPageRoute(
        builder: (context) => NoticeDetailPage(noticeId: noticeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotices),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '공지사항 검색',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          noticeState.isSearching
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('검색'),
                ),
              ],
            ),
          ),

          // 검색 결과 표시
          if (noticeState.isSearching)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    "'${noticeState.searchKeyword}' 검색 결과 (${noticeState.notices.length}건)",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('전체보기'),
                  ),
                ],
              ),
            ),

          // 공지사항 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNotices,
              child: Builder(
                builder: (context) {
                  if (noticeState.isLoading && noticeState.notices.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (noticeState.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            noticeState.errorMessage!,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(noticeProvider.notifier).clearError();
                              _loadNotices();
                            },
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!noticeState.hasNotices) {
                    return const EmptyNoticeMessage();
                  }

                  return NoticeListView(
                    notices: noticeState.notices,
                    scrollController: _scrollController,
                    onNoticeTap: _navigateToDetail,
                    isLoading: noticeState.isLoading,
                    hasMore: noticeState.hasMore,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

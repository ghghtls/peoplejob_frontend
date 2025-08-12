import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/model/notice.dart';
import 'package:peoplejob_frontend/services/notice_service.dart';

// 공지사항 서비스 Provider
final noticeServiceProvider = Provider<NoticeService>((ref) {
  return NoticeService();
});

// 공지사항 상태 클래스
class NoticeState {
  final List<Notice> notices;
  final Notice? selectedNotice;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String searchKeyword;

  NoticeState({
    this.notices = const [],
    this.selectedNotice,
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 0,
    this.totalPages = 0,
    this.hasMore = false,
    this.searchKeyword = '',
  });

  bool get hasNotices => notices.isNotEmpty;
  bool get isSearching => searchKeyword.isNotEmpty;

  NoticeState copyWith({
    List<Notice>? notices,
    Notice? selectedNotice,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? searchKeyword,
    bool clearSelectedNotice = false,
    bool clearError = false,
    bool clearSearch = false,
  }) {
    return NoticeState(
      notices: notices ?? this.notices,
      selectedNotice:
          clearSelectedNotice ? null : (selectedNotice ?? this.selectedNotice),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      searchKeyword: clearSearch ? '' : (searchKeyword ?? this.searchKeyword),
    );
  }
}

// 공지사항 StateNotifier
class NoticeNotifier extends StateNotifier<NoticeState> {
  final NoticeService _noticeService;

  NoticeNotifier(this._noticeService) : super(NoticeState());

  // 공지사항 목록 조회
  Future<void> loadNotices({bool refresh = false}) async {
    if (refresh || state.notices.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final result = await _noticeService.getNoticesWithPaging(
        page: refresh ? 0 : state.currentPage,
        size: 10,
      );

      final notices = result['notices'] as List<Notice>;

      state = state.copyWith(
        notices: refresh ? notices : [...state.notices, ...notices],
        isLoading: false,
        currentPage: result['currentPage'],
        totalPages: result['totalPages'],
        hasMore: result['hasNext'],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print('공지사항 목록 로드 실패: $e');
    }
  }

  // 더 많은 공지사항 로드 (무한 스크롤)
  Future<void> loadMoreNotices() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      final result = await _noticeService.getNoticesWithPaging(
        page: state.currentPage + 1,
        size: 10,
      );

      final notices = result['notices'] as List<Notice>;

      state = state.copyWith(
        notices: [...state.notices, ...notices],
        currentPage: result['currentPage'],
        hasMore: result['hasNext'],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      print('추가 공지사항 로드 실패: $e');
    }
  }

  // 공지사항 상세 조회
  Future<void> loadNoticeDetail(int noticeId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final notice = await _noticeService.getNoticeDetail(noticeId);
      if (notice != null) {
        state = state.copyWith(selectedNotice: notice, isLoading: false);
      } else {
        state = state.copyWith(
          errorMessage: '공지사항을 찾을 수 없습니다.',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print('공지사항 상세 로드 실패: $e');
    }
  }

  // 공지사항 검색
  Future<void> searchNotices(String keyword) async {
    state = state.copyWith(
      isLoading: true,
      searchKeyword: keyword,
      clearError: true,
    );

    try {
      final result = await _noticeService.searchNotices(
        keyword: keyword,
        page: 0,
        size: 20,
      );

      final notices = result['notices'] as List<Notice>;

      state = state.copyWith(
        notices: notices,
        isLoading: false,
        currentPage: result['currentPage'],
        totalPages: result['totalPages'],
        hasMore: result['hasNext'],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print('공지사항 검색 실패: $e');
    }
  }

  // 검색 초기화
  void clearSearch() {
    state = state.copyWith(clearSearch: true);
    loadNotices(refresh: true);
  }

  // 선택된 공지사항 초기화
  void clearSelectedNotice() {
    state = state.copyWith(clearSelectedNotice: true);
  }

  // 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // 새로고침
  Future<void> refresh() async {
    await loadNotices(refresh: true);
  }
}

// 공지사항 Provider
final noticeProvider = StateNotifierProvider<NoticeNotifier, NoticeState>((
  ref,
) {
  final noticeService = ref.watch(noticeServiceProvider);
  return NoticeNotifier(noticeService);
});

// 중요 공지사항 Provider
final importantNoticesProvider = FutureProvider<List<Notice>>((ref) async {
  final noticeService = ref.watch(noticeServiceProvider);
  return await noticeService.getImportantNotices();
});

// 최근 공지사항 Provider (메인 페이지용)
final recentNoticesProvider = FutureProvider<List<Notice>>((ref) async {
  final noticeService = ref.watch(noticeServiceProvider);
  return await noticeService.getRecentNotices(limit: 5);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/inquiry.dart';
import '../../services/inquiry_service.dart';

// 문의사항 서비스 Provider
final inquiryServiceProvider = Provider<InquiryService>((ref) {
  return InquiryService();
});

// 문의사항 상태 클래스
class InquiryState {
  final List<Inquiry> inquiries;
  final Inquiry? selectedInquiry;
  final bool isLoading;
  final String? errorMessage;

  InquiryState({
    this.inquiries = const [],
    this.selectedInquiry,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasInquiries => inquiries.isNotEmpty;

  InquiryState copyWith({
    List<Inquiry>? inquiries,
    Inquiry? selectedInquiry,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedInquiry = false,
    bool clearError = false,
  }) {
    return InquiryState(
      inquiries: inquiries ?? this.inquiries,
      selectedInquiry:
          clearSelectedInquiry
              ? null
              : (selectedInquiry ?? this.selectedInquiry),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// 문의사항 StateNotifier
class InquiryNotifier extends StateNotifier<InquiryState> {
  final InquiryService _inquiryService;

  InquiryNotifier(this._inquiryService) : super(InquiryState());

  // 내 문의 목록 조회
  Future<void> loadMyInquiries() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final inquiriesData = await _inquiryService.getMyInquiries();
      final inquiries =
          inquiriesData.map((data) => Inquiry.fromJson(data)).toList();

      // 최신순으로 정렬
      inquiries.sort((a, b) => (b.regdate ?? '').compareTo(a.regdate ?? ''));

      state = state.copyWith(inquiries: inquiries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: '문의 목록을 불러오는데 실패했습니다.',
        isLoading: false,
      );
      print('문의 목록 로드 실패: $e');
    }
  }

  // 문의 상세 조회
  Future<void> loadInquiryDetail(int inquiryNo) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final inquiryData = await _inquiryService.getInquiryDetail(inquiryNo);
      if (inquiryData != null) {
        final inquiry = Inquiry.fromJson(inquiryData);
        state = state.copyWith(selectedInquiry: inquiry, isLoading: false);
      } else {
        state = state.copyWith(
          errorMessage: '문의를 찾을 수 없습니다.',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '문의 상세 정보를 불러오는데 실패했습니다.',
        isLoading: false,
      );
      print('문의 상세 로드 실패: $e');
    }
  }

  // 문의 등록
  Future<bool> createInquiry(String title, String content) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await _inquiryService.createInquiry(title, content);
      if (success) {
        // 등록 후 목록 새로고침
        await loadMyInquiries();
        return true;
      } else {
        state = state.copyWith(
          errorMessage: '문의 등록에 실패했습니다.',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '문의 등록 중 오류가 발생했습니다.',
        isLoading: false,
      );
      print('문의 등록 실패: $e');
      return false;
    }
  }

  // 문의 수정
  Future<bool> updateInquiry(
    int inquiryNo,
    String title,
    String content,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await _inquiryService.updateInquiry(
        inquiryNo,
        title,
        content,
      );
      if (success) {
        // 수정 후 목록 새로고침
        await loadMyInquiries();
        return true;
      } else {
        state = state.copyWith(
          errorMessage: '문의 수정에 실패했습니다.',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '문의 수정 중 오류가 발생했습니다.',
        isLoading: false,
      );
      print('문의 수정 실패: $e');
      return false;
    }
  }

  // 문의 삭제
  Future<bool> deleteInquiry(int inquiryNo) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await _inquiryService.deleteInquiry(inquiryNo);
      if (success) {
        // 삭제 후 목록에서 제거
        final updatedInquiries =
            state.inquiries
                .where((inquiry) => inquiry.inquiryNo != inquiryNo)
                .toList();
        state = state.copyWith(inquiries: updatedInquiries, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: '문의 삭제에 실패했습니다.',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '문의 삭제 중 오류가 발생했습니다.',
        isLoading: false,
      );
      print('문의 삭제 실패: $e');
      return false;
    }
  }

  // 선택된 문의 초기화
  void clearSelectedInquiry() {
    state = state.copyWith(clearSelectedInquiry: true);
  }

  // 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// 문의사항 Provider
final inquiryProvider = StateNotifierProvider<InquiryNotifier, InquiryState>((
  ref,
) {
  final inquiryService = ref.watch(inquiryServiceProvider);
  return InquiryNotifier(inquiryService);
});

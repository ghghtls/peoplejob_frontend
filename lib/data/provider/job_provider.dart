import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../model/job.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';

// Job 상태 관리
class JobState {
  final List<Job> jobs;
  final Map<String, int> statusCounts;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final Job? selectedJob;
  final String? currentFilter; // 현재 필터 상태
  final String? searchKeyword; // 검색 키워드

  JobState({
    this.jobs = const [],
    this.statusCounts = const {},
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.selectedJob,
    this.currentFilter,
    this.searchKeyword,
  });

  JobState copyWith({
    List<Job>? jobs,
    Map<String, int>? statusCounts,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    Job? selectedJob,
    String? currentFilter,
    String? searchKeyword,
  }) {
    return JobState(
      jobs: jobs ?? this.jobs,
      statusCounts: statusCounts ?? this.statusCounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedJob: selectedJob ?? this.selectedJob,
      currentFilter: currentFilter ?? this.currentFilter,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

// Job Provider Notifier
class JobNotifier extends StateNotifier<JobState> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();

  JobNotifier() : super(JobState());

  // ============ 기본 CRUD 작업 ============

  // 채용공고 생성 (기본 임시저장 상태)
  Future<bool> createJob(Job job) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.createJobPosting(job);

      if (result['success']) {
        // 생성된 채용공고를 목록에 추가
        final newJob = result['job'] as Job;
        final updatedJobs = [newJob, ...state.jobs];

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        // 상태별 개수 업데이트
        await _updateStatusCounts();

        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return false;
    }
  }

  // 임시저장
  Future<bool> saveDraft(Job job) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.saveDraft(job.toJson());

      if (result['success']) {
        final savedJob = Job.fromJson(result['job']);

        // 기존 임시저장 업데이트 또는 새로 추가
        final updatedJobs =
            state.jobs.map((existingJob) {
              return existingJob.jobNo == savedJob.jobNo
                  ? savedJob
                  : existingJob;
            }).toList();

        // 새로운 임시저장인 경우 목록에 추가
        if (!updatedJobs.any((job) => job.jobNo == savedJob.jobNo)) {
          updatedJobs.insert(0, savedJob);
        }

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        await _updateStatusCounts();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return false;
    }
  }

  // 채용공고 게시
  Future<bool> publishJob(int jobNo) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final result = await _jobService.publishJob(jobNo, userNo);

      if (result['success']) {
        final publishedJob = Job.fromJson(result['job']);

        // 목록에서 해당 채용공고 업데이트
        final updatedJobs =
            state.jobs.map((job) {
              return job.jobNo == jobNo ? publishedJob : job;
            }).toList();

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        await _updateStatusCounts();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return false;
    }
  }

  // 상태 변경
  Future<bool> changeJobStatus(int jobNo, String status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final result = await _jobService.changeJobStatus(jobNo, status, userNo);

      if (result['success']) {
        final updatedJob = Job.fromJson(result['job']);

        // 목록에서 해당 채용공고 업데이트
        final updatedJobs =
            state.jobs.map((job) {
              return job.jobNo == jobNo ? updatedJob : job;
            }).toList();

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        await _updateStatusCounts();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return false;
    }
  }

  // 채용공고 수정
  Future<bool> updateJob(Job job) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (job.jobNo == null) {
        throw Exception('채용공고 번호가 없습니다.');
      }

      final result = await _jobService.updateJobPosting(job.jobNo!, job);

      if (result['success']) {
        final updatedJob = result['job'] as Job;

        // 목록에서 해당 채용공고 업데이트
        final updatedJobs =
            state.jobs.map((existingJob) {
              return existingJob.jobNo == job.jobNo ? updatedJob : existingJob;
            }).toList();

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return false;
    }
  }

  // 채용공고 삭제
  Future<bool> deleteJob(int jobNo) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.deleteJobPosting(jobNo);

      if (result['success']) {
        // 목록에서 해당 채용공고 제거
        final updatedJobs =
            state.jobs.where((job) => job.jobNo != jobNo).toList();

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        await _updateStatusCounts();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return false;
    }
  }

  // ============ 목록 조회 ============

  // 사용자의 모든 채용공고 조회
  Future<void> loadUserJobs({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        jobs: [],
        currentPage: 0,
        hasMore: true,
        currentFilter: null,
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final result = await _jobService.getUserJobsByStatus(
        userNo,
        null, // 모든 상태
        page: refresh ? 0 : state.currentPage,
      );

      if (result['success']) {
        final newJobs =
            (result['jobs'] as List)
                .map((jobJson) => Job.fromJson(jobJson))
                .toList();

        final updatedJobs = refresh ? newJobs : [...state.jobs, ...newJobs];

        state = state.copyWith(
          jobs: updatedJobs,
          currentPage: result['currentPage'],
          hasMore: result['hasNext'],
          isLoading: false,
        );

        // 상태별 개수도 함께 로드
        await _updateStatusCounts();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
    }
  }

  // 상태별 채용공고 조회
  Future<void> loadJobsByStatus(String status, {bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        jobs: [],
        currentPage: 0,
        hasMore: true,
        currentFilter: status,
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final result = await _jobService.getUserJobsByStatus(
        userNo,
        status,
        page: refresh ? 0 : state.currentPage,
      );

      if (result['success']) {
        final newJobs =
            (result['jobs'] as List)
                .map((jobJson) => Job.fromJson(jobJson))
                .toList();

        final updatedJobs = refresh ? newJobs : [...state.jobs, ...newJobs];

        state = state.copyWith(
          jobs: updatedJobs,
          currentPage: result['currentPage'],
          hasMore: result['hasNext'],
          isLoading: false,
          currentFilter: status,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
    }
  }

  // 임시저장 목록 조회
  Future<void> loadDrafts({bool refresh = false}) async {
    await loadJobsByStatus('DRAFT', refresh: refresh);
  }

  // 게시중인 채용공고 조회 (일반 사용자용)
  Future<void> loadPublishedJobs({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        jobs: [],
        currentPage: 0,
        hasMore: true,
        currentFilter: 'PUBLISHED',
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.getPublishedJobs(
        page: refresh ? 0 : state.currentPage,
      );

      if (result['success']) {
        final newJobs =
            (result['jobs'] as List)
                .map((jobJson) => Job.fromJson(jobJson))
                .toList();

        final updatedJobs = refresh ? newJobs : [...state.jobs, ...newJobs];

        state = state.copyWith(
          jobs: updatedJobs,
          currentPage: result['currentPage'],
          hasMore: result['hasNext'],
          isLoading: false,
          currentFilter: 'PUBLISHED',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
    }
  }

  // ============ 검색 및 필터링 ============

  // 검색
  Future<void> searchJobs(String keyword, {bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        jobs: [],
        currentPage: 0,
        hasMore: true,
        searchKeyword: keyword,
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.searchPublishedJobs(
        keyword,
        page: refresh ? 0 : state.currentPage,
      );

      if (result['success']) {
        final newJobs =
            (result['jobs'] as List)
                .map((jobJson) => Job.fromJson(jobJson))
                .toList();

        final updatedJobs = refresh ? newJobs : [...state.jobs, ...newJobs];

        state = state.copyWith(
          jobs: updatedJobs,
          currentPage: result['currentPage'],
          hasMore: result['hasNext'],
          isLoading: false,
          searchKeyword: keyword,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
    }
  }

  // 카테고리별 조회
  Future<void> loadJobsByCategory(
    String? jobType,
    String? location, {
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(jobs: [], currentPage: 0, hasMore: true);
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.getJobsByCategory(
        jobType,
        location,
        page: refresh ? 0 : state.currentPage,
      );

      if (result['success']) {
        final newJobs =
            (result['jobs'] as List)
                .map((jobJson) => Job.fromJson(jobJson))
                .toList();

        final updatedJobs = refresh ? newJobs : [...state.jobs, ...newJobs];

        state = state.copyWith(
          jobs: updatedJobs,
          currentPage: result['currentPage'],
          hasMore: result['hasNext'],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
    }
  }

  // ============ 상세 조회 ============

  // 특정 채용공고 조회
  Future<void> loadJobDetail(int jobNo) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final job = await _jobService.getJobPosting(jobNo);

      state = state.copyWith(selectedJob: job, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
    }
  }

  // ============ 상태별 개수 조회 ============

  Future<void> _updateStatusCounts() async {
    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) return;

      final result = await _jobService.getUserJobStatusCounts(userNo);

      if (result['success']) {
        final counts = Map<String, int>.from(
          (result['counts'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ),
        );

        state = state.copyWith(statusCounts: counts);
      }
    } catch (e) {
      // 상태별 개수 조회 실패는 무시 (중요하지 않은 기능)
      debugPrint('상태별 개수 조회 실패: $e');
    }
  }

  // ============ 유틸리티 메서드들 ============

  // 선택된 채용공고 클리어
  void clearSelectedJob() {
    state = state.copyWith(selectedJob: null);
  }

  // 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 필터 클리어
  void clearFilter() {
    state = state.copyWith(currentFilter: null, searchKeyword: null);
  }

  // 목록 초기화
  void resetJobs() {
    state = state.copyWith(
      jobs: [],
      currentPage: 0,
      hasMore: true,
      currentFilter: null,
      searchKeyword: null,
      selectedJob: null,
      error: null,
    );
  }

  // 더 보기 (페이지네이션)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(currentPage: state.currentPage + 1);

    if (state.searchKeyword != null) {
      await searchJobs(state.searchKeyword!);
    } else if (state.currentFilter != null) {
      if (state.currentFilter == 'PUBLISHED') {
        await loadPublishedJobs();
      } else {
        await loadJobsByStatus(state.currentFilter!);
      }
    } else {
      await loadUserJobs();
    }
  }

  // ============ 배치 작업 ============

  // 여러 채용공고 상태 일괄 변경
  Future<Map<String, dynamic>> batchChangeStatus(
    List<int> jobNos,
    String status,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userNo = await _authService.getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final result = await _jobService.batchChangeStatus(
        jobNos,
        status,
        userNo,
      );

      if (result['success']) {
        // 성공한 작업들만 목록에서 업데이트
        final successResults =
            (result['results'] as List).where((r) => r['success']).toList();

        final updatedJobs =
            state.jobs.map((job) {
              final successResult = successResults.firstWhere(
                (r) => r['jobNo'] == job.jobNo,
                orElse: () => null,
              );

              if (successResult != null) {
                return Job.fromJson(successResult['job']);
              }
              return job;
            }).toList();

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        await _updateStatusCounts();
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return {'success': false, 'error': _jobService.parseErrorMessage(e)};
    }
  }

  // 여러 채용공고 일괄 삭제
  Future<Map<String, dynamic>> batchDeleteJobs(List<int> jobNos) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _jobService.batchDeleteJobs(jobNos);

      if (result['success']) {
        // 성공한 삭제만 목록에서 제거
        final successResults =
            (result['results'] as List)
                .where((r) => r['success'])
                .map((r) => r['jobNo'] as int)
                .toList();

        final updatedJobs =
            state.jobs
                .where((job) => !successResults.contains(job.jobNo))
                .toList();

        state = state.copyWith(jobs: updatedJobs, isLoading: false);

        await _updateStatusCounts();
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _jobService.parseErrorMessage(e),
      );
      return {'success': false, 'error': _jobService.parseErrorMessage(e)};
    }
  }
}

// ============ Provider 정의 ============

final jobProvider = StateNotifierProvider<JobNotifier, JobState>(
  (ref) => JobNotifier(),
);

// ============ 편의용 Provider들 ============

// 특정 상태의 채용공고 개수
final jobStatusCountProvider = Provider.family<int, String>((ref, status) {
  final jobState = ref.watch(jobProvider);
  return jobState.statusCounts[status] ?? 0;
});

// 임시저장 개수
final draftCountProvider = Provider<int>((ref) {
  final jobState = ref.watch(jobProvider);
  return jobState.statusCounts['DRAFT'] ?? 0;
});

// 게시중인 채용공고 개수
final publishedCountProvider = Provider<int>((ref) {
  final jobState = ref.watch(jobProvider);
  return jobState.statusCounts['PUBLISHED'] ?? 0;
});

// 마감된 채용공고 개수
final expiredCountProvider = Provider<int>((ref) {
  final jobState = ref.watch(jobProvider);
  return jobState.statusCounts['EXPIRED'] ?? 0;
});

// 현재 로딩 상태
final jobLoadingProvider = Provider<bool>((ref) {
  final jobState = ref.watch(jobProvider);
  return jobState.isLoading;
});

// 현재 에러 상태
final jobErrorProvider = Provider<String?>((ref) {
  final jobState = ref.watch(jobProvider);
  return jobState.error;
});

// 선택된 채용공고
final selectedJobProvider = Provider<Job?>((ref) {
  final jobState = ref.watch(jobProvider);
  return jobState.selectedJob;
});

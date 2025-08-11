import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/file_upload_service.dart';

// 파일 업로드 서비스 Provider
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadService();
});

// 업로드 상태 클래스
class FileUploadState {
  final bool isUploading;
  final double uploadProgress;
  final String? uploadedFileUrl;
  final String? originalFileName;
  final String? errorMessage;

  FileUploadState({
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.uploadedFileUrl,
    this.originalFileName,
    this.errorMessage,
  });

  FileUploadState copyWith({
    bool? isUploading,
    double? uploadProgress,
    String? uploadedFileUrl,
    String? originalFileName,
    String? errorMessage,
    bool clearError = false,
    bool clearFile = false,
  }) {
    return FileUploadState(
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadedFileUrl:
          clearFile ? null : (uploadedFileUrl ?? this.uploadedFileUrl),
      originalFileName:
          clearFile ? null : (originalFileName ?? this.originalFileName),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// 파일 업로드 StateNotifier
class FileUploadNotifier extends StateNotifier<FileUploadState> {
  final FileUploadService _fileUploadService;

  FileUploadNotifier(this._fileUploadService) : super(FileUploadState());

  // 이력서 이미지 업로드
  Future<String?> uploadResumeImage(File imageFile, int resumeId) async {
    state = state.copyWith(isUploading: true, clearError: true);

    try {
      // 파일 크기 체크 (5MB 제한)
      if (!_fileUploadService.isFileSizeValid(imageFile, maxSizeMB: 5.0)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '이미지 크기는 5MB 이하여야 합니다.',
        );
        return null;
      }

      // 이미지 파일 여부 확인
      if (!_fileUploadService.isImageFile(imageFile)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '이미지 파일만 업로드 가능합니다.',
        );
        return null;
      }

      final fileUrl = await _fileUploadService.uploadResumeImage(
        imageFile,
        resumeId,
      );

      if (fileUrl != null) {
        state = state.copyWith(
          isUploading: false,
          uploadedFileUrl: fileUrl,
          uploadProgress: 100.0,
        );
        return fileUrl;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '이미지 업로드에 실패했습니다.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: '업로드 중 오류가 발생했습니다.',
      );
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  // 이력서 파일 업로드
  Future<Map<String, String>?> uploadResumeFile(File file, int resumeId) async {
    state = state.copyWith(isUploading: true, clearError: true);

    try {
      // 파일 크기 체크 (10MB 제한)
      if (!_fileUploadService.isFileSizeValid(file, maxSizeMB: 10.0)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '파일 크기는 10MB 이하여야 합니다.',
        );
        return null;
      }

      // 문서 파일 여부 확인
      if (!_fileUploadService.isDocumentFile(file)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: 'PDF, DOC, DOCX, HWP, TXT 파일만 업로드 가능합니다.',
        );
        return null;
      }

      final result = await _fileUploadService.uploadResumeFile(file, resumeId);

      if (result != null) {
        state = state.copyWith(
          isUploading: false,
          uploadedFileUrl: result['fileUrl'],
          originalFileName: result['originalName'],
          uploadProgress: 100.0,
        );
        return result;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '파일 업로드에 실패했습니다.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: '업로드 중 오류가 발생했습니다.',
      );
      print('파일 업로드 실패: $e');
      return null;
    }
  }

  // 채용공고 파일 업로드
  Future<Map<String, String>?> uploadJobFile(File file, int jobId) async {
    state = state.copyWith(isUploading: true, clearError: true);

    try {
      // 파일 크기 체크 (15MB 제한)
      if (!_fileUploadService.isFileSizeValid(file, maxSizeMB: 15.0)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '파일 크기는 15MB 이하여야 합니다.',
        );
        return null;
      }

      final result = await _fileUploadService.uploadJobFile(file, jobId);

      if (result != null) {
        state = state.copyWith(
          isUploading: false,
          uploadedFileUrl: result['fileUrl'],
          originalFileName: result['originalName'],
          uploadProgress: 100.0,
        );
        return result;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '파일 업로드에 실패했습니다.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: '업로드 중 오류가 발생했습니다.',
      );
      print('파일 업로드 실패: $e');
      return null;
    }
  }

  // 게시판 이미지 업로드
  Future<String?> uploadBoardImage(File imageFile) async {
    state = state.copyWith(isUploading: true, clearError: true);

    try {
      // 파일 크기 체크 (5MB 제한)
      if (!_fileUploadService.isFileSizeValid(imageFile, maxSizeMB: 5.0)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '이미지 크기는 5MB 이하여야 합니다.',
        );
        return null;
      }

      // 이미지 파일 여부 확인
      if (!_fileUploadService.isImageFile(imageFile)) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '이미지 파일만 업로드 가능합니다.',
        );
        return null;
      }

      final fileUrl = await _fileUploadService.uploadBoardImage(imageFile);

      if (fileUrl != null) {
        state = state.copyWith(
          isUploading: false,
          uploadedFileUrl: fileUrl,
          uploadProgress: 100.0,
        );
        return fileUrl;
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '이미지 업로드에 실패했습니다.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: '업로드 중 오류가 발생했습니다.',
      );
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  // 파일 삭제
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final success = await _fileUploadService.deleteFile(fileUrl);
      if (success) {
        state = state.copyWith(clearFile: true);
      }
      return success;
    } catch (e) {
      print('파일 삭제 실패: $e');
      return false;
    }
  }

  // 상태 초기화
  void reset() {
    state = FileUploadState();
  }

  // 에러 초기화
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// 파일 업로드 Provider
final fileUploadProvider =
    StateNotifierProvider<FileUploadNotifier, FileUploadState>((ref) {
      final fileUploadService = ref.watch(fileUploadServiceProvider);
      return FileUploadNotifier(fileUploadService);
    });

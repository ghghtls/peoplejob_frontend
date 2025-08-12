import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileUploadService {
  static const String baseUrl = 'http://localhost:8080/api/files';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();

  FileUploadService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // JWT 토큰 가져오기
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // 인증 헤더 생성
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  // 이미지 선택 (카메라 또는 갤러리)
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('이미지 선택 실패: $e');
      return null;
    }
  }

  // 파일 선택
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('파일 선택 실패: $e');
      return null;
    }
  }

  // 이력서 프로필 이미지 업로드
  Future<String?> uploadResumeImage(File imageFile, int resumeId) async {
    try {
      final headers = await _getHeaders();

      String fileName =
          'resume_${resumeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'type': 'resume_image',
        'resumeId': resumeId,
      });

      final response = await _dio.post(
        '$baseUrl/upload/resume/image',
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          print('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        return response.data['fileUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('이력서 이미지 업로드 실패: $e');
      return null;
    }
  }

  // 이력서 첨부파일 업로드
  Future<Map<String, String>?> uploadResumeFile(File file, int resumeId) async {
    try {
      final headers = await _getHeaders();

      String fileName =
          'resume_${resumeId}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': 'resume_file',
        'resumeId': resumeId,
      });

      final response = await _dio.post(
        '$baseUrl/upload/resume/file',
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          print('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        return {
          'fileUrl': response.data['fileUrl'] as String,
          'originalName': response.data['originalName'] as String,
        };
      }
      return null;
    } catch (e) {
      print('이력서 파일 업로드 실패: $e');
      return null;
    }
  }

  // 채용공고 첨부파일 업로드
  Future<Map<String, String>?> uploadJobFile(File file, int jobId) async {
    try {
      final headers = await _getHeaders();

      String fileName =
          'job_${jobId}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': 'job_file',
        'jobId': jobId,
      });

      final response = await _dio.post(
        '$baseUrl/upload/job/file',
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          print('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        return {
          'fileUrl': response.data['fileUrl'] as String,
          'originalName': response.data['originalName'] as String,
        };
      }
      return null;
    } catch (e) {
      print('채용공고 파일 업로드 실패: $e');
      return null;
    }
  }

  // 게시판 이미지 업로드
  Future<String?> uploadBoardImage(File imageFile) async {
    try {
      final headers = await _getHeaders();

      String fileName = 'board_${DateTime.now().millisecondsSinceEpoch}.jpg';

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'type': 'board_image',
      });

      final response = await _dio.post(
        '$baseUrl/upload/board/image',
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          print('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        return response.data['fileUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('게시판 이미지 업로드 실패: $e');
      return null;
    }
  }

  // 파일 다운로드
  Future<String?> downloadFile(String fileUrl, {String? fileName}) async {
    try {
      final headers = await _getHeaders();

      // 다운로드 디렉토리 가져오기
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        print('다운로드 디렉토리를 찾을 수 없습니다.');
        return null;
      }

      // 파일명 설정
      final downloadFileName =
          fileName ?? 'download_${DateTime.now().millisecondsSinceEpoch}';
      final savePath = '${downloadDir.path}/$downloadFileName';

      // 파일 다운로드
      final response = await _dio.download(
        '$baseUrl/download',
        savePath,
        queryParameters: {'fileUrl': fileUrl},
        options: Options(headers: headers),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('다운로드 진행률: ${(received / total * 100).toStringAsFixed(1)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        print('파일 다운로드 완료: $savePath');
        return savePath;
      }
      return null;
    } catch (e) {
      print('파일 다운로드 실패: $e');
      return null;
    }
  }

  // 파일 목록 조회 (관리자용)
  Future<Map<String, dynamic>?> getFileList({
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '$baseUrl/admin/list',
        queryParameters: {
          if (type != null) 'type': type,
          'page': page,
          'size': size,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('파일 목록 조회 실패: $e');
      return null;
    }
  }

  // 파일 정보 조회
  Future<Map<String, dynamic>?> getFileInfo(String fileUrl) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '$baseUrl/info',
        queryParameters: {'fileUrl': fileUrl},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('파일 정보 조회 실패: $e');
      return null;
    }
  }

  // 파일 삭제
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.delete(
        '$baseUrl/delete',
        data: {'fileUrl': fileUrl},
        options: Options(headers: headers),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('파일 삭제 실패: $e');
      return false;
    }
  }

  // 파일 크기 체크 (MB 단위)
  bool isFileSizeValid(File file, {double maxSizeMB = 10.0}) {
    final fileSizeBytes = file.lengthSync();
    final fileSizeMB = fileSizeBytes / (1024 * 1024);
    return fileSizeMB <= maxSizeMB;
  }

  // 파일 확장자 체크
  bool isFileExtensionValid(File file, List<String> allowedExtensions) {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // 이미지 파일 여부 확인
  bool isImageFile(File file) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return isFileExtensionValid(file, imageExtensions);
  }

  // 문서 파일 여부 확인
  bool isDocumentFile(File file) {
    const docExtensions = ['pdf', 'doc', 'docx', 'hwp', 'txt'];
    return isFileExtensionValid(file, docExtensions);
  }

  // 파일 크기를 읽기 쉬운 형태로 변환
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // 여러 파일 다운로드 (압축)
  Future<String?> downloadMultipleFiles(
    List<String> fileUrls,
    String zipFileName,
  ) async {
    try {
      final headers = await _getHeaders();

      // 다운로드 디렉토리 가져오기
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        print('다운로드 디렉토리를 찾을 수 없습니다.');
        return null;
      }

      final savePath = '${downloadDir.path}/$zipFileName';

      // 여러 파일 다운로드 요청
      final response = await _dio.post(
        '$baseUrl/download/multiple',
        data: {'fileUrls': fileUrls, 'zipFileName': zipFileName},
        options: Options(headers: headers, responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
              '압축 파일 다운로드 진행률: ${(received / total * 100).toStringAsFixed(1)}%',
            );
          }
        },
      );

      if (response.statusCode == 200) {
        // 바이트 데이터를 파일로 저장
        final file = File(savePath);
        await file.writeAsBytes(response.data);
        print('압축 파일 다운로드 완료: $savePath');
        return savePath;
      }
      return null;
    } catch (e) {
      print('압축 파일 다운로드 실패: $e');
      return null;
    }
  }
}

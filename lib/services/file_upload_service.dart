import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'config/api_config.dart';
import '../utils/excel_download_helper.dart';

class FileUploadService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();

  FileUploadService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'jwt');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) return File(image.path);
      return null;
    } catch (e) {
      debugPrint('이미지 선택 실패: $e');
      return null;
    }
  }

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
      debugPrint('파일 선택 실패: $e');
      return null;
    }
  }

  Future<String?> uploadResumeImage(File imageFile, int resumeId) async {
    try {
      final fileName =
          'resume_${resumeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'type': 'resume_image',
        'resumeId': resumeId,
      });
      final response = await _dio.post(
        '/api/files/upload/resume/image',
        data: formData,
        onSendProgress: (sent, total) {
          debugPrint('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );
      if (response.statusCode == 200) return response.data['fileUrl'] as String?;
      return null;
    } catch (e) {
      debugPrint('이력서 이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<Map<String, String>?> uploadResumeFile(File file, int resumeId) async {
    try {
      final fileName =
          'resume_${resumeId}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': 'resume_file',
        'resumeId': resumeId,
      });
      final response = await _dio.post(
        '/api/files/upload/resume/file',
        data: formData,
        onSendProgress: (sent, total) {
          debugPrint('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
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
      debugPrint('이력서 파일 업로드 실패: $e');
      return null;
    }
  }

  Future<Map<String, String>?> uploadJobFile(File file, int jobId) async {
    try {
      final fileName =
          'job_${jobId}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': 'job_file',
        'jobId': jobId,
      });
      final response = await _dio.post(
        '/api/files/upload/job/file',
        data: formData,
        onSendProgress: (sent, total) {
          debugPrint('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
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
      debugPrint('채용공고 파일 업로드 실패: $e');
      return null;
    }
  }

  Future<String?> uploadBoardImage(File imageFile) async {
    try {
      final fileName = 'board_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'type': 'board_image',
      });
      final response = await _dio.post(
        '/api/files/upload/board/image',
        data: formData,
        onSendProgress: (sent, total) {
          debugPrint('업로드 진행률: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );
      if (response.statusCode == 200) return response.data['fileUrl'] as String?;
      return null;
    } catch (e) {
      debugPrint('게시판 이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<Map<String, String>?> uploadJobAttachment(
      Uint8List bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post(
        '/api/files/upload/job/attachment',
        data: formData,
      );
      if (response.statusCode == 200) {
        return {
          'fileUrl': response.data['fileUrl'] as String,
          'originalName': response.data['originalName'] as String,
        };
      }
      return null;
    } catch (e) {
      debugPrint('채용공고 첨부파일 업로드 실패: $e');
      return null;
    }
  }

  Future<Map<String, String>?> uploadBoardFile(
      Uint8List bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post(
        '/api/files/upload/board/file',
        data: formData,
      );
      if (response.statusCode == 200) {
        return {
          'fileUrl': response.data['fileUrl'] as String,
          'originalName': response.data['originalName'] as String,
        };
      }
      return null;
    } catch (e) {
      debugPrint('게시판 파일 업로드 실패: $e');
      return null;
    }
  }

  Future<String?> downloadFile(String fileUrl, {String? fileName}) async {
    try {
      final downloadFileName =
          fileName ?? 'download_${DateTime.now().millisecondsSinceEpoch}';

      final response = await _dio.get(
        '/api/files/download',
        queryParameters: {'fileUrl': fileUrl},
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint('다운로드 진행률: ${(received / total * 100).toStringAsFixed(1)}%');
          }
        },
      );

      if (response.statusCode != 200) return null;

      final bytes = response.data;
      final byteList = bytes is List<int> ? bytes : (bytes as List).cast<int>();

      if (kIsWeb) {
        await downloadBytesOnWeb(byteList, downloadFileName);
        return downloadFileName;
      }

      final downloadDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      if (downloadDir == null) {
        debugPrint('다운로드 디렉토리를 찾을 수 없습니다.');
        return null;
      }
      final savePath = '${downloadDir.path}/$downloadFileName';
      await File(savePath).writeAsBytes(byteList);
      debugPrint('파일 다운로드 완료: $savePath');
      return savePath;
    } catch (e) {
      debugPrint('파일 다운로드 실패: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFileList({
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/files/admin/list',
        queryParameters: {
          if (type != null) 'type': type,
          'page': page,
          'size': size,
        },
      );
      if (response.statusCode == 200) return response.data;
      return null;
    } catch (e) {
      debugPrint('파일 목록 조회 실패: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFileInfo(String fileUrl) async {
    try {
      final response = await _dio.get(
        '/api/files/info',
        queryParameters: {'fileUrl': fileUrl},
      );
      if (response.statusCode == 200) return response.data;
      return null;
    } catch (e) {
      debugPrint('파일 정보 조회 실패: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String fileUrl) async {
    try {
      final response = await _dio.delete(
        '/api/files/delete',
        data: {'fileUrl': fileUrl},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('파일 삭제 실패: $e');
      return false;
    }
  }

  Future<String?> downloadMultipleFiles(
    List<String> fileUrls,
    String zipFileName,
  ) async {
    try {
      final response = await _dio.post(
        '/api/files/download/multiple',
        data: {'fileUrls': fileUrls, 'zipFileName': zipFileName},
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              '압축 파일 다운로드 진행률: ${(received / total * 100).toStringAsFixed(1)}%',
            );
          }
        },
      );
      if (response.statusCode != 200) return null;

      final byteList = response.data is List<int>
          ? response.data as List<int>
          : (response.data as List).cast<int>();

      if (kIsWeb) {
        await downloadBytesOnWeb(byteList, zipFileName, 'application/zip');
        return zipFileName;
      }

      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      if (downloadDir == null) {
        debugPrint('다운로드 디렉토리를 찾을 수 없습니다.');
        return null;
      }
      final savePath = '${downloadDir.path}/$zipFileName';
      await File(savePath).writeAsBytes(byteList);
      debugPrint('압축 파일 다운로드 완료: $savePath');
      return savePath;
    } catch (e) {
      debugPrint('압축 파일 다운로드 실패: $e');
      return null;
    }
  }

  bool isFileSizeValid(File file, {double maxSizeMB = 10.0}) {
    final fileSizeMB = file.lengthSync() / (1024 * 1024);
    return fileSizeMB <= maxSizeMB;
  }

  bool isFileExtensionValid(File file, List<String> allowedExtensions) {
    final extension = file.path.split('/').last.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  bool isImageFile(File file) =>
      isFileExtensionValid(file, ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']);

  bool isDocumentFile(File file) =>
      isFileExtensionValid(file, ['pdf', 'doc', 'docx', 'hwp', 'txt']);

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

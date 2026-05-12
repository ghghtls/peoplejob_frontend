import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

class ScrapService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ScrapService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
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

  /// 스크랩 등록
  /// POST /api/scrap
  Future<bool> addScrap(int jobopeningNo) async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await _dio.post(
        '/api/scrap',
        data: {
          'userNo': userNo,
          'jobopeningNo': jobopeningNo,
        },
      );
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('이미 스크랩한 채용공고입니다.');
      }
      throw Exception('스크랩 추가에 실패했습니다: $e');
    }
  }

  /// 스크랩 삭제 (user + job 기준)
  /// DELETE /api/scrap?userNo={userNo}&jobopeningNo={jobopeningNo}
  Future<bool> removeScrap(int jobopeningNo) async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await _dio.delete(
        '/api/scrap',
        queryParameters: {
          'userNo': userNo,
          'jobopeningNo': jobopeningNo,
        },
      );
      return true;
    } catch (e) {
      throw Exception('스크랩 제거에 실패했습니다: $e');
    }
  }

  /// 내 스크랩 목록 조회
  /// GET /api/scrap/{userNo}
  Future<List<dynamic>> getMyScrapList() async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _dio.get('/api/scrap/$userNo');
      return response.data is List ? response.data : [];
    } catch (e) {
      throw Exception('스크랩 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 스크랩 개별 삭제
  /// DELETE /api/scrap/{scrapNo}
  Future<bool> deleteScrapById(int scrapNo) async {
    try {
      await _dio.delete('/api/scrap/$scrapNo');
      return true;
    } catch (e) {
      throw Exception('스크랩 삭제에 실패했습니다: $e');
    }
  }

  /// 특정 채용공고가 스크랩되어 있는지 확인
  Future<bool> isScraped(int jobOpeningNo) async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) return false;

      final res = await _dio.get(
        '/api/scrap/check',
        queryParameters: {
          'jobopeningNo': jobOpeningNo,
          'userNo': userNo,
        },
      );
      return res.data == true || (res.data is Map && res.data['isScraped'] == true);
    } catch (e) {
      return false;
    }
  }

  /// 내부 헬퍼: userNo 가져오기
  Future<int?> _getUserNo() async {
    try {
      final userNoStr = await _storage.read(key: 'userNo');
      return userNoStr != null ? int.tryParse(userNoStr) : null;
    } catch (e) {
      return null;
    }
  }
}

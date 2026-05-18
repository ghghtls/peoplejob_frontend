import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

class PaymentService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  PaymentService({Dio? dio, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
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

  /// 결제 처리
  /// POST /api/payment
  Future<Map<String, dynamic>> processPayment({
    required int amount,
    required String paymentMethod,
    String? description,
    int? jobNo,
    String? adEndDate,
  }) async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) throw Exception('로그인이 필요합니다.');

      final res = await _dio.post(
        '/api/payment',
        data: {
          'userNo': userNo,
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (description != null) 'description': description,
          if (jobNo != null) 'jobNo': jobNo,
          if (adEndDate != null) 'adEndDate': adEndDate,
        },
      );
      return {'success': true, 'data': res.data};
    } catch (e) {
      return {'success': false, 'error': '결제에 실패했습니다: $e'};
    }
  }

  /// 내 결제 내역 조회
  /// GET /api/payment/user/{userNo}
  Future<List<dynamic>> getMyPayments() async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) throw Exception('로그인이 필요합니다.');

      final res = await _dio.get('/api/payment/user/$userNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      return [];
    }
  }

  /// 결제 취소
  /// PUT /api/payment/cancel/{paymentNo}
  Future<Map<String, dynamic>> cancelPayment(int paymentNo) async {
    try {
      final res = await _dio.put('/api/payment/cancel/$paymentNo');
      return {'success': true, 'data': res.data};
    } catch (e) {
      return {'success': false, 'error': '결제 취소에 실패했습니다: $e'};
    }
  }

  Future<int?> _getUserNo() async {
    final str = await _storage.read(key: 'userNo');
    return str != null ? int.tryParse(str) : null;
  }
}

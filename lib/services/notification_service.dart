import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

/// 알림 서비스
/// 백엔드 NotificationController와 연동
class NotificationService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  NotificationService({Dio? dio, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: 'jwt');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          handler.next(options);
        },
        onError: (error, handler) async {
          try {
            if (error.response?.statusCode == 401) {
              await _storage.delete(key: 'jwt');
            }
          } catch (_) {}
          handler.next(error);
        },
      ),
    );
  }

  /// 알림 목록 조회 (페이지네이션)
  /// GET /api/notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final res = await _dio.get(
        '/api/notifications',
        queryParameters: {'page': page, 'size': size},
      );

      if (res.statusCode == 200) {
        return {'success': true, 'data': res.data};
      } else {
        return {'success': false, 'error': '알림 목록을 가져올 수 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  /// 읽지 않은 알림 조회
  /// GET /api/notifications/unread
  Future<Map<String, dynamic>> getUnreadNotifications() async {
    try {
      final res = await _dio.get('/api/notifications/unread');

      if (res.statusCode == 200) {
        return {'success': true, 'data': res.data};
      } else {
        return {'success': false, 'error': '읽지 않은 알림을 가져올 수 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  /// 읽지 않은 알림 개수 조회
  /// GET /api/notifications/unread-count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final res = await _dio.get('/api/notifications/unread-count');

      if (res.statusCode == 200) {
        final data = res.data;
        return {'success': true, 'count': data['unreadCount'] ?? 0};
      } else {
        return {'success': false, 'count': 0};
      }
    } catch (e) {
      return {'success': false, 'count': 0};
    }
  }

  /// 알림 통계 조회
  /// GET /api/notifications/stats
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final res = await _dio.get('/api/notifications/stats');

      if (res.statusCode == 200) {
        return {'success': true, 'data': res.data};
      } else {
        return {'success': false, 'error': '알림 통계를 가져올 수 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  /// 특정 알림 읽음 처리
  /// PUT /api/notifications/{notificationId}/read
  Future<Map<String, dynamic>> markAsRead({
    required int notificationId,
  }) async {
    try {
      final res = await _dio.put('/api/notifications/$notificationId/read');

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 여러 알림 일괄 읽음 처리
  /// PUT /api/notifications/bulk-read
  Future<Map<String, dynamic>> markMultipleAsRead({
    required List<int> notificationIds,
  }) async {
    try {
      final res = await _dio.put(
        '/api/notifications/bulk-read',
        data: {
          'notificationIds': notificationIds,
        },
      );

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'updatedCount': data['updatedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 모든 알림 읽음 처리
  /// PUT /api/notifications/read-all
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final res = await _dio.put('/api/notifications/read-all');

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'updatedCount': data['updatedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 특정 알림 삭제
  /// DELETE /api/notifications/{notificationId}
  Future<Map<String, dynamic>> deleteNotification({
    required int notificationId,
  }) async {
    try {
      final res = await _dio.delete('/api/notifications/$notificationId');

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 여러 알림 일괄 삭제
  /// DELETE /api/notifications/bulk-delete
  Future<Map<String, dynamic>> deleteMultipleNotifications({
    required List<int> notificationIds,
  }) async {
    try {
      final res = await _dio.delete(
        '/api/notifications/bulk-delete',
        data: {
          'notificationIds': notificationIds,
        },
      );

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'deletedCount': data['deletedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 모든 알림 삭제
  /// DELETE /api/notifications/delete-all
  Future<Map<String, dynamic>> deleteAllNotifications() async {
    try {
      final res = await _dio.delete('/api/notifications/delete-all');

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'deletedCount': data['deletedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 알림 생성 (관리자용)
  /// POST /api/notifications
  Future<Map<String, dynamic>> createNotification({
    required String recipientUserId,
    required String title,
    required String message,
    required String type,
    String? relatedEntityType,
    int? relatedEntityId,
    String? actionUrl,
  }) async {
    try {
      final res = await _dio.post(
        '/api/notifications',
        data: {
          'recipientUserId': recipientUserId,
          'title': title,
          'message': message,
          'type': type,
          'relatedEntityType': relatedEntityType,
          'relatedEntityId': relatedEntityId,
          'actionUrl': actionUrl,
        },
      );

      final data = res.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  /// 실시간 알림 개수 폴링
  Future<void> startPolling({
    required Function(int) onUnreadCountChanged,
    Duration interval = const Duration(seconds: 30),
  }) async {
    while (true) {
      try {
        final result = await getUnreadCount();
        if (result['success']) {
          onUnreadCountChanged(result['count']);
        }
      } catch (e) {
        // 폴링 오류는 무시
      }
      await Future.delayed(interval);
    }
  }

  /// 알림 타입 검증
  static bool isValidNotificationType(String type) {
    const validTypes = [
      'JOB_APPLICATION',
      'JOB_STATUS_UPDATE',
      'NEW_JOB_POSTING',
      'RESUME_VIEW',
      'MESSAGE',
      'SYSTEM',
      'PAYMENT',
      'EMAIL_VERIFICATION',
      'PASSWORD_RESET',
      'COMPANY_APPROVAL',
      'JOB_EXPIRED',
      'INTERVIEW_SCHEDULE',
    ];
    return validTypes.contains(type);
  }
}

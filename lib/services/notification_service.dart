import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = 'http://localhost:9000/api/notifications';

  /// 알림 목록 조회 (페이지네이션)
  static Future<Map<String, dynamic>> getNotifications({
    required String token,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': '알림 목록을 가져올 수 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 읽지 않은 알림 조회
  static Future<Map<String, dynamic>> getUnreadNotifications({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': '읽지 않은 알림을 가져올 수 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 읽지 않은 알림 개수 조회
  static Future<Map<String, dynamic>> getUnreadCount({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'count': data['unreadCount'] ?? 0};
      } else {
        return {'success': false, 'count': 0};
      }
    } catch (e) {
      return {'success': false, 'count': 0};
    }
  }

  /// 알림 통계 조회
  static Future<Map<String, dynamic>> getNotificationStats({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': '알림 통계를 가져올 수 없습니다.'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 특정 알림 읽음 처리
  static Future<Map<String, dynamic>> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 여러 알림 일괄 읽음 처리
  static Future<Map<String, dynamic>> markMultipleAsRead({
    required String token,
    required List<int> notificationIds,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bulk-read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'notificationIds': notificationIds,
          'action': 'read',
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'updatedCount': data['updatedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 모든 알림 읽음 처리
  static Future<Map<String, dynamic>> markAllAsRead({
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'updatedCount': data['updatedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 특정 알림 삭제
  static Future<Map<String, dynamic>> deleteNotification({
    required String token,
    required int notificationId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 여러 알림 일괄 삭제
  static Future<Map<String, dynamic>> deleteMultipleNotifications({
    required String token,
    required List<int> notificationIds,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bulk-delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'notificationIds': notificationIds,
          'action': 'delete',
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'deletedCount': data['deletedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 모든 알림 삭제
  static Future<Map<String, dynamic>> deleteAllNotifications({
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'deletedCount': data['deletedCount'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 알림 생성 (관리자용)
  static Future<Map<String, dynamic>> createNotification({
    required String token,
    required String recipientUserId,
    required String title,
    required String message,
    required String type,
    String? relatedEntityType,
    int? relatedEntityId,
    String? actionUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipientUserId': recipientUserId,
          'title': title,
          'message': message,
          'type': type,
          'relatedEntityType': relatedEntityType,
          'relatedEntityId': relatedEntityId,
          'actionUrl': actionUrl,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 실시간 알림 개수 폴링
  static Future<void> startPolling({
    required String token,
    required Function(int) onUnreadCountChanged,
    Duration interval = const Duration(seconds: 30),
  }) async {
    while (true) {
      try {
        final result = await getUnreadCount(token: token);
        if (result['success']) {
          onUnreadCountChanged(result['count']);
        }
      } catch (e) {
        print('알림 개수 폴링 오류: $e');
      }
      await Future.delayed(interval);
    }
  }

  /// 네트워크 연결 상태 확인
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
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

import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/data/model/notification_model.dart';
import 'package:peoplejob_frontend/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  NotificationStats? _stats;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int _unreadCount = 0;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  NotificationStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;

  /// 알림 목록 로드
  Future<void> loadNotifications({
    required String token,
    bool refresh = false,
    int pageSize = 20,
  }) async {
    if (refresh) {
      _currentPage = 0;
      _notifications.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await NotificationService.getNotifications(
        token: token,
        page: _currentPage,
        size: pageSize,
      );

      if (result['success']) {
        final response = NotificationPageResponse.fromJson(result['data']);

        if (refresh) {
          _notifications = response.notifications;
        } else {
          _notifications.addAll(response.notifications);
        }

        _hasMore = response.hasNext;
        _currentPage++;
        _unreadCount = response.unreadCount;

        _error = null;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = '알림을 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 읽지 않은 알림 로드
  Future<void> loadUnreadNotifications(String token) async {
    try {
      final result = await NotificationService.getUnreadNotifications(
        token: token,
      );

      if (result['success']) {
        _unreadNotifications =
            (result['data'] as List)
                .map((item) => NotificationModel.fromJson(item))
                .toList();
        _unreadCount = _unreadNotifications.length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('읽지 않은 알림 로드 실패: $e');
    }
  }

  /// 읽지 않은 알림 개수 새로고침
  Future<void> refreshUnreadCount(String token) async {
    try {
      final result = await NotificationService.getUnreadCount(token: token);
      if (result['success']) {
        _unreadCount = result['count'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('읽지 않은 알림 개수 새로고침 실패: $e');
    }
  }

  /// 알림 통계 로드
  Future<void> loadStats(String token) async {
    try {
      final result = await NotificationService.getNotificationStats(
        token: token,
      );

      if (result['success']) {
        _stats = NotificationStats.fromJson(result['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('알림 통계 로드 실패: $e');
    }
  }

  /// 특정 알림 읽음 처리
  Future<bool> markAsRead(String token, int notificationId) async {
    try {
      final result = await NotificationService.markAsRead(
        token: token,
        notificationId: notificationId,
      );

      if (result['success']) {
        // 로컬 상태 업데이트
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            recipientUserId: _notifications[index].recipientUserId,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            typeDescription: _notifications[index].typeDescription,
            isRead: true,
            relatedEntityType: _notifications[index].relatedEntityType,
            relatedEntityId: _notifications[index].relatedEntityId,
            actionUrl: _notifications[index].actionUrl,
            createdAt: _notifications[index].createdAt,
            readAt: DateTime.now(),
            timeAgo: _notifications[index].timeAgo,
          );
        }

        // 읽지 않은 알림 목록에서 제거
        _unreadNotifications.removeWhere((n) => n.id == notificationId);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('알림 읽음 처리 실패: $e');
      return false;
    }
  }

  /// 모든 알림 읽음 처리
  Future<bool> markAllAsRead(String token) async {
    try {
      final result = await NotificationService.markAllAsRead(token: token);

      if (result['success']) {
        // 로컬 상태 업데이트
        _notifications =
            _notifications.map((notification) {
              return NotificationModel(
                id: notification.id,
                recipientUserId: notification.recipientUserId,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                typeDescription: notification.typeDescription,
                isRead: true,
                relatedEntityType: notification.relatedEntityType,
                relatedEntityId: notification.relatedEntityId,
                actionUrl: notification.actionUrl,
                createdAt: notification.createdAt,
                readAt: DateTime.now(),
                timeAgo: notification.timeAgo,
              );
            }).toList();

        _unreadNotifications.clear();
        _unreadCount = 0;

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('전체 읽음 처리 실패: $e');
      return false;
    }
  }

  /// 특정 알림 삭제
  Future<bool> deleteNotification(String token, int notificationId) async {
    try {
      final result = await NotificationService.deleteNotification(
        token: token,
        notificationId: notificationId,
      );

      if (result['success']) {
        // 로컬 상태에서 제거
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('알림 삭제 실패: $e');
      return false;
    }
  }

  /// 여러 알림 일괄 삭제
  Future<bool> deleteMultipleNotifications(
    String token,
    List<int> notificationIds,
  ) async {
    try {
      final result = await NotificationService.deleteMultipleNotifications(
        token: token,
        notificationIds: notificationIds,
      );

      if (result['success']) {
        // 로컬 상태에서 제거
        _notifications.removeWhere((n) => notificationIds.contains(n.id));
        _unreadNotifications.removeWhere((n) => notificationIds.contains(n.id));

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('일괄 삭제 실패: $e');
      return false;
    }
  }

  /// 모든 알림 삭제
  Future<bool> deleteAllNotifications(String token) async {
    try {
      final result = await NotificationService.deleteAllNotifications(
        token: token,
      );

      if (result['success']) {
        // 로컬 상태 초기화
        _notifications.clear();
        _unreadNotifications.clear();
        _unreadCount = 0;

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('전체 삭제 실패: $e');
      return false;
    }
  }

  /// 새로운 알림 추가 (실시간 알림용)
  void addNewNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (notification.isUnread) {
      _unreadNotifications.insert(0, notification);
      _unreadCount++;
    }
    notifyListeners();
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 타입별 알림 필터링
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type.value).toList();
  }

  /// 오늘 온 알림들
  List<NotificationModel> get todayNotifications {
    return _notifications.where((n) => n.isToday).toList();
  }

  /// 이번 주 온 알림들
  List<NotificationModel> get thisWeekNotifications {
    return _notifications.where((n) => n.isThisWeek).toList();
  }

  /// 상태 초기화
  void reset() {
    _notifications.clear();
    _unreadNotifications.clear();
    _stats = null;
    _isLoading = false;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    _unreadCount = 0;
    notifyListeners();
  }
}

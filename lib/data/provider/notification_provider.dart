import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/model/notification_model.dart';
import 'package:peoplejob_frontend/services/notification_service.dart';

// ── State ────────────────────────────────────────────────────────────────────

class NotificationState {
  final List<NotificationModel> notifications;
  final List<NotificationModel> unreadNotifications;
  final NotificationStats? stats;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.unreadNotifications = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    List<NotificationModel>? unreadNotifications,
    NotificationStats? stats,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? unreadCount,
    bool clearError = false,
    bool clearStats = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      stats: clearStats ? null : (stats ?? this.stats),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service = NotificationService();

  NotificationNotifier() : super(const NotificationState());

  @override
  void dispose() {
    _service.stopPolling();
    super.dispose();
  }

  Future<void> loadNotifications({bool refresh = false, int pageSize = 20}) async {
    if (refresh) {
      state = state.copyWith(currentPage: 0, notifications: [], hasMore: true, clearError: true);
    }
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getNotifications(page: state.currentPage, size: pageSize);
      if (result['success']) {
        final response = NotificationPageResponse.fromJson(result['data']);
        final merged = refresh ? response.notifications : [...state.notifications, ...response.notifications];
        state = state.copyWith(
          notifications: merged,
          hasMore: response.hasNext,
          currentPage: state.currentPage + 1,
          unreadCount: response.unreadCount,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: result['error'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: '알림을 불러오는 중 오류가 발생했습니다: $e', isLoading: false);
    }
  }

  Future<void> loadUnreadNotifications() async {
    try {
      final result = await _service.getUnreadNotifications();
      if (result['success']) {
        final list = (result['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
        state = state.copyWith(unreadNotifications: list, unreadCount: list.length);
      }
    } catch (e) {
      debugPrint('읽지 않은 알림 로드 실패: $e');
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final result = await _service.getUnreadCount();
      if (result['success']) {
        state = state.copyWith(unreadCount: result['count'] as int);
      }
    } catch (e) {
      debugPrint('읽지 않은 알림 개수 새로고침 실패: $e');
    }
  }

  Future<void> loadStats() async {
    try {
      final result = await _service.getNotificationStats();
      if (result['success']) {
        state = state.copyWith(stats: NotificationStats.fromJson(result['data']));
      }
    } catch (e) {
      debugPrint('알림 통계 로드 실패: $e');
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final result = await _service.markAsRead(notificationId: notificationId);
      if (result['success']) {
        final updated = state.notifications.map((n) {
          if (n.id != notificationId) return n;
          return NotificationModel(
            id: n.id, recipientUserId: n.recipientUserId, title: n.title,
            message: n.message, type: n.type, typeDescription: n.typeDescription,
            isRead: true, relatedEntityType: n.relatedEntityType,
            relatedEntityId: n.relatedEntityId, actionUrl: n.actionUrl,
            createdAt: n.createdAt, readAt: DateTime.now(), timeAgo: n.timeAgo,
          );
        }).toList();
        state = state.copyWith(
          notifications: updated,
          unreadNotifications: state.unreadNotifications.where((n) => n.id != notificationId).toList(),
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );
        return true;
      }
    } catch (e) {
      debugPrint('알림 읽음 처리 실패: $e');
    }
    return false;
  }

  Future<bool> markAllAsRead() async {
    try {
      final result = await _service.markAllAsRead();
      if (result['success']) {
        final updated = state.notifications.map((n) => NotificationModel(
          id: n.id, recipientUserId: n.recipientUserId, title: n.title,
          message: n.message, type: n.type, typeDescription: n.typeDescription,
          isRead: true, relatedEntityType: n.relatedEntityType,
          relatedEntityId: n.relatedEntityId, actionUrl: n.actionUrl,
          createdAt: n.createdAt, readAt: DateTime.now(), timeAgo: n.timeAgo,
        )).toList();
        state = state.copyWith(notifications: updated, unreadNotifications: [], unreadCount: 0);
        return true;
      }
    } catch (e) {
      debugPrint('전체 읽음 처리 실패: $e');
    }
    return false;
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final result = await _service.deleteNotification(notificationId: notificationId);
      if (result['success']) {
        state = state.copyWith(
          notifications: state.notifications.where((n) => n.id != notificationId).toList(),
          unreadNotifications: state.unreadNotifications.where((n) => n.id != notificationId).toList(),
        );
        return true;
      }
    } catch (e) {
      debugPrint('알림 삭제 실패: $e');
    }
    return false;
  }

  Future<bool> deleteMultipleNotifications(List<int> ids) async {
    try {
      final result = await _service.deleteMultipleNotifications(notificationIds: ids);
      if (result['success']) {
        state = state.copyWith(
          notifications: state.notifications.where((n) => !ids.contains(n.id)).toList(),
          unreadNotifications: state.unreadNotifications.where((n) => !ids.contains(n.id)).toList(),
        );
        return true;
      }
    } catch (e) {
      debugPrint('일괄 삭제 실패: $e');
    }
    return false;
  }

  Future<bool> deleteAllNotifications() async {
    try {
      final result = await _service.deleteAllNotifications();
      if (result['success']) {
        state = state.copyWith(notifications: [], unreadNotifications: [], unreadCount: 0);
        return true;
      }
    } catch (e) {
      debugPrint('전체 삭제 실패: $e');
    }
    return false;
  }

  void addNewNotification(NotificationModel notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
      unreadNotifications: notification.isUnread
          ? [notification, ...state.unreadNotifications]
          : state.unreadNotifications,
      unreadCount: notification.isUnread ? state.unreadCount + 1 : state.unreadCount,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);

  List<NotificationModel> getByType(NotificationType type) =>
      state.notifications.where((n) => n.type == type.value).toList();

  void reset() => state = const NotificationState();
}

// ── Provider ─────────────────────────────────────────────────────────────────

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (_) => NotificationNotifier(),
);

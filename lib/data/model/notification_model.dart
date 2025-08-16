class NotificationModel {
  final int id;
  final String recipientUserId;
  final String title;
  final String message;
  final String type;
  final String typeDescription;
  final bool isRead;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime? readAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.recipientUserId,
    required this.title,
    required this.message,
    required this.type,
    required this.typeDescription,
    required this.isRead,
    this.relatedEntityType,
    this.relatedEntityId,
    this.actionUrl,
    required this.createdAt,
    this.readAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      recipientUserId: json['recipientUserId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      typeDescription: json['typeDescription'],
      isRead: json['isRead'],
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId'],
      actionUrl: json['actionUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      timeAgo: json['timeAgo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientUserId': recipientUserId,
      'title': title,
      'message': message,
      'type': type,
      'typeDescription': typeDescription,
      'isRead': isRead,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'timeAgo': timeAgo,
    };
  }

  /// 알림 타입에 따른 아이콘 반환
  String getTypeIcon() {
    switch (type) {
      case 'JOB_APPLICATION':
        return '📝';
      case 'JOB_STATUS_UPDATE':
        return '📊';
      case 'NEW_JOB_POSTING':
        return '💼';
      case 'RESUME_VIEW':
        return '👀';
      case 'MESSAGE':
        return '💬';
      case 'SYSTEM':
        return '⚙️';
      case 'PAYMENT':
        return '💳';
      case 'EMAIL_VERIFICATION':
        return '✉️';
      case 'PASSWORD_RESET':
        return '🔐';
      case 'COMPANY_APPROVAL':
        return '✅';
      case 'JOB_EXPIRED':
        return '⏰';
      case 'INTERVIEW_SCHEDULE':
        return '📅';
      default:
        return '🔔';
    }
  }

  /// 알림 타입에 따른 색상 반환
  String getTypeColor() {
    switch (type) {
      case 'JOB_APPLICATION':
        return '#4CAF50'; // 초록색
      case 'JOB_STATUS_UPDATE':
        return '#2196F3'; // 파란색
      case 'NEW_JOB_POSTING':
        return '#FF9800'; // 주황색
      case 'RESUME_VIEW':
        return '#9C27B0'; // 보라색
      case 'MESSAGE':
        return '#607D8B'; // 회색
      case 'SYSTEM':
        return '#795548'; // 갈색
      case 'PAYMENT':
        return '#F44336'; // 빨간색
      case 'EMAIL_VERIFICATION':
        return '#00BCD4'; // 청록색
      case 'PASSWORD_RESET':
        return '#FF5722'; // 진한 주황색
      case 'COMPANY_APPROVAL':
        return '#8BC34A'; // 연두색
      case 'JOB_EXPIRED':
        return '#FFC107'; // 노란색
      case 'INTERVIEW_SCHEDULE':
        return '#3F51B5'; // 인디고
      default:
        return '#9E9E9E'; // 회색
    }
  }

  /// 읽지 않은 알림인지 확인
  bool get isUnread => !isRead;

  /// 알림이 오늘 온 것인지 확인
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// 알림이 이번 주에 온 것인지 확인
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return createdAt.isAfter(weekStart);
  }
}

/// 알림 페이지 응답 모델
class NotificationPageResponse {
  final List<NotificationModel> notifications;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;
  final int unreadCount;

  NotificationPageResponse({
    required this.notifications,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
    required this.unreadCount,
  });

  factory NotificationPageResponse.fromJson(Map<String, dynamic> json) {
    return NotificationPageResponse(
      notifications:
          (json['notifications'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList(),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
      unreadCount: json['unreadCount'],
    );
  }
}

/// 알림 통계 모델
class NotificationStats {
  final int totalCount;
  final int unreadCount;
  final int todayCount;
  final int weekCount;
  final Map<String, int> typeCountMap;

  NotificationStats({
    required this.totalCount,
    required this.unreadCount,
    required this.todayCount,
    required this.weekCount,
    required this.typeCountMap,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalCount: json['totalCount'],
      unreadCount: json['unreadCount'],
      todayCount: json['todayCount'],
      weekCount: json['weekCount'],
      typeCountMap: Map<String, int>.from(json['typeCountMap'] ?? {}),
    );
  }
}

/// 알림 타입 enum
enum NotificationType {
  jobApplication('JOB_APPLICATION', '지원 알림'),
  jobStatusUpdate('JOB_STATUS_UPDATE', '지원 상태 변경'),
  newJobPosting('NEW_JOB_POSTING', '새로운 채용공고'),
  resumeView('RESUME_VIEW', '이력서 조회'),
  message('MESSAGE', '메시지'),
  system('SYSTEM', '시스템 알림'),
  payment('PAYMENT', '결제 알림'),
  emailVerification('EMAIL_VERIFICATION', '이메일 인증'),
  passwordReset('PASSWORD_RESET', '비밀번호 재설정'),
  companyApproval('COMPANY_APPROVAL', '기업 승인'),
  jobExpired('JOB_EXPIRED', '채용공고 만료'),
  interviewSchedule('INTERVIEW_SCHEDULE', '면접 일정');

  const NotificationType(this.value, this.description);

  final String value;
  final String description;

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

class Job {
  final int? jobNo;
  final String title;
  final String content;
  final String company;
  final String? location;
  final String? jobType;
  final String? salary;
  final String? workType;
  final String? experience;
  final String? education;
  final DateTime? deadline;
  final DateTime? regdate;
  final DateTime? updatedAt;
  final int? viewCount;
  final bool? isActive;
  final int? userNo;

  // ✅ 새로 추가: 상태 관리 필드들
  final String status;
  final String statusDescription;
  final bool canEdit;
  final bool canPublish;
  final bool canDelete;
  final bool isExpired;

  Job({
    this.jobNo,
    required this.title,
    required this.content,
    required this.company,
    this.location,
    this.jobType,
    this.salary,
    this.workType,
    this.experience,
    this.education,
    this.deadline,
    this.regdate,
    this.updatedAt,
    this.viewCount,
    this.isActive,
    this.userNo,
    this.status = 'DRAFT',
    this.statusDescription = '임시저장',
    this.canEdit = true,
    this.canPublish = false,
    this.canDelete = true,
    this.isExpired = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobNo: json['jobNo'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      company: json['company'] ?? '',
      location: json['location'],
      jobType: json['jobType'],
      salary: json['salary'],
      workType: json['workType'],
      experience: json['experience'],
      education: json['education'],
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      regdate: json['regdate'] != null ? DateTime.parse(json['regdate']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      viewCount: json['viewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      userNo: json['userNo'],
      status: json['status'] ?? 'DRAFT',
      statusDescription: json['statusDescription'] ?? '임시저장',
      canEdit: json['canEdit'] ?? true,
      canPublish: json['canPublish'] ?? false,
      canDelete: json['canDelete'] ?? true,
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (jobNo != null) 'jobNo': jobNo,
      'title': title,
      'content': content,
      'company': company,
      if (location != null) 'location': location,
      if (jobType != null) 'jobType': jobType,
      if (salary != null) 'salary': salary,
      if (workType != null) 'workType': workType,
      if (experience != null) 'experience': experience,
      if (education != null) 'education': education,
      if (deadline != null)
        'deadline': deadline!.toIso8601String().split('T')[0],
      if (viewCount != null) 'viewCount': viewCount,
      if (isActive != null) 'isActive': isActive,
      if (userNo != null) 'userNo': userNo,
      'status': status,
    };
  }

  // ✅ 상태 확인 헬퍼 메서드들
  bool get isDraft => status == 'DRAFT';
  bool get isPublished => status == 'PUBLISHED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';
  bool get isSuspended => status == 'SUSPENDED';

  // ✅ 상태별 색상
  Color get statusColor {
    switch (status) {
      case 'DRAFT':
        return Colors.grey;
      case 'PENDING':
        return Colors.orange;
      case 'PUBLISHED':
        return Colors.green;
      case 'EXPIRED':
        return Colors.red;
      case 'REJECTED':
        return Colors.red.shade300;
      case 'SUSPENDED':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // ✅ 상태별 아이콘
  IconData get statusIcon {
    switch (status) {
      case 'DRAFT':
        return Icons.edit_note;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'PUBLISHED':
        return Icons.public;
      case 'EXPIRED':
        return Icons.schedule;
      case 'REJECTED':
        return Icons.cancel;
      case 'SUSPENDED':
        return Icons.pause;
      default:
        return Icons.help;
    }
  }

  Job copyWith({
    int? jobNo,
    String? title,
    String? content,
    String? company,
    String? location,
    String? jobType,
    String? salary,
    String? workType,
    String? experience,
    String? education,
    DateTime? deadline,
    DateTime? regdate,
    DateTime? updatedAt,
    int? viewCount,
    bool? isActive,
    int? userNo,
    String? status,
    String? statusDescription,
    bool? canEdit,
    bool? canPublish,
    bool? canDelete,
    bool? isExpired,
  }) {
    return Job(
      jobNo: jobNo ?? this.jobNo,
      title: title ?? this.title,
      content: content ?? this.content,
      company: company ?? this.company,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      salary: salary ?? this.salary,
      workType: workType ?? this.workType,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      deadline: deadline ?? this.deadline,
      regdate: regdate ?? this.regdate,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      isActive: isActive ?? this.isActive,
      userNo: userNo ?? this.userNo,
      status: status ?? this.status,
      statusDescription: statusDescription ?? this.statusDescription,
      canEdit: canEdit ?? this.canEdit,
      canPublish: canPublish ?? this.canPublish,
      canDelete: canDelete ?? this.canDelete,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}

// ✅ 채용공고 상태 열거형
enum JobStatus {
  draft('DRAFT', '임시저장', Colors.grey),
  pending('PENDING', '승인대기', Colors.orange),
  published('PUBLISHED', '게시중', Colors.green),
  expired('EXPIRED', '마감', Colors.red),
  rejected('REJECTED', '승인거부', Colors.red),
  suspended('SUSPENDED', '게시중단', Colors.amber);

  const JobStatus(this.value, this.description, this.color);

  final String value;
  final String description;
  final Color color;

  static JobStatus fromString(String status) {
    return JobStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => JobStatus.draft,
    );
  }
}

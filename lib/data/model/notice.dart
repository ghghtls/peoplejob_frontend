class Notice {
  final int? noticeNo;
  final String title;
  final String content;
  final String writer;
  final String? regdate;
  final int? viewCount;
  final bool? isImportant;
  final bool? isActive;
  final String? filename;
  final String? originalFilename;
  final String? createdAt;
  final String? updatedAt;

  Notice({
    this.noticeNo,
    required this.title,
    required this.content,
    required this.writer,
    this.regdate,
    this.viewCount,
    this.isImportant,
    this.isActive,
    this.filename,
    this.originalFilename,
    this.createdAt,
    this.updatedAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticeNo: json['noticeNo'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      writer: json['writer'] ?? '',
      regdate: json['regdate'],
      viewCount: json['viewCount'] ?? 0,
      isImportant: json['isImportant'] ?? false,
      isActive: json['isActive'] ?? true,
      filename: json['filename'],
      originalFilename: json['originalFilename'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeNo': noticeNo,
      'title': title,
      'content': content,
      'writer': writer,
      'regdate': regdate,
      'viewCount': viewCount,
      'isImportant': isImportant,
      'isActive': isActive,
      'filename': filename,
      'originalFilename': originalFilename,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // 요약 내용 반환 (목록용)
  String getContentSummary() {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 100)}...';
  }

  // 중요 공지 여부 확인
  bool get isImportantNotice => isImportant ?? false;

  // 활성 공지 여부 확인
  bool get isActiveNotice => isActive ?? true;

  // 첨부파일 존재 여부
  bool get hasAttachment => filename != null && filename!.isNotEmpty;

  // 날짜 포맷팅
  String get formattedDate {
    if (regdate == null) return '날짜 없음';
    try {
      final date = DateTime.parse(regdate!);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return regdate!;
    }
  }

  // 복사본 생성 (수정용)
  Notice copyWith({
    int? noticeNo,
    String? title,
    String? content,
    String? writer,
    String? regdate,
    int? viewCount,
    bool? isImportant,
    bool? isActive,
    String? filename,
    String? originalFilename,
    String? createdAt,
    String? updatedAt,
  }) {
    return Notice(
      noticeNo: noticeNo ?? this.noticeNo,
      title: title ?? this.title,
      content: content ?? this.content,
      writer: writer ?? this.writer,
      regdate: regdate ?? this.regdate,
      viewCount: viewCount ?? this.viewCount,
      isImportant: isImportant ?? this.isImportant,
      isActive: isActive ?? this.isActive,
      filename: filename ?? this.filename,
      originalFilename: originalFilename ?? this.originalFilename,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

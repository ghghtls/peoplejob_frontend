class Inquiry {
  final int? inquiryNo;
  final int? userNo;
  final String title;
  final String content;
  final String? regdate;
  final String? answer;
  final String? answerDate;
  final String? status;

  Inquiry({
    this.inquiryNo,
    this.userNo,
    required this.title,
    required this.content,
    this.regdate,
    this.answer,
    this.answerDate,
    this.status,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      inquiryNo: _parseToInt(json['inquiryNo']),
      userNo: _parseToInt(json['userNo']),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      regdate: json['regdate']?.toString(),
      answer: json['answer']?.toString(),
      answerDate: json['answerDate']?.toString(),
      status: json['status']?.toString() ?? 'WAIT',
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'inquiryNo': inquiryNo,
      'userNo': userNo,
      'title': title,
      'content': content,
      'regdate': regdate,
      'answer': answer,
      'answerDate': answerDate,
      'status': status,
    };
  }

  // 상태별 색상 반환
  String get statusText {
    switch (status) {
      case 'WAIT':
        return '답변 대기';
      case 'ANSWERED':
        return '답변 완료';
      default:
        return '알 수 없음';
    }
  }

  // 상태별 컬러 반환
  bool get isAnswered => status == 'ANSWERED';
}

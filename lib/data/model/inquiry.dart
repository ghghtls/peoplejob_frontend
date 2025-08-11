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
      inquiryNo: json['inquiryNo'],
      userNo: json['userNo'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      regdate: json['regdate'],
      answer: json['answer'],
      answerDate: json['answerDate'],
      status: json['status'] ?? 'WAIT',
    );
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

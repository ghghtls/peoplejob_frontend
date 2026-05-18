class Inquiry {
  final int? inquiryNo;
  final String? writer;
  final String? email;
  final String? category;
  final String title;
  final String content;
  final String? regdate;
  final String? answer;
  final String? answerDate;
  final bool isAnswered;

  Inquiry({
    this.inquiryNo,
    this.writer,
    this.email,
    this.category,
    required this.title,
    required this.content,
    this.regdate,
    this.answer,
    this.answerDate,
    this.isAnswered = false,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    final answered = json['isAnswered'];
    return Inquiry(
      inquiryNo: _toInt(json['inquiryNo']),
      writer: json['writer']?.toString(),
      email: json['email']?.toString(),
      category: json['category']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      regdate: json['regdate']?.toString(),
      answer: json['answer']?.toString(),
      answerDate: json['answerDate']?.toString(),
      isAnswered: answered == true || answered == 1 || answered.toString() == 'true',
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // userNo 접근자 — 기존 코드 호환용 (writer 문자열을 그대로 반환)
  String? get userNo => writer;

  String get statusText => isAnswered ? '답변 완료' : '답변 대기';
}

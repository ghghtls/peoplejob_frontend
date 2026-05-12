class Board {
  final int? boardNo;
  final String? category;
  final String title;
  final String content;
  final String? writer;
  final DateTime? regdate;
  final String? filename;
  final String? originalFilename;
  final int? viewCount;

  Board({
    this.boardNo,
    this.category,
    required this.title,
    required this.content,
    this.writer,
    this.regdate,
    this.filename,
    this.originalFilename,
    this.viewCount,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      boardNo: json['boardNo'],
      category: json['category'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      writer: json['writer'],
      regdate: json['regdate'] != null ? DateTime.parse(json['regdate']) : null,
      filename: json['filename'],
      originalFilename: json['originalFilename'],
      viewCount: json['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (boardNo != null) 'boardNo': boardNo,
      if (category != null) 'category': category,
      'title': title,
      'content': content,
      if (writer != null) 'writer': writer,
      if (regdate != null) 'regdate': regdate!.toIso8601String().split('T')[0],
      if (filename != null) 'filename': filename,
      if (originalFilename != null) 'originalFilename': originalFilename,
      if (viewCount != null) 'viewCount': viewCount,
    };
  }

  Board copyWith({
    int? boardNo,
    String? category,
    String? title,
    String? content,
    String? writer,
    DateTime? regdate,
    String? filename,
    String? originalFilename,
    int? viewCount,
  }) {
    return Board(
      boardNo: boardNo ?? this.boardNo,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      writer: writer ?? this.writer,
      regdate: regdate ?? this.regdate,
      filename: filename ?? this.filename,
      originalFilename: originalFilename ?? this.originalFilename,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

class Board {
  final int id;
  final String title;
  final bool isActive;
  final bool allowUpload;
  final bool allowComment;

  Board({
    required this.id,
    required this.title,
    required this.isActive,
    required this.allowUpload,
    required this.allowComment,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      title: json['title'],
      isActive: json['isActive'],
      allowUpload: json['allowUpload'],
      allowComment: json['allowComment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isActive': isActive,
      'allowUpload': allowUpload,
      'allowComment': allowComment,
    };
  }
}

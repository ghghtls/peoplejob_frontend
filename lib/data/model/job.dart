class Job {
  final int id;
  final String title;

  Job({required this.id, required this.title});

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(id: json['id'] as int, title: json['title'] as String);
  }
}

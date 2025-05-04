class Job {
  final int id;
  final int companyId;
  final String title;
  final String description;
  final String salary;
  final String location;
  final String workType;
  final String status;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.salary,
    required this.location,
    required this.workType,
    required this.status,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      salary: json['salary'] as String,
      location: json['location'] as String,
      workType: json['work_type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

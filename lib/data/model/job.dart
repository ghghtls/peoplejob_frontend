class Job {
  final int id;
  final int companyId;
  final String title;
  final String? content;
  final String? location;
  final String? salary;
  final String? career;
  final String? education;
  final DateTime? deadline;
  final DateTime? regdate;
  final String? jobType;
  final String? filename;
  final String? originalFilename;

  Job({
    required this.id,
    required this.companyId,
    required this.title,
    this.content,
    this.location,
    this.salary,
    this.career,
    this.education,
    this.deadline,
    this.regdate,
    this.jobType,
    this.filename,
    this.originalFilename,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['jobopening_no'] ?? 0,
      companyId: json['company_no'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'],
      location: json['location'],
      salary: json['salary'],
      career: json['career'],
      education: json['education'],
      deadline:
          json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      regdate:
          json['regdate'] != null ? DateTime.tryParse(json['regdate']) : null,
      jobType: json['jobtype'],
      filename: json['filename'],
      originalFilename: json['original_filename'],
    );
  }
}

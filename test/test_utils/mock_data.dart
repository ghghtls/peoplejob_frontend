class MockData {
  // 사용자 데이터
  static const Map<String, dynamic> mockUser = {
    'userNo': 1,
    'userid': 'testuser',
    'name': '테스트 사용자',
    'email': 'test@example.com',
    'phone': '010-1234-5678',
    'userType': 'INDIVIDUAL',
    'role': 'USER',
    'isActive': true,
    'isEmailVerified': true,
  };

  static const Map<String, dynamic> mockCompanyUser = {
    'userNo': 2,
    'userid': 'company',
    'name': '회사 담당자',
    'email': 'company@example.com',
    'phone': '02-1234-5678',
    'userType': 'COMPANY',
    'role': 'USER',
    'companyName': '테스트 회사',
    'businessNumber': '123-45-67890',
    'isActive': true,
    'isEmailVerified': true,
  };

  // 채용공고 데이터
  static final List<Map<String, dynamic>> mockJobs = [
    {
      'jobopeningNo': 1,
      'title': '백엔드 개발자 모집',
      'content': 'Java/Spring Boot 개발자를 모집합니다.',
      'company': '테스트 회사',
      'location': '서울',
      'jobtype': '정규직',
      'salary': '협의',
      'education': '대졸',
      'career': '경력무관',
      'deadline': '2024-12-31',
      'regdate': '2024-01-01T00:00:00',
      'isActive': true,
    },
    {
      'jobopeningNo': 2,
      'title': '프론트엔드 개발자 모집',
      'content': 'React 개발자를 모집합니다.',
      'company': '테스트 회사2',
      'location': '부산',
      'jobtype': '계약직',
      'salary': '3000만원',
      'education': '대졸',
      'career': '2년 이상',
      'deadline': '2024-11-30',
      'regdate': '2024-01-02T00:00:00',
      'isActive': true,
    },
  ];

  // 이력서 데이터
  static final List<Map<String, dynamic>> mockResumes = [
    {
      'resumeNo': 1,
      'userNo': 1,
      'title': '백엔드 개발자 이력서',
      'content': '3년 경력의 백엔드 개발자입니다.',
      'name': '홍길동',
      'email': 'hong@example.com',
      'phone': '010-1234-5678',
      'address': '서울시 강남구',
      'education': '컴퓨터공학과 학사',
      'career': '3년',
      'skills': 'Java, Spring Boot, MySQL',
      'hopeJobtype': '개발자',
      'hopeLocation': '서울',
      'hopeSalary': '4000만원',
      'regdate': '2024-01-01T00:00:00',
    },
    {
      'resumeNo': 2,
      'userNo': 1,
      'title': '풀스택 개발자 이력서',
      'content': '프론트엔드와 백엔드 모두 가능한 개발자입니다.',
      'name': '홍길동',
      'email': 'hong@example.com',
      'phone': '010-1234-5678',
      'address': '서울시 강남구',
      'education': '컴퓨터공학과 학사',
      'career': '3년',
      'skills': 'Java, Spring Boot, React, JavaScript',
      'hopeJobtype': '개발자',
      'hopeLocation': '서울',
      'hopeSalary': '5000만원',
      'regdate': '2024-01-15T00:00:00',
    },
  ];

  // 게시글 데이터
  static final List<Map<String, dynamic>> mockBoards = [
    {
      'boardNo': 1,
      'category': '공지사항',
      'title': '서비스 점검 안내',
      'content': '서버 점검으로 인한 서비스 일시 중단 안내입니다.',
      'writer': '관리자',
      'regdate': '2024-01-01',
      'viewCount': 100,
    },
    {
      'boardNo': 2,
      'category': '자유게시판',
      'title': '취업 후기 공유',
      'content': '면접 경험을 공유합니다.',
      'writer': '홍길동',
      'regdate': '2024-01-02',
      'viewCount': 50,
    },
  ];

  // 지원 내역 데이터
  static final List<Map<String, dynamic>> mockApplications = [
    {
      'applyNo': 1,
      'userNo': 1,
      'jobNo': 1,
      'resumeNo': 1,
      'status': 'PENDING',
      'applyDate': '2024-01-01T10:00:00',
      'coverLetter': '지원 동기입니다.',
      'jobTitle': '백엔드 개발자 모집',
      'companyName': '테스트 회사',
    },
    {
      'applyNo': 2,
      'userNo': 1,
      'jobNo': 2,
      'resumeNo': 1,
      'status': 'ACCEPTED',
      'applyDate': '2024-01-02T14:00:00',
      'coverLetter': '열정적으로 일하겠습니다.',
      'jobTitle': '프론트엔드 개발자 모집',
      'companyName': '테스트 회사2',
    },
  ];

  // 공지사항 데이터
  static final List<Map<String, dynamic>> mockNotices = [
    {
      'noticeNo': 1,
      'title': '서비스 업데이트 안내',
      'content': '새로운 기능이 추가되었습니다.',
      'author': '관리자',
      'createdAt': '2024-01-01T10:00:00',
      'isImportant': true,
      'isPublished': true,
      'viewCount': 150,
    },
    {
      'noticeNo': 2,
      'title': '이용약관 변경 안내',
      'content': '이용약관이 일부 변경되었습니다.',
      'author': '관리자',
      'createdAt': '2024-01-02T14:00:00',
      'isImportant': false,
      'isPublished': true,
      'viewCount': 80,
    },
  ];

  // JWT 토큰
  static const String mockJwtToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0dXNlciIsImlhdCI6MTUxNjIzOTAyMn0.mock-signature';

  // API 응답
  static final Map<String, dynamic> mockLoginResponse = {
    'token': mockJwtToken,
    'userid': 'testuser',
    'userNo': 1,
    'name': '테스트 사용자',
    'email': 'test@example.com',
    'userType': 'INDIVIDUAL',
    'role': 'USER',
  };

  // 에러 응답
  static final Map<String, dynamic> mockErrorResponse = {
    'error': 'Bad Request',
    'message': '잘못된 요청입니다.',
    'statusCode': 400,
  };

  // 페이지네이션 응답
  static Map<String, dynamic> mockPageResponse({
    required List<Map<String, dynamic>> content,
    int page = 0,
    int size = 10,
    int totalElements = 0,
  }) {
    return {
      'content': content,
      'page': page,
      'size': size,
      'totalElements': totalElements,
      'totalPages': (totalElements / size).ceil(),
      'first': page == 0,
      'last': page >= (totalElements / size).ceil() - 1,
    };
  }

  // 테스트 헬퍼 메서드
  static Map<String, dynamic> createMockJob({
    int? id,
    String? title,
    String? company,
    String? location,
  }) {
    return {
      'jobopeningNo': id ?? 1,
      'title': title ?? '개발자 모집',
      'content': '개발자를 모집합니다.',
      'company': company ?? '테스트 회사',
      'location': location ?? '서울',
      'jobtype': '정규직',
      'salary': '협의',
      'education': '대졸',
      'career': '경력무관',
      'deadline': '2024-12-31',
      'regdate': '2024-01-01T00:00:00',
      'isActive': true,
    };
  }

  static Map<String, dynamic> createMockResume({
    int? id,
    int? userNo,
    String? title,
    String? name,
  }) {
    return {
      'resumeNo': id ?? 1,
      'userNo': userNo ?? 1,
      'title': title ?? '개발자 이력서',
      'content': '이력서 내용입니다.',
      'name': name ?? '홍길동',
      'email': 'test@example.com',
      'phone': '010-1234-5678',
      'address': '서울시 강남구',
      'education': '대졸',
      'career': '3년',
      'skills': 'Java, Spring',
      'hopeJobtype': '개발자',
      'hopeLocation': '서울',
      'regdate': '2024-01-01T00:00:00',
    };
  }

  static Map<String, dynamic> createMockApplication({
    int? id,
    int? userNo,
    int? jobNo,
    String? status,
  }) {
    return {
      'applyNo': id ?? 1,
      'userNo': userNo ?? 1,
      'jobNo': jobNo ?? 1,
      'resumeNo': 1,
      'status': status ?? 'PENDING',
      'applyDate': '2024-01-01T10:00:00',
      'coverLetter': '지원 동기입니다.',
      'jobTitle': '백엔드 개발자 모집',
      'companyName': '테스트 회사',
    };
  }
}

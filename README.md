# PeopleJob — 채용 플랫폼 Flutter 앱

> 구직자 · 기업 · 관리자를 위한 통합 채용 서비스 모바일/웹 애플리케이션

<br>

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/home.png" width="200"/><br/><sub>홈 화면</sub></td>
    <td align="center"><img src="assets/screenshots/joblist.png" width="200"/><br/><sub>채용공고 목록</sub></td>
    <td align="center"><img src="assets/screenshots/jobdetail.png" width="200"/><br/><sub>채용공고 상세</sub></td>
    <td align="center"><img src="assets/screenshots/mypage.png" width="200"/><br/><sub>마이페이지</sub></td>
  </tr>
</table>

<br>

## 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [스크린샷](#스크린샷)
3. [주요 기능](#주요-기능)
4. [기술 스택](#기술-스택)
5. [아키텍처](#아키텍처)
6. [디렉토리 구조](#디렉토리-구조)
7. [서비스 레이어](#서비스-레이어)
8. [상태 관리](#상태-관리)
9. [디자인 시스템](#디자인-시스템)
10. [API 연동](#api-연동)
11. [테스트](#테스트)
12. [빌드 및 배포](#빌드-및-배포)

<br>

---

## 프로젝트 개요

**PeopleJob**은 구직자, 기업 채용담당자, 플랫폼 관리자 세 가지 역할을 지원하는 Flutter 기반 채용 플랫폼입니다. REST API 백엔드와 연동하며 Android · iOS · Web 멀티플랫폼을 단일 코드베이스로 지원합니다.

| 항목 | 내용 |
|------|------|
| 플랫폼 | Android / iOS / Web |
| Flutter SDK | ≥ 3.7.2 |
| 언어 | Dart |
| 아키텍처 | 서비스 레이어 + Riverpod 상태 관리 |
| 인증 방식 | JWT Bearer Token (FlutterSecureStorage) |
| 로케일 | 한국어 (ko_KR), 영어 (en_US) |

<br>

---

## 스크린샷

### 인증

로그인, 비밀번호 찾기 화면입니다. 아이디/비밀번호 입력 후 로그인 유지 옵션을 선택할 수 있으며, 비밀번호 찾기는 가입한 이메일로 재설정 링크를 발송합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/login.png" width="220"/><br/><sub>로그인</sub></td>
    <td align="center"><img src="assets/screenshots/find_password.png" width="220"/><br/><sub>비밀번호 찾기</sub></td>
  </tr>
</table>

---

### 홈 화면

로그인한 사용자의 이름으로 개인화된 인사말 배너를 표시합니다. 채용공고·이력서·인재검색·공지사항·게시판·자료실 6개 빠른 메뉴와 추천 채용공고 카드 슬라이더를 제공합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/home.png" width="220"/><br/><sub>홈 화면 — 개인화 배너 · 빠른 메뉴 · 추천 공고</sub></td>
  </tr>
</table>

---

### 채용공고

고용형태(정규직·계약직·인턴·프리랜서·파트타임)와 지역(서울·경기·인천·부산·대구·대전 등) 필터 칩을 제공합니다. 프리미엄 광고 공고는 `AD` 배지와 주황색 테두리로 강조 표시됩니다. 상세 화면은 D-Day 배지, 급여·지역·마감일·고용형태 요약 카드, 학력/경력 요건, 전체 공고 내용을 포함합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/joblist.png" width="220"/><br/><sub>채용공고 목록 — 필터 · AD 배지</sub></td>
    <td align="center"><img src="assets/screenshots/jobdetail.png" width="220"/><br/><sub>채용공고 상세 — D-Day · 요약 카드</sub></td>
  </tr>
</table>

---

### 이력서

**내 이력서** 페이지는 자신이 작성한 이력서만 노출하며, 빠른 등록을 위한 FAB(+) 버튼을 제공합니다. **이력서 등록** 화면에서는 프로필 사진 업로드, 이력서 제목, 희망직종·지역·근무형태를 칩 선택 방식으로 입력합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/resume.png" width="220"/><br/><sub>내 이력서 목록 (빈 상태)</sub></td>
    <td align="center"><img src="assets/screenshots/resume_register.png" width="220"/><br/><sub>이력서 등록 — 프로필 사진 · 직종/지역 선택</sub></td>
  </tr>
</table>

---

### 인재정보 검색

기업 채용담당자가 희망 지역과 직무(백엔드·프론트엔드·iOS·안드로이드 등)로 구직자 이력서를 검색합니다. 검색 결과는 이력서 제목, 직종, 지역, 고용형태, 자기소개 미리보기를 카드 형태로 표시합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/talent_list.png" width="220"/><br/><sub>인재정보 검색 — 지역·직무 필터</sub></td>
    <td align="center"><img src="assets/screenshots/resumelist.png" width="220"/><br/><sub>이력서 목록 — 직종 필터 · 제안하기</sub></td>
  </tr>
</table>

---

### 마이페이지 (개인)

프로필 카드(이름·이메일·회원 유형)와 지원·스크랩·이력서 현황을 한눈에 확인할 수 있습니다. 취업 활동(지원 내역·스크랩 공고·이력서 관리), 정보/지원(문의사항·자료실·게시판), 설정(내정보 수정·알림·비밀번호 변경) 메뉴를 제공합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/mypage.png" width="220"/><br/><sub>개인 마이페이지 — 통계 · 메뉴 그룹</sub></td>
  </tr>
</table>

---

### 기업 마이페이지 · 지원자 관리

기업 프로필 카드 아래 채용 관리(채용공고 등록·관리·지원자 관리), 기업 서비스(광고 신청·결제 내역·인재정보 검색), 정보 및 지원, 계정 설정 메뉴를 제공합니다. 지원자 관리에서는 공고별 지원자 목록과 개별 지원자의 이력서 보기·연락하기 기능을 사용할 수 있습니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/company_mypage.png" width="220"/><br/><sub>기업 마이페이지 — 채용·서비스 메뉴</sub></td>
    <td align="center"><img src="assets/screenshots/company1.png" width="220"/><br/><sub>지원자 관리 — 공고별 목록</sub></td>
    <td align="center"><img src="assets/screenshots/comany_applicants.png" width="220"/><br/><sub>지원자 상세 — 이력서 보기 · 연락하기</sub></td>
  </tr>
</table>

---

### 광고 결제 시스템

채용공고 광고 신청부터 결제까지 5단계 플로우로 구성됩니다. Basic(10,000원 · 7일), Standard(30,000원 · 7일), Premium(50,000원 · 7일) 세 가지 상품을 제공하며, 광고 노출 기간은 7일·14일·30일 중 선택합니다. 결제 완료 후 영수증과 결제 내역 확인 화면으로 이동합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/payment1.png" width="180"/><br/><sub>광고 효과 안내</sub></td>
    <td align="center"><img src="assets/screenshots/payment2.png" width="180"/><br/><sub>광고할 공고 선택</sub></td>
    <td align="center"><img src="assets/screenshots/payment3.png" width="180"/><br/><sub>광고 상품 선택</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="assets/screenshots/payment4.png" width="180"/><br/><sub>광고 일정 설정</sub></td>
    <td align="center"><img src="assets/screenshots/payment5.png" width="180"/><br/><sub>결제 완료 영수증</sub></td>
    <td align="center"><img src="assets/screenshots/payment6.png" width="180"/><br/><sub>광고 결제 내역</sub></td>
  </tr>
</table>

---

### 게시판 · 공지사항 · 문의사항

게시판은 공지사항·자유게시판·질문게시판·취업정보 카테고리를 지원하며 제목·작성자로 실시간 검색이 가능합니다. 공지사항은 중요 공지를 빨간 배지로 강조 표시하고 공유 기능을 제공합니다. 1:1 문의는 제목과 상세 내용을 입력해 제출하며, 관리자의 답변을 앱 내에서 확인할 수 있습니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/board.png" width="180"/><br/><sub>게시판 목록 — 카테고리 탭</sub></td>
    <td align="center"><img src="assets/screenshots/board_write.png" width="180"/><br/><sub>게시글 작성</sub></td>
    <td align="center"><img src="assets/screenshots/notice.png" width="180"/><br/><sub>공지사항 목록</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="assets/screenshots/notice_detail.png" width="180"/><br/><sub>공지사항 상세 · 공유</sub></td>
    <td align="center"><img src="assets/screenshots/inquiry.png" width="180"/><br/><sub>1:1 문의 작성</sub></td>
  </tr>
</table>

---

### 자료실 · 취업 뉴스 · 글자 수 세기

자료실에서는 자소서 작성 가이드, 채용 설명회 자료집, 면접 준비 체크리스트 등 취업 관련 자료를 제공하고, 글자 수 세기 도구와 취업 뉴스, 워크넷 바로가기를 통합 제공합니다. 취업 뉴스는 실시간 채용 트렌드와 정책 변화 정보를 목록 형태로 제공합니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/resources.png" width="180"/><br/><sub>자료실 메인 — 자료·도구·뉴스</sub></td>
    <td align="center"><img src="assets/screenshots/resources_list.png" width="180"/><br/><sub>자료 상세 — 자소서 가이드</sub></td>
    <td align="center"><img src="assets/screenshots/news.png" width="180"/><br/><sub>취업 뉴스</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="assets/screenshots/wordcount.png" width="180"/><br/><sub>글자 수 세기 (공백 포함/제외)</sub></td>
  </tr>
</table>

---

### 관리자 패널

관리자 전용 패널로 회원·채용공고·지원자·광고결제·문의사항·공지사항·FAQ·팝업·파일·서비스 상품을 통합 관리합니다. 주요 목록에는 Excel 다운로드 버튼이 제공됩니다.

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/admin1.png" width="180"/><br/><sub>관리자 홈 — 전체 메뉴</sub></td>
    <td align="center"><img src="assets/screenshots/admin_user.png" width="180"/><br/><sub>회원 관리 — 기업/개인 구분</sub></td>
    <td align="center"><img src="assets/screenshots/admin_job.png" width="180"/><br/><sub>채용공고 관리 — 상태 탭 · 승인</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="assets/screenshots/admin2.png" width="180"/><br/><sub>지원자 목록 — 상태별 필터</sub></td>
    <td align="center"><img src="assets/screenshots/admin4.png" width="180"/><br/><sub>문의사항 관리 — 답변 처리</sub></td>
    <td align="center"><img src="assets/screenshots/admin3.png" width="180"/><br/><sub>서비스 상품 조회 · 관리</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="assets/screenshots/admin_notice.png" width="180"/><br/><sub>공지사항 관리</sub></td>
    <td align="center"><img src="assets/screenshots/faq.png" width="180"/><br/><sub>FAQ 관리 — 아코디언 Q&A</sub></td>
    <td align="center"><img src="assets/screenshots/popup.png" width="180"/><br/><sub>팝업 관리 — 노출 토글</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="assets/screenshots/admin_file.png" width="180"/><br/><sub>파일 관리 — 유형별 탭</sub></td>
    <td align="center"><img src="assets/screenshots/excel.png" width="300"/><br/><sub>Excel 다운로드 완료 알림</sub></td>
  </tr>
</table>

<br>

---

## 주요 기능

### 👤 구직자 (User)

| 기능 | 설명 |
|------|------|
| 회원가입 / 로그인 | 아이디·비밀번호 기반 인증, 이메일 인증 |
| 채용공고 탐색 | 전체 목록, 고용형태·지역 필터 칩, 키워드 검색, AD 배지 |
| 채용공고 지원 | 이력서 선택 후 원클릭 지원, 중복 지원 방지 |
| 이력서 관리 | 이력서 CRUD, 희망직종·지역·근무형태 선택, 프로필 사진 업로드 |
| 마이페이지 | 지원/스크랩/이력서 현황 통계, 내정보 수정, 비밀번호 변경 |
| 커뮤니티 | 게시판 카테고리별 읽기·쓰기·수정·삭제 |
| 자료실 | 취업 관련 자료 다운로드, 자소서 가이드, 면접 체크리스트 |
| 도구 | 글자 수 세기(공백 포함/제외), 취업 뉴스, 워크넷 바로가기 |
| 알림 | 실시간 알림 수신, 읽음 처리 |

### 🏢 기업 (Company)

| 기능 | 설명 |
|------|------|
| 채용공고 관리 | 등록·수정·삭제, 임시저장, 게시 상태 관리 |
| 공고 상태 제어 | DRAFT → PENDING → PUBLISHED → EXPIRED 흐름 |
| 지원자 관리 | 공고별 지원자 목록, 이력서 열람, 이메일 연락 |
| 기업 마이페이지 | 기업 프로필 관리, 채용·서비스·계정 메뉴 통합 |
| 인재 검색 | 지역·직무 필터로 구직자 이력서 검색, 제안하기 |
| 광고 결제 | Basic·Standard·Premium 상품, 7일·14일·30일 노출 기간 선택 |
| 결제 내역 | 광고별 결제 금액·기간 이력, 총 결제 금액 요약 |

### 🔧 관리자 (Admin)

| 기능 | 설명 |
|------|------|
| 대시보드 | 사용자·공고·지원 현황 통계 |
| 회원 관리 | 기업/개인 회원 구분 조회·삭제, Excel 다운로드 |
| 채용공고 관리 | 전체/승인대기/게시중/마감 탭, 승인·반려·강제마감, Excel 다운로드 |
| 지원자 관리 | 전체 지원 내역, 상태(지원완료·검토중·합격·불합격) 필터, Excel 다운로드 |
| 문의사항 관리 | 답변 대기/완료 탭, 인라인 답변 처리, Excel 다운로드 |
| 공지사항 관리 | 공지 등록·수정·삭제 |
| FAQ 관리 | Q&A 아코디언 형식, 등록·수정·삭제 |
| 팝업 관리 | 팝업 배너 등록·수정, 노출/미노출 토글 |
| 파일 관리 | 이력서·채용공고·게시판·이미지·문서 유형별 탭, 다운로드·삭제 |
| 서비스 상품 관리 | 광고 상품(프리미엄·배너·로고 강조) 등록·수정·삭제 |

<br>

---

## 기술 스택

### 코어

| 분야 | 기술 | 버전 |
|------|------|------|
| UI 프레임워크 | Flutter | ≥ 3.7.2 |
| 상태 관리 | flutter_riverpod | 2.6.1 |
| HTTP 클라이언트 | Dio | 5.8.0+1 |
| HTTP 클라이언트 (보조) | http | 0.13.6 |
| 로컬 보안 저장소 | flutter_secure_storage | 9.0.0 |
| 로컬 설정 저장소 | shared_preferences | 2.2.2 |
| 로컬 DB | Hive + hive_flutter | 2.2.3 / 1.1.0 |

### UI / UX

| 분야 | 기술 | 버전 |
|------|------|------|
| 디자인 시스템 | Material Design 3 | — |
| 커스텀 폰트 | Pretendard | 400/500/600/700 |
| 리치 텍스트 에디터 | flutter_quill + extensions | 11.4.0 / 11.0.0 |
| 이미지 캐싱 | cached_network_image | 3.3.0 |
| 아이콘 | cupertino_icons | 1.0.8 |
| 국제화 | intl | 0.20.2 |
| 웹뷰 | webview_flutter | 4.11.0 |

### 파일 처리

| 분야 | 기술 | 버전 |
|------|------|------|
| 파일 선택 | file_picker | 10.2.0 |
| 이미지 선택 | image_picker | 1.1.2 |
| 파일 경로 | path_provider | 2.1.1 |
| 암호화 | crypto + encrypt | 3.0.3 / 5.0.1 |

### Firebase (설정 완료, 선택적 사용)

| 서비스 | 패키지 | 버전 |
|--------|--------|------|
| Core | firebase_core | 3.13.0 |
| Auth | firebase_auth | 5.5.3 |
| Database | cloud_firestore | 5.6.7 |
| Storage | firebase_storage | 12.4.5 |

### 개발 / 테스트

| 분야 | 기술 | 버전 |
|------|------|------|
| 모킹 | mockito | 5.4.4 |
| 코드 생성 | build_runner | 2.4.9 |
| HTTP 모킹 | http_mock_adapter | 0.6.1 |
| 이미지 모킹 | network_image_mock | 2.1.1 |
| 테스트 데이터 | faker | 2.1.0 |
| 골든 테스트 | golden_toolkit | 0.15.0 |
| 코드 분석 | very_good_analysis | 6.0.0 |

<br>

---

## 아키텍처

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                         │
│  Pages (100+)  ·  Shared Widgets  ·  App Bar        │
└────────────────────────┬────────────────────────────┘
                         │ consumes
┌────────────────────────▼────────────────────────────┐
│              State Management Layer                 │
│         Riverpod Providers (StateProvider)          │
│   AuthProvider · JobProvider · NotifProvider · …   │
└────────────────────────┬────────────────────────────┘
                         │ calls
┌────────────────────────▼────────────────────────────┐
│                 Service Layer                       │
│  AuthService · JobService · ResumeService           │
│  ApplyService · BoardService · InquiryService       │
│  ScrapService · PaymentService · AdminService · …   │
│  (JWT 인터셉터, 에러 처리, 페이지네이션 내장)         │
└──────────────┬─────────────────┬───────────────────┘
               │                 │
┌──────────────▼──────┐  ┌───────▼───────────────────┐
│   Remote API        │  │  Local Storage             │
│  REST (Dio/http)    │  │  SecureStorage             │
│  JWT 인증           │  │  SharedPreferences         │
│  멀티파트 업로드     │  │  Hive                      │
└─────────────────────┘  └───────────────────────────┘
```

### 라우팅

`MaterialApp.routes` + `onGenerateRoute`를 사용한 55+ 정적 라우트와 동적 라우트 혼합 방식입니다.

```
/                       → 홈
├─ /login               → 로그인
├─ /register            → 회원가입
├─ /find-id             → 아이디 찾기
├─ /find-password       → 비밀번호 찾기
├─ /job-list            → 채용공고 목록
├─ /job-detail          → 채용공고 상세 (동적: jobId)
├─ /job-register        → 채용공고 등록
├─ /resume              → 내 이력서 목록
├─ /resume-register     → 이력서 등록
├─ /profile-edit        → 내정보 수정
├─ /board               → 게시판
├─ /notice              → 공지사항
├─ /inquiry/*           → 1:1 문의
├─ /search              → 통합 검색
├─ /talent-search       → 인재정보 검색
├─ /payment/*           → 광고 결제 (공고 선택→상품 선택→일정→결제→완료)
├─ /mypage              → 개인 마이페이지
├─ /companymypage       → 기업 마이페이지
├─ /resources/list      → 자료실
├─ /tools/wordcount     → 글자 수 세기
└─ /admin/*             → 관리자 패널 (권한 체크)
    ├─ /admin/dashboard     → 대시보드
    ├─ /admin/user          → 회원 관리
    ├─ /admin/jobs          → 채용공고 관리
    ├─ /admin/applicants    → 지원자 관리
    ├─ /admin/inquiry       → 문의사항 관리
    ├─ /admin/notice        → 공지사항 관리
    ├─ /admin/faq           → FAQ 관리
    ├─ /admin/popup         → 팝업 관리
    ├─ /admin/files         → 파일 관리
    └─ /admin/products      → 서비스 상품 관리
```

관리자 라우트는 `isAdminProvider`로 접근 제어하며, 권한이 없으면 `UnauthorizedPage`로 리다이렉트합니다.

<br>

---

## 디렉토리 구조

```
lib/
├── main.dart                   # 앱 진입점, 초기화, 라우팅 정의
├── firebase_options.dart       # Firebase 설정
├── api_service.dart            # 공통 API 서비스
│
├── config/
│   └── theme/
│       └── app_theme.dart      # 디자인 토큰, ThemeData
│
├── services/                   # 비즈니스 로직 계층
│   ├── auth_service.dart
│   ├── job_service.dart
│   ├── resume_service.dart
│   ├── apply_service.dart
│   ├── board_service.dart
│   ├── notice_service.dart
│   ├── inquiry_service.dart
│   ├── notification_service.dart
│   ├── scrap_service.dart
│   ├── payment_service.dart
│   ├── file_upload_service.dart
│   ├── admin_service.dart
│   ├── email_service.dart
│   ├── password_reset_service.dart
│   ├── token_service.dart
│   ├── session_service.dart
│   └── config/
│       └── api_config.dart     # API 엔드포인트, 환경 설정
│
├── data/
│   ├── model/                  # 데이터 모델
│   │   ├── job.dart
│   │   ├── inquiry.dart
│   │   ├── board.dart
│   │   └── notification_model.dart
│   └── provider/               # Riverpod 상태 관리
│       ├── auth_provider.dart
│       ├── job_provider.dart
│       ├── resume_providers.dart
│       ├── admin_provider.dart
│       ├── profile_provider.dart
│       ├── notification_provider.dart
│       └── …
│
├── ui/
│   ├── pages/
│   │   ├── home/               # 홈 화면
│   │   ├── login/              # 인증 (로그인, 회원가입, 아이디/비번 찾기)
│   │   ├── job/                # 채용공고
│   │   ├── resume/             # 이력서
│   │   ├── board/              # 게시판
│   │   ├── notice/             # 공지사항
│   │   ├── inquiry/            # 1:1 문의
│   │   ├── mypage/             # 개인 마이페이지 (프로필 수정 포함)
│   │   ├── company_mypage/     # 기업 마이페이지
│   │   ├── company/            # 기업 전용 (지원자 관리)
│   │   ├── search/             # 검색, 인재정보 검색
│   │   ├── payment/            # 광고 결제 플로우
│   │   ├── notification/       # 알림
│   │   ├── resources/          # 자료실, 취업 뉴스
│   │   ├── tools/              # 글자 수 세기
│   │   ├── admin/              # 관리자 패널
│   │   └── error/              # 오류 페이지
│   └── widgets/                # 공유 위젯
│       ├── app_bar.dart        # 공통 AppBar + 로고 + 홈 버튼
│       ├── apply_dialog.dart
│       ├── job_status_change_button.dart
│       ├── quill_editor_widget.dart
│       └── …
│
├── core/
│   ├── constants/
│   ├── routes/
│   └── utils/
│
└── extension/                  # Dart 확장 메서드
```

<br>

---

## 서비스 레이어

### AuthService

인증·사용자 정보의 모든 흐름을 담당합니다.

```dart
login(userid, password)         // JWT 발급 및 SecureStorage 저장
register(...)                   // 개인/기업 회원가입 (25개 이상 필드)
verifyEmail(userid, code)       // 이메일 인증 코드 확인
checkUserid(userid)             // 아이디 중복 확인
getUserProfile()                // 현재 사용자 프로필 조회
updateUserProfile(...)          // 프로필 수정 (이름·이메일·전화번호·주소·기업정보)
changePassword(...)             // 비밀번호 변경
uploadProfileImage(file)        // 이미지 업로드 (Dio FormData)
deleteAccount()                 // 회원 탈퇴
logout()                        // 토큰 및 캐시 삭제
```

**토큰 관리:** Dio 인터셉터가 모든 요청에 `Authorization: Bearer <token>` 헤더를 자동으로 첨부합니다. 401 응답 시 토큰을 즉시 삭제합니다.

---

### JobService

채용공고 CRUD 및 상태 흐름 관리.

```dart
getAllJobs({size})               // 게시된 공고 목록 (페이지네이션)
getJobDetail(jobId)             // 공고 상세
createJob(jobData)              // 공고 등록
updateJob(jobId, jobData)       // 공고 수정
deleteJob(jobId)                // 공고 삭제
searchJobs(keyword)             // 키워드 검색
saveDraft(jobData)              // 임시 저장
publishJob(jobNo, userNo)       // 임시저장 → 게시 신청
changeJobStatus(...)            // 상태 변경 (PUBLISHED / EXPIRED / ...)
expireOverdueJobs()             // 마감된 공고 일괄 처리
batchChangeStatus(...)          // 일괄 상태 변경 (관리자)
batchDeleteJobs(jobNos)         // 일괄 삭제 (관리자)
```

**공고 상태 흐름:**

```
DRAFT ──► PENDING ──► PUBLISHED ──► EXPIRED
  │                      │
  └──────────────────────┘  (수정 후 재심사)
```

---

### ResumeService

이력서 CRUD와 첨부파일 처리.

```dart
getUserResumes(userNo)          // 사용자별 이력서 목록 (본인 이력서만)
getAllResumes()                  // 전체 이력서 조회 (인재검색용)
getResumeDetail(resumeId)       // 이력서 상세 (Quill Delta 포함)
createResume(resumeData)        // 이력서 등록 → resumeId 반환
updateResume(resumeId, data)    // 이력서 수정
deleteResume(resumeId)          // 이력서 삭제
searchResumes(keyword)          // 키워드 검색
getResumesByJobType(jobType)    // 직종별 조회
```

테스트용 `setTestOverrides(dio, storage)`로 Mock Dio/Storage를 주입할 수 있습니다.

---

### ApplyService

지원 처리와 상태 추적.

```dart
applyToJob(jobNo, resumeNo)         // 공고 지원 (400: 중복 지원 방지)
cancelApplication(applyNo)          // 지원 취소
getMyApplications()                 // 내 지원 목록
getApplicationsByJob(jobNo)         // 공고별 지원자 목록 (기업용)
updateApplicationStatus(...)        // 지원 상태 변경 (기업용)
hasAppliedToJob(jobNo)              // 특정 공고 지원 여부 확인
```

---

### AdminNotifier (Riverpod StateNotifier)

관리자 기능 전체를 하나의 StateNotifier로 통합 관리합니다.

```dart
loadDashboard()                 // 통계 데이터 조회
loadUsers() / deleteUser()      // 회원 관리
loadJobs() / deleteJob()        // 채용공고 목록·삭제
approveJob(jobNo)               // 공고 승인 (PENDING → PUBLISHED)
rejectJob(jobNo)                // 공고 반려 (PENDING → DRAFT)
expireJob(jobNo)                // 공고 강제 마감 (PUBLISHED → EXPIRED)
loadApplicants()                // 전체 지원자 조회
loadInquiries() / answerInquiry() / deleteInquiry()  // 문의사항 관리
loadPayments()                  // 결제 내역 조회
downloadUsersExcel()            // 회원 목록 Excel 다운로드
downloadJobsExcel()             // 채용공고 Excel 다운로드
downloadApplicantsExcel(jobNo)  // 지원자 목록 Excel 다운로드
downloadInquiriesExcel()        // 문의사항 Excel 다운로드
downloadPaymentsExcel()         // 결제 내역 Excel 다운로드
```

---

### 기타 서비스 요약

| 서비스 | 주요 기능 |
|--------|-----------|
| **BoardService** | 게시판 CRUD, 카테고리 필터, 검색, 조회수 증가 |
| **NoticeService** | 공지사항 조회, 중요 공지 구분, 페이지네이션 |
| **InquiryService** | 문의 작성, 조회, 관리자 답변 등록 |
| **NotificationService** | 알림 목록, 읽지 않은 알림 수, 읽음 처리 |
| **ScrapService** | 공고 스크랩 추가/삭제/목록 |
| **FileUploadService** | 이미지·파일 선택, 업로드 (Dio FormData), Excel 다운로드 |
| **PasswordResetService** | 비밀번호 재설정 이메일 발송 |
| **EmailService** | 이메일 인증 코드 발송 |

<br>

---

## 상태 관리

Riverpod의 `StateProvider` / `StateNotifier` 패턴을 사용합니다.

### 핵심 Provider

```dart
// 관리자 여부 (라우팅 권한 제어)
final isAdminProvider = StateProvider<bool>((ref) => false);

// 채용공고 상태
final jobProvider = StateNotifierProvider<JobNotifier, JobState>(...);
// JobState: jobs, filteredJobs, isLoading, error, currentPage, ...

// 프로필 수정
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(...);
// ProfileState: userProfile, isLoading, error, selectedImage

// 관리자 상태 (회원/공고/지원자/결제/문의 통합)
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>(...);

// 알림
final notificationProvider = ChangeNotifierProvider<NotificationProvider>(...);

// 이력서 폼 필드 (세분화된 StateProvider)
final resumeTitleProvider       = StateProvider<String>((ref) => '');
final resumeDescriptionProvider = StateProvider<String?>((ref) => null);
final resumeAddressProvider     = StateProvider<String>((ref) => '');
final resumeImageProvider       = StateProvider<File?>((ref) => null);
```

### 데이터 흐름

```
사용자 액션
    │
    ▼
ConsumerWidget (UI)
    │ ref.watch(provider)
    ▼
StateNotifier / StateProvider
    │ calls
    ▼
Service (비즈니스 로직)
    │ HTTP request
    ▼
REST API
```

<br>

---

## 디자인 시스템

`AppTheme` 클래스에 모든 디자인 토큰을 정의합니다.

### 색상 팔레트

| 팔레트 | 토큰 | 값 | 용도 |
|--------|------|----|------|
| **Sapphire** | `sapphire500` | `#0B5FFF` | 브랜드 프라이머리 |
| | `sapphire300` | `#5A99FF` | 호버, 포커스 링 |
| | `sapphire50` | `#E8F0FF` | 배경 강조 |
| **Obsidian** | `ink900` | `#0B1220` | 헤드라인 |
| | `ink700` | `#1C1C1E` | 본문 |
| | `ink300` | `#8E8E93` | 보조 텍스트 |
| | `ink50` | `#F2F2F7` | 페이지 배경 |
| **Champagne** | `champagne500` | `#C8A96A` | 프리미엄 강조 |
| **Semantic** | `success` | `#0FA958` | 성공 |
| | `warning` | `#E89500` | 경고 |
| | `danger` | `#E5342F` | 오류 |

### 타이포그래피

Pretendard 폰트 기반 7단계 역할 스케일:

| 역할 | TextTheme 키 | 크기 | 굵기 | 용도 |
|------|-------------|------|------|------|
| Display | `displayLarge` | 32 | 700 | 히어로 헤딩 |
| H1 | `headlineLarge` | 24 | 700 | 섹션 헤더 |
| H2 | `headlineMedium` | 20 | 700 | 서브 섹션 |
| Title | `titleLarge` | 17 | 600 | 카드 제목, 앱바 |
| Body | `bodyMedium` | 15 | 400 | 본문 |
| Caption | `bodySmall` | 13 | 400 | 보조 설명 |
| Micro | `labelSmall` | 11 | 600 | 배지, 태그 |

### 그림자 시스템

```dart
AppTheme.shadowXs    // blur: 4,  y: 1  — 미세 구분선
AppTheme.shadowSm    // blur: 8,  y: 2  — 카드
AppTheme.shadowMd    // blur: 16, y: 4  — 모달
AppTheme.shadowLg    // blur: 24, y: 8  — 드롭다운
AppTheme.shadowBrand // blur: 28, y: 10 — CTA 버튼 (브랜드 색상)
```

### Border Radius

```dart
radiusSm  = 8    // 입력 필드, 칩
radiusMd  = 12   // 카드, 버튼
radiusLg  = 16   // 큰 카드
radiusXl  = 20   // 시트
radius2xl = 28   // 다이얼로그
radiusFull = 999 // 원형 버튼, 아바타
```

### 공통 AppBar

```dart
buildCommonAppBar(
  title: '페이지 제목',
  showBackButton: true,   // arrow_back_ios_rounded, 사파이어 컬러
  showHomeButton: true,   // 홈 버튼 (우측 상단)
  onBack: () => ...,      // 커스텀 뒤로가기 동작 (옵션)
  actions: [...],
)
```

<br>

---

## API 연동

환경별 API 엔드포인트는 `flutter_dotenv`를 사용해 `.env` 파일로 분리 관리합니다.

### API 설정값

| 항목 | 값 |
|------|----|
| 연결 타임아웃 | 30초 |
| 응답 타임아웃 | 30초 |
| 재시도 횟수 | 3회 |
| 페이지 기본 크기 | 20개 |
| 최대 페이지 크기 | 100개 |
| 파일 최대 크기 | 20 MB |
| 지원 이미지 형식 | jpg, jpeg, png, gif, webp |
| 지원 문서 형식 | pdf, doc, docx, hwp |

### 인증 헤더

```dart
// 모든 인증 요청에 자동 적용
ApiConfig.getAuthHeaders(token)
// → {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', ...}

// 파일 업로드
ApiConfig.getMultipartAuthHeaders(token)
// → {'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data', ...}
```

### 페이지네이션 응답 구조

```json
{
  "content": [...],
  "totalElements": 100,
  "totalPages": 5,
  "number": 0,
  "last": false
}
```

<br>

---

## 테스트

### 테스트 구조

```
test/
├── auth_service_test.dart       # 인증 서비스 단위 테스트
├── job_service_test.dart        # 채용공고 서비스 단위 테스트
├── board_service_test.dart      # 게시판 서비스 단위 테스트
├── resume_service_test.dart     # 이력서 서비스 단위 테스트
├── notice_service_test.dart     # 공지사항 서비스 단위 테스트
├── apply_service_test.dart      # 지원 서비스 단위 테스트
├── widget_tests/
│   ├── login_page_test.dart
│   └── job_list_page_test.dart
├── integration_test/
│   └── app_integration_test.dart
├── performance/
│   └── performance_test.dart
├── fixtures/
│   └── test_data.json           # 공용 모킹 데이터
├── mocks/
│   └── mocks.mocks.dart         # Mockito 자동 생성 Mock 클래스
├── test_setup.dart
├── test_config.dart
└── test_utils.dart
```

### 테스트 실행

```bash
# 전체 단위 테스트
flutter test

# 위젯 테스트
flutter test test/widget_tests/

# 통합 테스트
flutter test integration_test/

# 성능 테스트
flutter test test/performance/

# 커버리지 리포트 생성
flutter test --coverage
```

### 테스트 전략

- **단위 테스트:** `mockito` + `http_mock_adapter`로 Dio HTTP 요청 모킹
- **위젯 테스트:** `flutter_test`로 UI 렌더링 및 사용자 인터랙션 검증
- **통합 테스트:** `integration_test` 패키지로 실제 앱 플로우 검증
- **골든 테스트:** `golden_toolkit`으로 UI 스냅샷 회귀 방지
- **테스트 훅:** `ResumeService.setTestOverrides()`, `BoardService.setTestOverrides()`로 Mock DI 지원

<br>

---

## 빌드 및 배포

### 개발 환경 설정

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Mockito Mock 클래스)
dart run build_runner build --delete-conflicting-outputs

# 개발 서버 실행
flutter run
```

### 빌드 명령

```bash
# 웹 프로덕션 빌드
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# 코드 품질 검사
flutter analyze
dart format .
```

### Android 권한

```xml
<!-- 미디어 접근 (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<!-- 저장소 접근 (Android ≤ 12) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<!-- 네트워크 -->
<uses-permission android:name="android.permission.INTERNET" />
```

### CI/CD

GitHub Actions 워크플로우(`.github/workflows/`)로 PR 시 자동 빌드 및 테스트가 실행됩니다.

<br>

---

## 실행 방법

```bash
git clone <repository-url>
cd peoplejob_frontend

# 의존성 설치
flutter pub get

# 실행
flutter run
```

> **참고:** Firebase 설정(`google-services.json`)은 저장소에 포함되지 않습니다. 별도 설정이 필요합니다.

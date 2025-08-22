import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:peoplejob_frontend/services/auth_service.dart';
import 'package:peoplejob_frontend/services/job_service.dart';
import 'package:peoplejob_frontend/services/resume_service.dart';
import 'package:peoplejob_frontend/services/board_service.dart';
import 'package:peoplejob_frontend/services/apply_service.dart';
import 'package:peoplejob_frontend/services/notice_service.dart';

@GenerateMocks([
  // HTTP 클라이언트
  http.Client,
  Dio,

  // Firebase
  FirebaseAuth,
  FirebaseFirestore,
  User,

  // 로컬 저장소
  SharedPreferences,

  // 서비스들
  AuthService,
  JobService,
  ResumeService,
  BoardService,
  ApplyService,
  NoticeService,
])
void main() {}

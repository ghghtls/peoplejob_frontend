import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // JWT 기반 백엔드 설정
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Firebase 설정
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ 이메일 로그인 (백엔드 API + JWT)
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _dio.post(
        '/api/member/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final role = response.data['role'];
      final userEmail = response.data['email'];

      await _storage.write(key: 'jwt', value: token);
      await _storage.write(key: 'role', value: role);
      await _storage.write(key: 'email', value: userEmail);

      if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/mypage');
      } else if (role == 'company') {
        Navigator.pushReplacementNamed(context, '/companymypage');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }

      return true;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      print('로그인 실패: ${errorData ?? e.message}');
      _showSnackbar(context, '로그인 실패: 아이디 또는 비밀번호를 확인해주세요.');
      return false;
    } catch (e) {
      print('예외 발생: $e');
      _showSnackbar(context, '알 수 없는 오류가 발생했습니다.');
      return false;
    }
  }

  /// ✅ 구글 로그인 (Firebase + Firestore 존재 여부 확인)
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 사용자 취소

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Navigator.pushReplacementNamed(context, '/mypage');
      } else {
        Navigator.pushReplacementNamed(context, '/register');
      }
    } catch (e) {
      print('구글 로그인 오류: $e');
      _showSnackbar(context, '구글 로그인에 실패했습니다. 다시 시도해주세요.');
    }
  }

  /// ✅ 로그아웃 (토큰/이메일 초기화 + Firebase 로그아웃)
  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'email');

    await _auth.signOut(); // Firebase 로그아웃

    Navigator.pushReplacementNamed(context, '/login');
  }

  /// ✅ JWT 토큰 반환
  Future<String?> getToken() async => await _storage.read(key: 'jwt');

  /// ✅ 사용자 역할 반환
  Future<String?> getRole() async => await _storage.read(key: 'role');

  /// ✅ 공통 스낵바 알림
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

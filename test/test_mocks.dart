import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([Dio, FlutterSecureStorage, http.Client])
void main() {}

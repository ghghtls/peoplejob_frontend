import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../model/job.dart';

//  Dio Provider
final dioProvider = Provider<Dio>((ref) {
  final base = dotenv.env['API_BASE_URL']?.replaceAll(RegExp(r'\/$'), '') ?? '';
  return Dio(BaseOptions(baseUrl: base));
});

//  채용공고 리스트 Provider
final jobListProvider = FutureProvider<List<Job>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/jobopening');

  // 예시: 백엔드가 [{id:1,title:공고명}, ...] 이런 형태로 내려온다고 가정
  final List<dynamic> data = response.data;
  return data.map((json) => Job.fromJson(json)).toList();
});

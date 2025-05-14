import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTypeProvider = StateProvider<String>(
  (ref) => 'user',
); // 'user', 'company', 'admin'

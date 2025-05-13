import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final resumeTitleProvider = StateProvider<String>((ref) => '');
final resumeDescriptionProvider = StateProvider<String>((ref) => '');
final resumeAddressProvider = StateProvider<String>((ref) => '');
final resumeImageProvider = StateProvider<File?>((ref) => null);
final resumeFileProvider = StateProvider<File?>((ref) => null);

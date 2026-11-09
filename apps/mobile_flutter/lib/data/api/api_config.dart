import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  /// Override at build time:
  /// flutter run --dart-define=SUPPERCOOK_API_URL=http://192.168.1.20:3000
  static String get baseUrl {
    const defined = String.fromEnvironment('SUPPERCOOK_API_URL');
    if (defined.isNotEmpty) return defined;

    if (!kIsWeb && Platform.isAndroid) {
      // Android emulator loopback to the development machine.
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}

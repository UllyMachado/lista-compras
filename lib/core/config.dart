import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8090';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090';
    }
    return 'http://localhost:8090';
  }
}

import '../config/api_config.dart';

class ApiConstants {
  // Use secure API configuration
  static String get geminiApiKey => ApiConfig.getValidatedApiKey();
  static String get geminiBaseUrl => ApiConfig.geminiBaseUrl;
  static String get geminiModel => ApiConfig.geminiModel;
  static String get generateContentEndpoint =>
      ApiConfig.generateContentEndpoint;
  static Map<String, String> get headers => ApiConfig.headers;
}

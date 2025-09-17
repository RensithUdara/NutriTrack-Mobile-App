import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/error_types.dart';

class ApiConfig {
  static String? _cachedApiKey;
  static bool _initialized = false;
  static AppError? _lastError;

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      _initialized = true;
      _lastError = null;

      if (kDebugMode) {
        print('ApiConfig: Successfully loaded .env file');
      }
    } catch (e) {
      _lastError = AppError(
        type: ErrorType.apiKeyMissing,
        message: 'Failed to load .env file',
        details: e.toString(),
        recoverySuggestion: 'Create a .env file with your GEMINI_API_KEY',
      );

      if (kDebugMode) {
        print('ApiConfig Warning: Could not load .env file: $e');
        print('Make sure to create a .env file with your GEMINI_API_KEY');
      }
    }
  }

  static String get geminiApiKey {
    // Return cached key if available
    if (_cachedApiKey != null) {
      return _cachedApiKey!;
    }

    // Try to get from .env file first
    if (_initialized) {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && _isValidApiKey(envKey)) {
        _cachedApiKey = envKey;
        _lastError = null;
        return envKey;
      }
    }

    // Try to get from build-time environment variable
    const String buildTimeKey = String.fromEnvironment('GEMINI_API_KEY');
    if (buildTimeKey.isNotEmpty && _isValidApiKey(buildTimeKey)) {
      _cachedApiKey = buildTimeKey;
      _lastError = null;
      return buildTimeKey;
    }

    // If no valid key found, throw a detailed error
    final errorMessage = _buildErrorMessage();
    _lastError = AppError(
      type: ErrorType.apiKeyMissing,
      message: 'GEMINI_API_KEY not found or invalid',
      details: errorMessage,
      recoverySuggestion:
          'Get your API key from: https://makersuite.google.com/app/apikey',
    );

    throw Exception(errorMessage);
  }

  static String _buildErrorMessage() {
    final messages = <String>[];

    if (!_initialized) {
      messages.add('Failed to load .env file');
    }

    if (_initialized) {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey == null || envKey.isEmpty) {
        messages.add('GEMINI_API_KEY not found in .env file');
      } else if (!_isValidApiKey(envKey)) {
        messages.add('GEMINI_API_KEY in .env file is invalid format');
      }
    }

    const buildTimeKey = String.fromEnvironment('GEMINI_API_KEY');
    if (buildTimeKey.isEmpty) {
      messages.add('GEMINI_API_KEY not set as build-time environment variable');
    } else if (!_isValidApiKey(buildTimeKey)) {
      messages.add('GEMINI_API_KEY from build-time variable is invalid format');
    }

    messages.addAll([
      '',
      'Please:',
      '1. Create a .env file in the project root',
      '2. Add GEMINI_API_KEY=your_actual_api_key',
      '3. Or set it as a build-time environment variable',
      '4. Get your API key from: https://makersuite.google.com/app/apikey',
      '',
      'Example .env file:',
      'GEMINI_API_KEY=YOUR_API_KEY_HERE',
    ]);

    return messages.join('\n');
  }

  static bool _isValidApiKey(String key) {
    // Basic validation for Gemini API key format
    return key.isNotEmpty &&
        key.length >= 35 &&
        key.length <= 45 &&
        key.startsWith('AIza');
  }

  static AppError? get lastError => _lastError;

  static bool get isConfigured => _cachedApiKey != null;

  static void clearCache() {
    _cachedApiKey = null;
    _lastError = null;
  }

  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.0-flash-exp';

  // API Endpoints
  static String get generateContentEndpoint =>
      '/models/$geminiModel:generateContent';

  // Request Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  // Validate API key format (legacy method for backward compatibility)
  static bool isValidApiKey(String key) {
    return _isValidApiKey(key);
  }

  // Get API key with validation
  static String getValidatedApiKey() {
    final key = geminiApiKey;
    if (!_isValidApiKey(key)) {
      throw Exception(
          'Invalid API key format. Please check your GEMINI_API_KEY environment variable.');
    }
    return key;
  }
}

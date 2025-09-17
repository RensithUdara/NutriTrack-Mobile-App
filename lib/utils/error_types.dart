enum ErrorType {
  // API Errors
  apiKeyInvalid,
  apiKeyMissing,
  apiRateLimitExceeded,
  apiServerError,
  apiNetworkError,
  apiTimeout,
  apiQuotaExceeded,
  apiPermissionDenied,

  // Network Errors
  networkUnavailable,
  networkTimeout,
  networkConnectionLost,

  // Database Errors
  databaseConnectionFailed,
  databaseOperationFailed,
  databaseCorrupted,
  databaseInsufficientSpace,

  // Image Processing Errors
  imageProcessingFailed,
  imageFormatUnsupported,
  imageSizeExceeded,
  imageCorrupted,
  cameraPermissionDenied,
  cameraNotAvailable,
  galleryPermissionDenied,

  // File System Errors
  fileNotFound,
  fileAccessDenied,
  fileCorrupted,
  insufficientStorage,

  // Validation Errors
  invalidInput,
  missingRequiredField,
  dataValidationFailed,

  // System Errors
  memoryInsufficient,
  systemOverloaded,
  unknownError,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final String? recoverySuggestion;
  final bool isRetryable;
  final int? retryAfterSeconds;

  const AppError({
    required this.type,
    required this.message,
    this.details,
    this.recoverySuggestion,
    this.isRetryable = false,
    this.retryAfterSeconds,
  });

  factory AppError.fromException(Exception exception, {String? context}) {
    final message = exception.toString();

    // API Key Errors
    if (message.contains('API key not valid') ||
        message.contains('INVALID_ARGUMENT')) {
      return const AppError(
        type: ErrorType.apiKeyInvalid,
        message: 'Invalid API key. Please check your configuration.',
        recoverySuggestion:
            'Verify your API key in the .env file or environment variables.',
        isRetryable: false,
      );
    }

    if (message.contains('GEMINI_API_KEY not found')) {
      return const AppError(
        type: ErrorType.apiKeyMissing,
        message: 'API key not found. Please configure your API key.',
        recoverySuggestion:
            'Create a .env file with your GEMINI_API_KEY or set it as an environment variable.',
        isRetryable: false,
      );
    }

    // Network Errors
    if (message.contains('SocketException') ||
        message.contains('Network is unreachable')) {
      return const AppError(
        type: ErrorType.networkUnavailable,
        message: 'No internet connection available.',
        recoverySuggestion: 'Check your internet connection and try again.',
        isRetryable: true,
        retryAfterSeconds: 5,
      );
    }

    if (message.contains('TimeoutException') || message.contains('timeout')) {
      return const AppError(
        type: ErrorType.networkTimeout,
        message: 'Request timed out. The server is taking too long to respond.',
        recoverySuggestion: 'Check your internet connection and try again.',
        isRetryable: true,
        retryAfterSeconds: 10,
      );
    }

    // HTTP Status Code Errors
    if (message.contains('400')) {
      return const AppError(
        type: ErrorType.apiKeyInvalid,
        message: 'Bad request. Please check your API key and request format.',
        recoverySuggestion:
            'Verify your API key and ensure the request is properly formatted.',
        isRetryable: false,
      );
    }

    if (message.contains('401')) {
      return const AppError(
        type: ErrorType.apiKeyInvalid,
        message: 'Unauthorized. Invalid API key.',
        recoverySuggestion: 'Check your API key configuration.',
        isRetryable: false,
      );
    }

    if (message.contains('403')) {
      return const AppError(
        type: ErrorType.apiPermissionDenied,
        message: 'Access forbidden. Check your API permissions.',
        recoverySuggestion:
            'Verify your API key has the necessary permissions.',
        isRetryable: false,
      );
    }

    if (message.contains('429')) {
      return const AppError(
        type: ErrorType.apiRateLimitExceeded,
        message: 'Rate limit exceeded. Too many requests.',
        recoverySuggestion: 'Wait a moment before trying again.',
        isRetryable: true,
        retryAfterSeconds: 60,
      );
    }

    if (message.contains('500') ||
        message.contains('502') ||
        message.contains('503')) {
      return const AppError(
        type: ErrorType.apiServerError,
        message: 'Server error. The API is temporarily unavailable.',
        recoverySuggestion: 'Try again in a few moments.',
        isRetryable: true,
        retryAfterSeconds: 30,
      );
    }

    // Database Errors
    if (message.contains('database') || message.contains('SQLite')) {
      return AppError(
        type: ErrorType.databaseOperationFailed,
        message: 'Database operation failed.',
        details: message,
        recoverySuggestion:
            'Try restarting the app. If the problem persists, contact support.',
        isRetryable: true,
      );
    }

    // Image Processing Errors
    if (message.contains('image') ||
        message.contains('camera') ||
        message.contains('gallery')) {
      return AppError(
        type: ErrorType.imageProcessingFailed,
        message: 'Image processing failed.',
        details: message,
        recoverySuggestion:
            'Try selecting a different image or check camera permissions.',
        isRetryable: true,
      );
    }

    // Default unknown error
    return AppError(
      type: ErrorType.unknownError,
      message: 'An unexpected error occurred.',
      details: message,
      recoverySuggestion:
          'Please try again. If the problem persists, contact support.',
      isRetryable: true,
    );
  }

  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.apiKeyInvalid:
        return 'Invalid API key. Please check your configuration.';
      case ErrorType.apiKeyMissing:
        return 'API key not configured. Please set up your API key.';
      case ErrorType.apiRateLimitExceeded:
        return 'Too many requests. Please wait a moment.';
      case ErrorType.apiServerError:
        return 'Service temporarily unavailable. Please try again later.';
      case ErrorType.apiNetworkError:
        return 'Network error. Please check your connection.';
      case ErrorType.apiTimeout:
        return 'Request timed out. Please try again.';
      case ErrorType.apiQuotaExceeded:
        return 'API quota exceeded. Please check your usage limits.';
      case ErrorType.apiPermissionDenied:
        return 'Access denied. Please check your API permissions.';
      case ErrorType.networkUnavailable:
        return 'No internet connection. Please check your network.';
      case ErrorType.networkTimeout:
        return 'Connection timed out. Please try again.';
      case ErrorType.networkConnectionLost:
        return 'Connection lost. Please check your internet.';
      case ErrorType.databaseConnectionFailed:
        return 'Database connection failed. Please restart the app.';
      case ErrorType.databaseOperationFailed:
        return 'Database operation failed. Please try again.';
      case ErrorType.databaseCorrupted:
        return 'Database corrupted. Please reinstall the app.';
      case ErrorType.databaseInsufficientSpace:
        return 'Insufficient storage space. Please free up space.';
      case ErrorType.imageProcessingFailed:
        return 'Image processing failed. Please try a different image.';
      case ErrorType.imageFormatUnsupported:
        return 'Unsupported image format. Please use JPEG or PNG.';
      case ErrorType.imageSizeExceeded:
        return 'Image too large. Please use a smaller image.';
      case ErrorType.imageCorrupted:
        return 'Image file is corrupted. Please try a different image.';
      case ErrorType.cameraPermissionDenied:
        return 'Camera permission denied. Please enable camera access.';
      case ErrorType.cameraNotAvailable:
        return 'Camera not available on this device.';
      case ErrorType.galleryPermissionDenied:
        return 'Gallery permission denied. Please enable photo access.';
      case ErrorType.fileNotFound:
        return 'File not found. Please try again.';
      case ErrorType.fileAccessDenied:
        return 'File access denied. Please check permissions.';
      case ErrorType.fileCorrupted:
        return 'File is corrupted. Please try again.';
      case ErrorType.insufficientStorage:
        return 'Insufficient storage space. Please free up space.';
      case ErrorType.invalidInput:
        return 'Invalid input. Please check your data.';
      case ErrorType.missingRequiredField:
        return 'Required field missing. Please fill in all required fields.';
      case ErrorType.dataValidationFailed:
        return 'Data validation failed. Please check your input.';
      case ErrorType.memoryInsufficient:
        return 'Insufficient memory. Please close other apps and try again.';
      case ErrorType.systemOverloaded:
        return 'System overloaded. Please try again later.';
      case ErrorType.unknownError:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details, isRetryable: $isRetryable)';
  }
}

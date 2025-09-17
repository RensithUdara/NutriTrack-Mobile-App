import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'error_types.dart';

class ErrorHandler {
  static final Map<ErrorType, int> _retryCounts = {};
  static const int maxRetries = 3;
  static const Duration baseRetryDelay = Duration(seconds: 2);

  /// Handle an exception and return a user-friendly AppError
  static AppError handleException(Exception exception, {String? context}) {
    final error = AppError.fromException(exception, context: context);

    if (kDebugMode) {
      print('ErrorHandler: ${error.type} - ${error.message}');
      if (error.details != null) {
        print('ErrorHandler Details: ${error.details}');
      }
    }

    return error;
  }

  /// Check if an error is retryable and handle retry logic
  static bool shouldRetry(AppError error) {
    if (!error.isRetryable) return false;

    final retryCount = _retryCounts[error.type] ?? 0;
    return retryCount < maxRetries;
  }

  /// Get retry delay with exponential backoff
  static Duration getRetryDelay(AppError error) {
    final retryCount = _retryCounts[error.type] ?? 0;
    final delay = baseRetryDelay * (retryCount + 1);

    if (error.retryAfterSeconds != null) {
      return Duration(seconds: error.retryAfterSeconds!);
    }

    return delay;
  }

  /// Increment retry count for an error type
  static void incrementRetryCount(ErrorType type) {
    _retryCounts[type] = (_retryCounts[type] ?? 0) + 1;
  }

  /// Reset retry count for an error type
  static void resetRetryCount(ErrorType type) {
    _retryCounts.remove(type);
  }

  /// Reset all retry counts
  static void resetAllRetryCounts() {
    _retryCounts.clear();
  }

  /// Check network connectivity
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Show error dialog with retry option
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ErrorDialog(
        error: error,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userFriendlyMessage),
        backgroundColor: getErrorColor(error.type),
        action: (error.isRetryable && onRetry != null)
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: Duration(seconds: error.isRetryable ? 5 : 3),
      ),
    );
  }

  /// Get error color based on error type
  static Color getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.apiKeyInvalid:
      case ErrorType.apiKeyMissing:
      case ErrorType.apiPermissionDenied:
        return Colors.red;
      case ErrorType.apiRateLimitExceeded:
      case ErrorType.apiQuotaExceeded:
        return Colors.orange;
      case ErrorType.networkUnavailable:
      case ErrorType.networkTimeout:
      case ErrorType.networkConnectionLost:
        return Colors.blue;
      case ErrorType.databaseConnectionFailed:
      case ErrorType.databaseOperationFailed:
      case ErrorType.databaseCorrupted:
        return Colors.purple;
      case ErrorType.imageProcessingFailed:
      case ErrorType.cameraPermissionDenied:
      case ErrorType.galleryPermissionDenied:
        return Colors.teal;
      case ErrorType.insufficientStorage:
      case ErrorType.memoryInsufficient:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  /// Log error for debugging
  static void logError(AppError error,
      {String? context, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('=== ERROR LOG ===');
      print('Context: ${context ?? 'Unknown'}');
      print('Type: ${error.type}');
      print('Message: ${error.message}');
      if (error.details != null) {
        print('Details: ${error.details}');
      }
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
      print('=================');
    }
  }
}

class _ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const _ErrorDialog({
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _getErrorIcon(error.type),
            color: ErrorHandler.getErrorColor(error.type),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getErrorTitle(error.type),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.userFriendlyMessage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (error.recoverySuggestion != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error.recoverySuggestion!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss!();
            },
            child: const Text('Dismiss'),
          ),
        if (error.isRetryable && onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ErrorHandler.getErrorColor(error.type),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
      ],
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.apiKeyInvalid:
      case ErrorType.apiKeyMissing:
        return Icons.key_off;
      case ErrorType.apiRateLimitExceeded:
        return Icons.speed;
      case ErrorType.networkUnavailable:
      case ErrorType.networkTimeout:
        return Icons.wifi_off;
      case ErrorType.databaseConnectionFailed:
        return Icons.storage;
      case ErrorType.imageProcessingFailed:
        return Icons.image_not_supported;
      case ErrorType.cameraPermissionDenied:
        return Icons.camera_alt_outlined;
      case ErrorType.insufficientStorage:
        return Icons.storage_outlined;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.apiKeyInvalid:
      case ErrorType.apiKeyMissing:
        return 'API Configuration Error';
      case ErrorType.apiRateLimitExceeded:
        return 'Rate Limit Exceeded';
      case ErrorType.networkUnavailable:
        return 'No Internet Connection';
      case ErrorType.databaseConnectionFailed:
        return 'Database Error';
      case ErrorType.imageProcessingFailed:
        return 'Image Processing Error';
      case ErrorType.cameraPermissionDenied:
        return 'Permission Denied';
      case ErrorType.insufficientStorage:
        return 'Storage Full';
      default:
        return 'Error';
    }
  }
}

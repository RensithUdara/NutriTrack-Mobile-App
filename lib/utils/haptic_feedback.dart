import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticFeedbackUtils {
  // Light haptic feedback for button taps
  static Future<void> lightImpact() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.lightImpact();
    }
  }

  // Medium haptic feedback for important actions
  static Future<void> mediumImpact() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.mediumImpact();
    }
  }

  // Heavy haptic feedback for critical actions
  static Future<void> heavyImpact() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.heavyImpact();
    }
  }

  // Selection haptic feedback for UI interactions
  static Future<void> selectionClick() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.selectionClick();
    }
  }

  // Success haptic feedback
  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Custom vibration pattern for success
      await Vibration.vibrate(duration: 100, amplitude: 128);
      await Future.delayed(const Duration(milliseconds: 50));
      await Vibration.vibrate(duration: 100, amplitude: 128);
    }
  }

  // Error haptic feedback
  static Future<void> error() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Custom vibration pattern for error
      await Vibration.vibrate(duration: 200, amplitude: 255);
    }
  }

  // Warning haptic feedback
  static Future<void> warning() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Custom vibration pattern for warning
      await Vibration.vibrate(duration: 150, amplitude: 200);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 150, amplitude: 200);
    }
  }

  // Camera capture haptic feedback
  static Future<void> cameraCapture() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Quick double tap for camera
      await Vibration.vibrate(duration: 50, amplitude: 100);
      await Future.delayed(const Duration(milliseconds: 30));
      await Vibration.vibrate(duration: 50, amplitude: 100);
    }
  }

  // Analysis complete haptic feedback
  static Future<void> analysisComplete() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Rising pattern for completion
      await Vibration.vibrate(duration: 100, amplitude: 64);
      await Future.delayed(const Duration(milliseconds: 50));
      await Vibration.vibrate(duration: 100, amplitude: 128);
      await Future.delayed(const Duration(milliseconds: 50));
      await Vibration.vibrate(duration: 100, amplitude: 192);
    }
  }

  // Delete confirmation haptic feedback
  static Future<void> deleteConfirmation() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Strong vibration for delete
      await Vibration.vibrate(duration: 300, amplitude: 255);
    }
  }

  // Theme toggle haptic feedback
  static Future<void> themeToggle() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Gentle vibration for theme change
      await Vibration.vibrate(duration: 80, amplitude: 100);
    }
  }

  // Navigation haptic feedback
  static Future<void> navigation() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Light vibration for navigation
      await Vibration.vibrate(duration: 50, amplitude: 80);
    }
  }
}

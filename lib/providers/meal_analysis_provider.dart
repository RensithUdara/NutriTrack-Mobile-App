import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/meal_analysis.dart';
import '../models/non_food_response.dart';
import '../services/enhanced_gemini_service.dart';
import '../services/database_service.dart';
import '../utils/error_types.dart';
import '../utils/error_handler.dart';

class MealAnalysisProvider with ChangeNotifier {
  final EnhancedGeminiService _enhancedGeminiService = EnhancedGeminiService();
  final DatabaseService _databaseService = DatabaseService();

  List<MealAnalysis> _mealAnalyses = [];
  bool _isLoading = false;
  AppError? _error;
  NonFoodResponse? _lastNonFoodResponse;
  int _retryCount = 0;

  List<MealAnalysis> get mealAnalyses => _mealAnalyses;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  String? get errorMessage => _error?.userFriendlyMessage;
  NonFoodResponse? get lastNonFoodResponse => _lastNonFoodResponse;
  int get retryCount => _retryCount;

  Future<void> loadMealAnalyses() async {
    _isLoading = true;
    _error = null;
    _retryCount = 0;
    notifyListeners();

    try {
      _mealAnalyses = await _databaseService.getAllMealAnalyses();
      _error = null;
    } catch (e) {
      _error = ErrorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: 'loadMealAnalyses',
      );
      ErrorHandler.logError(_error!, context: 'loadMealAnalyses');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeMealImage(File imageFile, BuildContext context) async {
    _isLoading = true;
    _error = null;
    _lastNonFoodResponse = null;
    _retryCount = 0;
    notifyListeners();

    await _performAnalysisWithRetry(imageFile, context);
  }

  Future<void> _performAnalysisWithRetry(
      File imageFile, BuildContext context) async {
    try {
      // First check if the image contains food
      final nonFoodResponse =
          await _enhancedGeminiService.checkIfFoodImage(imageFile);

      if (!nonFoodResponse.isFood) {
        // Image is not food - show dialog and don't save
        _isLoading = false;
        _lastNonFoodResponse = nonFoodResponse;
        notifyListeners();
        if (context.mounted) {
          _showNonFoodDialog(context, nonFoodResponse);
        }
        return;
      }

      // Image is food - proceed with analysis
      final analysis = await _enhancedGeminiService.analyzeMealImage(imageFile);
      await _databaseService.insertMealAnalysis(analysis);
      _mealAnalyses.insert(0, analysis);
      _lastNonFoodResponse = null;
      _error = null;
      _retryCount = 0;
    } catch (e) {
      final error = ErrorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: 'analyzeMealImage',
      );

      ErrorHandler.logError(error, context: 'analyzeMealImage');

      if (ErrorHandler.shouldRetry(error) && _retryCount < 3) {
        _retryCount++;
        _error = error;
        notifyListeners();

        // Wait before retrying
        await Future.delayed(ErrorHandler.getRetryDelay(error));

        // Retry the analysis if context is still mounted
        if (context.mounted) {
          await _performAnalysisWithRetry(imageFile, context);
        }
        return;
      }

      _error = error;
      _lastNonFoodResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showNonFoodDialog(BuildContext context, NonFoodResponse response) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildNonFoodDialog(context, response),
    );
  }

  Future<void> deleteMealAnalysis(int id) async {
    try {
      await _databaseService.deleteMealAnalysis(id);
      _mealAnalyses
          .removeWhere((meal) => meal.analyzedAt.millisecondsSinceEpoch == id);
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: 'deleteMealAnalysis',
      );
      ErrorHandler.logError(_error!, context: 'deleteMealAnalysis');
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _retryCount = 0;
    notifyListeners();
  }

  void clearNonFoodResponse() {
    _lastNonFoodResponse = null;
    notifyListeners();
  }

  Future<void> retryLastOperation(
      File? imageFile, BuildContext? context) async {
    if (imageFile != null && context != null) {
      await analyzeMealImage(imageFile, context);
    } else {
      await loadMealAnalyses();
    }
  }

  void resetRetryCount() {
    _retryCount = 0;
    notifyListeners();
  }

  Widget _buildNonFoodDialog(BuildContext context, NonFoodResponse response) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withValues(alpha: 0.2),
                          Colors.amber.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Oops! That\'s not food',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Friendly message
            Text(
              response.friendlyComment,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Detected object
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'I detected: ${response.detectedObject}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Dismiss'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Trigger camera again
                      _showCameraBottomSheet(context);
                    },
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromSource(context, ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromSource(context, ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(
      BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null && context.mounted) {
      final file = File(pickedFile.path);
      await analyzeMealImage(file, context);
    }
  }
}

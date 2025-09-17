import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/meal_analysis_provider.dart';
import '../widgets/meal_analysis_card.dart';
import '../widgets/camera_bottom_sheet.dart';
import '../utils/responsive.dart';
import '../utils/haptic_feedback.dart';
import '../utils/error_handler.dart';
import '../utils/error_types.dart';

class MealAnalysisScreen extends StatefulWidget {
  const MealAnalysisScreen({super.key});

  @override
  State<MealAnalysisScreen> createState() => _MealAnalysisScreenState();
}

class _MealAnalysisScreenState extends State<MealAnalysisScreen> {
  int _currentMessageIndex = 0;
  late List<String> _analysisMessages;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnalysisMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealAnalysisProvider>().loadMealAnalyses();
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _initializeAnalysisMessages() {
    _analysisMessages = [
      "🔍 Taking a closer look at your photo...",
      "🍎 Identifying ingredients and portions...",
      "📊 Calculating nutritional values...",
      "✨ Almost done analyzing your meal...",
      "🎯 Preparing your nutrition insights...",
    ];
  }

  Future<void> _pickImage(ImageSource source) async {
    // Haptic feedback for camera action
    await HapticFeedbackUtils.cameraCapture();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null && mounted) {
      final file = File(pickedFile.path);

      // Start message rotation
      _startMessageRotation();

      await context
          .read<MealAnalysisProvider>()
          .analyzeMealImage(file, context);

      // Haptic feedback for successful analysis
      await HapticFeedbackUtils.analysisComplete();
    }
  }

  void _startMessageRotation() {
    _messageTimer?.cancel();
    _currentMessageIndex = 0;
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _analysisMessages.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Widget _buildAnalysisProgressBar(
      BuildContext context, MealAnalysisProvider provider) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Animated progress indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Animated message
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _analysisMessages[_currentMessageIndex],
                  key: ValueKey(_currentMessageIndex),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
            // Subtle pulse animation
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: (1.0 - value).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1.0 + (value * 0.5),
                      child: child,
                    ),
                  );
                },
                onEnd: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealAnalysisProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            bottom: provider.isLoading
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: _buildAnalysisProgressBar(context, provider),
                  )
                : const PreferredSize(
                    preferredSize: Size.fromHeight(0),
                    child: SizedBox.shrink(),
                  ),
          ),
          body: _buildBody(context, provider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCameraBottomSheet(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Analyze'),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MealAnalysisProvider provider) {
    if (provider.isLoading && provider.mealAnalyses.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.getResponsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: Responsive.getResponsiveFontSize(context, 64,
                      tabletFontSize: 72, desktopFontSize: 80),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ready to analyze your meal!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 24,
                          tabletFontSize: 28, desktopFontSize: 32),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Take a photo of your meal to get started with AI-powered nutrition analysis',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _showCameraBottomSheet(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Analyze Meal'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.error != null) {
      return _buildErrorScreen(context, provider);
    }

    // Non-food response is now handled in the provider and shown as dialog

    if (provider.mealAnalyses.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.getResponsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: Responsive.getResponsiveFontSize(context, 64,
                      tabletFontSize: 72, desktopFontSize: 80),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No meals analyzed yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 24,
                          tabletFontSize: 28, desktopFontSize: 32),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Take a photo of your meal to get started with AI-powered nutrition analysis',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _showCameraBottomSheet(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Analyze Meal'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMealAnalyses(),
      child: Responsive.getResponsiveLayout(
        context,
        mobileLayout: ListView.builder(
          padding: Responsive.getResponsivePadding(context),
          itemCount: provider.mealAnalyses.length,
          itemBuilder: (context, index) {
            final meal = provider.mealAnalyses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MealAnalysisCard(
                mealAnalysis: meal,
                onDelete: () => provider.deleteMealAnalysis(
                  meal.analyzedAt.millisecondsSinceEpoch,
                ),
              ),
            );
          },
        ),
        tabletLayout: GridView.builder(
          padding: Responsive.getResponsivePadding(context),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getResponsiveColumns(context,
                mobileColumns: 1, tabletColumns: 2, desktopColumns: 3),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: provider.mealAnalyses.length,
          itemBuilder: (context, index) {
            final meal = provider.mealAnalyses[index];
            return MealAnalysisCard(
              mealAnalysis: meal,
              onDelete: () => provider.deleteMealAnalysis(
                meal.analyzedAt.millisecondsSinceEpoch,
              ),
            );
          },
        ),
        desktopLayout: GridView.builder(
          padding: Responsive.getResponsivePadding(context),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getResponsiveColumns(context,
                mobileColumns: 1, tabletColumns: 2, desktopColumns: 3),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 0.75,
          ),
          itemCount: provider.mealAnalyses.length,
          itemBuilder: (context, index) {
            final meal = provider.mealAnalyses[index];
            return MealAnalysisCard(
              mealAnalysis: meal,
              onDelete: () => provider.deleteMealAnalysis(
                meal.analyzedAt.millisecondsSinceEpoch,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCameraBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CameraBottomSheet(
        onCameraPressed: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGalleryPressed: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  Widget _buildErrorScreen(
      BuildContext context, MealAnalysisProvider provider) {
    final error = provider.error!;

    return Center(
      child: Padding(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with animation
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
                          ErrorHandler.getErrorColor(error.type)
                              .withValues(alpha: 0.2),
                          ErrorHandler.getErrorColor(error.type)
                              .withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ErrorHandler.getErrorColor(error.type)
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getErrorIcon(error.type),
                      size: 40,
                      color: ErrorHandler.getErrorColor(error.type),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Error title
            Text(
              _getErrorTitle(error.type),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ErrorHandler.getErrorColor(error.type),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Error message
            Text(
              error.userFriendlyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),

            // Recovery suggestion
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

            // Retry count if applicable
            if (provider.retryCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Retry attempt ${provider.retryCount}/3',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (error.isRetryable) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.clearError();
                      provider.loadMealAnalyses();
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ErrorHandler.getErrorColor(error.type),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    provider.clearError();
                    _showCameraBottomSheet(context);
                  },
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text('Try Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

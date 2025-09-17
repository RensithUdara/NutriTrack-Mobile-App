import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../providers/meal_analysis_provider.dart';
import '../widgets/nutrition_chart.dart';
import '../widgets/comprehensive_history_widget.dart';
import '../widgets/grid_weekly_summary_widget.dart';
import '../widgets/meal_plan_analysis_dialog.dart';
import '../utils/responsive.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAllAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer2<AnalyticsProvider, MealAnalysisProvider>(
        builder: (context, analyticsProvider, mealProvider, child) {
          if (analyticsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (analyticsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    analyticsProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      analyticsProvider.clearError();
                      analyticsProvider.loadWeeklyNutrition();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (mealProvider.mealAnalyses.isEmpty) {
            return Center(
              child: Padding(
                padding: Responsive.getResponsivePadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        size: Responsive.getResponsiveFontSize(context, 64,
                            tabletFontSize: 72, desktopFontSize: 80),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No data available',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: Responsive.getResponsiveFontSize(
                                    context, 24,
                                    tabletFontSize: 28, desktopFontSize: 32),
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Analyze some meals to see your nutrition trends and insights',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => analyticsProvider.loadAllAnalyticsData(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grid Weekly Summary Section
                  GridWeeklySummaryWidget(
                    weeklyNutrition: analyticsProvider.weeklyNutrition,
                    totalMealPlans: analyticsProvider.weeklyMealPlansCount,
                    totalAnalyzedMeals:
                        analyticsProvider.weeklyAnalyzedMealsCount,
                  ),

                  const SizedBox(height: 32),

                  // Comprehensive History Section
                  ComprehensiveHistoryWidget(
                    mealPlans: analyticsProvider.mealPlanHistory,
                    mealAnalyses: mealProvider.mealAnalyses,
                    onMealPlanTap: (mealPlan) =>
                        _showMealPlanDetails(context, mealPlan),
                    onAnalyzeAdherence: (mealPlan) =>
                        _showMealPlanAnalysis(context, mealPlan),
                    onMealAnalysisTap: (mealAnalysis) =>
                        _showMealAnalysisDetails(context, mealAnalysis),
                  ),

                  const SizedBox(height: 32),

                  // Nutrition Chart
                  NutritionChart(
                    nutritionData: analyticsProvider.weeklyNutrition,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMealPlanDetails(BuildContext context, mealPlan) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final isToday = _isSameDay(mealPlan.date, DateTime.now());
    final isYesterday = _isSameDay(
        mealPlan.date, DateTime.now().subtract(const Duration(days: 1)));

    String dateText;
    if (isToday) {
      dateText = 'Today ${timeFormat.format(mealPlan.date)}';
    } else if (isYesterday) {
      dateText = 'Yesterday ${timeFormat.format(mealPlan.date)}';
    } else {
      dateText =
          '${dateFormat.format(mealPlan.date)} ${timeFormat.format(mealPlan.date)}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Meal Plan Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Date: $dateText',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Planned Meals:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...mealPlan.meals.map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meal.type.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meal.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${meal.nutritionalInfo.calories.toStringAsFixed(0)} kcal',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMealPlanAnalysis(BuildContext context, mealPlan) async {
    final analyticsProvider = context.read<AnalyticsProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final adherenceData =
          await analyticsProvider.getMealPlanAdherence(mealPlan);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show analysis dialog
      showDialog(
        context: context,
        builder: (context) => MealPlanAnalysisDialog(
          mealPlan: mealPlan,
          adherenceData: adherenceData,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load meal plan analysis: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildNutritionDetail(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  void _showMealAnalysisDetails(BuildContext context, mealAnalysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Meal Analysis Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Meal: ${mealAnalysis.mealName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Analyzed: ${mealAnalysis.analyzedAt.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              if (mealAnalysis.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  mealAnalysis.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Nutrition Information:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNutritionDetail(
                        context,
                        'Calories',
                        '${mealAnalysis.nutritionalInfo.calories.toStringAsFixed(0)} kcal',
                        Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNutritionDetail(
                        context,
                        'Protein',
                        '${mealAnalysis.nutritionalInfo.protein.toStringAsFixed(1)}g',
                        Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNutritionDetail(
                        context,
                        'Carbs',
                        '${mealAnalysis.nutritionalInfo.carbohydrates.toStringAsFixed(1)}g',
                        Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNutritionDetail(
                        context,
                        'Fat',
                        '${mealAnalysis.nutritionalInfo.fat.toStringAsFixed(1)}g',
                        Colors.purple),
                  ),
                ],
              ),
              if (mealAnalysis.ingredients.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Ingredients:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (mealAnalysis.ingredients as List<String>)
                      .map((ingredient) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ingredient,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

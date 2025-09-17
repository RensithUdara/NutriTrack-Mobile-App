import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../utils/responsive.dart';

class MealPlanAnalysisDialog extends StatelessWidget {
  final MealPlan mealPlan;
  final Map<String, dynamic> adherenceData;

  const MealPlanAnalysisDialog({
    super.key,
    required this.mealPlan,
    required this.adherenceData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: Responsive.isDesktop(context) ? 600 : double.infinity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: Responsive.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdherenceOverview(context),
                    const SizedBox(height: 24),
                    _buildNutritionComparison(context),
                    const SizedBox(height: 24),
                    _buildMealBreakdown(context),
                    const SizedBox(height: 24),
                    _buildInsights(context),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isToday = _isSameDay(mealPlan.date, DateTime.now());
    final isYesterday = _isSameDay(
        mealPlan.date, DateTime.now().subtract(const Duration(days: 1)));

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = dateFormat.format(mealPlan.date);
    }

    return Container(
      padding: Responsive.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: Theme.of(context).colorScheme.primary,
            size: Responsive.getResponsiveFontSize(context, 24,
                tabletFontSize: 28, desktopFontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Plan Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.getResponsiveFontSize(context, 18,
                            tabletFontSize: 20, desktopFontSize: 22),
                      ),
                ),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceOverview(BuildContext context) {
    final overallAdherence = adherenceData['overallAdherence'] ?? 0.0;
    final adherencePercentage = (overallAdherence * 100).round();

    Color adherenceColor;
    String adherenceText;
    if (overallAdherence >= 0.8) {
      adherenceColor = Colors.green;
      adherenceText = 'Excellent';
    } else if (overallAdherence >= 0.6) {
      adherenceColor = Colors.orange;
      adherenceText = 'Good';
    } else if (overallAdherence >= 0.4) {
      adherenceColor = Colors.amber;
      adherenceText = 'Fair';
    } else {
      adherenceColor = Colors.red;
      adherenceText = 'Needs Improvement';
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: Responsive.getResponsivePadding(context,
            mobilePadding: const EdgeInsets.all(16),
            tabletPadding: const EdgeInsets.all(20),
            desktopPadding: const EdgeInsets.all(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Adherence',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$adherencePercentage%',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: adherenceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        adherenceText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: adherenceColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: overallAdherence,
                    backgroundColor: adherenceColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(adherenceColor),
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionComparison(BuildContext context) {
    final actualNutrition =
        adherenceData['actualNutrition'] as Map<String, double>? ?? {};
    final plannedNutrition =
        adherenceData['plannedNutrition'] as Map<String, double>? ?? {};

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: Responsive.getResponsivePadding(context,
            mobilePadding: const EdgeInsets.all(16),
            tabletPadding: const EdgeInsets.all(20),
            desktopPadding: const EdgeInsets.all(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Comparison',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildNutritionComparisonItem(
              context,
              'Calories',
              actualNutrition['calories'] ?? 0.0,
              plannedNutrition['calories'] ?? 0.0,
              Icons.local_fire_department,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildNutritionComparisonItem(
              context,
              'Protein',
              actualNutrition['protein'] ?? 0.0,
              plannedNutrition['protein'] ?? 0.0,
              Icons.fitness_center,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildNutritionComparisonItem(
              context,
              'Carbohydrates',
              actualNutrition['carbohydrates'] ?? 0.0,
              plannedNutrition['carbohydrates'] ?? 0.0,
              Icons.grain,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildNutritionComparisonItem(
              context,
              'Fat',
              actualNutrition['fat'] ?? 0.0,
              plannedNutrition['fat'] ?? 0.0,
              Icons.opacity,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionComparisonItem(
    BuildContext context,
    String label,
    double actual,
    double planned,
    IconData icon,
    Color color,
  ) {
    final ratio = planned > 0 ? actual / planned : 0.0;
    final percentage = (ratio * 100).round();

    Color statusColor;
    IconData statusIcon;
    if (ratio >= 0.9 && ratio <= 1.1) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (ratio >= 0.7 && ratio <= 1.3) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${actual.toStringAsFixed(0)} / ${planned.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($percentage%)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(statusIcon, color: statusColor, size: 20),
      ],
    );
  }

  Widget _buildMealBreakdown(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: Responsive.getResponsivePadding(context,
            mobilePadding: const EdgeInsets.all(16),
            tabletPadding: const EdgeInsets.all(20),
            desktopPadding: const EdgeInsets.all(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planned Meals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...mealPlan.meals
                .map((meal) => _buildMealItem(context, meal))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(BuildContext context, PlannedMeal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _capitalizeFirst(meal.type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                '${meal.nutritionalInfo.calories.toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meal.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (meal.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meal.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsights(BuildContext context) {
    final insights = _generateInsights();

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: Responsive.getResponsivePadding(context,
            mobilePadding: const EdgeInsets.all(16),
            tabletPadding: const EdgeInsets.all(20),
            desktopPadding: const EdgeInsets.all(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights & Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights
                .map((insight) => _buildInsightItem(context, insight))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insight['type'] == 'positive'
            ? Colors.green.withOpacity(0.1)
            : insight['type'] == 'warning'
                ? Colors.orange.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight['type'] == 'positive'
              ? Colors.green.withOpacity(0.3)
              : insight['type'] == 'warning'
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            insight['type'] == 'positive'
                ? Icons.check_circle
                : insight['type'] == 'warning'
                    ? Icons.warning
                    : Icons.error,
            color: insight['type'] == 'positive'
                ? Colors.green
                : insight['type'] == 'warning'
                    ? Colors.orange
                    : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight['text'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: Responsive.getResponsivePadding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights() {
    final insights = <Map<String, dynamic>>[];
    final overallAdherence = adherenceData['overallAdherence'] ?? 0.0;
    final actualNutrition =
        adherenceData['actualNutrition'] as Map<String, double>? ?? {};
    final plannedNutrition =
        adherenceData['plannedNutrition'] as Map<String, double>? ?? {};

    // Overall adherence insight
    if (overallAdherence >= 0.8) {
      insights.add({
        'type': 'positive',
        'text':
            'Excellent adherence! You\'re following your meal plan very well with ${(overallAdherence * 100).round()}% accuracy.',
      });
    } else if (overallAdherence >= 0.6) {
      insights.add({
        'type': 'warning',
        'text':
            'Good progress! You\'re following ${(overallAdherence * 100).round()}% of your meal plan. Focus on consistency.',
      });
    } else if (overallAdherence >= 0.4) {
      insights.add({
        'type': 'warning',
        'text':
            'Moderate adherence at ${(overallAdherence * 100).round()}%. Consider simplifying your meal plan or setting reminders.',
      });
    } else {
      insights.add({
        'type': 'negative',
        'text':
            'Low adherence at ${(overallAdherence * 100).round()}%. Review your meal plan and make it more realistic for your lifestyle.',
      });
    }

    // Calorie insight
    final calorieRatio = plannedNutrition['calories']! > 0
        ? (actualNutrition['calories'] ?? 0) / plannedNutrition['calories']!
        : 0.0;

    if (calorieRatio < 0.5) {
      insights.add({
        'type': 'negative',
        'text':
            'You\'re consuming only ${(calorieRatio * 100).round()}% of planned calories. This may lead to energy deficiency.',
      });
    } else if (calorieRatio < 0.7) {
      insights.add({
        'type': 'warning',
        'text':
            'You\'re consuming ${(calorieRatio * 100).round()}% of planned calories. Consider adding healthy snacks or larger portions.',
      });
    } else if (calorieRatio > 1.5) {
      insights.add({
        'type': 'warning',
        'text':
            'You\'re consuming ${(calorieRatio * 100).round()}% of planned calories. Consider portion control or adjusting your plan.',
      });
    } else if (calorieRatio > 1.2) {
      insights.add({
        'type': 'warning',
        'text':
            'You\'re consuming ${(calorieRatio * 100).round()}% of planned calories. Monitor portion sizes.',
      });
    }

    // Protein insight
    final proteinRatio = plannedNutrition['protein']! > 0
        ? (actualNutrition['protein'] ?? 0) / plannedNutrition['protein']!
        : 0.0;

    if (proteinRatio < 0.5) {
      insights.add({
        'type': 'negative',
        'text':
            'Protein intake is very low at ${(proteinRatio * 100).round()}% of planned. Add lean meats, beans, or protein supplements.',
      });
    } else if (proteinRatio < 0.7) {
      insights.add({
        'type': 'warning',
        'text':
            'Protein intake is ${(proteinRatio * 100).round()}% of planned. Include more protein-rich foods in your meals.',
      });
    } else if (proteinRatio > 1.3) {
      insights.add({
        'type': 'warning',
        'text':
            'Protein intake is ${(proteinRatio * 100).round()}% of planned. Consider reducing protein portions.',
      });
    }

    // Carbohydrate insight
    final carbRatio = plannedNutrition['carbohydrates']! > 0
        ? (actualNutrition['carbohydrates'] ?? 0) /
            plannedNutrition['carbohydrates']!
        : 0.0;

    if (carbRatio < 0.5) {
      insights.add({
        'type': 'warning',
        'text':
            'Carbohydrate intake is low at ${(carbRatio * 100).round()}% of planned. Add whole grains, fruits, or vegetables.',
      });
    } else if (carbRatio > 1.5) {
      insights.add({
        'type': 'warning',
        'text':
            'Carbohydrate intake is high at ${(carbRatio * 100).round()}% of planned. Focus on complex carbs and reduce simple sugars.',
      });
    }

    // Fat insight
    final fatRatio = plannedNutrition['fat']! > 0
        ? (actualNutrition['fat'] ?? 0) / plannedNutrition['fat']!
        : 0.0;

    if (fatRatio < 0.5) {
      insights.add({
        'type': 'warning',
        'text':
            'Fat intake is low at ${(fatRatio * 100).round()}% of planned. Include healthy fats like nuts, avocado, or olive oil.',
      });
    } else if (fatRatio > 1.5) {
      insights.add({
        'type': 'warning',
        'text':
            'Fat intake is high at ${(fatRatio * 100).round()}% of planned. Choose healthier fat sources and monitor portions.',
      });
    }

    // Meal timing insight
    final now = DateTime.now();
    final mealPlanDate = mealPlan.date;
    final daysDifference = now.difference(mealPlanDate).inDays;

    if (daysDifference == 0) {
      insights.add({
        'type': 'positive',
        'text': 'This is today\'s meal plan. Great job planning ahead!',
      });
    } else if (daysDifference == 1) {
      insights.add({
        'type': 'positive',
        'text': 'This was yesterday\'s meal plan. How did it go?',
      });
    } else if (daysDifference > 7) {
      insights.add({
        'type': 'warning',
        'text':
            'This meal plan is from ${daysDifference} days ago. Consider creating more recent plans.',
      });
    }

    return insights;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

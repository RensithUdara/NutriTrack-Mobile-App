import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../models/meal_analysis.dart';
import '../utils/responsive.dart';

class ComprehensiveHistoryWidget extends StatelessWidget {
  final List<MealPlan> mealPlans;
  final List<MealAnalysis> mealAnalyses;
  final Function(MealPlan) onMealPlanTap;
  final Function(MealPlan) onAnalyzeAdherence;
  final Function(MealAnalysis) onMealAnalysisTap;

  const ComprehensiveHistoryWidget({
    super.key,
    required this.mealPlans,
    required this.mealAnalyses,
    required this.onMealPlanTap,
    required this.onAnalyzeAdherence,
    required this.onMealAnalysisTap,
  });

  @override
  Widget build(BuildContext context) {
    // Combine and sort all items by date
    final allItems = _combineAndSortItems();

    if (allItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.getResponsivePadding(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meal History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 20,
                          tabletFontSize: 24, desktopFontSize: 28),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${allItems.length} items',
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
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            if (item['type'] == 'mealPlan') {
              return _buildMealPlanCard(context, item['data'] as MealPlan);
            } else {
              return _buildMealAnalysisCard(
                  context, item['data'] as MealAnalysis);
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: Responsive.getResponsivePadding(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: Responsive.getResponsiveFontSize(context, 48,
                  tabletFontSize: 56, desktopFontSize: 64),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No meal history yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: Responsive.getResponsiveFontSize(context, 18,
                      tabletFontSize: 20, desktopFontSize: 22),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create meal plans or analyze meals to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanCard(BuildContext context, MealPlan mealPlan) {
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

    return Padding(
      padding: Responsive.getResponsivePadding(context).copyWith(
        left: Responsive.getResponsivePadding(context).left,
        right: Responsive.getResponsivePadding(context).right,
        top: 0,
        bottom: 12,
      ),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => onMealPlanTap(mealPlan),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
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
                          'MEAL PLAN',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${mealPlan.meals.length} meals planned',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionSummary(context, mealPlan.totalNutrition),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMealTypeChips(context, mealPlan),
                      ),
                      IconButton(
                        onPressed: () => onAnalyzeAdherence(mealPlan),
                        icon: Icon(
                          Icons.analytics_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Analyze adherence',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealAnalysisCard(
      BuildContext context, MealAnalysis mealAnalysis) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final isToday = _isSameDay(mealAnalysis.analyzedAt, DateTime.now());
    final isYesterday = _isSameDay(mealAnalysis.analyzedAt,
        DateTime.now().subtract(const Duration(days: 1)));

    String dateText;
    if (isToday) {
      dateText = 'Today ${timeFormat.format(mealAnalysis.analyzedAt)}';
    } else if (isYesterday) {
      dateText = 'Yesterday ${timeFormat.format(mealAnalysis.analyzedAt)}';
    } else {
      dateText =
          '${dateFormat.format(mealAnalysis.analyzedAt)} ${timeFormat.format(mealAnalysis.analyzedAt)}';
    }

    return Padding(
      padding: Responsive.getResponsivePadding(context).copyWith(
        left: Responsive.getResponsivePadding(context).left,
        right: Responsive.getResponsivePadding(context).right,
        top: 0,
        bottom: 12,
      ),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => onMealAnalysisTap(mealAnalysis),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ANALYZED',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mealAnalysis.mealName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (mealAnalysis.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      mealAnalysis.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildNutritionSummary(context, mealAnalysis.nutritionalInfo),
                  if (mealAnalysis.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildIngredientsChips(context, mealAnalysis.ingredients),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(
      BuildContext context, NutritionalInfo nutrition) {
    return Row(
      children: [
        Expanded(
          child: _buildNutritionItem(
            context,
            'Calories',
            nutrition.calories.toStringAsFixed(0),
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNutritionItem(
            context,
            'Protein',
            '${nutrition.protein.toStringAsFixed(1)}g',
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNutritionItem(
            context,
            'Carbs',
            '${nutrition.carbohydrates.toStringAsFixed(1)}g',
            Icons.grain,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNutritionItem(
            context,
            'Fat',
            '${nutrition.fat.toStringAsFixed(1)}g',
            Icons.opacity,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: Responsive.getResponsiveFontSize(context, 16,
              tabletFontSize: 18, desktopFontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: Responsive.getResponsiveFontSize(context, 10,
                    tabletFontSize: 11, desktopFontSize: 12),
              ),
        ),
      ],
    );
  }

  Widget _buildMealTypeChips(BuildContext context, MealPlan mealPlan) {
    final mealTypes = mealPlan.meals.map((meal) => meal.type).toSet().toList();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: mealTypes.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _capitalizeFirst(type),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsChips(
      BuildContext context, List<String> ingredients) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: ingredients.take(5).map((ingredient) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
    );
  }

  List<Map<String, dynamic>> _combineAndSortItems() {
    final List<Map<String, dynamic>> allItems = [];

    // Add meal plans
    for (final mealPlan in mealPlans) {
      allItems.add({
        'type': 'mealPlan',
        'data': mealPlan,
        'date': mealPlan.date,
      });
    }

    // Add meal analyses
    for (final mealAnalysis in mealAnalyses) {
      allItems.add({
        'type': 'mealAnalysis',
        'data': mealAnalysis,
        'date': mealAnalysis.analyzedAt,
      });
    }

    // Sort by date (newest first)
    allItems.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return allItems;
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

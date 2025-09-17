import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../utils/responsive.dart';

class MealPlanCard extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanCard({
    super.key,
    required this.mealPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(mealPlan.date),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${mealPlan.meals.length} meals',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Diet Type and Goals
            _buildDietInfo(context),
            const SizedBox(height: 16),

            // Total Nutrition Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Daily Nutrition',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Responsive.getResponsiveLayout(
                    context,
                    mobileLayout: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutritionSummary(
                              context,
                              'Calories',
                              '${mealPlan.totalNutrition.calories.toStringAsFixed(0)}',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                            _buildNutritionSummary(
                              context,
                              'Protein',
                              '${mealPlan.totalNutrition.protein.toStringAsFixed(1)}g',
                              Icons.fitness_center,
                              Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutritionSummary(
                              context,
                              'Carbs',
                              '${mealPlan.totalNutrition.carbohydrates.toStringAsFixed(1)}g',
                              Icons.grain,
                              Colors.green,
                            ),
                            _buildNutritionSummary(
                              context,
                              'Fat',
                              '${mealPlan.totalNutrition.fat.toStringAsFixed(1)}g',
                              Icons.opacity,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                    tabletLayout: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionSummary(
                          context,
                          'Calories',
                          '${mealPlan.totalNutrition.calories.toStringAsFixed(0)}',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        _buildNutritionSummary(
                          context,
                          'Protein',
                          '${mealPlan.totalNutrition.protein.toStringAsFixed(1)}g',
                          Icons.fitness_center,
                          Colors.blue,
                        ),
                        _buildNutritionSummary(
                          context,
                          'Carbs',
                          '${mealPlan.totalNutrition.carbohydrates.toStringAsFixed(1)}g',
                          Icons.grain,
                          Colors.green,
                        ),
                        _buildNutritionSummary(
                          context,
                          'Fat',
                          '${mealPlan.totalNutrition.fat.toStringAsFixed(1)}g',
                          Icons.opacity,
                          Colors.purple,
                        ),
                      ],
                    ),
                    desktopLayout: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionSummary(
                          context,
                          'Calories',
                          '${mealPlan.totalNutrition.calories.toStringAsFixed(0)}',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        _buildNutritionSummary(
                          context,
                          'Protein',
                          '${mealPlan.totalNutrition.protein.toStringAsFixed(1)}g',
                          Icons.fitness_center,
                          Colors.blue,
                        ),
                        _buildNutritionSummary(
                          context,
                          'Carbs',
                          '${mealPlan.totalNutrition.carbohydrates.toStringAsFixed(1)}g',
                          Icons.grain,
                          Colors.green,
                        ),
                        _buildNutritionSummary(
                          context,
                          'Fat',
                          '${mealPlan.totalNutrition.fat.toStringAsFixed(1)}g',
                          Icons.opacity,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meals List
            Text(
              'Meals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...mealPlan.meals.map((meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getMealTypeColor(meal.type)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                meal.type.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: _getMealTypeColor(meal.type),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                meal.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Text(
                              '${meal.nutritionalInfo.calories.toStringAsFixed(0)} cal',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        if (meal.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            meal.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildMiniNutrition(
                              context,
                              'P',
                              '${meal.nutritionalInfo.protein.toStringAsFixed(1)}g',
                              Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _buildMiniNutrition(
                              context,
                              'C',
                              '${meal.nutritionalInfo.carbohydrates.toStringAsFixed(1)}g',
                              Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _buildMiniNutrition(
                              context,
                              'F',
                              '${meal.nutritionalInfo.fat.toStringAsFixed(1)}g',
                              Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: Responsive.getResponsiveFontSize(context, 14,
                tabletFontSize: 16, desktopFontSize: 18),
          ),
          SizedBox(
              height: Responsive.getResponsiveHeight(context, 3,
                  tabletHeight: 4, desktopHeight: 4)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.getResponsiveFontSize(context, 10,
                      tabletFontSize: 11, desktopFontSize: 12),
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: Responsive.getResponsiveFontSize(context, 9,
                      tabletFontSize: 10, desktopFontSize: 11),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNutrition(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.getResponsiveWidth(context, 18,
              tabletWidth: 20, desktopWidth: 22),
          height: Responsive.getResponsiveWidth(context, 18,
              tabletWidth: 20, desktopWidth: 22),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.getResponsiveFontSize(context, 9,
                        tabletFontSize: 10, desktopFontSize: 11),
                  ),
            ),
          ),
        ),
        SizedBox(
            width: Responsive.getResponsiveWidth(context, 3,
                tabletWidth: 4, desktopWidth: 4)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: Responsive.getResponsiveFontSize(context, 9,
                    tabletFontSize: 10, desktopFontSize: 11),
              ),
        ),
      ],
    );
  }

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.purple;
      case 'snack':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDietInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Diet Type: ${mealPlan.preferences.dietType.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${mealPlan.preferences.dailyCalorieTarget.toInt()} cal • ${mealPlan.preferences.proteinGoal.toInt()}g protein • ${mealPlan.preferences.carbGoal.toInt()}g carbs • ${mealPlan.preferences.fatGoal.toInt()}g fat',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          if (mealPlan.preferences.dietaryRestrictions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Restrictions: ${mealPlan.preferences.dietaryRestrictions.join(', ')}',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (difference.inDays == 0) {
      return 'Today ${timeFormat.format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${timeFormat.format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago ${timeFormat.format(date)}';
    } else {
      return '${dateFormat.format(date)} ${timeFormat.format(date)}';
    }
  }
}

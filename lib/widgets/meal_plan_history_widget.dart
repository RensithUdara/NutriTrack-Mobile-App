import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../utils/responsive.dart';

class MealPlanHistoryWidget extends StatelessWidget {
  final List<MealPlan> mealPlans;
  final Function(MealPlan) onMealPlanTap;
  final Function(MealPlan) onAnalyzeAdherence;

  const MealPlanHistoryWidget({
    super.key,
    required this.mealPlans,
    required this.onMealPlanTap,
    required this.onAnalyzeAdherence,
  });

  @override
  Widget build(BuildContext context) {
    if (mealPlans.isEmpty) {
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
                'Meal Plan History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 20,
                          tabletFontSize: 24, desktopFontSize: 28),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${mealPlans.length} plans',
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
          itemCount: mealPlans.length,
          itemBuilder: (context, index) {
            final mealPlan = mealPlans[index];
            return _buildMealPlanCard(context, mealPlan);
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
              Icons.restaurant_menu_outlined,
              size: Responsive.getResponsiveFontSize(context, 48,
                  tabletFontSize: 56, desktopFontSize: 64),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No meal plans yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: Responsive.getResponsiveFontSize(context, 18,
                      tabletFontSize: 20, desktopFontSize: 22),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first meal plan to see it here',
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
          child: Padding(
            padding: Responsive.getResponsivePadding(context,
                mobilePadding: const EdgeInsets.all(16),
                tabletPadding: const EdgeInsets.all(20),
                desktopPadding: const EdgeInsets.all(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.getResponsiveFontSize(
                                        context, 16,
                                        tabletFontSize: 18,
                                        desktopFontSize: 20),
                                  ),
                        ),
                        Text(
                          '${mealPlan.meals.length} meals planned',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getAdherenceColor(mealPlan).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getAdherenceColor(mealPlan).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getAdherenceText(mealPlan),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getAdherenceColor(mealPlan),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNutritionSummary(context, mealPlan),
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
    );
  }

  Widget _buildNutritionSummary(BuildContext context, MealPlan mealPlan) {
    final nutrition = mealPlan.totalNutrition;

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

  Color _getAdherenceColor(MealPlan mealPlan) {
    // This is a placeholder - in a real implementation, you'd calculate actual adherence
    // For now, we'll use a simple heuristic based on meal count
    if (mealPlan.meals.length >= 3) {
      return Colors.green;
    } else if (mealPlan.meals.length >= 2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getAdherenceText(MealPlan mealPlan) {
    if (mealPlan.meals.length >= 3) {
      return 'Complete';
    } else if (mealPlan.meals.length >= 2) {
      return 'Partial';
    } else {
      return 'Incomplete';
    }
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

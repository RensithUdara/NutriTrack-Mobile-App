import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class GridWeeklySummaryWidget extends StatelessWidget {
  final Map<String, double> weeklyNutrition;
  final int totalMealPlans;
  final int totalAnalyzedMeals;

  const GridWeeklySummaryWidget({
    super.key,
    required this.weeklyNutrition,
    required this.totalMealPlans,
    required this.totalAnalyzedMeals,
  });

  @override
  Widget build(BuildContext context) {
    final avgCalories = weeklyNutrition['calories']! / 7;
    final avgProtein = weeklyNutrition['protein']! / 7;
    final avgCarbs = weeklyNutrition['carbohydrates']! / 7;
    final avgFat = weeklyNutrition['fat']! / 7;

    return Padding(
      padding: Responsive.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Summary',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: Responsive.getResponsiveFontSize(context, 20,
                      tabletFontSize: 24, desktopFontSize: 28),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Grid layout for nutrition data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.isDesktop(context)
                ? 4
                : Responsive.isTablet(context)
                    ? 3
                    : 2,
            childAspectRatio: Responsive.isDesktop(context) ? 1.2 : 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildNutritionCard(
                context,
                'Total Calories',
                '${weeklyNutrition['calories']?.toStringAsFixed(0) ?? '0'}',
                'kcal',
                Icons.local_fire_department,
                Colors.orange,
                'Daily Avg: ${avgCalories.toStringAsFixed(0)} kcal',
              ),
              _buildNutritionCard(
                context,
                'Total Protein',
                '${weeklyNutrition['protein']?.toStringAsFixed(1) ?? '0'}',
                'g',
                Icons.fitness_center,
                Colors.blue,
                'Daily Avg: ${avgProtein.toStringAsFixed(1)}g',
              ),
              _buildNutritionCard(
                context,
                'Total Carbs',
                '${weeklyNutrition['carbohydrates']?.toStringAsFixed(1) ?? '0'}',
                'g',
                Icons.grain,
                Colors.green,
                'Daily Avg: ${avgCarbs.toStringAsFixed(1)}g',
              ),
              _buildNutritionCard(
                context,
                'Total Fat',
                '${weeklyNutrition['fat']?.toStringAsFixed(1) ?? '0'}',
                'g',
                Icons.opacity,
                Colors.purple,
                'Daily Avg: ${avgFat.toStringAsFixed(1)}g',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Activity summary cards
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Meal Plans',
                  totalMealPlans.toString(),
                  Icons.restaurant_menu,
                  Colors.indigo,
                  'Planned meals this week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Analyzed Meals',
                  totalAnalyzedMeals.toString(),
                  Icons.camera_alt,
                  Colors.teal,
                  'Meals analyzed this week',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: Responsive.getResponsivePadding(context,
              mobilePadding: const EdgeInsets.all(16),
              tabletPadding: const EdgeInsets.all(20),
              desktopPadding: const EdgeInsets.all(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Responsive.getResponsiveFontSize(context, 24,
                      tabletFontSize: 28, desktopFontSize: 32),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$value$unit',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getResponsiveFontSize(context, 18,
                          tabletFontSize: 20, desktopFontSize: 22),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: Responsive.getResponsivePadding(context,
              mobilePadding: const EdgeInsets.all(16),
              tabletPadding: const EdgeInsets.all(20),
              desktopPadding: const EdgeInsets.all(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Responsive.getResponsiveFontSize(context, 20,
                      tabletFontSize: 24, desktopFontSize: 28),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getResponsiveFontSize(context, 20,
                          tabletFontSize: 24, desktopFontSize: 28),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

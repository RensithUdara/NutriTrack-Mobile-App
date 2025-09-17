import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ProgressTrackingWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final Map<String, double> todayNutrition;
  final Map<String, double> weeklyNutrition;

  const ProgressTrackingWidget({
    super.key,
    required this.weeklyData,
    required this.todayNutrition,
    required this.weeklyNutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.getResponsivePadding(context),
          child: Text(
            'Progress Tracking',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: Responsive.getResponsiveFontSize(context, 20,
                      tabletFontSize: 24, desktopFontSize: 28),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTodayProgress(context),
        const SizedBox(height: 24),
        _buildWeeklySummary(context),
      ],
    );
  }

  Widget _buildTodayProgress(BuildContext context) {
    return Padding(
      padding: Responsive.getResponsivePadding(context),
      child: Card(
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
                    Icons.today,
                    color: Theme.of(context).colorScheme.primary,
                    size: Responsive.getResponsiveFontSize(context, 20,
                        tabletFontSize: 24, desktopFontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.getResponsiveFontSize(
                              context, 18,
                              tabletFontSize: 20, desktopFontSize: 22),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Responsive.getResponsiveLayout(
                context,
                mobileLayout: Column(
                  children: [
                    _buildProgressBar(context, 'Calories',
                        todayNutrition['calories'] ?? 0, 2000, 'kcal'),
                    const SizedBox(height: 12),
                    _buildProgressBar(context, 'Protein',
                        todayNutrition['protein'] ?? 0, 150, 'g'),
                    const SizedBox(height: 12),
                    _buildProgressBar(context, 'Carbs',
                        todayNutrition['carbohydrates'] ?? 0, 250, 'g'),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                        context, 'Fat', todayNutrition['fat'] ?? 0, 65, 'g'),
                  ],
                ),
                tabletLayout: Row(
                  children: [
                    Expanded(
                        child: _buildProgressBar(context, 'Calories',
                            todayNutrition['calories'] ?? 0, 2000, 'kcal')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildProgressBar(context, 'Protein',
                            todayNutrition['protein'] ?? 0, 150, 'g')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildProgressBar(context, 'Carbs',
                            todayNutrition['carbohydrates'] ?? 0, 250, 'g')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildProgressBar(context, 'Fat',
                            todayNutrition['fat'] ?? 0, 65, 'g')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double current,
      double target, String unit) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = Colors.green;
    } else if (progress >= 0.7) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${current.toStringAsFixed(0)}/$target$unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: progressColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary(BuildContext context) {
    final avgCalories = weeklyNutrition['calories']! / 7;
    final avgProtein = weeklyNutrition['protein']! / 7;
    final avgCarbs = weeklyNutrition['carbohydrates']! / 7;
    final avgFat = weeklyNutrition['fat']! / 7;

    return Padding(
      padding: Responsive.getResponsivePadding(context),
      child: Card(
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
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: Responsive.getResponsiveFontSize(context, 20,
                        tabletFontSize: 24, desktopFontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.getResponsiveFontSize(
                              context, 18,
                              tabletFontSize: 20, desktopFontSize: 22),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Daily averages section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Averages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Responsive.getResponsiveLayout(
                      context,
                      mobileLayout: Column(
                        children: [
                          _buildAverageItem(
                              context,
                              'Calories',
                              '${avgCalories.toStringAsFixed(0)} kcal/day',
                              Icons.local_fire_department,
                              Colors.orange),
                          const SizedBox(height: 8),
                          _buildAverageItem(
                              context,
                              'Protein',
                              '${avgProtein.toStringAsFixed(1)} g/day',
                              Icons.fitness_center,
                              Colors.blue),
                          const SizedBox(height: 8),
                          _buildAverageItem(
                              context,
                              'Carbs',
                              '${avgCarbs.toStringAsFixed(1)} g/day',
                              Icons.grain,
                              Colors.green),
                          const SizedBox(height: 8),
                          _buildAverageItem(
                              context,
                              'Fat',
                              '${avgFat.toStringAsFixed(1)} g/day',
                              Icons.opacity,
                              Colors.purple),
                        ],
                      ),
                      tabletLayout: Row(
                        children: [
                          Expanded(
                              child: _buildAverageItem(
                                  context,
                                  'Calories',
                                  '${avgCalories.toStringAsFixed(0)} kcal/day',
                                  Icons.local_fire_department,
                                  Colors.orange)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildAverageItem(
                                  context,
                                  'Protein',
                                  '${avgProtein.toStringAsFixed(1)} g/day',
                                  Icons.fitness_center,
                                  Colors.blue)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildAverageItem(
                                  context,
                                  'Carbs',
                                  '${avgCarbs.toStringAsFixed(1)} g/day',
                                  Icons.grain,
                                  Colors.green)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildAverageItem(
                                  context,
                                  'Fat',
                                  '${avgFat.toStringAsFixed(1)} g/day',
                                  Icons.opacity,
                                  Colors.purple)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Total weekly values
              Text(
                'Weekly Totals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Responsive.getResponsiveLayout(
                context,
                mobileLayout: Column(
                  children: [
                    _buildSummaryItem(
                        context,
                        'Total Calories',
                        '${weeklyNutrition['calories']?.toStringAsFixed(0) ?? '0'} kcal',
                        Icons.local_fire_department,
                        Colors.orange),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                        context,
                        'Total Protein',
                        '${weeklyNutrition['protein']?.toStringAsFixed(1) ?? '0'} g',
                        Icons.fitness_center,
                        Colors.blue),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                        context,
                        'Total Carbs',
                        '${weeklyNutrition['carbohydrates']?.toStringAsFixed(1) ?? '0'} g',
                        Icons.grain,
                        Colors.green),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                        context,
                        'Total Fat',
                        '${weeklyNutrition['fat']?.toStringAsFixed(1) ?? '0'} g',
                        Icons.opacity,
                        Colors.purple),
                  ],
                ),
                tabletLayout: Row(
                  children: [
                    Expanded(
                        child: _buildSummaryItem(
                            context,
                            'Total Calories',
                            '${weeklyNutrition['calories']?.toStringAsFixed(0) ?? '0'} kcal',
                            Icons.local_fire_department,
                            Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildSummaryItem(
                            context,
                            'Total Protein',
                            '${weeklyNutrition['protein']?.toStringAsFixed(1) ?? '0'} g',
                            Icons.fitness_center,
                            Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildSummaryItem(
                            context,
                            'Total Carbs',
                            '${weeklyNutrition['carbohydrates']?.toStringAsFixed(1) ?? '0'} g',
                            Icons.grain,
                            Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildSummaryItem(
                            context,
                            'Total Fat',
                            '${weeklyNutrition['fat']?.toStringAsFixed(1) ?? '0'} g',
                            Icons.opacity,
                            Colors.purple)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: Responsive.getResponsiveFontSize(context, 24,
                tabletFontSize: 28, desktopFontSize: 32),
          ),
          const SizedBox(height: 8),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAverageItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
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
          Icon(
            icon,
            color: color,
            size: Responsive.getResponsiveFontSize(context, 20,
                tabletFontSize: 22, desktopFontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

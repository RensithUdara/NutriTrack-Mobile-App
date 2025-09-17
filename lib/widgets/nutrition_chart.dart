import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class NutritionChart extends StatefulWidget {
  final Map<String, double> nutritionData;

  const NutritionChart({
    super.key,
    required this.nutritionData,
  });

  @override
  State<NutritionChart> createState() => _NutritionChartState();
}

class _NutritionChartState extends State<NutritionChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calories = widget.nutritionData['calories'] ?? 0;
    final protein = widget.nutritionData['protein'] ?? 0;
    final carbs = widget.nutritionData['carbohydrates'] ?? 0;
    final fat = widget.nutritionData['fat'] ?? 0;

    final total = protein + carbs + fat;

    if (total == 0) {
      return _buildEmptyState(context);
    }

    final proteinPercentage = (protein / total) * 100;
    final carbsPercentage = (carbs / total) * 100;
    final fatPercentage = (fat / total) * 100;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
          ),
          child: Padding(
            padding: Responsive.getResponsivePadding(
              context,
              mobilePadding: const EdgeInsets.all(16),
              tabletPadding: const EdgeInsets.all(20),
              desktopPadding: const EdgeInsets.all(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                SizedBox(
                    height: Responsive.getResponsiveHeight(context, 16,
                        tabletHeight: 20, desktopHeight: 24)),
                Flexible(
                  child: _buildChartSection(
                      context,
                      proteinPercentage,
                      carbsPercentage,
                      fatPercentage,
                      protein,
                      carbs,
                      fat,
                      calories),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: Responsive.getResponsiveHeight(context, 200,
              tabletHeight: 240, desktopHeight: 280),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  size: Responsive.getResponsiveFontSize(context, 48,
                      tabletFontSize: 56, desktopFontSize: 64),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
                SizedBox(
                    height: Responsive.getResponsiveHeight(context, 16,
                        tabletHeight: 20, desktopHeight: 24)),
                Text(
                  'No nutrition data available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(
                    height: Responsive.getResponsiveHeight(context, 8,
                        tabletHeight: 10, desktopHeight: 12)),
                Text(
                  'Analyze some meals to see your nutrition breakdown',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: Responsive.getResponsiveFontSize(context, 24,
                tabletFontSize: 28, desktopFontSize: 32),
          ),
        ),
        SizedBox(
            width: Responsive.getResponsiveWidth(context, 12,
                tabletWidth: 16, desktopWidth: 20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutritional Breakdown',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getResponsiveFontSize(context, 20,
                          tabletFontSize: 24, desktopFontSize: 28),
                    ),
              ),
              Text(
                'Macronutrient distribution',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: Responsive.getResponsiveFontSize(context, 12,
                          tabletFontSize: 14, desktopFontSize: 16),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(
      BuildContext context,
      double proteinPercentage,
      double carbsPercentage,
      double fatPercentage,
      double protein,
      double carbs,
      double fat,
      double calories) {
    return Responsive.getResponsiveLayout(
      context,
      mobileLayout: _buildMobileLayout(context, proteinPercentage,
          carbsPercentage, fatPercentage, protein, carbs, fat, calories),
      tabletLayout: _buildTabletLayout(context, proteinPercentage,
          carbsPercentage, fatPercentage, protein, carbs, fat, calories),
      desktopLayout: _buildDesktopLayout(context, proteinPercentage,
          carbsPercentage, fatPercentage, protein, carbs, fat, calories),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      double proteinPercentage,
      double carbsPercentage,
      double fatPercentage,
      double protein,
      double carbs,
      double fat,
      double calories) {
    return Column(
      children: [
        // Bar Chart
        Container(
          height: Responsive.getResponsiveHeight(context, 180,
              tabletHeight: 200, desktopHeight: 220),
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25,
          ),
          child: _buildBarChart(context, protein, carbs, fat, true),
        ),
        SizedBox(
            height: Responsive.getResponsiveHeight(context, 12,
                tabletHeight: 16, desktopHeight: 20)),
        // Legend and Stats
        _buildLegendAndStats(context, protein, carbs, fat, calories, true),
      ],
    );
  }

  Widget _buildTabletLayout(
      BuildContext context,
      double proteinPercentage,
      double carbsPercentage,
      double fatPercentage,
      double protein,
      double carbs,
      double fat,
      double calories) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Row(
        children: [
          // Bar Chart
          Expanded(
            flex: 3,
            child: Container(
              height: Responsive.getResponsiveHeight(context, 180,
                  tabletHeight: 200, desktopHeight: 220),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: _buildBarChart(context, protein, carbs, fat, false),
            ),
          ),
          SizedBox(
              width: Responsive.getResponsiveWidth(context, 16,
                  tabletWidth: 20, desktopWidth: 24)),
          // Legend and Stats
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: _buildLegendAndStats(
                  context, protein, carbs, fat, calories, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      double proteinPercentage,
      double carbsPercentage,
      double fatPercentage,
      double protein,
      double carbs,
      double fat,
      double calories) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Row(
        children: [
          // Bar Chart
          Expanded(
            flex: 2,
            child: Container(
              height: Responsive.getResponsiveHeight(context, 200,
                  tabletHeight: 220, desktopHeight: 240),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: _buildBarChart(context, protein, carbs, fat, false),
            ),
          ),
          SizedBox(
              width: Responsive.getResponsiveWidth(context, 20,
                  tabletWidth: 24, desktopWidth: 28)),
          // Legend and Stats
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: _buildLegendAndStats(
                  context, protein, carbs, fat, calories, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, double protein, double carbs,
      double fat, bool isMobile) {
    final maxValue = [protein, carbs, fat].reduce((a, b) => a > b ? a : b);
    final colors = [
      const Color(0xFF2196F3), // Blue for Protein
      const Color(0xFF4CAF50), // Green for Carbs
      const Color(0xFF9C27B0), // Purple for Fat
    ];
    final labels = ['Protein', 'Carbs', 'Fat'];
    final values = [protein, carbs, fat];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: Responsive.getResponsivePadding(
            context,
            mobilePadding: const EdgeInsets.all(12),
            tabletPadding: const EdgeInsets.all(16),
            desktopPadding: const EdgeInsets.all(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bar Chart
              SizedBox(
                height: Responsive.getResponsiveHeight(context, 140,
                    tabletHeight: 160, desktopHeight: 180),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(3, (index) {
                    final animatedValue = values[index] * _animation.value;
                    final height =
                        maxValue > 0 ? (animatedValue / maxValue) : 0.0;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getResponsiveWidth(context, 2,
                              tabletWidth: 4, desktopWidth: 6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Value Label
                            Text(
                              '${values[index].toStringAsFixed(1)}g',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.getResponsiveFontSize(
                                        context, 9,
                                        tabletFontSize: 10,
                                        desktopFontSize: 11),
                                    color: colors[index],
                                  ),
                            ),
                            SizedBox(
                                height: Responsive.getResponsiveHeight(
                                    context, 3,
                                    tabletHeight: 4, desktopHeight: 5)),
                            // Bar
                            Container(
                              height: Responsive.getResponsiveHeight(
                                      context, 100,
                                      tabletHeight: 120, desktopHeight: 140) *
                                  height,
                              decoration: BoxDecoration(
                                color: colors[index],
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    colors[index],
                                    colors[index].withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors[index].withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: Responsive.getResponsiveHeight(
                                    context, 6,
                                    tabletHeight: 8, desktopHeight: 10)),
                            // Label
                            Text(
                              labels[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Responsive.getResponsiveFontSize(
                                        context, 9,
                                        tabletFontSize: 10,
                                        desktopFontSize: 11),
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendAndStats(BuildContext context, double protein,
      double carbs, double fat, double calories, bool isMobile) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Legend
          ...List.generate(3, (index) {
            final data = [
              {
                'label': 'Protein',
                'value': protein,
                'color': const Color(0xFF2196F3),
                'icon': Icons.fitness_center
              },
              {
                'label': 'Carbs',
                'value': carbs,
                'color': const Color(0xFF4CAF50),
                'icon': Icons.grain
              },
              {
                'label': 'Fat',
                'value': fat,
                'color': const Color(0xFF9C27B0),
                'icon': Icons.opacity
              },
            ][index];

            return Padding(
              padding: EdgeInsets.only(
                  bottom: Responsive.getResponsiveHeight(context, 8,
                      tabletHeight: 10, desktopHeight: 12)),
              child: _buildModernLegendItem(
                  context,
                  data['label'] as String,
                  data['value'] as double,
                  data['color'] as Color,
                  data['icon'] as IconData),
            );
          }),

          SizedBox(
              height: Responsive.getResponsiveHeight(context, 12,
                  tabletHeight: 16, desktopHeight: 20)),

          // Total Calories Card
          _buildCaloriesCard(context, calories),
        ],
      ),
    );
  }

  Widget _buildModernLegendItem(BuildContext context, String label,
      double value, Color color, IconData icon) {
    return Container(
      padding: Responsive.getResponsivePadding(
        context,
        mobilePadding: const EdgeInsets.all(8),
        tabletPadding: const EdgeInsets.all(10),
        desktopPadding: const EdgeInsets.all(12),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: Responsive.getResponsiveFontSize(context, 14,
                  tabletFontSize: 16, desktopFontSize: 18),
            ),
          ),
          SizedBox(
              width: Responsive.getResponsiveWidth(context, 8,
                  tabletWidth: 10, desktopWidth: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.getResponsiveFontSize(context, 10,
                            tabletFontSize: 12, desktopFontSize: 14),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${value.toStringAsFixed(1)}g',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.getResponsiveFontSize(context, 12,
                            tabletFontSize: 14, desktopFontSize: 16),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context, double calories) {
    return Container(
      width: double.infinity,
      padding: Responsive.getResponsivePadding(
        context,
        mobilePadding: const EdgeInsets.all(12),
        tabletPadding: const EdgeInsets.all(14),
        desktopPadding: const EdgeInsets.all(16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: Theme.of(context).colorScheme.primary,
                size: Responsive.getResponsiveFontSize(context, 16,
                    tabletFontSize: 18, desktopFontSize: 20),
              ),
              SizedBox(
                  width: Responsive.getResponsiveWidth(context, 6,
                      tabletWidth: 8, desktopWidth: 10)),
              Flexible(
                child: Text(
                  'Total Calories',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.getResponsiveFontSize(context, 12,
                            tabletFontSize: 14, desktopFontSize: 16),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
              height: Responsive.getResponsiveHeight(context, 6,
                  tabletHeight: 8, desktopHeight: 10)),
          Text(
            calories.toStringAsFixed(0),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Responsive.getResponsiveFontSize(context, 18,
                      tabletFontSize: 20, desktopFontSize: 24),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

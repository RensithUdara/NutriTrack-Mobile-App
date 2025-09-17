import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_planning_provider.dart';
import '../widgets/meal_plan_card.dart';
import '../widgets/meal_plan_generation_dialog.dart';
import '../utils/responsive.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealPlanningProvider>().loadMealPlans();
      context.read<MealPlanningProvider>().loadUserPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          Consumer<MealPlanningProvider>(
            builder: (context, provider, child) {
              return provider.mealPlans.isNotEmpty
                  ? IconButton(
                      onPressed: () => _showClearDialog(context),
                      icon: const Icon(Icons.clear_all),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MealPlanningProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.mealPlans.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
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
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadMealPlans();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.mealPlans.isEmpty) {
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
                        Icons.restaurant_menu_outlined,
                        size: Responsive.getResponsiveFontSize(context, 64,
                            tabletFontSize: 72, desktopFontSize: 80),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No meal plans yet',
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
                      'Set your dietary preferences and generate personalized meal plans with AI',
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
                      onPressed: () => _showMealPlanGenerationDialog(context),
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Generate Meal Plan'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMealPlans(),
            child: Responsive.getResponsiveLayout(
              context,
              mobileLayout: ListView.builder(
                padding: Responsive.getResponsivePadding(context),
                itemCount: provider.mealPlans.length,
                itemBuilder: (context, index) {
                  final plan = provider.mealPlans[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MealPlanCard(mealPlan: plan),
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
                itemCount: provider.mealPlans.length,
                itemBuilder: (context, index) {
                  final plan = provider.mealPlans[index];
                  return MealPlanCard(mealPlan: plan);
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
                itemCount: provider.mealPlans.length,
                itemBuilder: (context, index) {
                  final plan = provider.mealPlans[index];
                  return MealPlanCard(mealPlan: plan);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<MealPlanningProvider>(
        builder: (context, provider, child) {
          return provider.mealPlans.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _showMealPlanGenerationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Generate Plan'),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _showMealPlanGenerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MealPlanGenerationDialog(),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Meal Plans'),
        content: const Text(
            'Are you sure you want to delete all meal plans? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MealPlanningProvider>().clearAllMealPlans();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All meal plans cleared successfully'),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_planning_provider.dart';
import '../models/meal_plan.dart';

class MealPlanGenerationDialog extends StatefulWidget {
  const MealPlanGenerationDialog({super.key});

  @override
  State<MealPlanGenerationDialog> createState() =>
      _MealPlanGenerationDialogState();
}

class _MealPlanGenerationDialogState extends State<MealPlanGenerationDialog> {
  final List<String> _availableMealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack'
  ];
  final List<String> _availableDietTypes = [
    'balanced',
    'vegetarian',
    'vegan',
    'keto',
    'paleo',
    'mediterranean',
    'low-carb',
    'high-protein',
  ];

  List<String> _selectedMealTypes = ['breakfast', 'lunch', 'dinner'];
  String _selectedDietType = 'balanced';
  final _calorieController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  bool _isGenerating = false;
  bool _useCustomGoals = false;

  @override
  void initState() {
    super.initState();
    // Always start with default values - don't load saved preferences
    _calorieController.text = '2000';
    _proteinController.text = '150';
    _carbController.text = '250';
    _fatController.text = '65';
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Generate Meal Plan',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Configure your meal plan preferences below. These settings will only apply to this meal plan generation.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Diet Type Selection
                    Text(
                      'Diet Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDietType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _availableDietTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDietType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nutrition Goals
                    Row(
                      children: [
                        Text(
                          'Nutrition Goals',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _useCustomGoals,
                          onChanged: (value) {
                            setState(() {
                              _useCustomGoals = value;
                            });
                          },
                        ),
                        Text(
                          'Custom',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_useCustomGoals) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _calorieController,
                              decoration: const InputDecoration(
                                labelText: 'Calories',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _proteinController,
                              decoration: const InputDecoration(
                                labelText: 'Protein (g)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _carbController,
                              decoration: const InputDecoration(
                                labelText: 'Carbs (g)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _fatController,
                              decoration: const InputDecoration(
                                labelText: 'Fat (g)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Meal Type Selection
                    Text(
                      'Select Meal Types',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose which meals to include in your daily plan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _availableMealTypes.map((mealType) {
                        final isSelected =
                            _selectedMealTypes.contains(mealType);
                        return FilterChip(
                          label: Text(mealType.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedMealTypes.add(mealType);
                              } else {
                                _selectedMealTypes.remove(mealType);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Generation Options
                    Text(
                      'Generation Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI will create a diverse, nutritionally balanced meal plan based on your preferences',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isGenerating ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isGenerating ? null : _generateMealPlan,
                      child: _isGenerating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Generate Plan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateMealPlan() async {
    if (_selectedMealTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one meal type'),
        ),
      );
      return;
    }

    if (_useCustomGoals) {
      if (_calorieController.text.isEmpty ||
          _proteinController.text.isEmpty ||
          _carbController.text.isEmpty ||
          _fatController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all nutrition goals'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      print('Starting meal plan generation...');
      final provider = context.read<MealPlanningProvider>();

      // Create temporary preferences for this generation only (don't save)
      UserPreferences tempPreferences = UserPreferences(
        dietaryRestrictions: [],
        allergies: [],
        dietType: _selectedDietType,
        dailyCalorieTarget: _useCustomGoals
            ? double.tryParse(_calorieController.text) ?? 2000
            : 2000,
        proteinGoal: _useCustomGoals
            ? double.tryParse(_proteinController.text) ?? 150
            : 150,
        carbGoal: _useCustomGoals
            ? double.tryParse(_carbController.text) ?? 250
            : 250,
        fatGoal:
            _useCustomGoals ? double.tryParse(_fatController.text) ?? 65 : 65,
        dislikedFoods: [],
        preferredMealTypes: _selectedMealTypes,
      );

      print(
          'Created preferences: ${tempPreferences.dietType}, meals: ${tempPreferences.preferredMealTypes}');

      // Generate meal plan with temporary preferences
      print('Calling generateMealPlanWithPreferences...');
      await provider.generateMealPlanWithPreferences(tempPreferences);
      print('Meal plan generation completed successfully');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meal plan generated successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate meal plan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

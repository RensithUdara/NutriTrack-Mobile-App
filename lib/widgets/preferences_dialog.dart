import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_planning_provider.dart';
import '../models/meal_plan.dart';

class PreferencesDialog extends StatefulWidget {
  const PreferencesDialog({super.key});

  @override
  State<PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _calorieController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();

  String _dietType = 'balanced';
  final List<String> _dietaryRestrictions = [];
  final List<String> _allergies = [];
  final List<String> _dislikedFoods = [];
  final List<String> _preferredMealTypes = ['breakfast', 'lunch', 'dinner'];
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

  final List<String> _availableRestrictions = [
    'gluten-free',
    'dairy-free',
    'nut-free',
    'soy-free',
    'egg-free',
    'shellfish-free',
    'low-sodium',
    'low-sugar',
  ];

  final List<String> _commonAllergies = [
    'nuts',
    'dairy',
    'eggs',
    'shellfish',
    'soy',
    'wheat',
    'fish',
    'sesame',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  void _loadExistingPreferences() {
    final provider = context.read<MealPlanningProvider>();
    if (provider.userPreferences != null) {
      final prefs = provider.userPreferences!;
      _calorieController.text = prefs.dailyCalorieTarget.toString();
      _proteinController.text = prefs.proteinGoal.toString();
      _carbController.text = prefs.carbGoal.toString();
      _fatController.text = prefs.fatGoal.toString();
      _dietType = prefs.dietType;
      _dietaryRestrictions.addAll(prefs.dietaryRestrictions);
      _allergies.addAll(prefs.allergies);
      _dislikedFoods.addAll(prefs.dislikedFoods);
      _preferredMealTypes.clear();
      _preferredMealTypes.addAll(prefs.preferredMealTypes);
    } else {
      // Default values
      _calorieController.text = '2000';
      _proteinController.text = '150';
      _carbController.text = '250';
      _fatController.text = '65';
    }
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
        constraints: const BoxConstraints(maxHeight: 600),
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
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dietary Preferences',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Diet Type
                      Text(
                        'Diet Type',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _dietType,
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
                            _dietType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Daily Goals
                      Text(
                        'Daily Nutrition Goals',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Preferred Meal Types
                      Text(
                        'Preferred Meal Types',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select which meals you want included in your daily plan',
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
                              _preferredMealTypes.contains(mealType);
                          return FilterChip(
                            label: Text(mealType.toUpperCase()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _preferredMealTypes.add(mealType);
                                } else {
                                  _preferredMealTypes.remove(mealType);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Dietary Restrictions
                      Text(
                        'Dietary Restrictions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _availableRestrictions.map((restriction) {
                          final isSelected =
                              _dietaryRestrictions.contains(restriction);
                          return FilterChip(
                            label: Text(restriction),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _dietaryRestrictions.add(restriction);
                                } else {
                                  _dietaryRestrictions.remove(restriction);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Allergies
                      Text(
                        'Allergies',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _commonAllergies.map((allergy) {
                          final isSelected = _allergies.contains(allergy);
                          return FilterChip(
                            label: Text(allergy),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _allergies.add(allergy);
                                } else {
                                  _allergies.remove(allergy);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _savePreferences,
                      child: const Text('Save'),
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

  void _savePreferences() async {
    if (_formKey.currentState!.validate()) {
      final preferences = UserPreferences(
        dietaryRestrictions: _dietaryRestrictions,
        allergies: _allergies,
        dietType: _dietType,
        dailyCalorieTarget: double.parse(_calorieController.text),
        proteinGoal: double.parse(_proteinController.text),
        carbGoal: double.parse(_carbController.text),
        fatGoal: double.parse(_fatController.text),
        dislikedFoods: _dislikedFoods,
        preferredMealTypes: _preferredMealTypes,
      );

      await context
          .read<MealPlanningProvider>()
          .saveUserPreferences(preferences);
      Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Preferences saved! You can now generate personalized meal plans.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Generate Plan',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                context.read<MealPlanningProvider>().generateMealPlan();
              },
            ),
          ),
        );
      }
    }
  }
}

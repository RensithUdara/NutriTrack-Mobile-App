import 'package:json_annotation/json_annotation.dart';
import 'meal_analysis.dart';

part 'meal_plan.g.dart';

@JsonSerializable()
class MealPlan {
  final String id;
  final DateTime date;
  final List<PlannedMeal> meals;
  final NutritionalInfo totalNutrition;
  final UserPreferences preferences;

  const MealPlan({
    required this.id,
    required this.date,
    required this.meals,
    required this.totalNutrition,
    required this.preferences,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanToJson(this);
}

@JsonSerializable()
class PlannedMeal {
  final String id;
  final String name;
  final String type; 
  final String description;
  final NutritionalInfo nutritionalInfo;
  final List<String> ingredients;
  final String? instructions;

  const PlannedMeal({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.nutritionalInfo,
    required this.ingredients,
    this.instructions,
  });

  factory PlannedMeal.fromJson(Map<String, dynamic> json) =>
      _$PlannedMealFromJson(json);

  Map<String, dynamic> toJson() => _$PlannedMealToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final String dietType; // vegetarian, vegan, keto, etc.
  final double dailyCalorieTarget;
  final double proteinGoal;
  final double carbGoal;
  final double fatGoal;
  final List<String> dislikedFoods;
  final List<String> preferredMealTypes;

  const UserPreferences({
    required this.dietaryRestrictions,
    required this.allergies,
    required this.dietType,
    required this.dailyCalorieTarget,
    required this.proteinGoal,
    required this.carbGoal,
    required this.fatGoal,
    required this.dislikedFoods,
    required this.preferredMealTypes,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

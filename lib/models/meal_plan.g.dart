
part of 'meal_plan.dart';


MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => MealPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List<dynamic>)
          .map((e) => PlannedMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalNutrition: NutritionalInfo.fromJson(
          json['totalNutrition'] as Map<String, dynamic>),
      preferences:
          UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'meals': instance.meals,
      'totalNutrition': instance.totalNutrition,
      'preferences': instance.preferences,
    };

PlannedMeal _$PlannedMealFromJson(Map<String, dynamic> json) => PlannedMeal(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      nutritionalInfo: NutritionalInfo.fromJson(
          json['nutritionalInfo'] as Map<String, dynamic>),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$PlannedMealToJson(PlannedMeal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'nutritionalInfo': instance.nutritionalInfo,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      dietType: json['dietType'] as String,
      dailyCalorieTarget: (json['dailyCalorieTarget'] as num).toDouble(),
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      carbGoal: (json['carbGoal'] as num).toDouble(),
      fatGoal: (json['fatGoal'] as num).toDouble(),
      dislikedFoods: (json['dislikedFoods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      preferredMealTypes: (json['preferredMealTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'dietaryRestrictions': instance.dietaryRestrictions,
      'allergies': instance.allergies,
      'dietType': instance.dietType,
      'dailyCalorieTarget': instance.dailyCalorieTarget,
      'proteinGoal': instance.proteinGoal,
      'carbGoal': instance.carbGoal,
      'fatGoal': instance.fatGoal,
      'dislikedFoods': instance.dislikedFoods,
      'preferredMealTypes': instance.preferredMealTypes,
    };

import 'package:json_annotation/json_annotation.dart';

part 'meal_analysis.g.dart';

@JsonSerializable()
class MealAnalysis {
  final String mealName;
  final String description;
  final NutritionalInfo nutritionalInfo;
  final List<String> ingredients;
  final DateTime analyzedAt;
  final String? imagePath;

  const MealAnalysis({
    required this.mealName,
    required this.description,
    required this.nutritionalInfo,
    required this.ingredients,
    required this.analyzedAt,
    this.imagePath,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MealAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$MealAnalysisToJson(this);
}

@JsonSerializable()
class NutritionalInfo {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double cholesterol;

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.cholesterol,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) =>
      _$NutritionalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionalInfoToJson(this);
}

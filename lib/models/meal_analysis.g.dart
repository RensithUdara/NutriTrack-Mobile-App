
part of 'meal_analysis.dart';
MealAnalysis _$MealAnalysisFromJson(Map<String, dynamic> json) => MealAnalysis(
      mealName: json['mealName'] as String,
      description: json['description'] as String,
      nutritionalInfo: NutritionalInfo.fromJson(
          json['nutritionalInfo'] as Map<String, dynamic>),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$MealAnalysisToJson(MealAnalysis instance) =>
    <String, dynamic>{
      'mealName': instance.mealName,
      'description': instance.description,
      'nutritionalInfo': instance.nutritionalInfo,
      'ingredients': instance.ingredients,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'imagePath': instance.imagePath,
    };

NutritionalInfo _$NutritionalInfoFromJson(Map<String, dynamic> json) =>
    NutritionalInfo(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      cholesterol: (json['cholesterol'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionalInfoToJson(NutritionalInfo instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'carbohydrates': instance.carbohydrates,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'sodium': instance.sodium,
      'cholesterol': instance.cholesterol,
    };

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/meal_analysis.dart';
import '../models/meal_plan.dart';
import '../models/non_food_response.dart';

class GeminiService {
  static String get _baseUrl => ApiConstants.geminiBaseUrl;
  static String get _apiKey => ApiConstants.geminiApiKey;
  static String get _model => ApiConstants.geminiModel;

  // Check if image contains food
  Future<NonFoodResponse> checkIfFoodImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Analyze this image and determine if it contains food or a meal. If it's not food, identify what it is and provide a friendly, encouraging response. Examples of non-food objects: flowers, pets, people, landscapes, buildings, vehicles, books, electronics, etc. For flowers, say something like 'Those flowers are really beautiful! But I'm your meal analyzer, so I can't provide nutrition info for them.' For pets, say something like 'What a cute pet! But I specialize in analyzing food, not furry friends.' Return the response in the following JSON format: {\"isFood\": boolean, \"message\": \"string\", \"detectedObject\": \"string\", \"friendlyComment\": \"string\"}"
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.3,
          "topK": 32,
          "topP": 1,
          "maxOutputTokens": 512,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: ApiConstants.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the JSON response from Gemini
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}');

        if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
          throw Exception('Invalid JSON response from Gemini API');
        }

        final jsonString = content.substring(jsonStart, jsonEnd + 1);
        final responseData = jsonDecode(jsonString);

        return NonFoodResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      print('Food detection error: $e');
      // Default to treating as food if detection fails
      return NonFoodResponse(
        isFood: true,
        message: 'Unable to determine if this is food',
        detectedObject: 'Unknown',
        friendlyComment: 'Let me try to analyze this as a meal',
      );
    }
  }

  // Analyze meal from image
  Future<MealAnalysis> analyzeMealImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Analyze this meal image and provide detailed nutritional information. Return the response in the following JSON format: {\"mealName\": \"string\", \"description\": \"string\", \"nutritionalInfo\": {\"calories\": number, \"protein\": number, \"carbohydrates\": number, \"fat\": number, \"fiber\": number, \"sugar\": number, \"sodium\": number, \"cholesterol\": number}, \"ingredients\": [\"string\"]}"
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "topK": 32,
          "topP": 1,
          "maxOutputTokens": 2048,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: ApiConstants.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug: Print the response structure
        print('Gemini API Response: $data');

        // Check if response has the expected structure
        if (data['candidates'] == null ||
            data['candidates'].isEmpty ||
            data['candidates'][0]['content'] == null ||
            data['candidates'][0]['content']['parts'] == null ||
            data['candidates'][0]['content']['parts'].isEmpty) {
          throw Exception('Invalid response structure from Gemini API');
        }

        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('Gemini API Content: $content');

        // Parse the JSON response from Gemini
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}');

        if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
          throw Exception('Invalid JSON response from Gemini API');
        }

        final jsonString = content.substring(jsonStart, jsonEnd + 1);
        final mealData = jsonDecode(jsonString);

        return MealAnalysis(
          mealName: mealData['mealName'] ?? 'Unknown Meal',
          description: mealData['description'] ?? 'No description available',
          nutritionalInfo:
              NutritionalInfo.fromJson(mealData['nutritionalInfo']),
          ingredients: List<String>.from(mealData['ingredients'] ?? []),
          analyzedAt: DateTime.now(),
          imagePath: imageFile.path,
        );
      } else {
        final errorBody = response.body;
        throw Exception(
            'Failed to analyze meal: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Gemini API Error: $e');
      throw Exception('Error analyzing meal: $e');
    }
  }

  // Generate meal plan based on preferences
  Future<MealPlan> generateMealPlan(UserPreferences preferences) async {
    try {
      print('Gemini: Starting meal plan generation');
      print('Gemini: Diet type: ${preferences.dietType}');
      print('Gemini: Preferred meal types: ${preferences.preferredMealTypes}');

      // Create a more detailed and varied prompt based on diet type
      String dietSpecificPrompt = _getDietSpecificPrompt(preferences);
      print(
          'Gemini: Generated diet-specific prompt length: ${dietSpecificPrompt.length}');

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "$dietSpecificPrompt\n\nGenerate a complete daily meal plan that is diverse, creative, and nutritionally balanced. Ensure the total daily nutrition closely matches the specified goals. Include detailed cooking instructions and use fresh, whole ingredients. Make each meal unique and flavorful. Return the response in the following JSON format: {\"meals\": [{\"id\": \"string\", \"name\": \"string\", \"type\": \"breakfast|lunch|dinner|snack\", \"description\": \"string\", \"nutritionalInfo\": {\"calories\": number, \"protein\": number, \"carbohydrates\": number, \"fat\": number, \"fiber\": number, \"sugar\": number, \"sodium\": number, \"cholesterol\": number}, \"ingredients\": [\"string\"], \"instructions\": \"string\"}], \"totalNutrition\": {\"calories\": number, \"protein\": number, \"carbohydrates\": number, \"fat\": number, \"fiber\": number, \"sugar\": number, \"sodium\": number, \"cholesterol\": number}}"
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.8,
          "topK": 40,
          "topP": 0.9,
          "maxOutputTokens": 4096,
        }
      };

      print('Gemini: Making API request...');
      final response = await http.post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: ApiConstants.headers,
        body: jsonEncode(requestBody),
      );

      print('Gemini: API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Gemini: Successfully parsed response');
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('Gemini: Content length: ${content.length}');

        // Parse the JSON response from Gemini
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        print('Gemini: JSON start: $jsonStart, end: $jsonEnd');

        if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
          print('Gemini: Invalid JSON structure in response');
          throw Exception('Invalid JSON response from Gemini API');
        }

        final jsonString = content.substring(jsonStart, jsonEnd);
        print('Gemini: JSON string length: ${jsonString.length}');

        final planData = jsonDecode(jsonString);
        print(
            'Gemini: Successfully parsed JSON, meals count: ${(planData['meals'] as List).length}');

        final allMeals = (planData['meals'] as List)
            .map((meal) => PlannedMeal.fromJson(meal))
            .toList();
        print(
            'Gemini: Successfully created ${allMeals.length} PlannedMeal objects');

        // Filter meals to only include selected meal types
        print(
            'Gemini: Filtering meals. Available types: ${allMeals.map((m) => m.type).toList()}');
        print('Gemini: Preferred types: ${preferences.preferredMealTypes}');

        final filteredMeals = allMeals
            .where((meal) => preferences.preferredMealTypes.contains(meal.type))
            .toList();
        print('Gemini: Filtered to ${filteredMeals.length} meals');

        // Recalculate total nutrition based on filtered meals
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;
        double totalSugar = 0;
        double totalSodium = 0;
        double totalCholesterol = 0;

        for (final meal in filteredMeals) {
          totalCalories += meal.nutritionalInfo.calories;
          totalProtein += meal.nutritionalInfo.protein;
          totalCarbs += meal.nutritionalInfo.carbohydrates;
          totalFat += meal.nutritionalInfo.fat;
          totalFiber += meal.nutritionalInfo.fiber;
          totalSugar += meal.nutritionalInfo.sugar;
          totalSodium += meal.nutritionalInfo.sodium;
          totalCholesterol += meal.nutritionalInfo.cholesterol;
        }

        final recalculatedNutrition = NutritionalInfo(
          calories: totalCalories,
          protein: totalProtein,
          carbohydrates: totalCarbs,
          fat: totalFat,
          fiber: totalFiber,
          sugar: totalSugar,
          sodium: totalSodium,
          cholesterol: totalCholesterol,
        );

        final mealPlan = MealPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          meals: filteredMeals,
          totalNutrition: recalculatedNutrition,
          preferences: preferences,
        );

        print(
            'Gemini: Successfully created MealPlan with ${mealPlan.meals.length} meals');
        print('Gemini: Total calories: ${mealPlan.totalNutrition.calories}');
        return mealPlan;
      } else {
        throw Exception('Failed to generate meal plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating meal plan: $e');
    }
  }

  // Generate diet-specific prompts for more varied meal plans
  String _getDietSpecificPrompt(UserPreferences preferences) {
    final basePrompt =
        "Create a personalized daily meal plan with these specifications:\n";
    final nutritionPrompt =
        "Daily Calorie Target: ${preferences.dailyCalorieTarget}, Protein Goal: ${preferences.proteinGoal}g, Carb Goal: ${preferences.carbGoal}g, Fat Goal: ${preferences.fatGoal}g\n";
    final mealTypesPrompt =
        "Include these meal types: ${preferences.preferredMealTypes.join(', ')}\n";
    final restrictionsPrompt =
        "Dietary Restrictions: ${preferences.dietaryRestrictions.isEmpty ? 'None' : preferences.dietaryRestrictions.join(', ')}\n";
    final allergiesPrompt =
        "Allergies: ${preferences.allergies.isEmpty ? 'None' : preferences.allergies.join(', ')}\n";
    final dislikesPrompt =
        "Disliked Foods: ${preferences.dislikedFoods.isEmpty ? 'None' : preferences.dislikedFoods.join(', ')}\n";

    String dietSpecificPrompt = "";

    switch (preferences.dietType.toLowerCase()) {
      case 'vegetarian':
        dietSpecificPrompt =
            "VEGETARIAN DIET: Focus on plant-based proteins like beans, lentils, tofu, tempeh, quinoa, and nuts. Include plenty of vegetables, fruits, whole grains, and dairy/eggs. Avoid all meat and fish. Create colorful, nutrient-dense meals with variety in textures and flavors.";
        break;
      case 'vegan':
        dietSpecificPrompt =
            "VEGAN DIET: Completely plant-based with no animal products. Emphasize legumes, nuts, seeds, whole grains, vegetables, and fruits. Include fortified foods for B12 and other nutrients. Create creative, satisfying meals that are rich in plant proteins and healthy fats.";
        break;
      case 'keto':
        dietSpecificPrompt =
            "KETOGENIC DIET: Very low-carb (under 20g net carbs), high-fat, moderate-protein. Focus on healthy fats like avocado, olive oil, nuts, seeds, and fatty fish. Include non-starchy vegetables, eggs, meat, and dairy. Avoid grains, fruits, and starchy vegetables.";
        break;
      case 'paleo':
        dietSpecificPrompt =
            "PALEO DIET: Whole, unprocessed foods that our ancestors would have eaten. Include lean meats, fish, eggs, vegetables, fruits, nuts, and seeds. Avoid grains, legumes, dairy, processed foods, and refined sugars. Focus on nutrient-dense, natural foods.";
        break;
      case 'mediterranean':
        dietSpecificPrompt =
            "MEDITERRANEAN DIET: Emphasize olive oil, fish, vegetables, fruits, whole grains, legumes, and nuts. Include moderate amounts of dairy and wine. Focus on heart-healthy fats, lean proteins, and plenty of colorful vegetables. Create fresh, flavorful meals inspired by Mediterranean cuisine.";
        break;
      case 'low-carb':
        dietSpecificPrompt =
            "LOW-CARB DIET: Reduce carbohydrate intake while maintaining adequate protein and healthy fats. Focus on non-starchy vegetables, lean proteins, nuts, seeds, and healthy fats. Limit grains, fruits, and starchy vegetables. Create satisfying meals that help maintain stable blood sugar.";
        break;
      case 'high-protein':
        dietSpecificPrompt =
            "HIGH-PROTEIN DIET: Emphasize protein-rich foods like lean meats, fish, eggs, dairy, legumes, and protein supplements. Include adequate carbohydrates and healthy fats. Focus on muscle-building and satiety. Create meals that support fitness goals and recovery.";
        break;
      default:
        dietSpecificPrompt =
            "BALANCED DIET: Create a well-rounded meal plan with a good balance of macronutrients. Include a variety of whole foods, lean proteins, complex carbohydrates, healthy fats, and plenty of fruits and vegetables. Focus on nutrient density and variety.";
    }

    return basePrompt +
        dietSpecificPrompt +
        "\n" +
        nutritionPrompt +
        mealTypesPrompt +
        restrictionsPrompt +
        allergiesPrompt +
        dislikesPrompt;
  }
}

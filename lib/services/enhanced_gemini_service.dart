import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/meal_analysis.dart';
import '../models/meal_plan.dart';
import '../models/non_food_response.dart';
import '../utils/error_handler.dart';

class EnhancedGeminiService {
  static String get _baseUrl => ApiConstants.geminiBaseUrl;
  static String get _apiKey => ApiConstants.geminiApiKey;
  static String get _model => ApiConstants.geminiModel;

  // Check if image contains food with enhanced error handling
  Future<NonFoodResponse> checkIfFoodImage(File imageFile) async {
    try {
      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Check file size (max 10MB for Gemini API)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file too large (max 10MB)');
      }

      // Check network connectivity
      if (!await ErrorHandler.isNetworkAvailable()) {
        throw Exception('No internet connection available');
      }

      final bytes = await imageFile.readAsBytes();

      // Validate image format
      if (bytes.isEmpty) {
        throw Exception('Image file is empty or corrupted');
      }

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

      final response = await http
          .post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: ApiConstants.headers,
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate response structure
        if (data['candidates'] == null ||
            data['candidates'].isEmpty ||
            data['candidates'][0]['content'] == null ||
            data['candidates'][0]['content']['parts'] == null ||
            data['candidates'][0]['content']['parts'].isEmpty) {
          throw Exception('Invalid response structure from Gemini API');
        }

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
        final errorBody = response.body;
        final error = ErrorHandler.handleException(
          Exception('HTTP ${response.statusCode}: $errorBody'),
          context: 'checkIfFoodImage',
        );
        throw Exception(error.message);
      }
    } catch (e) {
      final error = ErrorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: 'checkIfFoodImage',
      );

      ErrorHandler.logError(error, context: 'checkIfFoodImage');

      // Default to treating as food if detection fails
      return NonFoodResponse(
        isFood: true,
        message: 'Unable to determine if this is food',
        detectedObject: 'Unknown',
        friendlyComment: 'Let me try to analyze this as a meal',
      );
    }
  }

  // Analyze meal from image with enhanced error handling
  Future<MealAnalysis> analyzeMealImage(File imageFile) async {
    try {
      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Check file size (max 10MB for Gemini API)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file too large (max 10MB)');
      }

      // Check network connectivity
      if (!await ErrorHandler.isNetworkAvailable()) {
        throw Exception('No internet connection available');
      }

      final bytes = await imageFile.readAsBytes();

      // Validate image format
      if (bytes.isEmpty) {
        throw Exception('Image file is empty or corrupted');
      }

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

      final response = await http
          .post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: ApiConstants.headers,
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate response structure
        if (data['candidates'] == null ||
            data['candidates'].isEmpty ||
            data['candidates'][0]['content'] == null ||
            data['candidates'][0]['content']['parts'] == null ||
            data['candidates'][0]['content']['parts'].isEmpty) {
          throw Exception('Invalid response structure from Gemini API');
        }

        final content = data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the JSON response from Gemini
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}');

        if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
          throw Exception('Invalid JSON response from Gemini API');
        }

        final jsonString = content.substring(jsonStart, jsonEnd + 1);
        final mealData = jsonDecode(jsonString);

        // Validate required fields
        if (mealData['mealName'] == null ||
            mealData['nutritionalInfo'] == null) {
          throw Exception('Invalid meal data structure from API');
        }

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
        final error = ErrorHandler.handleException(
          Exception('HTTP ${response.statusCode}: $errorBody'),
          context: 'analyzeMealImage',
        );
        throw Exception(error.message);
      }
    } catch (e) {
      final error = ErrorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: 'analyzeMealImage',
      );

      ErrorHandler.logError(error, context: 'analyzeMealImage');
      rethrow;
    }
  }

  // Generate meal plan with enhanced error handling
  Future<MealPlan> generateMealPlan(UserPreferences preferences) async {
    try {
      // Check network connectivity
      if (!await ErrorHandler.isNetworkAvailable()) {
        throw Exception('No internet connection available');
      }

      // Validate preferences
      if (preferences.dailyCalorieTarget <= 0) {
        throw Exception('Invalid daily calorie target');
      }

      // Create a more detailed and varied prompt based on diet type
      String dietSpecificPrompt = _getDietSpecificPrompt(preferences);

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

      final response = await http
          .post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: ApiConstants.headers,
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the JSON response from Gemini
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;

        if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
          throw Exception('Invalid JSON response from Gemini API');
        }

        final jsonString = content.substring(jsonStart, jsonEnd);
        final planData = jsonDecode(jsonString);

        // Validate response structure
        if (planData['meals'] == null || planData['totalNutrition'] == null) {
          throw Exception('Invalid meal plan data structure from API');
        }

        final allMeals = (planData['meals'] as List)
            .map((meal) => PlannedMeal.fromJson(meal))
            .toList();

        // Filter meals to only include selected meal types
        final filteredMeals = allMeals
            .where((meal) => preferences.preferredMealTypes.contains(meal.type))
            .toList();

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

        return mealPlan;
      } else {
        final errorBody = response.body;
        final error = ErrorHandler.handleException(
          Exception('HTTP ${response.statusCode}: $errorBody'),
          context: 'generateMealPlan',
        );
        throw Exception(error.message);
      }
    } catch (e) {
      final error = ErrorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: 'generateMealPlan',
      );

      ErrorHandler.logError(error, context: 'generateMealPlan');
      rethrow;
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

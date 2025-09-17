import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal_analysis.dart';
import '../models/meal_plan.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'meal_analyzer.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _mealAnalysisTable = 'meal_analysis';
  static const String _mealPlanTable = 'meal_plans';
  static const String _userPreferencesTable = 'user_preferences';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create meal analysis table
    await db.execute('''
      CREATE TABLE $_mealAnalysisTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_name TEXT NOT NULL,
        description TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbohydrates REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL,
        sugar REAL NOT NULL,
        sodium REAL NOT NULL,
        cholesterol REAL NOT NULL,
        ingredients TEXT NOT NULL,
        analyzed_at TEXT NOT NULL,
        image_path TEXT
      )
    ''');

    // Create meal plans table
    await db.execute('''
      CREATE TABLE $_mealPlanTable (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        meals TEXT NOT NULL,
        total_nutrition TEXT NOT NULL,
        preferences TEXT NOT NULL
      )
    ''');

    // Create user preferences table
    await db.execute('''
      CREATE TABLE $_userPreferencesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dietary_restrictions TEXT NOT NULL,
        allergies TEXT NOT NULL,
        diet_type TEXT NOT NULL,
        daily_calorie_target REAL NOT NULL,
        protein_goal REAL NOT NULL,
        carb_goal REAL NOT NULL,
        fat_goal REAL NOT NULL,
        disliked_foods TEXT NOT NULL,
        preferred_meal_types TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Meal Analysis CRUD operations
  Future<int> insertMealAnalysis(MealAnalysis mealAnalysis) async {
    final db = await database;
    return await db.insert(_mealAnalysisTable, {
      'meal_name': mealAnalysis.mealName,
      'description': mealAnalysis.description,
      'calories': mealAnalysis.nutritionalInfo.calories,
      'protein': mealAnalysis.nutritionalInfo.protein,
      'carbohydrates': mealAnalysis.nutritionalInfo.carbohydrates,
      'fat': mealAnalysis.nutritionalInfo.fat,
      'fiber': mealAnalysis.nutritionalInfo.fiber,
      'sugar': mealAnalysis.nutritionalInfo.sugar,
      'sodium': mealAnalysis.nutritionalInfo.sodium,
      'cholesterol': mealAnalysis.nutritionalInfo.cholesterol,
      'ingredients': jsonEncode(mealAnalysis.ingredients),
      'analyzed_at': mealAnalysis.analyzedAt.toIso8601String(),
      'image_path': mealAnalysis.imagePath,
    });
  }

  Future<List<MealAnalysis>> getAllMealAnalyses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _mealAnalysisTable,
      orderBy: 'analyzed_at DESC',
    );

    return List.generate(maps.length, (i) {
      return MealAnalysis(
        mealName: maps[i]['meal_name'],
        description: maps[i]['description'],
        nutritionalInfo: NutritionalInfo(
          calories: maps[i]['calories'],
          protein: maps[i]['protein'],
          carbohydrates: maps[i]['carbohydrates'],
          fat: maps[i]['fat'],
          fiber: maps[i]['fiber'],
          sugar: maps[i]['sugar'],
          sodium: maps[i]['sodium'],
          cholesterol: maps[i]['cholesterol'],
        ),
        ingredients: List<String>.from(jsonDecode(maps[i]['ingredients'])),
        analyzedAt: DateTime.parse(maps[i]['analyzed_at']),
        imagePath: maps[i]['image_path'],
      );
    });
  }

  Future<void> deleteMealAnalysis(int id) async {
    final db = await database;
    await db.delete(
      _mealAnalysisTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Meal Plan CRUD operations
  Future<int> insertMealPlan(MealPlan mealPlan) async {
    final db = await database;
    return await db.insert(_mealPlanTable, {
      'id': mealPlan.id,
      'date': mealPlan.date.toIso8601String(),
      'meals': jsonEncode(mealPlan.meals.map((m) => m.toJson()).toList()),
      'total_nutrition': jsonEncode(mealPlan.totalNutrition.toJson()),
      'preferences': jsonEncode(mealPlan.preferences.toJson()),
    });
  }

  Future<List<MealPlan>> getAllMealPlans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _mealPlanTable,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      try {
        final mealsJson = jsonDecode(maps[i]['meals']) as List;
        final meals =
            mealsJson.map((meal) => PlannedMeal.fromJson(meal)).toList();

        // Handle preferences with backward compatibility
        final preferencesJson = jsonDecode(maps[i]['preferences']);
        UserPreferences preferences;

        try {
          preferences = UserPreferences.fromJson(preferencesJson);
        } catch (e) {
          // Handle old preferences without preferredMealTypes
          preferences = UserPreferences(
            dietaryRestrictions:
                List<String>.from(preferencesJson['dietaryRestrictions'] ?? []),
            allergies: List<String>.from(preferencesJson['allergies'] ?? []),
            dietType: preferencesJson['dietType'] ?? 'balanced',
            dailyCalorieTarget:
                preferencesJson['dailyCalorieTarget']?.toDouble() ?? 2000.0,
            proteinGoal: preferencesJson['proteinGoal']?.toDouble() ?? 150.0,
            carbGoal: preferencesJson['carbGoal']?.toDouble() ?? 250.0,
            fatGoal: preferencesJson['fatGoal']?.toDouble() ?? 65.0,
            dislikedFoods:
                List<String>.from(preferencesJson['dislikedFoods'] ?? []),
            preferredMealTypes: List<String>.from(
                preferencesJson['preferredMealTypes'] ??
                    ['breakfast', 'lunch', 'dinner']),
          );
        }

        return MealPlan(
          id: maps[i]['id'],
          date: DateTime.parse(maps[i]['date']),
          meals: meals,
          totalNutrition:
              NutritionalInfo.fromJson(jsonDecode(maps[i]['total_nutrition'])),
          preferences: preferences,
        );
      } catch (e) {
        print('Error loading meal plan ${maps[i]['id']}: $e');
        // Return a default meal plan to prevent app crash
        return MealPlan(
          id: maps[i]['id'] ?? 'error',
          date: DateTime.now(),
          meals: [],
          totalNutrition: NutritionalInfo(
            calories: 0,
            protein: 0,
            carbohydrates: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            cholesterol: 0,
          ),
          preferences: UserPreferences(
            dietaryRestrictions: [],
            allergies: [],
            dietType: 'balanced',
            dailyCalorieTarget: 2000,
            proteinGoal: 150,
            carbGoal: 250,
            fatGoal: 65,
            dislikedFoods: [],
            preferredMealTypes: ['breakfast', 'lunch', 'dinner'],
          ),
        );
      }
    });
  }

  // Clear all meal plans
  Future<void> clearAllMealPlans() async {
    final db = await database;
    await db.delete(_mealPlanTable);
  }

  // User Preferences operations
  Future<int> saveUserPreferences(UserPreferences preferences) async {
    final db = await database;
    // Clear existing preferences first
    await db.delete(_userPreferencesTable);

    return await db.insert(_userPreferencesTable, {
      'dietary_restrictions': jsonEncode(preferences.dietaryRestrictions),
      'allergies': jsonEncode(preferences.allergies),
      'diet_type': preferences.dietType,
      'daily_calorie_target': preferences.dailyCalorieTarget,
      'protein_goal': preferences.proteinGoal,
      'carb_goal': preferences.carbGoal,
      'fat_goal': preferences.fatGoal,
      'disliked_foods': jsonEncode(preferences.dislikedFoods),
      'preferred_meal_types': jsonEncode(preferences.preferredMealTypes),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<UserPreferences?> getUserPreferences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _userPreferencesTable,
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return UserPreferences(
      dietaryRestrictions:
          List<String>.from(jsonDecode(map['dietary_restrictions'])),
      allergies: List<String>.from(jsonDecode(map['allergies'])),
      dietType: map['diet_type'],
      dailyCalorieTarget: map['daily_calorie_target'],
      proteinGoal: map['protein_goal'],
      carbGoal: map['carb_goal'],
      fatGoal: map['fat_goal'],
      dislikedFoods: List<String>.from(jsonDecode(map['disliked_foods'])),
      preferredMealTypes: List<String>.from(jsonDecode(
          map['preferred_meal_types'] ?? '["breakfast", "lunch", "dinner"]')),
    );
  }

  // Analytics methods
  Future<Map<String, double>> getWeeklyNutritionSummary() async {
    final db = await database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Get analyzed meals from the past week
    final List<Map<String, dynamic>> analyzedMeals = await db.query(
      _mealAnalysisTable,
      where: 'analyzed_at >= ?',
      whereArgs: [weekAgo.toIso8601String()],
    );

    // Get meal plans from the past week
    final List<Map<String, dynamic>> mealPlans = await db.query(
      _mealPlanTable,
      where: 'date >= ?',
      whereArgs: [weekAgo.toIso8601String()],
    );

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    // Add analyzed meals nutrition
    for (final map in analyzedMeals) {
      totalCalories += map['calories'];
      totalProtein += map['protein'];
      totalCarbs += map['carbohydrates'];
      totalFat += map['fat'];
    }

    // Add planned meals nutrition
    for (final map in mealPlans) {
      try {
        final nutritionJson = jsonDecode(map['total_nutrition']);
        final nutrition = NutritionalInfo.fromJson(nutritionJson);
        totalCalories += nutrition.calories;
        totalProtein += nutrition.protein;
        totalCarbs += nutrition.carbohydrates;
        totalFat += nutrition.fat;
      } catch (e) {
        print('Error parsing meal plan nutrition: $e');
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbohydrates': totalCarbs,
      'fat': totalFat,
    };
  }

  // Get meal plan history
  Future<List<MealPlan>> getMealPlanHistory({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _mealPlanTable,
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      try {
        final mealsJson = jsonDecode(maps[i]['meals']) as List;
        final meals =
            mealsJson.map((meal) => PlannedMeal.fromJson(meal)).toList();

        final preferencesJson = jsonDecode(maps[i]['preferences']);
        UserPreferences preferences;

        try {
          preferences = UserPreferences.fromJson(preferencesJson);
        } catch (e) {
          preferences = UserPreferences(
            dietaryRestrictions:
                List<String>.from(preferencesJson['dietaryRestrictions'] ?? []),
            allergies: List<String>.from(preferencesJson['allergies'] ?? []),
            dietType: preferencesJson['dietType'] ?? 'balanced',
            dailyCalorieTarget:
                preferencesJson['dailyCalorieTarget']?.toDouble() ?? 2000.0,
            proteinGoal: preferencesJson['proteinGoal']?.toDouble() ?? 150.0,
            carbGoal: preferencesJson['carbGoal']?.toDouble() ?? 250.0,
            fatGoal: preferencesJson['fatGoal']?.toDouble() ?? 65.0,
            dislikedFoods:
                List<String>.from(preferencesJson['dislikedFoods'] ?? []),
            preferredMealTypes: List<String>.from(
                preferencesJson['preferredMealTypes'] ??
                    ['breakfast', 'lunch', 'dinner']),
          );
        }

        return MealPlan(
          id: maps[i]['id'],
          date: DateTime.parse(maps[i]['date']),
          meals: meals,
          totalNutrition:
              NutritionalInfo.fromJson(jsonDecode(maps[i]['total_nutrition'])),
          preferences: preferences,
        );
      } catch (e) {
        print('Error loading meal plan ${maps[i]['id']}: $e');
        return MealPlan(
          id: maps[i]['id'] ?? 'error',
          date: DateTime.now(),
          meals: [],
          totalNutrition: NutritionalInfo(
            calories: 0,
            protein: 0,
            carbohydrates: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            cholesterol: 0,
          ),
          preferences: UserPreferences(
            dietaryRestrictions: [],
            allergies: [],
            dietType: 'balanced',
            dailyCalorieTarget: 2000,
            proteinGoal: 150,
            carbGoal: 250,
            fatGoal: 65,
            dislikedFoods: [],
            preferredMealTypes: ['breakfast', 'lunch', 'dinner'],
          ),
        );
      }
    });
  }

  // Get daily nutrition for a specific date
  Future<Map<String, double>> getDailyNutrition(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      _mealAnalysisTable,
      where: 'analyzed_at >= ? AND analyzed_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final map in maps) {
      totalCalories += map['calories'];
      totalProtein += map['protein'];
      totalCarbs += map['carbohydrates'];
      totalFat += map['fat'];
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbohydrates': totalCarbs,
      'fat': totalFat,
    };
  }

  // Get weekly nutrition data for each day
  Future<List<Map<String, dynamic>>> getWeeklyNutritionData() async {
    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final nutrition = await getDailyNutrition(date);

      weeklyData.add({
        'date': date,
        'calories': nutrition['calories'] ?? 0.0,
        'protein': nutrition['protein'] ?? 0.0,
        'carbohydrates': nutrition['carbohydrates'] ?? 0.0,
        'fat': nutrition['fat'] ?? 0.0,
      });
    }

    return weeklyData;
  }

  // Get meal plan adherence data
  Future<Map<String, dynamic>> getMealPlanAdherence(MealPlan mealPlan) async {
    final dailyNutrition = await getDailyNutrition(mealPlan.date);
    final plannedNutrition = mealPlan.totalNutrition;

    final caloriesAdherence = plannedNutrition.calories > 0
        ? dailyNutrition['calories']! / plannedNutrition.calories
        : 0;
    final proteinAdherence = plannedNutrition.protein > 0
        ? dailyNutrition['protein']! / plannedNutrition.protein
        : 0;
    final carbAdherence = plannedNutrition.carbohydrates > 0
        ? dailyNutrition['carbohydrates']! / plannedNutrition.carbohydrates
        : 0;
    final fatAdherence = plannedNutrition.fat > 0
        ? dailyNutrition['fat']! / plannedNutrition.fat
        : 0;

    return {
      'caloriesAdherence': caloriesAdherence,
      'proteinAdherence': proteinAdherence,
      'carbAdherence': carbAdherence,
      'fatAdherence': fatAdherence,
      'overallAdherence': (caloriesAdherence +
              proteinAdherence +
              carbAdherence +
              fatAdherence) /
          4,
      'actualNutrition': dailyNutrition,
      'plannedNutrition': {
        'calories': plannedNutrition.calories,
        'protein': plannedNutrition.protein,
        'carbohydrates': plannedNutrition.carbohydrates,
        'fat': plannedNutrition.fat,
      },
    };
  }

  // Get weekly meal plans count
  Future<int> getWeeklyMealPlansCount() async {
    final db = await database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await db.query(
      _mealPlanTable,
      where: 'date >= ?',
      whereArgs: [weekAgo.toIso8601String()],
    );

    return maps.length;
  }

  // Get weekly analyzed meals count
  Future<int> getWeeklyAnalyzedMealsCount() async {
    final db = await database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await db.query(
      _mealAnalysisTable,
      where: 'analyzed_at >= ?',
      whereArgs: [weekAgo.toIso8601String()],
    );

    return maps.length;
  }
}

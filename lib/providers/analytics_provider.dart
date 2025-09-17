import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/meal_plan.dart';

class AnalyticsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  Map<String, double> _weeklyNutrition = {};
  List<MealPlan> _mealPlanHistory = [];
  List<Map<String, dynamic>> _weeklyNutritionData = [];
  Map<String, double> _todayNutrition = {};
  int _weeklyMealPlansCount = 0;
  int _weeklyAnalyzedMealsCount = 0;
  bool _isLoading = false;
  String? _error;

  Map<String, double> get weeklyNutrition => _weeklyNutrition;
  List<MealPlan> get mealPlanHistory => _mealPlanHistory;
  List<Map<String, dynamic>> get weeklyNutritionData => _weeklyNutritionData;
  Map<String, double> get todayNutrition => _todayNutrition;
  int get weeklyMealPlansCount => _weeklyMealPlansCount;
  int get weeklyAnalyzedMealsCount => _weeklyAnalyzedMealsCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWeeklyNutrition() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weeklyNutrition = await _databaseService.getWeeklyNutritionSummary();
    } catch (e) {
      _error = 'Failed to load nutrition data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMealPlanHistory() async {
    try {
      _mealPlanHistory = await _databaseService.getMealPlanHistory(limit: 20);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load meal plan history: $e';
      notifyListeners();
    }
  }

  Future<void> loadWeeklyNutritionData() async {
    try {
      _weeklyNutritionData = await _databaseService.getWeeklyNutritionData();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load weekly nutrition data: $e';
      notifyListeners();
    }
  }

  Future<void> loadTodayNutrition() async {
    try {
      _todayNutrition =
          await _databaseService.getDailyNutrition(DateTime.now());
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load today\'s nutrition: $e';
      notifyListeners();
    }
  }

  Future<void> loadWeeklyCounts() async {
    try {
      _weeklyMealPlansCount = await _databaseService.getWeeklyMealPlansCount();
      _weeklyAnalyzedMealsCount =
          await _databaseService.getWeeklyAnalyzedMealsCount();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load weekly counts: $e';
      notifyListeners();
    }
  }

  Future<void> loadAllAnalyticsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadWeeklyNutrition(),
        loadMealPlanHistory(),
        loadWeeklyNutritionData(),
        loadTodayNutrition(),
        loadWeeklyCounts(),
      ]);
    } catch (e) {
      _error = 'Failed to load analytics data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getMealPlanAdherence(MealPlan mealPlan) async {
    try {
      return await _databaseService.getMealPlanAdherence(mealPlan);
    } catch (e) {
      _error = 'Failed to load meal plan adherence: $e';
      notifyListeners();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

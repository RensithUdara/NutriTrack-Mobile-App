import 'package:flutter/foundation.dart';
import '../models/meal_plan.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';

class MealPlanningProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final DatabaseService _databaseService = DatabaseService();

  List<MealPlan> _mealPlans = [];
  UserPreferences? _userPreferences;
  bool _isLoading = false;
  String? _error;

  List<MealPlan> get mealPlans => _mealPlans;
  UserPreferences? get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMealPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mealPlans = await _databaseService.getAllMealPlans();
    } catch (e) {
      _error = 'Failed to load meal plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPreferences() async {
    try {
      _userPreferences = await _databaseService.getUserPreferences();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user preferences: $e';
      notifyListeners();
    }
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.saveUserPreferences(preferences);
      _userPreferences = preferences;

      await loadMealPlans();
    } catch (e) {
      _error = 'Failed to save user preferences: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateMealPlan() async {
    if (_userPreferences == null) {
      _error = 'Please set your preferences first';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mealPlan = await _geminiService.generateMealPlan(_userPreferences!);
      await _databaseService.insertMealPlan(mealPlan);
      _mealPlans.insert(0, mealPlan);
    } catch (e) {
      _error = 'Failed to generate meal plan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateMealPlanWithPreferences(
      UserPreferences preferences) async {
    print('Provider: Starting meal plan generation with preferences');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Provider: Calling Gemini service...');
      final mealPlan = await _geminiService.generateMealPlan(preferences);
      print('Provider: Gemini service completed, saving to database...');
      await _databaseService.insertMealPlan(mealPlan);
      print('Provider: Database save completed, updating UI...');
      _mealPlans.insert(0, mealPlan);
      print('Provider: Meal plan generation completed successfully');
    } catch (e) {
      print('Provider: Error occurred: $e');
      _error = 'Failed to generate meal plan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> clearAllMealPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.clearAllMealPlans();
      _mealPlans.clear();
    } catch (e) {
      _error = 'Failed to clear meal plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

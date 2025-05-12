import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterService extends ChangeNotifier {
  int _steps = 0;
  int _dailyGoal = 10000;
  DateTime? _lastResetDate;
  String _status = 'stopped';
  Stream<StepCount>? _stepCountStream;
  late SharedPreferences _prefs;

  StepCounterService() {
    _initPrefs();
  }

  int get steps => _steps;
  int get dailyGoal => _dailyGoal;
  String get status => _status;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSteps();
    _loadGoal();
    _checkForDailyReset();
  }

  Future<void> _loadSteps() async {
    _steps = _prefs.getInt('steps') ?? 0;
    final lastResetString = _prefs.getString('lastResetDate');
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    }
    notifyListeners();
  }

  Future<void> _loadGoal() async {
    _dailyGoal = _prefs.getInt('dailyGoal') ?? 10000;
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _prefs.setInt('dailyGoal', goal);
    notifyListeners();
  }

  Future<void> _saveSteps() async {
    await _prefs.setInt('steps', _steps);
    await _prefs.setString('lastResetDate', DateTime.now().toIso8601String());
  }

  Future<void> _checkForDailyReset() async {
    if (_lastResetDate == null) {
      _lastResetDate = DateTime.now();
      await _prefs.setString('lastResetDate', _lastResetDate!.toIso8601String());
      return;
    }

    final now = DateTime.now();
    final lastMidnight = DateTime(now.year, now.month, now.day);
    final resetMidnight = DateTime(
      _lastResetDate!.year,
      _lastResetDate!.month,
      _lastResetDate!.day,
    );

    if (lastMidnight.isAfter(resetMidnight)) {
      // New day, reset steps
      _steps = 0;
      _lastResetDate = now;
      await _saveSteps();
      notifyListeners();
    }
  }

  void startCounting() {
    _setupPedometer();
    _status = 'counting';
    notifyListeners();
  }

  void stopCounting() {
    _status = 'stopped';
    notifyListeners();
  }

  void _setupPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    // For now, just incrementing steps by 1 for demo purposes
    // In a real app, would need to handle step count differences properly
    _steps = event.steps;
    
    _saveSteps();
    notifyListeners();
  }

  void _onStepCountError(error) {
    _status = 'error: $error';
    debugPrint('Step counter error: $error');
    notifyListeners();
  }

  // For testing or manual entry
  void addSteps(int count) {
    _steps += count;
    _saveSteps();
    notifyListeners();
  }

  void resetSteps() {
    _steps = 0;
    _saveSteps();
    notifyListeners();
  }
} 
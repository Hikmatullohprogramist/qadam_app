import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinService extends ChangeNotifier {
  int _coins = 0;
  int _todayEarned = 0;
  int _stepsPerCoin = 100; // Number of steps needed for 1 coin
  int _dailyCoinLimit = 100; // Maximum coins per day
  DateTime? _lastResetDate;
  late SharedPreferences _prefs;

  CoinService() {
    _initPrefs();
  }

  int get coins => _coins;
  int get todayEarned => _todayEarned;
  int get stepsPerCoin => _stepsPerCoin;
  int get dailyCoinLimit => _dailyCoinLimit;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCoins();
    await _checkForDailyReset();
  }

  Future<void> _loadCoins() async {
    _coins = _prefs.getInt('coins') ?? 0;
    _todayEarned = _prefs.getInt('todayEarned') ?? 0;
    final lastResetString = _prefs.getString('coinLastResetDate');
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    }
    notifyListeners();
  }

  Future<void> _saveCoins() async {
    await _prefs.setInt('coins', _coins);
    await _prefs.setInt('todayEarned', _todayEarned);
    await _prefs.setString('coinLastResetDate', DateTime.now().toIso8601String());
  }

  Future<void> _checkForDailyReset() async {
    if (_lastResetDate == null) {
      _lastResetDate = DateTime.now();
      await _prefs.setString('coinLastResetDate', _lastResetDate!.toIso8601String());
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
      // New day, reset today's earned coins
      _todayEarned = 0;
      _lastResetDate = now;
      await _saveCoins();
      notifyListeners();
    }
  }

  // Add coins based on steps - called when steps are updated
  Future<int> addCoinsFromSteps(int steps) async {
    if (_todayEarned >= _dailyCoinLimit) {
      return 0; // Daily limit reached
    }

    int earnedCoins = (steps / _stepsPerCoin).floor();
    
    // Cap to daily limit
    if (_todayEarned + earnedCoins > _dailyCoinLimit) {
      earnedCoins = _dailyCoinLimit - _todayEarned;
    }

    if (earnedCoins > 0) {
      _coins += earnedCoins;
      _todayEarned += earnedCoins;
      await _saveCoins();
      notifyListeners();
    }

    return earnedCoins;
  }

  // Add coins from challenge or referral
  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveCoins();
    notifyListeners();
  }

  // Use coins for purchase
  Future<bool> useCoins(int amount) async {
    if (_coins < amount) {
      return false; // Not enough coins
    }

    _coins -= amount;
    await _saveCoins();
    notifyListeners();
    return true;
  }

  // For withdrawal to cash
  Future<bool> withdrawCoins(int amount) async {
    if (_coins < amount) {
      return false; // Not enough coins
    }

    // This would typically involve an API call to process the withdrawal
    // For now, just deduct the coins
    _coins -= amount;
    await _saveCoins();
    notifyListeners();
    return true;
  }

  // For adding referral bonus
  Future<void> addReferralBonus(int bonus) async {
    _coins += bonus;
    await _saveCoins();
    notifyListeners();
  }

  // Set steps per coin ratio
  Future<void> setStepsPerCoin(int steps) async {
    _stepsPerCoin = steps;
    await _prefs.setInt('stepsPerCoin', steps);
    notifyListeners();
  }

  // Set daily coin limit
  Future<void> setDailyCoinLimit(int limit) async {
    _dailyCoinLimit = limit;
    await _prefs.setInt('dailyCoinLimit', limit);
    notifyListeners();
  }
} 
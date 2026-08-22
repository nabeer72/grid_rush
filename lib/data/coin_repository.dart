import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinRepository extends GetxController {
  static const _kCoinsKey = 'grid_rush_coins_v1';

  static const int extraTimeCost = 50;
  static const int extraTimeSeconds = 30;

  final RxInt balance = 0.obs;

  SharedPreferences? _prefs;
  bool _initialized = false;

  static CoinRepository get to => Get.find<CoinRepository>();

  @override
  void onInit() {
    super.onInit();
    unawaited(ensureInitialized());
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _prefs ??= await SharedPreferences.getInstance();
    balance.value = _prefs?.getInt(_kCoinsKey) ?? 0;
    _initialized = true;
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt(_kCoinsKey, balance.value);
  }

  int get currentBalance => balance.value;

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    balance.value += amount;
    await _persist();
  }

  bool canAfford(int amount) => balance.value >= amount;

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    if (!canAfford(amount)) return false;
    balance.value -= amount;
    await _persist();
    return true;
  }

  static int coinsForLevel(int starsEarned, int difficultyScore) {
    final base = 10 + (difficultyScore ~/ 5);
    final starBonus = starsEarned * 5;
    return base + starBonus;
  }

  Future<void> resetAll() async {
    balance.value = 0;
    await _persist();
  }
}

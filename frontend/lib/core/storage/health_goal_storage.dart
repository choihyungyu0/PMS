import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HealthGoalStorage {
  const HealthGoalStorage();

  static const storageKey = 'more_cycle_health_goals';

  Future<void> saveGoalIds(List<String> goalIds) async {
    final prefs = await SharedPreferences.getInstance();
    final uniqueGoalIds = <String>[];
    for (final goalId in goalIds) {
      if (!uniqueGoalIds.contains(goalId)) {
        uniqueGoalIds.add(goalId);
      }
    }
    await prefs.setString(storageKey, jsonEncode(uniqueGoalIds));
  }

  Future<List<String>> readGoalIds() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(storageKey);
    if (storedValue == null || storedValue.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(storedValue);
    if (decoded is! List) {
      return const [];
    }
    return decoded.map((value) => value.toString()).toList();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/storage_provider.dart';

final introCompletedProvider =
    StateNotifierProvider<IntroCompletedNotifier, bool>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPrefsProvider);
  } catch (_) {
    // Graceful fallback when sharedPrefsProvider is uninitialized in isolated test suites
  }
  return IntroCompletedNotifier(prefs);
});

class IntroCompletedNotifier extends StateNotifier<bool> {
  final SharedPreferences? _prefs;
  static const String key = 'skilltwin_intro_completed';

  IntroCompletedNotifier(this._prefs) : super(_prefs?.getBool(key) ?? false);

  Future<void> completeIntro() async {
    state = true;
    try {
      await _prefs?.setBool(key, true);
    } catch (_) {}
  }

  Future<void> resetIntro() async {
    state = false;
    try {
      await _prefs?.remove(key);
    } catch (_) {}
  }
}

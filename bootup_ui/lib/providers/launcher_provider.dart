import 'package:flutter/foundation.dart';

enum LauncherState { inactive, booting, running, error }

class LauncherProvider with ChangeNotifier {
  // Track environment states independently by an ID string
  final Map<String, LauncherState> _states = {};
  final Map<String, String> _errorMessages = {};

  LauncherState getState(String stackId) => _states[stackId] ?? LauncherState.inactive;
  String getErrorMessage(String stackId) => _errorMessages[stackId] ?? '';

  bool isInactive(String stackId) => getState(stackId) == LauncherState.inactive;
  bool isBooting(String stackId) => getState(stackId) == LauncherState.booting;
  bool isRunning(String stackId) => getState(stackId) == LauncherState.running;
  bool isError(String stackId) => getState(stackId) == LauncherState.error;

  Future<void> bootUp(String stackId) async {
    if (getState(stackId) != LauncherState.inactive) return;
    _states[stackId] = LauncherState.booting;
    _errorMessages[stackId] = '';
    notifyListeners();

    // Mock delay for UI visual feedback (Phase 3 will replace this)
    await Future.delayed(const Duration(seconds: 3));
    _states[stackId] = LauncherState.running;
    notifyListeners();
  }

  Future<void> shutDown(String stackId) async {
    if (getState(stackId) != LauncherState.running && getState(stackId) != LauncherState.error) return;
    _states[stackId] = LauncherState.inactive;
    _errorMessages[stackId] = '';
    notifyListeners();
  }

  void triggerError(String stackId, String message) {
    _states[stackId] = LauncherState.error;
    _errorMessages[stackId] = message;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

enum LauncherState {
  inactive,
  booting,
  running,
  error,
}

class LauncherProvider with ChangeNotifier {
  LauncherState _state = LauncherState.inactive;
  String _errorMessage = '';

  LauncherState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isInactive => _state == LauncherState.inactive;
  bool get isBooting => _state == LauncherState.booting;
  bool get isRunning => _state == LauncherState.running;
  bool get isError => _state == LauncherState.error;

  /// Simulates starting the environment (inactive -> booting -> running)
  Future<void> bootUp() async {
    if (_state != LauncherState.inactive) return;

    _state = LauncherState.booting;
    _errorMessage = '';
    notifyListeners();

    // Simulate database and container startup processes
    await Future.delayed(const Duration(seconds: 3));

    _state = LauncherState.running;
    notifyListeners();
  }

  /// Simulates stopping the environment (running -> inactive)
  Future<void> shutDown() async {
    if (_state != LauncherState.running && _state != LauncherState.error) return;

    _state = LauncherState.inactive;
    _errorMessage = '';
    notifyListeners();
  }

  /// Trigger error state for testing UI alerts
  void triggerError(String message) {
    _state = LauncherState.error;
    _errorMessage = message;
    notifyListeners();
  }
}

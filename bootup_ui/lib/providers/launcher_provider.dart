import 'package:flutter/foundation.dart';
import 'package:bootup_bridge/bootup_bridge.dart';

enum LauncherState { inactive, booting, running, error }

class LauncherProvider with ChangeNotifier {
  final ContainerService _containerService = ContainerService();

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
    if (getState(stackId) != LauncherState.inactive) {
      return;
    }

    _states[stackId] = LauncherState.booting;
    _errorMessages[stackId] = '';
    notifyListeners();

    try {
      // Check if Docker is installed and running
      try {
        await _containerService.checkDockerStatus();
      } catch (e) {
        _states[stackId] = LauncherState.error;
        _errorMessages[stackId] =
            'Docker Desktop is turned off or not installed. Please launch Docker and try again.';
        notifyListeners();
        return;
      }

      // Invoke startStack on ../bootup_core
      await _containerService.startStack('../bootup_core');

      _states[stackId] = LauncherState.running;
      notifyListeners();
    } catch (e) {
      _states[stackId] = LauncherState.error;
      final errorString = e.toString();
      if (errorString.contains('PORT_CONFLICT')) {
        _errorMessages[stackId] =
            'Port Conflict Detected: Port 3000 or 27017 is already in use by another application.';
      } else {
        _errorMessages[stackId] =
            'Error: ${e.toString().replaceAll('Exception: ', '')}';
      }
      notifyListeners();
    }
  }

  Future<void> shutDown(String stackId) async {
    if (getState(stackId) != LauncherState.running &&
        getState(stackId) != LauncherState.error) {
      return;
    }

    _states[stackId] = LauncherState.booting;
    notifyListeners();

    try {
      // Invoke stopStack on ../bootup_core
      await _containerService.stopStack('../bootup_core');

      _states[stackId] = LauncherState.inactive;
      _errorMessages[stackId] = '';
      notifyListeners();
    } catch (e) {
      _states[stackId] = LauncherState.error;
      _errorMessages[stackId] =
          'Failed to stop: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    }
  }

  void triggerError(String stackId, String message) {
    _states[stackId] = LauncherState.error;
    _errorMessages[stackId] = message;
    notifyListeners();
  }
}

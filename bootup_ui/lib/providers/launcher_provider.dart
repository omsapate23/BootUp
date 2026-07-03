import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bootup_bridge/bootup_bridge.dart';
import 'package:path/path.dart' as p;

enum LauncherState { inactive, booting, running, error }

class LauncherProvider with ChangeNotifier {
  final ContainerService _containerService = ContainerService();

  // Track environment states independently by an ID string
  final Map<String, LauncherState> _states = {};
  final Map<String, String> _errorMessages = {};
  bool _isDockerAvailable = false;

  // Transaction protection lock state to prevent button flooding / race conditions
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;
  bool get isDockerAvailable => _isDockerAvailable;

  LauncherState getState(String stackId) => _states[stackId] ?? LauncherState.inactive;
  String getErrorMessage(String stackId) => _errorMessages[stackId] ?? '';

  bool isInactive(String stackId) => getState(stackId) == LauncherState.inactive;
  bool isBooting(String stackId) => getState(stackId) == LauncherState.booting;
  bool isRunning(String stackId) => getState(stackId) == LauncherState.running;
  bool isError(String stackId) => getState(stackId) == LauncherState.error;

  /// Traverses upward from the current directory to find the 'bootup_core' directory,
  /// falling back to a normalized absolute path to ensure robustness across platforms.
  String _resolveCorePath() {
    var dir = Directory.current;
    while (true) {
      final candidate = Directory(p.join(dir.path, 'bootup_core'));
      if (candidate.existsSync()) {
        return candidate.absolute.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    return Directory('../bootup_core').absolute.path;
  }

  Future<void> bootUp(String stackId) async {
    // If a transaction lock is active, discard subsequent button triggers
    if (_isProcessing || getState(stackId) != LauncherState.inactive) {
      return;
    }

    _isProcessing = true;
    _states[stackId] = LauncherState.booting;
    _errorMessages[stackId] = '';
    notifyListeners();

    try {
      // 1. Verify Docker daemon health status
      try {
        await _containerService.checkDockerStatus();
        _isDockerAvailable = true;
      } catch (e) {
        _isDockerAvailable = false;
        _states[stackId] = LauncherState.error;
        _errorMessages[stackId] =
            'Docker Desktop is turned off or not installed. Please launch Docker and try again.';
        return;
      }

      // 2. Resolve blueprint directories dynamically
      final corePath = _resolveCorePath();

      // 3. Initiate Docker Compose composition
      await _containerService.startStack(corePath);

      _states[stackId] = LauncherState.running;
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
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> shutDown(String stackId) async {
    // If a transaction lock is active, discard subsequent triggers
    if (_isProcessing) {
      return;
    }
    if (getState(stackId) != LauncherState.running &&
        getState(stackId) != LauncherState.error) {
      return;
    }

    // DEADLOCK GUARD: If Docker is unavailable and the card is in error state,
    // calling stopStack would throw and re-trap the card in an error loop.
    // Bypass the shell entirely and reset the card directly to inactive.
    if (getState(stackId) == LauncherState.error && !_isDockerAvailable) {
      _states[stackId] = LauncherState.inactive;
      _errorMessages[stackId] = '';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _states[stackId] = LauncherState.booting;
    notifyListeners();

    try {
      final corePath = _resolveCorePath();
      await _containerService.stopStack(corePath);

      _states[stackId] = LauncherState.inactive;
      _errorMessages[stackId] = '';
    } catch (e) {
      _states[stackId] = LauncherState.error;
      _errorMessages[stackId] =
          'Failed to stop: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Probes Docker availability via the system bridge and updates the
  /// reactive [isDockerAvailable] flag so the UI footer reflects real state.
  Future<void> checkSystemDependencies() async {
    try {
      await _containerService.checkDockerStatus();
      _isDockerAvailable = true;
    } catch (_) {
      _isDockerAvailable = false;
    }
    notifyListeners();
  }

  void triggerError(String stackId, String message) {
    if (_isProcessing) return;
    _states[stackId] = LauncherState.error;
    _errorMessages[stackId] = message;
    notifyListeners();
  }
}

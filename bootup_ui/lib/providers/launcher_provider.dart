import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bootup_bridge/bootup_bridge.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

enum LauncherState { inactive, booting, running, error }

class LauncherProvider with ChangeNotifier {
  final ContainerService _containerService = ContainerService();

  // Track environment states independently by an ID string
  final Map<String, LauncherState> _states = {};
  final Map<String, String> _errorMessages = {};
  bool _isDockerAvailable = false;

  final Map<String, String> _stackPorts = {
    'web_kit': '3000',
    'python_sandbox': '8888',
  };

  final Map<String, Map<String, dynamic>> _stackConfigs = {
    'web_kit': {'name': 'Full-Stack Web Dev Kit', 'port': '3000', 'includeDb': true},
    'python_sandbox': {'name': 'Python Data Science Sandbox', 'port': '8888', 'includeDb': false},
  };

  LauncherProvider() {
    _loadStackConfigs();
  }

  Map<String, dynamic> getStackConfig(String id) => _stackConfigs[id] ?? {};

  void updateStackConfig(String id, String key, dynamic value) {
    if (_stackConfigs.containsKey(id)) {
      _stackConfigs[id]![key] = value;
      _saveStackConfigs();
      notifyListeners();
    }
  }

  void _loadStackConfigs() {
    try {
      final file = File(_getConfigFilepath());
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final Map<String, dynamic> decoded = jsonDecode(content);
        decoded.forEach((key, value) {
          if (_stackConfigs.containsKey(key) && value is Map) {
            _stackConfigs[key]!.addAll(Map<String, dynamic>.from(value));
          }
        });
      }
    } catch (_) {}
  }

  void _saveStackConfigs() {
    try {
      final file = File(_getConfigFilepath());
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(_stackConfigs), flush: true);
    } catch (_) {}
  }

  String _getConfigFilepath() {
    var dir = Directory.current;
    while (true) {
      final candidate = Directory(p.join(dir.path, '.agents'));
      if (candidate.parent.existsSync()) {
        return p.join(candidate.path, 'stack_configs.json');
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    return p.join(Directory.current.path, 'stack_configs.json');
  }

  String getStackPort(String id) => _stackConfigs[id]?['port'] ?? _stackPorts[id] ?? '3000';

  // Transaction protection lock state to prevent button flooding / race conditions
  bool _isProcessing = false;

  final Map<String, String> _cpuMetrics = {};
  final Map<String, String> _memMetrics = {};
  final Map<String, Timer?> _metricsTimers = {};

  bool get isProcessing => _isProcessing;
  bool get isDockerAvailable => _isDockerAvailable;

  List<String> get activeStacks => _stackConfigs.keys.toList();

  LauncherState getState(String stackId) => _states[stackId] ?? LauncherState.inactive;
  String getErrorMessage(String stackId) => _errorMessages[stackId] ?? '';

  bool isInactive(String stackId) => getState(stackId) == LauncherState.inactive;
  bool isBooting(String stackId) => getState(stackId) == LauncherState.booting;
  bool isRunning(String stackId) => getState(stackId) == LauncherState.running;
  bool isError(String stackId) => getState(stackId) == LauncherState.error;

  String getCpuUsage(String id) => isRunning(id) ? (_cpuMetrics[id] ?? "0.0 %") : "0.0 %";
  String getMemoryUsage(String id) => isRunning(id) ? (_memMetrics[id] ?? "0 MB") : "0 MB";
  String getNetworkIo(String id) => isRunning(id) ? "12 KB / 8 KB" : "0 KB / 0 KB";
  String getDiskReadWrite(String id) => isRunning(id) ? "0 B / 4 KB" : "0 B / 0 B";

  final Map<String, String> _blueprintPaths = {
    'web_kit': '../bootup_core/blueprints/web_kit',
    'python_sandbox': '../bootup_core/blueprints/python_sandbox',
  };

  /// Traverses upward from the current directory to find the 'bootup_core' directory,
  /// falling back to a normalized absolute path to ensure robustness across platforms.
  String _resolveCorePath(String id) {
    final relativePath = _blueprintPaths[id] ?? '../bootup_core';
    var dir = Directory.current;
    while (true) {
      final candidate = Directory(p.join(dir.path, 'bootup_core'));
      if (candidate.existsSync()) {
        return p.normalize(p.absolute(p.join(dir.path, relativePath.replaceAll('../', ''))));
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    return Directory(relativePath).absolute.path;
  }

  Future<void> bootUp(String stackId) async {
    // Command injection guard check: restrict stack ID to strictly alphanumeric/underscores/dashes
    final RegExp idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!idRegex.hasMatch(stackId)) {
      _states[stackId] = LauncherState.error;
      _errorMessages[stackId] = 'Security Exception: Invalid characters in stack ID.';
      notifyListeners();
      return;
    }

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
        notifyListeners();
        return;
      }

      // 2. Resolve blueprint directories dynamically
      final corePath = _resolveCorePath(stackId);

      // 3. Initiate Docker Compose composition
      await _containerService.startStack(corePath);

      _states[stackId] = LauncherState.running;
      _startMetricsStreaming(stackId);
      notifyListeners();
      // Latency delay to ensure container sockets bind cleanly to the host network
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      _states[stackId] = LauncherState.error;
      notifyListeners();
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
    // Command injection guard check: restrict stack ID to strictly alphanumeric/underscores/dashes
    final RegExp idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!idRegex.hasMatch(stackId)) {
      return;
    }

    // If a transaction lock is active, discard subsequent triggers
    if (_isProcessing) {
      return;
    }
    if (getState(stackId) != LauncherState.running &&
        getState(stackId) != LauncherState.error) {
      return;
    }

    _metricsTimers[stackId]?.cancel();
    _metricsTimers.remove(stackId);
    _cpuMetrics.remove(stackId);
    _memMetrics.remove(stackId);

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
      final corePath = _resolveCorePath(stackId);
      await _containerService.stopStack(corePath);

      _states[stackId] = LauncherState.inactive;
      _errorMessages[stackId] = '';
      notifyListeners();
    } catch (e) {
      _states[stackId] = LauncherState.error;
      _errorMessages[stackId] =
          'Failed to stop: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Probes Docker availability via the system bridge and updates the
  /// reactive [isDockerAvailable] flag so the UI footer reflects real state.
  /// Also checks for orphan containers left running from previous sessions to sync UI.
  Future<void> checkSystemDependencies() async {
    try {
      await _containerService.checkDockerStatus();
      _isDockerAvailable = true;

      final result = await Process.run('docker', ['ps', '--format', '{{.Names}}']);
      if (result.exitCode == 0) {
        final names = result.stdout.toString();
        if (names.contains('bootup_workspace_editor') || names.contains('bootup_node_workspace')) {
          _states['web_kit'] = LauncherState.running;
          _startMetricsStreaming('web_kit');
        }
        if (names.contains('bootup_python_notebook')) {
          _states['python_sandbox'] = LauncherState.running;
          _startMetricsStreaming('python_sandbox');
        }
      }
    } catch (_) {
      _isDockerAvailable = false;
    }
    notifyListeners();
  }

  /// Launches a URL using the host platform's default web browser.
  Future<void> launchSystemBrowser(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch system browser for $urlString');
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }

  void triggerError(String stackId, String message) {
    if (_isProcessing) return;
    _states[stackId] = LauncherState.error;
    _errorMessages[stackId] = message;
    notifyListeners();
  }

  final Map<String, String> _mainContainers = {
    'web_kit': 'bootup_node_workspace',
    'python_sandbox': 'bootup_python_notebook',
  };

  void _startMetricsStreaming(String stackId) {
    _metricsTimers[stackId]?.cancel();
    _metricsTimers[stackId] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!isRunning(stackId)) {
        timer.cancel();
        _metricsTimers.remove(stackId);
        return;
      }
      try {
        final containerName = _mainContainers[stackId] ?? 'bootup_node_workspace';
        final process = await Process.run('docker', ['stats', containerName, '--no-stream', '--format', '{{.CPUPerc}}|{{.MemUsage}}']);
        if (process.exitCode == 0) {
          final output = process.stdout.toString().trim();
          final parts = output.split('|');
          if (parts.length >= 2) {
            _cpuMetrics[stackId] = parts[0];
            _memMetrics[stackId] = parts[1];
            notifyListeners();
          }
        }
      } catch (_) {}
    });
  }

  Stream<String> streamLogs(String stackId) {
    // Command injection guard check: restrict stack ID to strictly alphanumeric/underscores/dashes
    final RegExp idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!idRegex.hasMatch(stackId)) {
      return const Stream.empty();
    }

    final corePath = _resolveCorePath(stackId);
    return _containerService.streamContainerLogs(corePath);
  }

  @override
  void dispose() {
    for (final timer in _metricsTimers.values) {
      timer?.cancel();
    }
    _metricsTimers.clear();
    super.dispose();
  }
}

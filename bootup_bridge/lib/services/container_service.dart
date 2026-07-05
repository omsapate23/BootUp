import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class ContainerService {
  /// Resolves the absolute path to the `.agents/logs/` directory,
  /// traversing up from the current directory if necessary, and ensures it exists.
  String _getLogsDirectory() {
    var dir = Directory.current;
    while (true) {
      final candidate = Directory(p.join(dir.path, '.agents', 'logs'));
      if (candidate.parent.existsSync()) {
        candidate.createSync(recursive: true);
        return candidate.absolute.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    // Fallback to current working directory subfolder
    final fallback = Directory(p.join(Directory.current.path, '.agents', 'logs'));
    fallback.createSync(recursive: true);
    return fallback.absolute.path;
  }

  /// Appends a telemetry message to `telemetry.log`.
  void _logEvent(String event, {String? details}) {
    try {
      final logsDir = _getLogsDirectory();
      final logFile = File(p.join(logsDir, 'telemetry.log'));
      final timestamp = DateTime.now().toIso8601String();
      logFile.writeAsStringSync(
        '[$timestamp] $event${details != null ? "\nDetails:\n$details" : ""}\n\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Silently ignore log write errors in sandboxed/restricted desktop runners
    }
  }

  /// Dumps structured process details to a persistent file upon startup failure.
  void _dumpErrorDiagnostics(String command, String workingDir, int exitCode, String stdout, String stderr) {
    try {
      final logsDir = _getLogsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final diagFile = File(p.join(logsDir, 'initialization_error_$timestamp.log'));

      final report = '''
Timestamp: ${DateTime.now().toIso8601String()}
Command: $command
Working Directory: $workingDir
Exit Code: $exitCode

=== STDOUT ===
$stdout

=== STDERR ===
$stderr
''';

      diagFile.writeAsStringSync(report, flush: true);

      // Append to the aggregated error diagnostics log file
      final generalDiagFile = File(p.join(logsDir, 'error_diagnostics.log'));
      generalDiagFile.writeAsStringSync(
        '========================================\n$report\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Silently ignore telemetry failure details
    }
  }

  /// Checks whether Docker is installed and the Docker daemon is running.
  /// Throws a recognizable error if it is not running.
  Future<bool> checkDockerStatus() async {
    _logEvent('Running Docker daemon health check...');
    try {
      final result = await Process.run('docker', ['info']);
      if (result.exitCode != 0) {
        _logEvent('Docker daemon health check failed (daemon not running).');
        throw ProcessException(
          'docker',
          ['info'],
          'Docker daemon is not running. Please start Docker Desktop or ensure it is running in your background services.',
          result.exitCode,
        );
      }
      _logEvent('Docker daemon health check passed.');
      return true;
    } on ProcessException catch (e) {
      _logEvent('Docker check failed: executable not found or errored.', details: e.toString());
      throw ProcessException(
        e.executable,
        e.arguments,
        'Docker command failed: ${e.message}',
        e.errorCode,
      );
    } catch (e) {
      _logEvent('Docker health check failed with structural error.', details: e.toString());
      throw Exception(
        'Docker command not found or not running in system path. Please verify that Docker Desktop is installed and added to system variables. Error detail: $e',
      );
    }
  }

  /// Spins up a docker-compose environment in the targeted folder.
  /// Intercepts and parses stderr for port conflict errors (e.g. ports 3000 or 27017).
  Future<void> startStack(String stackPath, {Map<String, String>? environment}) async {
    final absoluteStackPath = p.absolute(p.normalize(stackPath));
    _logEvent('Starting Docker stack composition: $absoluteStackPath');

    try {
      final process = await Process.start(
        'docker',
        ['compose', 'up', '-d', '--force-recreate'],
        workingDirectory: absoluteStackPath,
        environment: environment,
      );

      final stderrBuffer = StringBuffer();
      final stdoutBuffer = StringBuffer();

      process.stderr.transform(utf8.decoder).listen((data) {
        stderrBuffer.write(data);
      });

      process.stdout.transform(utf8.decoder).listen((data) {
        stdoutBuffer.write(data);
      });

      final exitCode = await process.exitCode;
      final stdoutMsg = stdoutBuffer.toString();
      final stderrMsg = stderrBuffer.toString();

      if (exitCode != 0) {
        _logEvent('Stack startup failed for: $absoluteStackPath', details: stderrMsg);
        _dumpErrorDiagnostics(
          'docker compose up -d',
          absoluteStackPath,
          exitCode,
          stdoutMsg,
          stderrMsg,
        );

        if (stderrMsg.contains('port is already allocated') ||
            stderrMsg.contains('address already in use') ||
            stderrMsg.contains('Ports are not available')) {
          throw Exception(
            'PORT_CONFLICT: Port 3000 or 27017 is already in use by another local application. Please stop the conflicting service and try again.',
          );
        }
        throw Exception(
          'Failed to start Docker Compose environment (Exit code: $exitCode). Error: $stderrMsg',
        );
      }

      _logEvent('Stack startup completed successfully for: $absoluteStackPath');
    } catch (e) {
      if (e is! Exception) {
        throw Exception(e.toString());
      }
      rethrow;
    }
  }

  /// Shuts down the docker-compose environment in the targeted folder.
  Future<void> stopStack(String stackPath) async {
    final absoluteStackPath = p.absolute(p.normalize(stackPath));
    _logEvent('Stopping Docker stack composition: $absoluteStackPath');

    try {
      final process = await Process.start(
        'docker',
        ['compose', 'down'],
        workingDirectory: absoluteStackPath,
      );

      final stderrBuffer = StringBuffer();

      process.stderr.transform(utf8.decoder).listen((data) {
        stderrBuffer.write(data);
      });

      final exitCode = await process.exitCode;
      final stderrMsg = stderrBuffer.toString();

      if (exitCode != 0) {
        _logEvent('Stack teardown failed for: $absoluteStackPath', details: stderrMsg);
        throw Exception(
          'Failed to stop Docker Compose environment (Exit code: $exitCode). Error: $stderrMsg',
        );
      }

      _logEvent('Stack teardown completed successfully for: $absoluteStackPath');
    } catch (e) {
      if (e is! Exception) {
        throw Exception(e.toString());
      }
      rethrow;
    }
  }

  Future<String> queryContainerStats() async {
    try {
      final process = await Process.run('docker', ['stats', '--no-stream', '--format', '{{.CPUPerc}}|{{.MemUsage}}']);
      if (process.exitCode == 0) return process.stdout.toString().trim();
    } catch (_) {}
    return "0.0%|0MB";
  }

  Stream<String> streamContainerLogs(String corePath) {
    final controller = StreamController<String>();
    final buffer = StringBuffer();
    Process.start('docker', ['compose', 'logs', '-f', '--tail=100'], workingDirectory: corePath).then((process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        buffer.write(data);
        controller.add(buffer.toString());
      });
      process.stderr.transform(utf8.decoder).listen((data) {
        buffer.write(data);
        controller.add(buffer.toString());
      });
    });
    return controller.stream;
  }
}

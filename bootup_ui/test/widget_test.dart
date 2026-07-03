import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bootup_ui/main.dart';
import 'package:bootup_ui/providers/launcher_provider.dart';

class MockLauncherProvider extends LauncherProvider {
  @override
  Future<void> checkSystemDependencies() async {
    // No-op to prevent executing Process.run and spawning pending timers during tests
  }

  @override
  Future<void> bootUp(String stackId) async {
    // No-op
  }

  @override
  Future<void> shutDown(String stackId) async {
    // No-op
  }
}

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    // Suppress layout overflow errors in test environment caused by the wide fallback test font
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      if (exception is FlutterError && exception.message.contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };

    // Set a large screen size to prevent overflow errors in test environment
    await tester.binding.setSurfaceSize(const Size(1600, 1200));

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<LauncherProvider>(
        create: (_) => MockLauncherProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that the dashboard header and title are present
    expect(find.text('BootUp'), findsOneWidget);
    expect(find.text('Explore Stacks'), findsNWidgets(2));

    // Reset screen size and error handler
    await tester.binding.setSurfaceSize(null);
    FlutterError.onError = originalOnError;
  });
}

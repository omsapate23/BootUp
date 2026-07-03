import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/launcher_provider.dart';

class StackCard extends StatefulWidget {
  final String title;
  final String description;
  final List<String> techBadges;

  const StackCard({
    super.key,
    required this.title,
    required this.description,
    required this.techBadges,
  });

  @override
  State<StackCard> createState() => _StackCardState();
}

class _StackCardState extends State<StackCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final launcher = context.watch<LauncherProvider>();

    // Determine colors and status texts based on launcher state
    Color statusColor;
    String statusText;
    Widget statusIndicator;

    switch (launcher.state) {
      case LauncherState.inactive:
        statusColor = Colors.grey;
        statusText = 'Idle';
        statusIndicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        );
        break;
      case LauncherState.booting:
        statusColor = Colors.amber;
        statusText = 'Booting...';
        statusIndicator = AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 12 + (_pulseController.value * 6),
              height: 12 + (_pulseController.value * 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(1.0 - (_pulseController.value * 0.4)),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5 * _pulseController.value),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        );
        break;
      case LauncherState.running:
        statusColor = const Color(0xFF00FF66); // Neon green
        statusText = 'Active';
        statusIndicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF00FF66),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00FF66),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );
        break;
      case LauncherState.error:
        statusColor = Colors.redAccent;
        statusText = 'Error';
        statusIndicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C2C35),
            const Color(0xFF1E1E24),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Title & Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      statusIndicator,
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            // Technology Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.techBadges.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tech,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            // Error Alert Overlay if state is Error
            if (launcher.isError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          launcher.errorMessage.isNotEmpty
                              ? launcher.errorMessage
                              : 'Port 3000 conflicts with another service.',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Big Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: launcher.isRunning 
                      ? const Color(0xFFFF3B30) // Red
                      : const Color(0xFF6C63FF), // Neon Purple
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: launcher.isBooting
                    ? null
                    : () {
                        if (launcher.isRunning || launcher.isError) {
                          launcher.shutDown();
                        } else {
                          launcher.bootUp();
                        }
                      },
                child: launcher.isBooting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        launcher.isRunning || launcher.isError ? 'Shut Down' : 'Boot Up',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/launcher_provider.dart';

class TechPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light grey thin diagonal lines
    final greyPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 24) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        greyPaint,
      );
    }

    // Sharp green subtle accent diagonal lines
    final greenPaint = Paint()
      ..color = const Color(0xFF00C853).withOpacity(0.03)
      ..strokeWidth = 1.5;

    for (double i = -size.height; i < size.width; i += 96) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        greenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

    // Determine status values based on state
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
        statusColor = const Color(0xFF00C853); // Sharp green
        statusText = 'Active';
        statusIndicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF00C853),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00C853),
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
        color: const Color(0xFF212121), // Charcoal grey card background
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5),
        child: Stack(
          children: [
            // High-tech abstract diagonal linear patterns background
            Positioned.fill(
              child: CustomPaint(
                painter: TechPatternPainter(),
              ),
            ),
            Padding(
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
                      // Status Badge with glowing outlining active states
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: launcher.isRunning
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00C853).withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
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
                          color: const Color(0xFF004D40), // Deep green background
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00C853).withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tech,
                          style: const TextStyle(
                            color: Colors.white, // Sharp white text
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
                  // Big Action Button with Glowing Border and Dark Background
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: (launcher.isRunning || launcher.isBooting)
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00C853).withOpacity(0.18),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF333333), // Dark grey button background
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFF00C853).withOpacity(0.4), // Subtle green glowing accent outline
                              width: 1.5,
                            ),
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
                        icon: launcher.isBooting
                            ? const SizedBox.shrink()
                            : Icon(
                                launcher.isRunning || launcher.isError ? Icons.stop : Icons.play_arrow,
                                color: Colors.white, // Clean white icon
                                size: 18,
                              ),
                        label: launcher.isBooting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                launcher.isRunning || launcher.isError ? 'SHUT DOWN' : 'BOOT UP NOW',
                                style: const TextStyle(
                                  color: Colors.white, // Clean white text
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

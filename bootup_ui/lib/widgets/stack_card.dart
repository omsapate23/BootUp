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

    // Sharp azure blue subtle accent diagonal lines
    final greenPaint = Paint()
      ..color = const Color(0xFF007BFF).withOpacity(0.03)
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
  final String id;
  final String title;
  final String description;
  final List<String> techBadges;

  const StackCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.techBadges,
  });

  @override
  State<StackCard> createState() => _StackCardState();
}

class _StackCardState extends State<StackCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<Map<String, dynamic>> _visibleLogs = [];
  bool _isLogAnimationRunning = false;

  void _startLogAnimation() {
    if (_isLogAnimationRunning) return;
    _isLogAnimationRunning = true;
    _visibleLogs.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _visibleLogs.add({
          'text': '[BOOTUP] Attaching to container system runtime...',
          'color': const Color(0xFF007BFF),
        });
      });
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        final port = context.read<LauncherProvider>().getStackPort(widget.id);
        _visibleLogs.add({
          'text': '[NODE] Express server initialized on container port $port.',
          'color': const Color(0xFF28A745),
        });
      });
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _visibleLogs.add({
          'text': '[MONGO] Connection to isolated database context established.',
          'color': const Color(0xFFFFC107),
        });
      });
    });
  }

  void _showConfigDrawer(BuildContext context, LauncherProvider launcher) {
    final config = launcher.getStackConfig(widget.id);
    final nameController = TextEditingController(text: config['name'] ?? widget.title);
    final portController = TextEditingController(text: config['port'] ?? launcher.getStackPort(widget.id));
    bool includeDb = config['includeDb'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configure ${widget.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white60),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Display Name Field
                  const Text(
                    'Environment Display Name',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter custom name',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF2D2D2D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      launcher.updateStackConfig(widget.id, 'name', val);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Host Port Field
                  const Text(
                    'Host Connection Port',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter host port (e.g. 3000)',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF2D2D2D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      launcher.updateStackConfig(widget.id, 'port', val);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Include DB Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Isolated Database Container',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Includes MongoDB/PostgreSQL in runtime.',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: includeDb,
                        activeColor: const Color(0xFF007BFF),
                        onChanged: (val) {
                          setModalState(() {
                            includeDb = val;
                          });
                          launcher.updateStackConfig(widget.id, 'includeDb', val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
    final isRunning = launcher.isRunning(widget.id);
    if (isRunning) {
      if (!_isLogAnimationRunning) {
        _startLogAnimation();
      }
    } else {
      _isLogAnimationRunning = false;
      _visibleLogs.clear();
    }

    // Determine status values based on state
    Color statusColor;
    String statusText;
    Widget statusIndicator;

    switch (launcher.getState(widget.id)) {
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
        statusColor = const Color(0xFF007BFF); // Sharp azure blue
        statusText = 'Active';
        statusIndicator = const Icon(
          Icons.check,
          color: Color(0xFF007BFF),
          size: 14,
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
                          launcher.getStackConfig(widget.id)['name'] ?? widget.title,
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
                          boxShadow: launcher.isRunning(widget.id)
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF007BFF).withOpacity(0.2),
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
                      const SizedBox(width: 8),
                      // Settings Gear Icon button
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                        tooltip: 'Configure stack',
                        onPressed: launcher.isInactive(widget.id)
                            ? () => _showConfigDrawer(context, launcher)
                            : null,
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
                          color: const Color(0xFF004080), // Deep azure blue background
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF007BFF).withOpacity(0.15),
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
                  if (launcher.isRunning(widget.id)) ...[
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _visibleLogs.length,
                        itemBuilder: (context, index) {
                          final log = _visibleLogs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: _buildLogLine(log['text'], log['color']),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Error Alert Overlay if state is Error
                  if (launcher.isError(widget.id))
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
                                launcher.getErrorMessage(widget.id).isNotEmpty
                                    ? launcher.getErrorMessage(widget.id)
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
                  // Optional secondary action: Open Workspace (only when running)
                  if (launcher.isRunning(widget.id)) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF007BFF),
                          side: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          launcher.launchSystemBrowser('http://localhost:${launcher.getStackPort(widget.id)}');
                        },
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text(
                          'OPEN WORKSPACE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Big Action Button with Glowing Border and Dark Background
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: (launcher.isRunning(widget.id) || launcher.isBooting(widget.id))
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF007BFF).withOpacity(0.18),
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
                              // Dim to red tint when dependency is missing, azure blue otherwise
                              color: (!launcher.isDockerAvailable && launcher.isInactive(widget.id))
                                  ? Colors.redAccent.withOpacity(0.3)
                                  : const Color(0xFF007BFF).withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Disable button entirely if Docker is missing and card is idle
                        onPressed: (!launcher.isDockerAvailable && launcher.isInactive(widget.id))
                            ? null
                            : launcher.isBooting(widget.id)
                                ? null
                                : () {
                                    if (launcher.isRunning(widget.id) || launcher.isError(widget.id)) {
                                      launcher.shutDown(widget.id);
                                    } else {
                                      launcher.bootUp(widget.id);
                                    }
                                  },
                        icon: launcher.isBooting(widget.id)
                            ? const SizedBox.shrink()
                            : Icon(
                                launcher.isRunning(widget.id) || launcher.isError(widget.id)
                                    ? Icons.stop
                                    : (!launcher.isDockerAvailable && launcher.isInactive(widget.id))
                                        ? Icons.block
                                        : Icons.play_arrow,
                                color: Colors.white, // Clean white icon
                                size: 18,
                              ),
                        label: launcher.isBooting(widget.id)
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                launcher.isRunning(widget.id) || launcher.isError(widget.id)
                                    ? 'SHUT DOWN'
                                    : (!launcher.isDockerAvailable && launcher.isInactive(widget.id))
                                        ? 'DEPENDENCY MISSING'
                                        : 'BOOT UP NOW',
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

  Widget _buildLogLine(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> ',
          style: TextStyle(
            color: color,
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

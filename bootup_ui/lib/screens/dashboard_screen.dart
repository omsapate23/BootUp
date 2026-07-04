import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/launcher_provider.dart';
import '../widgets/stack_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    // Probe Docker availability immediately on launch so the footer is accurate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LauncherProvider>(context, listen: false).checkSystemDependencies();
    });
  }

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'label': 'Explore Stacks',
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore,
    },
    {
      'label': 'Active Environments',
      'icon': Icons.dashboard_customize_outlined,
      'activeIcon': Icons.dashboard_customize,
    },
    {
      'label': 'Settings',
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final launcher = context.watch<LauncherProvider>();
    final isRunning = launcher.isRunning('web_kit');

    Widget rightContent;
    if (_selectedNavigationIndex == 0) {
      rightContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _navigationItems[_selectedNavigationIndex]['label'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Launch your workspace with one click. No system configuration required.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // Quick action button to trigger mock error states (for debugging UI guardrails)
                IconButton(
                  tooltip: 'Simulate Environment Error (Port Conflict)',
                  icon: Icon(
                    Icons.bug_report_outlined,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  onPressed: () {
                    launcher.triggerError('web_kit', 'Port 3000 is occupied.');
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Dashboard Content Grid based on selection
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Dynamically adjust columns based on desktop viewport width
                  final columns = constraints.maxWidth > 800 ? 2 : 1;
                  final hasRunning = launcher.isRunning('web_kit');
                  final aspectRatio = hasRunning ? 0.95 : 1.35;
                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: aspectRatio,
                    children: const [
                      StackCard(
                        id: 'web_kit',
                        title: 'Full-Stack Web Dev Kit',
                        description: 'A complete Node.js app environment paired with a MongoDB database, running fully containerized inside isolated workspace borders.',
                        techBadges: ['NodeJS 20', 'Express', 'MongoDB 6.0', 'Mongoose'],
                      ),
                      // Placeholder stack cards for premium tiers
                      Opacity(
                        opacity: 0.5,
                        child: AbsorbPointer(
                          child: StackCard(
                            id: 'python_sandbox',
                            title: 'Python Data Science Kit',
                            description: 'Pre-configured Python Jupyter Notebook bundled with NumPy, Pandas, Matplotlib, and PostgreSQL databases.',
                            techBadges: ['Python 3.11', 'Jupyter', 'PostgreSQL 15', 'Pandas'],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (_selectedNavigationIndex == 1) {
      if (isRunning) {
        rightContent = _buildActiveWorkspaceCanvas(context, 'web_kit');
      } else {
        rightContent = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Colors.white.withOpacity(0.15),
              ),
              const SizedBox(height: 16),
              const Text(
                'No environments are currently running.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Head over to Explore Stacks to boot your workspace.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      rightContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_suggest,
              size: 64,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            const Text(
              'Settings Screen Placeholder',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Row(
        children: [
          // Left Sidebar (Navigation Rail)
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Application Brand Logo Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007BFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF007BFF).withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: Color(0xFF007BFF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'BootUp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sidebar items
                Expanded(
                  child: ListView.builder(
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _selectedNavigationIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedNavigationIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF007BFF).withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF007BFF).withOpacity(0.15),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icon(
                                  isSelected ? item['activeIcon'] : item['icon'],
                                  color: isSelected 
                                      ? const Color(0xFF007BFF) 
                                      : Colors.white.withOpacity(0.6),
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    color: isSelected 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                if (index == 1 && launcher.isRunning('web_kit'))
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF007BFF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Footer (Version & Status indicators)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: launcher.isDockerAvailable
                                  ? const Color(0xFF007BFF)
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            launcher.isDockerAvailable
                                ? 'Docker Daemon Active'
                                : 'Docker Dependency Missing',
                            style: TextStyle(
                              color: launcher.isDockerAvailable
                                  ? Colors.white70
                                  : Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'v1.0.0 (BETA)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right Content Area
          Expanded(
            child: rightContent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildActiveWorkspaceCanvas(BuildContext context, String stackId) {
    final launcher = Provider.of<LauncherProvider>(context);
    final port = launcher.getStackPort(stackId);
    
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Top bar: A dark charcoal control panel banner
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  color: Colors.white.withOpacity(0.6),
                  tooltip: 'Back to catalog',
                  onPressed: () {
                    setState(() {
                      _selectedNavigationIndex = 0;
                    });
                  },
                ),
                const SizedBox(width: 16),
                Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.3), size: 20),
                const SizedBox(width: 24),
                // Mock Address Bar
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.greenAccent, size: 14),
                        const SizedBox(width: 10),
                        Text(
                          'http://localhost:$port',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Spacer(),
                        // Blue refresh trailing button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              launcher.launchSystemBrowser('http://localhost:$port');
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.refresh,
                                color: Color(0xFF007BFF),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Prominent red "STOP ENVIRONMENT" action icon
                IconButton(
                  icon: const Icon(Icons.stop_circle, size: 28),
                  color: Colors.redAccent,
                  tooltip: 'STOP ENVIRONMENT',
                  onPressed: () {
                    launcher.shutDown(stackId);
                  },
                ),
              ],
            ),
          ),
          // Main content body below the banner: A split panel layout
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side: Container Health Metrics Placeholders
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF212121),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, color: Color(0xFF007BFF), size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Container Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildStatRow('CPU Usage', launcher.getCpuUsage(stackId), Icons.memory, Colors.greenAccent),
                        const SizedBox(height: 16),
                        _buildStatRow('Memory Usage', launcher.getMemoryUsage(stackId), Icons.storage, Colors.blueAccent),
                        const SizedBox(height: 16),
                        _buildStatRow('Network IO', launcher.getNetworkIo(stackId), Icons.swap_calls, Colors.purpleAccent),
                        const SizedBox(height: 16),
                        _buildStatRow('Disk Read/Write', launcher.getDiskReadWrite(stackId), Icons.save_alt, Colors.orangeAccent),
                        const Spacer(),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'All systems healthy',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right side: Large central developer view panel representing our running code workspace area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.5),
                        child: Container(
                          color: const Color(0xFF1E1E1E),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007BFF).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF007BFF).withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.code_rounded,
                                        color: Color(0xFF007BFF),
                                        size: 48,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Full-Stack Developer Kit Running',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your web application workspace is ready.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    StreamBuilder<String>(
                                      stream: launcher.streamLogs(stackId),
                                      builder: (context, snapshot) {
                                        final logs = snapshot.data ?? 'Initializing container logs stream...\n';
                                        return Container(
                                          height: 220,
                                          width: 600,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0C0C0F),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.08),
                                              width: 1.5,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: SingleChildScrollView(
                                            reverse: true,
                                            child: Text(
                                              logs,
                                              style: const TextStyle(
                                                color: Color(0xFF33FF33),
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => launcher.launchSystemBrowser('http://localhost:8443'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007BFF).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.3)),
                                      ),
                                      child: const Text(
                                        'LIVE WORKSPACE',
                                        style: TextStyle(
                                          color: Color(0xFF007BFF),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

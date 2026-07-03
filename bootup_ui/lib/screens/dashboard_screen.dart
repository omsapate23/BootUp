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
      context.read<LauncherProvider>().checkSystemDependencies();
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
            child: Padding(
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
                    child: _selectedNavigationIndex == 0
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              // Dynamically adjust columns based on desktop viewport width
                              final columns = constraints.maxWidth > 800 ? 2 : 1;
                              return GridView.count(
                                crossAxisCount: columns,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 1.35,
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
                          )
                        : _selectedNavigationIndex == 1
                            ? (launcher.isRunning('web_kit')
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Left side: Container Monitoring Stats Sidebar
                                      Container(
                                        width: 260,
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
                                            _buildStatRow('CPU Usage', '2.4%', Icons.memory, Colors.greenAccent),
                                            const SizedBox(height: 16),
                                            _buildStatRow('Memory Usage', '128 MB / 2.0 GB', Icons.storage, Colors.blueAccent),
                                            const SizedBox(height: 16),
                                            _buildStatRow('Network IO', '12 KB / 8 KB', Icons.swap_calls, Colors.purpleAccent),
                                            const SizedBox(height: 16),
                                            _buildStatRow('Disk Read/Write', '0 B / 4 KB', Icons.save_alt, Colors.orangeAccent),
                                            const Spacer(),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.redAccent,
                                                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  launcher.shutDown('web_kit');
                                                },
                                                icon: const Icon(Icons.power_settings_new, size: 16),
                                                label: const Text('STOP CONTAINER'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Right side: Embedded Code Sandbox Browser Shell
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF262626),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.08),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(14.5),
                                            child: Column(
                                              children: [
                                                // Browser-like Header Address Bar
                                                Container(
                                                  height: 48,
                                                  color: const Color(0xFF1F1F1F),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          _buildDot(Colors.redAccent.withOpacity(0.8)),
                                                          const SizedBox(width: 6),
                                                          _buildDot(Colors.amberAccent.withOpacity(0.8)),
                                                          const SizedBox(width: 6),
                                                          _buildDot(Colors.greenAccent.withOpacity(0.8)),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.3), size: 18),
                                                      const SizedBox(width: 12),
                                                      Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.3), size: 18),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Container(
                                                          height: 32,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF121212),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(
                                                              color: Colors.white.withOpacity(0.08),
                                                            ),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                                          alignment: Alignment.centerLeft,
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.lock, color: Colors.greenAccent, size: 12),
                                                              const SizedBox(width: 8),
                                                              Text(
                                                                'http://localhost:${launcher.getStackPort('web_kit')}',
                                                                style: TextStyle(
                                                                  color: Colors.white.withOpacity(0.8),
                                                                  fontSize: 13,
                                                                  fontFamily: 'monospace',
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Material(
                                                                color: Colors.transparent,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  borderRadius: BorderRadius.circular(4),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(4.0),
                                                                    child: Icon(
                                                                      Icons.refresh,
                                                                      color: Colors.white.withOpacity(0.6),
                                                                      size: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      IconButton(
                                                        icon: const Icon(Icons.open_in_new, size: 18),
                                                        color: const Color(0xFF007BFF),
                                                        onPressed: () {
                                                          launcher.launchSystemBrowser('http://localhost:${launcher.getStackPort('web_kit')}');
                                                        },
                                                        tooltip: 'Open in System Browser',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: const Color(0xFF1E1E1E),
                                                    width: double.infinity,
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
                                                                  size: 40,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 20),
                                                              const Text(
                                                                'Full-Stack Developer Kit Running',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
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
                                                              const SizedBox(height: 24),
                                                              Container(
                                                                width: 320,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFF121212),
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    _buildTerminalRow('Node.js Server', 'Listening on port 3000', Colors.green),
                                                                    const SizedBox(height: 6),
                                                                    _buildTerminalRow('MongoDB Database', 'Connected successfully', Colors.green),
                                                                    const SizedBox(height: 6),
                                                                    _buildTerminalRow('Hot Reload', 'Enabled and active', Colors.orangeAccent),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 16,
                                                          right: 16,
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF007BFF).withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.3)),
                                                            ),
                                                            child: const Text(
                                                              'LIVE WORKSPACE',
                                                              style: TextStyle(
                                                                color: Color(0xFF007BFF),
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                                letterSpacing: 0.5,
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      'No environments are currently running.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ))
                            : Center(
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

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTerminalRow(String component, String status, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$component: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        Expanded(
          child: Text(
            status,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

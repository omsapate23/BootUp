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
                            decoration: const BoxDecoration(
                              color: Color(0xFF007BFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Docker Ready',
                            style: TextStyle(
                              color: Colors.white70,
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
                            ? Center(
                                child: launcher.isRunning('web_kit')
                                    ? SizedBox(
                                        width: 400,
                                        height: 300,
                                        child: StackCard(
                                          id: 'web_kit',
                                          title: 'Full-Stack Web Dev Kit',
                                          description: 'A complete Node.js app environment paired with a MongoDB database, running fully containerized inside isolated workspace borders.',
                                          techBadges: ['NodeJS 20', 'Express', 'MongoDB 6.0', 'Mongoose'],
                                        ),
                                      )
                                    : Text(
                                        'No environments are currently running.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 16,
                                        ),
                                      ),
                              )
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
}

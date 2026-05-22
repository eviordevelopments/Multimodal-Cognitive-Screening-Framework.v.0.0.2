import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_container.dart';

class SessionOrchestratorPage extends StatefulWidget {
  final String sessionId;
  
  const SessionOrchestratorPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  _SessionOrchestratorPageState createState() => _SessionOrchestratorPageState();
}

class _SessionOrchestratorPageState extends State<SessionOrchestratorPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cognitive Assessment Session'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MCSFTheme.backgroundDark,
              MCSFTheme.surfaceDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Module',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: MCSFTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete all modules to generate the final analytical report.',
                    style: TextStyle(
                      fontSize: 16,
                      color: MCSFTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildModuleCard(
                          title: 'Clinical Assessment',
                          subtitle: 'MoCA, PHQ-9, AD8',
                          icon: Icons.assignment_outlined,
                          status: 'Pending',
                          progress: 0.0,
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildModuleCard(
                          title: 'Visuospatial Task',
                          subtitle: 'Clock Drawing, Figure Copying',
                          icon: Icons.draw_outlined,
                          status: 'Not Started',
                          progress: 0.0,
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildModuleCard(
                          title: 'Acoustic Prosody',
                          subtitle: 'Semantic Fluency, Picture Description',
                          icon: Icons.mic_none_outlined,
                          status: 'Not Started',
                          progress: 0.0,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('GENERATE REPORT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MCSFTheme.accentCyan.withOpacity(0.2),
                        foregroundColor: MCSFTheme.accentCyan,
                        shadowColor: Colors.transparent,
                        side: const BorderSide(color: MCSFTheme.accentCyan, width: 1.5),
                      ),
                      onPressed: null, // Disabled until all complete
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
    required double progress,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MCSFTheme.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: MCSFTheme.accentCyan, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: MCSFTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: MCSFTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: MCSFTheme.textSecondary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

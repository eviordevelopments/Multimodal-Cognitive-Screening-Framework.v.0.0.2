import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_container.dart';

class MoCAPage extends StatefulWidget {
  const MoCAPage({Key? key}) : super(key: key);

  @override
  _MoCAPageState createState() => _MoCAPageState();
}

class _MoCAPageState extends State<MoCAPage> {
  int _currentStep = 0;
  final List<String> _domains = [
    'Visuospatial / Executive',
    'Naming',
    'Attention',
    'Language',
    'Abstraction',
    'Delayed Recall',
    'Orientation'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Clinical Assessment (MoCA)'),
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
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _domains[_currentStep],
                          style: const TextStyle(
                            color: MCSFTheme.accentCyan,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Read the list of words. The patient must repeat them. Do two trials. Recall is asked after 5 minutes.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: MCSFTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Memory Items
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 2.5,
                            children: [
                              _buildScoreToggle('FACE'),
                              _buildScoreToggle('VELVET'),
                              _buildScoreToggle('CHURCH'),
                              _buildScoreToggle('DAISY'),
                              _buildScoreToggle('RED'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNavigationFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: List.generate(_domains.length, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep 
                    ? MCSFTheme.accentCyan 
                    : MCSFTheme.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScoreToggle(String label) {
    bool isSelected = false; // Mock state
    return StatefulBuilder(
      builder: (context, setState) {
        return InkWell(
          onTap: () => setState(() => isSelected = !isSelected),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? MCSFTheme.successGreen.withOpacity(0.2) 
                  : MCSFTheme.surfaceLight.withOpacity(0.3),
              border: Border.all(
                color: isSelected ? MCSFTheme.successGreen : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) const Icon(Icons.check_circle, color: MCSFTheme.successGreen, size: 20),
                if (isSelected) const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? MCSFTheme.textPrimary : MCSFTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildNavigationFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MCSFTheme.backgroundDark.withOpacity(0.8),
        border: Border(top: BorderSide(color: MCSFTheme.surfaceLight.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
            child: Text('BACK', style: TextStyle(color: _currentStep > 0 ? MCSFTheme.textSecondary : Colors.transparent)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentStep < _domains.length - 1) {
                setState(() => _currentStep++);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(_currentStep < _domains.length - 1 ? 'NEXT DOMAIN' : 'COMPLETE'),
          ),
        ],
      ),
    );
  }
}

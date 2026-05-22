import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../widgets/drawing_canvas.dart';

class ClockDrawingPage extends StatefulWidget {
  const ClockDrawingPage({Key? key}) : super(key: key);

  @override
  _ClockDrawingPageState createState() => _ClockDrawingPageState();
}

class _ClockDrawingPageState extends State<ClockDrawingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Visuospatial Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MCSFTheme.backgroundDark,
              MCSFTheme.surfaceDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MCSFTheme.accentCyan.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.timer_outlined, color: MCSFTheme.accentCyan),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task: Clock Drawing',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MCSFTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Draw a clock face, put in all the numbers, and set the time to 11:10.',
                              style: TextStyle(
                                fontSize: 14,
                                color: MCSFTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        DrawingCanvasWidget(
                          onStrokeCompleted: (points, velocity, pressure) {
                            // Link to StrokeAnalyzer
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.extended(
                            backgroundColor: MCSFTheme.primaryBlue,
                            onPressed: () {
                              // Save state and pop
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Complete Task', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

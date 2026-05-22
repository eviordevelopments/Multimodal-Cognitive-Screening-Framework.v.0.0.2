import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_container.dart';

class SpeechPromptPage extends StatefulWidget {
  const SpeechPromptPage({Key? key}) : super(key: key);

  @override
  _SpeechPromptPageState createState() => _SpeechPromptPageState();
}

class _SpeechPromptPageState extends State<SpeechPromptPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isRecording = false;

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

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Acoustic Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              MCSFTheme.surfaceDark,
              MCSFTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.record_voice_over_outlined, color: MCSFTheme.accentCyan, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Semantic Fluency',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MCSFTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Name as many animals as you can in one minute. Tap the microphone to begin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: MCSFTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? MCSFTheme.errorRed.withOpacity(0.2) : MCSFTheme.primaryBlue.withOpacity(0.1),
                          boxShadow: _isRecording 
                            ? [
                                BoxShadow(
                                  color: MCSFTheme.errorRed.withOpacity(0.5 * _pulseController.value),
                                  blurRadius: 30 * _pulseController.value,
                                  spreadRadius: 10 * _pulseController.value,
                                )
                              ]
                            : [],
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isRecording 
                                  ? [MColors.errorRed, Colors.redAccent] 
                                  : [MCSFTheme.primaryBlue, MCSFTheme.accentCyan],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isRecording ? 'Recording... 00:15 / 01:00' : 'Ready to record',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _isRecording ? MCSFTheme.errorRed : MCSFTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (!_isRecording)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MCSFTheme.surfaceLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {},
                      child: const Text('SAVE & CONTINUE'),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MColors {
  static const errorRed = MCSFTheme.errorRed;
}

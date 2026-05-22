import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class ProsodyExtractor {
  /// A simplified client-side prosody extraction mathematical model.
  /// In a production environment, OpenSMILE (via Python backend) handles advanced MFCC/F0.
  /// Here, we process raw PCM WAV data to extract silence and pause biomarkers.
  
  static const int _silenceThreshold = 500; // Amplitude threshold for silence
  static const int _minPauseDurationMs = 250; // Minimum duration to qualify as a cognitive pause

  static Future<Map<String, dynamic>> extractProsodicFeatures(String wavFilePath) async {
    final file = File(wavFilePath);
    if (!await file.exists()) {
      throw Exception('WAV file not found.');
    }

    final bytes = await file.readAsBytes();
    
    // Simplistic WAV parsing (assuming 44100Hz, 16-bit PCM Mono)
    // Audio data usually starts around byte 44 in a standard WAV header
    if (bytes.length <= 44) return _emptyFeatures();

    final int sampleRate = 44100;
    
    // Extract 16-bit PCM samples
    List<int> amplitudes = [];
    for (int i = 44; i < bytes.length - 1; i += 2) {
      int sample = bytes[i] | (bytes[i + 1] << 8);
      // Handle signed 16-bit
      if (sample >= 32768) sample -= 65536;
      amplitudes.add(sample.abs());
    }

    int pauseCount = 0;
    int currentPauseSamples = 0;
    double totalSilenceSamples = 0;
    List<int> pauseDurationsMs = [];

    for (int amp in amplitudes) {
      if (amp < _silenceThreshold) {
        currentPauseSamples++;
        totalSilenceSamples++;
      } else {
        if (currentPauseSamples > 0) {
          double pauseDurationMs = (currentPauseSamples / sampleRate) * 1000;
          if (pauseDurationMs >= _minPauseDurationMs) {
            pauseCount++;
            pauseDurationsMs.add(pauseDurationMs.toInt());
          }
          currentPauseSamples = 0;
        }
      }
    }

    // Check trailing silence
    if (currentPauseSamples > 0) {
      double pauseDurationMs = (currentPauseSamples / sampleRate) * 1000;
      if (pauseDurationMs >= _minPauseDurationMs) {
        pauseCount++;
        pauseDurationsMs.add(pauseDurationMs.toInt());
      }
    }

    double meanPauseDurationMs = 0.0;
    if (pauseDurationsMs.isNotEmpty) {
      meanPauseDurationMs = pauseDurationsMs.reduce((a, b) => a + b) / pauseDurationsMs.length;
    }

    double totalSilenceDurationMs = (totalSilenceSamples / sampleRate) * 1000;

    return {
      'pauseCount': pauseCount,
      'meanPauseDurationMs': meanPauseDurationMs,
      'totalSilenceDurationMs': totalSilenceDurationMs,
      'sampleRate': sampleRate,
    };
  }

  static Map<String, dynamic> _emptyFeatures() {
    return {
      'pauseCount': 0,
      'meanPauseDurationMs': 0.0,
      'totalSilenceDurationMs': 0.0,
      'sampleRate': 44100,
    };
  }
}

import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  Future<void> init() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<void> startRecording(String sessionId, String taskType) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/audio_${sessionId}_$taskType.wav';
    
    final recordConfig = const RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 44100,
      bitRate: 128000,
      numChannels: 1, // Mono for easier prosody extraction
    );

    await _audioRecorder.start(recordConfig, path: filePath);
  }

  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path;
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}

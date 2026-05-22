import 'package:freezed_annotation/freezed_annotation.dart';

part 'acoustic_features.freezed.dart';
part 'acoustic_features.g.dart';

@freezed
class AcousticModuleResult with _$AcousticModuleResult {
  const factory AcousticModuleResult({
    required String taskType,    // 'semantic_fluency' | 'phonemic_fluency' | 'picture_description'
    required String audioFilePath,
    required String audioFhirMediaId,
    required Duration recordingDuration,
    required int sampleRateHz,
    
    // Client-side computed features (basic amplitude thresholding)
    required int wordCount,
    required double speechRate,        // words per second
    required int pauseCount,
    required double meanPauseDurationMs,
    required double totalSilenceDurationMs,
    
    // Server-side extracted (via OpenSMILE / FastAPI backend)
    List<double>? mfccCoefficients,    // MFCC 1–13
    double? f0Mean,                    // Fundamental frequency mean
    double? f0Std,
    double? typeTokenRatio,            // TTR (lexical diversity proxy)
    double? disfluencyRate,            // 'uh', 'um' count / total words
    
    required DateTime completedAt,
  }) = _AcousticModuleResult;

  factory AcousticModuleResult.fromJson(Map<String, dynamic> json) => _$AcousticModuleResultFromJson(json);
}

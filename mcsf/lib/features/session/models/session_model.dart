import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String fhirEncounterId,
    required String patientId,
    required String clinicianId,
    required DateTime startTime,
    DateTime? endTime,
    required SessionStatus status,
    required SessionType type,    
    
    required bool consentCompleted,
    required bool clinicalModuleCompleted,
    required bool visuospatialModuleCompleted,
    required bool acousticModuleCompleted,
    
    // Composite output (using dynamic to simplify for now until specific models are made)
    Map<String, dynamic>? clinicalResult,
    Map<String, dynamic>? visuospatialResult,
    Map<String, dynamic>? acousticResult,
    Map<String, dynamic>? riskScore,
    
    String? clinicianNotes,
    
    required String deviceId,
    required String appVersion,
    required String checksum,   
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
}

enum SessionStatus { inProgress, completed, interrupted, voided }
enum SessionType { clinicianLed, patientSelfAssessment }

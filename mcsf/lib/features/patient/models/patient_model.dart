import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
class PatientModel with _$PatientModel {
  const factory PatientModel({
    required String id,             // UUID v4 — internal
    required String fhirId,         // FHIR Patient.id
    required String curp,           // Mexican national ID — encrypted at rest
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required Sex sex,
    required ResidenceType residenceType,  // RURAL | URBAN
    required String institutionId,
    
    // Demographics
    required int educationYears,
    required String occupation,
    required bool socialIsolation,
    required bool familyHistoryDementia,
    required List<Comorbidity> comorbidities,
    
    // Risk factors
    required double sleepHoursPerNight,
    required ActivityLevel physicalActivity,
    required NutritionRisk nutritionRisk,
    required bool ruralExposureOver20Years,
    required bool chronicStress,
    required bool postTraumaHistory,
    required bool epigeneticEnvironmentalExposure,
    
    String? caregiverName,
    String? caregiverPhone,
    String? caregiverRelationship,
    
    required DateTime enrollmentDate,
    required ConsentStatus consentStatus,
    String? consentFhirId,
  }) = _PatientModel;

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);
}

enum Sex { male, female, other, unknown }
enum ResidenceType { rural, urban }
enum ActivityLevel { sedentary, low, moderate, high }
enum NutritionRisk { none, low, moderate, high }
enum ConsentStatus { pending, signed, withdrawn }

enum Comorbidity {
  diabetes,
  hypertension,
  depression,
  heartDisease,
  stroke,
  thyroidDisorder,
  visualImpairment,
  hearingImpairment,
  other,
}

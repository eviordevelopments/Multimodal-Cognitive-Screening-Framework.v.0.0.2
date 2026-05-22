import 'package:flutter_test/flutter_test.dart';
import 'package:mcsf/features/patient/models/patient_model.dart';

void main() {
  group('PatientModel Tests', () {
    test('should correctly serialize to JSON', () {
      final patient = PatientModel(
        id: '123e4567-e89b-12d3-a456-426614174000',
        fhirId: 'patient-fhir-001',
        curp: 'ABC123456789',
        firstName: 'Juan',
        lastName: 'Perez',
        dateOfBirth: DateTime(1950, 5, 12),
        sex: Sex.male,
        residenceType: ResidenceType.rural,
        institutionId: 'ISSSTE-IRA',
        educationYears: 8,
        occupation: 'Farmer',
        socialIsolation: true,
        familyHistoryDementia: false,
        comorbidities: [Comorbidity.hypertension, Comorbidity.diabetes],
        sleepHoursPerNight: 6.5,
        physicalActivity: ActivityLevel.moderate,
        nutritionRisk: NutritionRisk.low,
        ruralExposureOver20Years: true,
        chronicStress: false,
        postTraumaHistory: false,
        epigeneticEnvironmentalExposure: true,
        enrollmentDate: DateTime(2026, 5, 21),
        consentStatus: ConsentStatus.signed,
      );

      final jsonMap = patient.toJson();

      expect(jsonMap['id'], '123e4567-e89b-12d3-a456-426614174000');
      expect(jsonMap['firstName'], 'Juan');
      expect(jsonMap['sex'], 'male');
      expect(jsonMap['comorbidities'], ['hypertension', 'diabetes']);
      expect(jsonMap['educationYears'], 8);
    });

    test('should correctly deserialize from JSON', () {
      final jsonMap = {
        'id': 'uuid-test',
        'fhirId': 'fhir-test',
        'curp': 'XYZ987',
        'firstName': 'Maria',
        'lastName': 'Lopez',
        'dateOfBirth': '1945-08-20T00:00:00.000',
        'sex': 'female',
        'residenceType': 'urban',
        'institutionId': 'ISSSTE',
        'educationYears': 12,
        'occupation': 'Teacher',
        'socialIsolation': false,
        'familyHistoryDementia': true,
        'comorbidities': ['depression'],
        'sleepHoursPerNight': 7.0,
        'physicalActivity': 'sedentary',
        'nutritionRisk': 'none',
        'ruralExposureOver20Years': false,
        'chronicStress': true,
        'postTraumaHistory': false,
        'epigeneticEnvironmentalExposure': false,
        'enrollmentDate': '2026-05-21T00:00:00.000',
        'consentStatus': 'pending'
      };

      final patient = PatientModel.fromJson(jsonMap);

      expect(patient.id, 'uuid-test');
      expect(patient.firstName, 'Maria');
      expect(patient.sex, Sex.female);
      expect(patient.comorbidities, contains(Comorbidity.depression));
      expect(patient.dateOfBirth, DateTime(1945, 8, 20));
    });
  });
}

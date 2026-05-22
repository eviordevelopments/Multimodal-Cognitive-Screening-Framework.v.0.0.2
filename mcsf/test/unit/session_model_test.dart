import 'package:flutter_test/flutter_test.dart';
import 'package:mcsf/features/session/models/session_model.dart';

void main() {
  group('SessionModel Tests', () {
    test('should serialize SessionModel to JSON', () {
      final session = SessionModel(
        id: 'session-123',
        fhirEncounterId: 'enc-123',
        patientId: 'pat-123',
        clinicianId: 'clin-123',
        startTime: DateTime(2026, 5, 21, 10, 0),
        status: SessionStatus.inProgress,
        type: SessionType.clinicianLed,
        consentCompleted: true,
        clinicalModuleCompleted: false,
        visuospatialModuleCompleted: false,
        acousticModuleCompleted: false,
        deviceId: 'ipad-pro-01',
        appVersion: '0.0.2',
        checksum: 'dummy-hash',
      );

      final jsonMap = session.toJson();

      expect(jsonMap['id'], 'session-123');
      expect(jsonMap['status'], 'inProgress');
      expect(jsonMap['consentCompleted'], true);
      expect(jsonMap['clinicalModuleCompleted'], false);
    });
  });
}

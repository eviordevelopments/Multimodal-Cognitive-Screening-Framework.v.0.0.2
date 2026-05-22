import 'package:fhir/r4.dart';
import '../../features/patient/models/patient_model.dart';
import '../../features/session/models/session_model.dart';

/// Maps MCSF internal domain models (and offline drift DB rows) 
/// to HL7 FHIR R4 resources for Google Cloud Healthcare API interoperability.
class FhirMapper {
  static const String curpOid = 'urn:oid:2.16.484.1.21.1.1.1.1';
  static const String extBaseUrl = 'http://mcsf.neuralhack.mx/fhir/ext';

  /// Converts a [PatientModel] to a FHIR [Patient] resource.
  static Patient toFhirPatient(PatientModel p) {
    return Patient(
      id: p.fhirId.isNotEmpty ? Id(p.fhirId) : null,
      identifier: [
        Identifier(
          system: FhirUri(curpOid),
          // Note: In production, ensure this value is handled securely.
          value: p.curp,
        ),
      ],
      name: [
        HumanName(
          family: p.lastName,
          given: [p.firstName],
        ),
      ],
      birthDate: FhirDate(p.dateOfBirth),
      gender: _mapSexToGender(p.sex),
      extension_: [
        FhirExtension(
          url: FhirUri('$extBaseUrl/education-years'),
          valueInteger: Integer(p.educationYears),
        ),
        FhirExtension(
          url: FhirUri('$extBaseUrl/residence-type'),
          valueCode: Code(p.residenceType.name),
        ),
      ],
    );
  }

  /// Converts session data and clinical scores to a FHIR [Observation] for the MoCA test.
  static Observation toMoCaObservation(
    SessionModel session,
    Map<String, dynamic> mocaResult,
  ) {
    return Observation(
      status: ObservationStatus.final_,
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://loinc.org'),
            code: Code('72133-2'),
            display: 'Montreal Cognitive Assessment [MoCA]',
          )
        ],
      ),
      subject: Reference(reference: 'Patient/${session.patientId}'),
      encounter: Reference(reference: 'Encounter/${session.fhirEncounterId}'),
      effectiveDateTime: FhirDateTime(session.startTime),
      valueInteger: Integer(mocaResult['adjustedTotal'] as int? ?? 0),
      component: [
        _buildObsComponent('72104-3', 'Visuospatial/Executive', mocaResult['visuospatialExecutive'] as int? ?? 0),
        _buildObsComponent('72105-0', 'Naming', mocaResult['naming'] as int? ?? 0),
        _buildObsComponent('72106-8', 'Attention', mocaResult['attention'] as int? ?? 0),
        _buildObsComponent('72107-6', 'Language', mocaResult['language'] as int? ?? 0),
        _buildObsComponent('72108-4', 'Abstraction', mocaResult['abstraction'] as int? ?? 0),
        _buildObsComponent('72109-2', 'Delayed recall', mocaResult['delayedRecall'] as int? ?? 0),
        _buildObsComponent('72110-0', 'Orientation', mocaResult['orientation'] as int? ?? 0),
      ],
    );
  }

  /// Converts Visuospatial output to a FHIR [DiagnosticReport] wrapping a [Media] resource.
  static DiagnosticReport toVisuospatialReport(
    SessionModel session,
    Map<String, dynamic> visuospatialResult,
    String clinicianId,
  ) {
    return DiagnosticReport(
      status: DiagnosticReportStatus.final_,
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://loinc.org'),
            code: Code('10185-7'), // Example code for visuospatial testing
            display: 'Visuospatial cognitive assessment',
          )
        ],
      ),
      subject: Reference(reference: 'Patient/${session.patientId}'),
      encounter: Reference(reference: 'Encounter/${session.fhirEncounterId}'),
      effectiveDateTime: FhirDateTime(session.startTime),
      performer: [Reference(reference: 'Practitioner/$clinicianId')],
      presentedForm: [
        Attachment(
          contentType: Code('image/png'),
          url: FhirUrl(visuospatialResult['image_url'] as String? ?? ''),
          title: 'Visuospatial Clock Drawing Result',
        )
      ],
    );
  }

  static PatientGender _mapSexToGender(Sex sex) {
    switch (sex) {
      case Sex.male:
        return PatientGender.male;
      case Sex.female:
        return PatientGender.female;
      case Sex.other:
        return PatientGender.other;
      case Sex.unknown:
      default:
        return PatientGender.unknown;
    }
  }

  static ObservationComponent _buildObsComponent(String code, String display, int value) {
    return ObservationComponent(
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://loinc.org'),
            code: Code(code),
            display: display,
          )
        ],
      ),
      valueInteger: Integer(value),
    );
  }
}

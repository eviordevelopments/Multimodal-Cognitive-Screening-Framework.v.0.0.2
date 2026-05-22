# Multimodal Cognitive Screening Framework (MCSF)
## Complete Platform Documentation — v0.02
**PrepaTec · Tecnológico de Monterrey · Campus Irapuato**
**Development Environment: Project IDX (Google) · Flutter 3.x**

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Regulatory & Compliance Framework](#2-regulatory--compliance-framework)
3. [System Architecture Overview](#3-system-architecture-overview)
4. [Flutter Project Structure](#4-flutter-project-structure)
5. [Data Models & FHIR Schema](#5-data-models--fhir-schema)
6. [Module Specifications](#6-module-specifications)
7. [Security & HIPAA Implementation](#7-security--hipaa-implementation)
8. [Backend API Architecture](#8-backend-api-architecture)
9. [Database Schema](#9-database-schema)
10. [Analytical Engine (v0.02)](#10-analytical-engine-v002)
11. [UI/UX Design System](#11-uiux-design-system)
12. [Project IDX Setup Guide](#12-project-idx-setup-guide)
13. [Testing Strategy](#13-testing-strategy)
14. [Deployment & CI/CD](#14-deployment--cicd)
15. [Roadmap to v1.0](#15-roadmap-to-v10)

---

## 1. Executive Summary

The **Multimodal Cognitive Screening Framework (MCSF)** is a research-grade, open-source clinical data acquisition platform designed to collect, standardize, and analyze cognitive biomarkers associated with neurodegenerative diseases.

This platform is **not a diagnostic medical device**. It is a Clinical Information System (CIS) designed to support licensed clinicians at the ISSSTE Geriatrics Department in collecting structured pilot data for future ensemble machine learning model development, as defined by the NeuralHack Cognitive AI research program (Castillo García, 2025).

### Core Design Principles

| Principle | Implementation |
|---|---|
| **Late-Fusion Modular Design** | Each biomarker domain runs as an independent module with its own data pipeline |
| **FHIR R4 Native** | All data structures map directly to HL7 FHIR R4 resources |
| **Offline-First** | Full local data capture with background sync (critical for rural settings) |
| **Dual Audience** | Clinician-facing dashboard + patient self-assessment portal, role-separated |
| **Privacy by Design** | AES-256 encryption at rest, TLS 1.3 in transit, anonymized research export |
| **Open Source** | Apache 2.0 license; reproducible builds via IDX/GitHub |

### Technology Stack

```
Frontend:     Flutter 3.x (iOS, Android, Web, Desktop/macOS, Linux, Windows)
IDE:          Project IDX (Google) — Dart/Flutter workspace
Backend:      Firebase (Auth, Firestore, Cloud Functions, Storage) + Supabase (PostgreSQL)
FHIR Server:  Google Cloud Healthcare API (FHIR R4)
ML Engine:    Python FastAPI microservice (scikit-learn RandomForest + statistical baselines)
Audio:        record / just_audio packages + server-side OpenSMILE feature extraction
Drawing:      flutter_drawing_board — stroke data (x, y, Δt, pressure, velocity)
Security:     flutter_secure_storage, AES-GCM, SHA-256 audit hashing
Compliance:   HIPAA, FDA 21 CFR Part 11, COFEPRIS NOM-024-SSA3, FHIR R4
```

---

## 2. Regulatory & Compliance Framework

### 2.1 Applicable Standards

#### HIPAA (United States — applicable for future clinical trials)

| Rule | Implementation |
|---|---|
| **Privacy Rule** | Minimum necessary data collection; role-based access; patient authorization forms |
| **Security Rule** | AES-256 at rest; TLS 1.3 in transit; MFA for all clinician accounts; audit logs |
| **Breach Notification Rule** | Automated breach detection via Firebase Security Rules + Supabase Row-Level Security; incident response SOP documented |
| **Business Associate Agreements** | Required with Firebase (Google Cloud), Supabase, any third-party processor |

#### FDA 21 CFR Part 11 (Electronic Records)

Because MCSF collects electronic patient records that may support regulatory submissions:

- **Audit trails**: Every data write generates an immutable timestamped log entry (SHA-256 hash chain)
- **Electronic signatures**: Clinician sign-off via biometric/PIN on each completed assessment session
- **Data integrity**: Checksums on all exported datasets; no in-place updates — append-only event log
- **System validation**: IQ/OQ/PQ documentation required before clinical use

#### COFEPRIS NOM-024-SSA3-2012 (Mexico — Clinical Information Systems)

| Requirement | MCSF Implementation |
|---|---|
| Patient identification minimum fields | CURP, name, DOB, sex, institution ID |
| Interoperability | FHIR R4 export; HL7 2.x messaging adapter planned for v0.05 |
| Data retention | Minimum 5 years; configurable per institution |
| Access logs | All reads and writes logged to immutable audit table |
| Backup | Daily encrypted backup to GCS; 30-day retention |

#### HL7 FHIR R4 (Fast Healthcare Interoperability Resources)

All clinical entities are mapped to canonical FHIR resources:

```
Patient           → Demographics, identifiers, contact
Practitioner      → Clinician profile, credentials
Observation       → MoCA score, MMSE score, PHQ-9, AD8, Katz ADL, Zarit
DiagnosticReport  → Full screening session summary
QuestionnaireResponse → Structured test responses
Media             → Audio recordings (base64/URL), drawing images
Condition         → Diagnosis codes (ICD-10-CM: F00–F09 dementias)
Encounter         → Each screening session
Consent           → Informed consent record with timestamp + signature
```

### 2.2 Data Classification

| Classification | Examples | Controls |
|---|---|---|
| **PHI (Protected Health Information)** | Name, DOB, CURP, audio recordings, drawing images | AES-256, access-log, de-id before ML training |
| **Clinical Data** | MoCA score, MMSE, PHQ-9, diagnoses | Role-gated access, audit trail |
| **Research Data** | Anonymized feature vectors, aggregated scores | Exportable; IRB-approved dataset |
| **Operational** | Logs, app telemetry | Separated infrastructure; no PHI |

### 2.3 Informed Consent Module

Every patient session must begin with digital informed consent:

```dart
// Consent FHIR resource generated on sign-off
Consent fhirConsent = Consent(
  status: ConsentStatus.active,
  scope: CodeableConcept(text: 'research'),
  category: [CodeableConcept(coding: [
    Coding(system: 'http://loinc.org', code: '59284-0', display: 'Consent Document')
  ])],
  dateTime: DateTime.now().toUtc(),
  patient: Reference(reference: 'Patient/${patient.id}'),
  performer: [Reference(reference: 'Practitioner/${clinician.id}')],
  sourceAttachment: Attachment(
    contentType: 'application/pdf',
    url: consentPdfUrl,
    hash: sha256Hash,
  ),
  provision: ConsentProvision(
    type: ConsentProvisionType.permit,
    period: Period(start: DateTime.now().toUtc()),
  ),
);
```

---

## 3. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    MCSF Flutter Client                       │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  Clinician   │  │   Patient    │  │  Admin / Research│  │
│  │  Dashboard   │  │  Self-Assess │  │  Analytics Panel │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         │                 │                    │            │
│  ┌──────▼─────────────────▼────────────────────▼──────────┐ │
│  │              Module Layer (BLoC State)                  │ │
│  │  Clinical │ Visuospatial │ Acoustic │ Analytics Engine │ │
│  └──────────────────────────┬──────────────────────────────┘ │
│                             │                               │
│  ┌──────────────────────────▼──────────────────────────────┐ │
│  │         Local Data Layer (offline-first)                │ │
│  │   Hive (encrypted) │ SQLite (drift) │ SecureStorage     │ │
│  └──────────────────────────┬──────────────────────────────┘ │
└─────────────────────────────┼───────────────────────────────┘
                              │ TLS 1.3
              ┌───────────────▼────────────────────┐
              │         API Gateway (Firebase)      │
              │   Auth (MFA) │ Functions │ Storage  │
              └───────────┬────────────┬────────────┘
                          │            │
           ┌──────────────▼───┐  ┌─────▼────────────────────┐
           │  FHIR R4 Server  │  │  Supabase (PostgreSQL)    │
           │  Google Cloud    │  │  Clinical + Research DB   │
           │  Healthcare API  │  │  Row-Level Security       │
           └──────────────────┘  └──────────────────────────┘
                          │
           ┌──────────────▼────────────────┐
           │  ML Microservice (Python)      │
           │  FastAPI + scikit-learn        │
           │  RandomForest + Statistical    │
           │  Normative Deviation Engine    │
           └───────────────────────────────┘
```

### 3.1 Late-Fusion Architecture

Each module independently processes its biomarker domain and produces a **feature vector**. These vectors are fused at the analytical engine layer:

```
Module Output Vectors:
  clinical_vec    → [age, education, katz, comorbidity_flags, moca_raw, mmse_raw, phq9, ad8]
  visuospatial_vec→ [stroke_velocity_mean, stroke_velocity_std, shape_error, execution_time, 
                     pressure_mean, trajectory_deviation, symmetry_index]
  acoustic_vec    → [TTR, disfluency_rate, pause_count, pause_duration_mean, F0_mean, 
                     F0_std, speech_rate, MFCC_1..13]
  
Fusion:
  feature_matrix  → pd.concat([clinical_vec, visuospatial_vec, acoustic_vec])
  prediction      → RandomForestClassifier.predict_proba(feature_matrix)
  risk_score      → weighted_sum(module_scores, alpha=[0.4, 0.35, 0.25])
```

---

## 4. Flutter Project Structure

```
mcsf/
├── .idx/                          # Project IDX configuration
│   └── dev.nix                    # Nix environment definition
├── lib/
│   ├── main.dart                  # App entry point, theme, router
│   ├── app/
│   │   ├── router.dart            # GoRouter configuration
│   │   ├── theme.dart             # Design system tokens
│   │   └── localization/          # l10n: en, es-MX
│   │
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_service.dart
│   │   │   ├── mfa_service.dart
│   │   │   └── role_guard.dart    # CLINICIAN | PATIENT | ADMIN
│   │   ├── crypto/
│   │   │   ├── aes_service.dart   # AES-256-GCM encryption
│   │   │   └── audit_logger.dart  # SHA-256 immutable audit chain
│   │   ├── fhir/
│   │   │   ├── fhir_client.dart   # Google Healthcare API client
│   │   │   ├── fhir_mapper.dart   # App models ↔ FHIR resources
│   │   │   └── resources/         # Typed FHIR R4 Dart models
│   │   ├── network/
│   │   │   ├── api_client.dart    # Dio + interceptors
│   │   │   └── connectivity.dart  # Offline-first sync manager
│   │   └── storage/
│   │       ├── hive_service.dart  # Encrypted local cache
│   │       └── secure_storage.dart
│   │
│   ├── features/
│   │   │
│   │   ├── auth/                  # Login, MFA, role selection
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   │
│   │   ├── consent/               # Informed consent flow
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   │   ├── consent_presentation_page.dart
│   │   │   │   └── consent_signature_page.dart
│   │   │   └── widgets/
│   │   │
│   │   ├── patient/               # Patient management
│   │   │   ├── bloc/
│   │   │   ├── models/
│   │   │   │   └── patient_model.dart
│   │   │   ├── pages/
│   │   │   │   ├── patient_list_page.dart
│   │   │   │   ├── patient_profile_page.dart
│   │   │   │   └── new_patient_page.dart
│   │   │   └── repository/
│   │   │       └── patient_repository.dart
│   │   │
│   │   ├── session/               # Screening session orchestrator
│   │   │   ├── bloc/
│   │   │   │   ├── session_bloc.dart
│   │   │   │   ├── session_event.dart
│   │   │   │   └── session_state.dart
│   │   │   ├── models/
│   │   │   │   └── session_model.dart
│   │   │   └── pages/
│   │   │       └── session_orchestrator_page.dart
│   │   │
│   │   ├── clinical_module/       # MoCA, MMSE, PHQ-9, AD8, Katz
│   │   │   ├── bloc/
│   │   │   ├── models/
│   │   │   │   ├── moca_response.dart
│   │   │   │   ├── mmse_response.dart
│   │   │   │   ├── phq9_response.dart
│   │   │   │   ├── ad8_response.dart
│   │   │   │   └── katz_adl_response.dart
│   │   │   ├── pages/
│   │   │   │   ├── moca_page.dart
│   │   │   │   ├── mmse_page.dart
│   │   │   │   ├── phq9_page.dart
│   │   │   │   ├── ad8_page.dart
│   │   │   │   └── katz_page.dart
│   │   │   └── widgets/
│   │   │       ├── likert_scale_widget.dart
│   │   │       ├── timer_widget.dart
│   │   │       └── question_card.dart
│   │   │
│   │   ├── visuospatial_module/   # Clock drawing + tracing tasks
│   │   │   ├── bloc/
│   │   │   ├── models/
│   │   │   │   └── stroke_data.dart
│   │   │   ├── pages/
│   │   │   │   ├── clock_drawing_page.dart
│   │   │   │   └── copy_figure_page.dart
│   │   │   ├── services/
│   │   │   │   ├── stroke_analyzer.dart  # Velocity, pressure, shape
│   │   │   │   └── image_exporter.dart   # PNG + SVG export
│   │   │   └── widgets/
│   │   │       ├── drawing_canvas.dart
│   │   │       └── stroke_recorder.dart
│   │   │
│   │   ├── acoustic_module/       # Speech recording + metadata
│   │   │   ├── bloc/
│   │   │   ├── models/
│   │   │   │   └── acoustic_features.dart
│   │   │   ├── pages/
│   │   │   │   ├── speech_prompt_page.dart
│   │   │   │   └── fluency_task_page.dart
│   │   │   └── services/
│   │   │       ├── recorder_service.dart
│   │   │       └── prosody_extractor.dart
│   │   │
│   │   ├── analytics/             # Results, reports, trends
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   │   ├── session_results_page.dart
│   │   │   │   ├── longitudinal_trends_page.dart
│   │   │   │   └── research_export_page.dart
│   │   │   └── widgets/
│   │   │       ├── radar_chart.dart
│   │   │       ├── risk_score_gauge.dart
│   │   │       └── moca_history_chart.dart
│   │   │
│   │   ├── clinician_dashboard/
│   │   │   ├── pages/
│   │   │   │   ├── dashboard_home_page.dart
│   │   │   │   ├── patient_queue_page.dart
│   │   │   │   └── cohort_analytics_page.dart
│   │   │   └── widgets/
│   │   │
│   │   └── patient_portal/        # Patient self-assessment UI
│   │       ├── pages/
│   │       │   ├── patient_home_page.dart
│   │       │   ├── self_assessment_page.dart
│   │       │   └── my_results_page.dart
│   │       └── widgets/
│   │
│   └── shared/
│       ├── widgets/               # Reusable UI components
│       ├── extensions/            # Dart extensions
│       └── utils/                 # Formatters, validators
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── firebase.json
├── pubspec.yaml
└── README.md
```

### 4.1 pubspec.yaml — Core Dependencies

```yaml
name: mcsf
description: Multimodal Cognitive Screening Framework v0.02
version: 0.2.0+1
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_bloc: ^8.1.5
  equatable: ^2.0.5

  # Navigation
  go_router: ^13.0.0

  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  firebase_storage: ^11.6.0
  cloud_functions: ^4.6.0

  # Local storage (encrypted)
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.18

  # FHIR R4
  fhir: ^0.10.0
  fhir_r4: ^0.10.0

  # Drawing
  flutter_drawing_board: ^0.2.0
  perfect_freehand: ^2.0.1

  # Audio recording
  record: ^5.1.1
  just_audio: ^0.9.36
  path_provider: ^2.1.2

  # Networking
  dio: ^5.4.1
  connectivity_plus: ^6.0.1

  # Cryptography
  pointycastle: ^3.7.4
  crypto: ^3.0.3

  # Charts
  fl_chart: ^0.67.0
  syncfusion_flutter_charts: ^25.1.38

  # PDF generation (consent, reports)
  pdf: ^3.10.8
  printing: ^5.13.1

  # Accessibility
  flutter_tts: ^4.0.2
  speech_to_text: ^6.6.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  logger: ^2.0.2+1
  rxdart: ^0.27.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  drift_dev: ^2.15.0
  mockito: ^5.4.4
  bloc_test: ^9.1.7
  integration_test:
    sdk: flutter
```

---

## 5. Data Models & FHIR Schema

### 5.1 Patient Model

```dart
// lib/features/patient/models/patient_model.dart

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
    
    // Demographics (maps to Table 4 in Phase 1 paper)
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
```

### 5.2 Session Model

```dart
// lib/features/session/models/session_model.dart

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
    required SessionType type,    // CLINICIAN_LED | PATIENT_SELF_ASSESSMENT
    
    // Module completion flags
    required bool consentCompleted,
    required bool clinicalModuleCompleted,
    required bool visuospatialModuleCompleted,
    required bool acousticModuleCompleted,
    
    // Module results (nullable until completed)
    ClinicalModuleResult? clinicalResult,
    VisuospatialModuleResult? visuospatialResult,
    AcousticModuleResult? acousticResult,
    
    // Composite output
    RiskScore? riskScore,
    String? clinicianNotes,
    
    // Audit
    required String deviceId,
    required String appVersion,
    required String checksum,   // SHA-256 of all module results
  }) = _SessionModel;
}

enum SessionStatus { inProgress, completed, interrupted, voided }
enum SessionType { clinicianLed, patientSelfAssessment }
```

### 5.3 Clinical Module Models

```dart
// MoCA Response — 30-point battery
@freezed
class MoCAResponse with _$MoCAResponse {
  const factory MoCAResponse({
    // Domain scores
    required int visuospatialExecutive,   // max 5
    required int naming,                  // max 3
    required int attention,               // max 6
    required int language,                // max 3
    required int abstraction,             // max 2
    required int delayedRecall,           // max 5
    required int orientation,             // max 6
    
    required int educationYears,
    required bool educationAdjustmentApplied,  // +1 for ≤12 years
    required int rawTotal,
    required int adjustedTotal,           // 0–30
    
    required Duration administrationTime,
    required DateTime completedAt,
    
    // Item-level responses for FHIR QuestionnaireResponse
    required List<MoCAItem> itemResponses,
    
    // Evaluator observations
    String? visuospatialNotes,
    String? recallNotes,
  }) = _MoCAResponse;
}

// PHQ-9 Depression Screening
@freezed
class PHQ9Response with _$PHQ9Response {
  const factory PHQ9Response({
    required List<int> itemScores,  // 9 items, 0–3 each
    required int totalScore,        // 0–27
    required PHQ9Severity severity,
    required DateTime completedAt,
    required RespondentType respondentType,  // PATIENT | PROXY
  }) = _PHQ9Response;
}

enum PHQ9Severity { none, mild, moderate, moderatelySevere, severe }
enum RespondentType { patient, proxy, patientWithAssistance }

// AD8 — Informant-based memory screen
@freezed
class AD8Response with _$AD8Response {
  const factory AD8Response({
    required List<AD8Item> items,   // 8 items: yes/no/dontKnow
    required int positiveCount,
    required AD8Interpretation interpretation,
    required String informantRelationship,
    required DateTime completedAt,
  }) = _AD8Response;
}

// Katz Activities of Daily Living
@freezed
class KatzADLResponse with _$KatzADLResponse {
  const factory KatzADLResponse({
    required KatzItem bathing,
    required KatzItem dressing,
    required KatzItem toileting,
    required KatzItem transferring,
    required KatzItem continence,
    required KatzItem feeding,
    required int totalScore,        // 0–6
    required KatzGrade grade,
    required DateTime completedAt,
  }) = _KatzADLResponse;
}
```

### 5.4 Visuospatial Module Model

```dart
// lib/features/visuospatial_module/models/stroke_data.dart

@freezed
class StrokePoint with _$StrokePoint {
  const factory StrokePoint({
    required double x,
    required double y,
    required int timestampMs,
    double? pressure,               // 0.0–1.0 (stylus/touch)
    double? velocity,               // pixels/ms
  }) = _StrokePoint;
}

@freezed
class DrawingStroke with _$DrawingStroke {
  const factory DrawingStroke({
    required String strokeId,
    required List<StrokePoint> points,
    required int startTimeMs,
    required int endTimeMs,
    required double meanVelocity,
    required double velocityVariability,
    required double meanPressure,
    required double pathLength,
  }) = _DrawingStroke;
}

@freezed
class VisuospatialModuleResult with _$VisuospatialModuleResult {
  const factory VisuospatialModuleResult({
    required String taskType,       // 'clock_drawing' | 'copy_figure'
    required List<DrawingStroke> strokes,
    required String pngBase64,      // Final image for FHIR Media resource
    required Duration executionTime,
    
    // Derived features (computed by StrokeAnalyzer)
    required double strokeVelocityMean,
    required double strokeVelocityStd,
    required double meanPressure,
    required double trajectoryDeviation,
    required double symmetryIndex,
    required int liftCount,         // number of pen lifts
    required double totalPathLength,
    
    // Clock-specific (if task = clock_drawing)
    ClockDrawingAnalysis? clockAnalysis,
    
    required DateTime completedAt,
  }) = _VisuospatialModuleResult;
}

@freezed
class ClockDrawingAnalysis with _$ClockDrawingAnalysis {
  const factory ClockDrawingAnalysis({
    required bool circlePresent,
    required double circleClosure,     // 0.0–1.0
    required bool numbersPresent,
    required bool handsPresent,
    required bool timeCorrect,         // Does the time set match the prompt?
    required double numberPlacementError,  // Mean angular deviation
    required int cdcScore,             // 0–4 simplified CDT score
    required List<String> errorTags,   // e.g. ['missing_minute_hand', 'number_crowding']
  }) = _ClockDrawingAnalysis;
}
```

### 5.5 Acoustic Module Model

```dart
@freezed
class AcousticModuleResult with _$AcousticModuleResult {
  const factory AcousticModuleResult({
    required String taskType,    // 'semantic_fluency' | 'phonemic_fluency' | 'picture_description'
    required String audioFilePath,
    required String audioFhirMediaId,
    required Duration recordingDuration,
    required int sampleRateHz,
    
    // Client-side computed (basic)
    required int wordCount,
    required double speechRate,        // words per second
    required int pauseCount,
    required double meanPauseDurationMs,
    required double totalSilenceDurationMs,
    
    // Server-side extracted (OpenSMILE or basic FFT)
    List<double>? mfccCoefficients,   // MFCC 1–13
    double? f0Mean,                    // Fundamental frequency mean
    double? f0Std,
    double? typeTokenRatio,            // TTR (lexical diversity proxy)
    double? disfluencyRate,            // 'uh', 'um' count / total words
    
    required DateTime completedAt,
  }) = _AcousticModuleResult;
}
```

### 5.6 FHIR Mapper

```dart
// lib/core/fhir/fhir_mapper.dart

class FhirMapper {
  // Patient → FHIR Patient
  static FhirPatient toFhirPatient(PatientModel p) => FhirPatient(
    id: p.fhirId,
    identifier: [
      Identifier(
        system: FhirUri('urn:oid:2.16.484.1.21.1.1.1.1'),  // CURP OID
        value: String(p.curp),  // stored encrypted; only clinician role decrypts
      ),
    ],
    name: [HumanName(family: p.lastName, given: [p.firstName])],
    birthDate: FhirDate(p.dateOfBirth),
    gender: p.sex == Sex.male ? PatientGender.male : PatientGender.female,
    extension_: [
      FhirExtension(
        url: FhirUri('http://mcsf.neuralhack.mx/fhir/ext/education-years'),
        valueInteger: Integer(p.educationYears),
      ),
      FhirExtension(
        url: FhirUri('http://mcsf.neuralhack.mx/fhir/ext/residence-type'),
        valueCode: Code(p.residenceType.name),
      ),
    ],
  );

  // MoCA → FHIR Observation
  static Observation moaToFhirObservation(MoCAResponse moca, String patientId, String encounterId) =>
    Observation(
      status: ObservationStatus.final_,
      code: CodeableConcept(
        coding: [Coding(
          system: FhirUri('http://loinc.org'),
          code: Code('72133-2'),
          display: String('Montreal Cognitive Assessment [MoCA]'),
        )],
      ),
      subject: Reference(reference: 'Patient/$patientId'),
      encounter: Reference(reference: 'Encounter/$encounterId'),
      valueInteger: Integer(moca.adjustedTotal),
      component: [
        _obsComponent('72104-3', 'Visuospatial/Executive', moca.visuospatialExecutive),
        _obsComponent('72105-0', 'Naming', moca.naming),
        _obsComponent('72106-8', 'Attention', moca.attention),
        _obsComponent('72107-6', 'Language', moca.language),
        _obsComponent('72108-4', 'Abstraction', moca.abstraction),
        _obsComponent('72109-2', 'Delayed recall', moca.delayedRecall),
        _obsComponent('72110-0', 'Orientation', moca.orientation),
      ],
    );
}
```

---

## 6. Module Specifications

### 6.1 Clinical Module

#### MoCA Digital Implementation

The MoCA is administered in 5 structured sections, each on its own screen:

**Section 1 — Visuospatial/Executive (5 points)**
- Trail-making: User connects circles A→1→B→2 on a digital canvas
- Copy cube: Drawing task (captured as stroke data)
- Draw clock: Setting to 11:10 (primary visuospatial task)

**Section 2 — Naming (3 points)**
- Three animal image cards (lion, rhinoceros, camel)
- Patient speaks name; app uses SpeechToText for auto-capture
- Clinician confirms or overrides

**Section 3 — Attention (6 points)**
- Digit span forward/backward: Audio playback of digit sequences
- Sustained attention: Tap when hearing letter 'A' in a sequence
- Serial 7s: Subtract 7 from 100, five times

**Section 4 — Language (3 points)**
- Sentence repetition: Two complex sentences played via TTS
- Phonemic fluency: 60-second timer, patient generates F-words

**Section 5 — Abstraction, Recall, Orientation (13 points)**
- Abstraction: Category similarity (train/bicycle, watch/ruler)
- Delayed recall: 5-word list from Section 3
- Orientation: Date, month, year, day, place, city

```dart
// Session orchestrator BLoC
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  static const moduleOrder = [
    SessionModule.consent,
    SessionModule.demographics,
    SessionModule.clinical,       // MoCA → MMSE → PHQ-9 → AD8 → Katz
    SessionModule.visuospatial,   // Clock drawing → Copy figure
    SessionModule.acoustic,       // Semantic fluency → Picture description
    SessionModule.review,         // Clinician review + sign-off
  ];
}
```

### 6.2 Visuospatial Module

#### Drawing Canvas Implementation

```dart
// lib/features/visuospatial_module/widgets/drawing_canvas.dart

class DrawingCanvas extends StatefulWidget {
  final Function(List<DrawingStroke> strokes) onComplete;
  final String taskType;       // 'clock' | 'copy' | 'trail'
  final Widget? referenceImage;
  
  const DrawingCanvas({
    required this.onComplete,
    required this.taskType,
    this.referenceImage,
  });
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingStroke> _strokes = [];
  final List<StrokePoint> _currentPoints = [];
  int? _strokeStartMs;
  
  void _onPointerDown(PointerDownEvent e) {
    _strokeStartMs = DateTime.now().millisecondsSinceEpoch;
    _currentPoints.clear();
    _currentPoints.add(StrokePoint(
      x: e.localPosition.dx,
      y: e.localPosition.dy,
      timestampMs: 0,
      pressure: e.pressure,
    ));
  }
  
  void _onPointerMove(PointerMoveEvent e) {
    final t = DateTime.now().millisecondsSinceEpoch - _strokeStartMs!;
    final prev = _currentPoints.last;
    final dx = e.localPosition.dx - prev.x;
    final dy = e.localPosition.dy - prev.y;
    final dist = sqrt(dx * dx + dy * dy);
    final velocity = dist / max(t - (_currentPoints.length > 1 
        ? _currentPoints[_currentPoints.length - 2].timestampMs : 0), 1);
    
    _currentPoints.add(StrokePoint(
      x: e.localPosition.dx,
      y: e.localPosition.dy,
      timestampMs: t,
      pressure: e.pressure,
      velocity: velocity,
    ));
  }
  
  void _onPointerUp(PointerUpEvent e) {
    if (_currentPoints.length < 2) return;
    final stroke = StrokeAnalyzer.processStroke(
      strokeId: const Uuid().v4(),
      points: List.from(_currentPoints),
      startTimeMs: _strokeStartMs!,
      endTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
    _strokes.add(stroke);
  }
}
```

#### StrokeAnalyzer

```dart
// lib/features/visuospatial_module/services/stroke_analyzer.dart

class StrokeAnalyzer {
  static DrawingStroke processStroke({
    required String strokeId,
    required List<StrokePoint> points,
    required int startTimeMs,
    required int endTimeMs,
  }) {
    final velocities = points.skip(1).map((p) => p.velocity ?? 0.0).toList();
    final pressures = points.map((p) => p.pressure ?? 0.5).toList();
    
    // Path length via Euclidean distances
    double pathLength = 0.0;
    for (int i = 1; i < points.length; i++) {
      final dx = points[i].x - points[i-1].x;
      final dy = points[i].y - points[i-1].y;
      pathLength += sqrt(dx * dx + dy * dy);
    }
    
    return DrawingStroke(
      strokeId: strokeId,
      points: points,
      startTimeMs: startTimeMs,
      endTimeMs: endTimeMs,
      meanVelocity: velocities.isEmpty ? 0 : velocities.reduce((a,b) => a+b) / velocities.length,
      velocityVariability: _std(velocities),
      meanPressure: pressures.reduce((a,b) => a+b) / pressures.length,
      pathLength: pathLength,
    );
  }

  static ClockDrawingAnalysis analyzeClockDrawing(List<DrawingStroke> strokes, Size canvasSize) {
    // Detect circle: first large closed stroke
    // Detect numbers: 12 approximate positions in polar coordinates
    // Detect hands: two line segments from center
    // This is a heuristic v0.02 baseline; v1.0 will use CNN inference
    return ClockDrawingAnalysis(
      circlePresent: _detectCircle(strokes, canvasSize),
      circleClosure: _measureClosure(strokes),
      numbersPresent: _detectNumbers(strokes),
      handsPresent: _detectHands(strokes, canvasSize),
      timeCorrect: false,   // requires CNN in v1.0
      numberPlacementError: _measureNumberPlacementError(strokes, canvasSize),
      cdcScore: _computeCDCScore(strokes, canvasSize),
      errorTags: _generateErrorTags(strokes, canvasSize),
    );
  }
  
  static double _std(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a,b) => a+b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a,b) => a+b) / values.length;
    return sqrt(variance);
  }
}
```

### 6.3 Acoustic Module

```dart
// lib/features/acoustic_module/pages/speech_prompt_page.dart

// Prompts used (aligned with Phase 1/2 literature):
const kSpeechPrompts = {
  'semantic_fluency': {
    'en': 'Name as many animals as you can in 60 seconds.',
    'es': 'Nombre todos los animales que pueda en 60 segundos.',
    'duration': 60,
  },
  'phonemic_fluency': {
    'en': 'Name as many words starting with the letter F as you can in 60 seconds.',
    'es': 'Nombre todas las palabras que empiecen con la letra F en 60 segundos.',
    'duration': 60,
  },
  'picture_description': {
    'en': 'Describe everything you see happening in this picture.',
    'es': 'Describa todo lo que ve que está pasando en esta imagen.',
    'duration': 90,
    'stimulus': 'cookie_theft_scene',   // Boston Aphasia stimulus
  },
};

class RecorderService {
  final _recorder = AudioRecorder();
  
  Future<String> startRecording(String sessionId, String taskType) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/sessions/$sessionId/${taskType}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
        bitRate: 128000,
      ),
      path: path,
    );
    return path;
  }
  
  Future<String> stopRecording() async => await _recorder.stop() ?? '';
}

// Basic prosody extraction (client-side v0.02)
class ProsodyExtractor {
  static AcousticFeatures extractBasic({
    required String transcript,      // From speech_to_text
    required Duration duration,
    required int pauseCount,
  }) {
    final words = transcript.split(' ').where((w) => w.isNotEmpty).toList();
    final uniqueWords = words.map((w) => w.toLowerCase()).toSet();
    
    return AcousticFeatures(
      wordCount: words.length,
      speechRate: words.length / duration.inSeconds.toDouble(),
      typeTokenRatio: words.isEmpty ? 0 : uniqueWords.length / words.length,
      pauseCount: pauseCount,
      disfluencyRate: _countDisfluencies(words) / max(words.length, 1),
    );
  }
  
  static int _countDisfluencies(List<String> words) =>
    words.where((w) => ['uh', 'um', 'er', 'eh', 'este', 'este...', 'mmm']
        .contains(w.toLowerCase())).length;
}
```

---

## 7. Security & HIPAA Implementation

### 7.1 Encryption Architecture

```dart
// lib/core/crypto/aes_service.dart

class AesService {
  // AES-256-GCM symmetric encryption for PHI fields
  static const _keyLength = 32;  // 256 bits
  static const _ivLength = 12;   // 96 bits for GCM
  static const _tagLength = 16;  // 128-bit authentication tag

  // Key derivation from user credentials + device ID (never stored in plaintext)
  static Future<Uint8List> deriveKey(String userId, String deviceId) async {
    final salt = utf8.encode('$userId:$deviceId:mcsf-v002');
    final keyMaterial = utf8.encode(await _getStoredSecret(userId));
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(keyMaterial),
      nonce: salt,
    );
    return Uint8List.fromList(await secretKey.extractBytes());
  }

  static Future<String> encrypt(String plaintext, Uint8List key) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);
    final nonce = algorithm.newNonce();
    final sealed = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );
    // Encode: iv(12) || ciphertext || tag(16)
    final combined = [
      ...nonce,
      ...sealed.cipherText,
      ...sealed.mac.bytes,
    ];
    return base64Url.encode(combined);
  }

  static Future<String> decrypt(String cipherBase64, Uint8List key) async {
    final combined = base64Url.decode(cipherBase64);
    final nonce = combined.sublist(0, _ivLength);
    final tag = combined.sublist(combined.length - _tagLength);
    final ciphertext = combined.sublist(_ivLength, combined.length - _tagLength);

    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);
    final result = await algorithm.decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: Mac(tag)),
      secretKey: secretKey,
    );
    return utf8.decode(result);
  }
}
```

### 7.2 Audit Logger (21 CFR Part 11 compliant)

```dart
// lib/core/crypto/audit_logger.dart

@immutable
class AuditEntry {
  final String id;
  final String userId;
  final String action;       // CREATE | READ | UPDATE | VOID | EXPORT | LOGIN
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final String previousHash; // SHA-256 of previous entry (chain integrity)
  final String hash;         // SHA-256(id + userId + action + timestamp + previousHash)
  
  String computeHash() => sha256.convert(
    utf8.encode('$id:$userId:$action:$resourceType:$resourceId:${timestamp.toIso8601String()}:$previousHash')
  ).toString();
}

class AuditLogger {
  final _db = Supabase.instance.client;
  
  Future<void> log({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
  }) async {
    final previous = await _getLatestEntry();
    final entry = AuditEntry(
      id: const Uuid().v4(),
      userId: userId,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      timestamp: DateTime.now().toUtc(),
      previousHash: previous?.hash ?? 'GENESIS',
    );
    
    await _db.from('audit_log').insert({
      'id': entry.id,
      'user_id': entry.userId,
      'action': entry.action,
      'resource_type': entry.resourceType,
      'resource_id': entry.resourceId,
      'timestamp': entry.timestamp.toIso8601String(),
      'previous_hash': entry.previousHash,
      'hash': entry.computeHash(),
    });
  }
}
```

### 7.3 Role-Based Access Control

```dart
enum UserRole { clinician, patient, researcher, admin, superAdmin }

// Firebase custom claims set on auth token
class RoleGuard {
  static bool canViewPatientPHI(UserRole role) => 
    [UserRole.clinician, UserRole.admin, UserRole.superAdmin].contains(role);
  
  static bool canExportResearchData(UserRole role) => 
    [UserRole.researcher, UserRole.admin, UserRole.superAdmin].contains(role);
  
  static bool canConductSelfAssessment(UserRole role) => 
    role == UserRole.patient;
  
  static bool canViewOwnResults(UserRole role) => 
    role == UserRole.patient;
  
  static bool canSignOffSession(UserRole role) => 
    role == UserRole.clinician;
}
```

### 7.4 Firebase Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function hasRole(role) {
      return isAuthenticated() && 
             request.auth.token.role == role;
    }
    
    function isClinician() { return hasRole('clinician'); }
    function isPatient() { return hasRole('patient'); }
    function isResearcher() { return hasRole('researcher'); }
    function isAdmin() { return hasRole('admin'); }
    
    // Patients — clinician can CRUD; patient can only read own record
    match /patients/{patientId} {
      allow read: if isClinician() || isAdmin() || 
                     (isPatient() && request.auth.uid == resource.data.userId);
      allow write: if isClinician() || isAdmin();
    }
    
    // Sessions — clinician full access; patient read own only
    match /sessions/{sessionId} {
      allow read: if isClinician() || isAdmin() ||
                     (isPatient() && request.auth.uid == resource.data.patientUserId);
      allow create, update: if isClinician();
      allow delete: if isAdmin();
    }
    
    // Research export — anonymized; researcher read only
    match /research_exports/{exportId} {
      allow read: if isResearcher() || isAdmin();
      allow write: if isAdmin();
    }
    
    // Audit log — append only; admin read
    match /audit_log/{entryId} {
      allow read: if isAdmin();
      allow create: if isAuthenticated();
      allow update, delete: if false;  // IMMUTABLE
    }
  }
}
```

---

## 8. Backend API Architecture

### 8.1 Cloud Functions (Firebase)

```typescript
// functions/src/index.ts

// Trigger: new session completed → compute composite risk score
export const onSessionCompleted = functions.firestore
  .document('sessions/{sessionId}')
  .onUpdate(async (change, context) => {
    const session = change.after.data();
    if (session.status !== 'completed') return;
    
    // Call ML microservice
    const riskResponse = await axios.post(
      `${process.env.ML_SERVICE_URL}/predict`,
      {
        sessionId: context.params.sessionId,
        clinicalFeatures: session.clinicalResult,
        visuospatialFeatures: session.visuospatialResult,
        acousticFeatures: session.acousticResult,
      },
      { headers: { 'Authorization': `Bearer ${process.env.ML_API_KEY}` } }
    );
    
    await change.after.ref.update({
      riskScore: riskResponse.data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Write to FHIR server
    await writeFhirDiagnosticReport(session, riskResponse.data);
  });

// Trigger: new audio uploaded → extract prosodic features
export const onAudioUploaded = functions.storage
  .object()
  .onFinalize(async (object) => {
    if (!object.name?.includes('/acoustic/')) return;
    
    const features = await callProsodyService(object.name);
    const sessionId = extractSessionId(object.name);
    
    await admin.firestore()
      .doc(`sessions/${sessionId}`)
      .update({ 'acousticResult.serverFeatures': features });
  });

// FHIR export endpoint
export const exportFhir = functions.https.onCall(async (data, context) => {
  if (!context.auth?.token.role === 'clinician') {
    throw new functions.https.HttpsError('permission-denied', 'Clinician role required');
  }
  const bundle = await buildFhirBundle(data.sessionId);
  return { bundle, checksum: sha256(JSON.stringify(bundle)) };
});
```

### 8.2 ML Microservice (Python FastAPI)

```python
# ml_service/main.py

from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import HTTPBearer
from pydantic import BaseModel
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
import joblib

app = FastAPI(title="MCSF Analytical Engine", version="0.2.0")
security = HTTPBearer()

# Feature extraction from module results
class PredictionRequest(BaseModel):
    session_id: str
    clinical_features: dict
    visuospatial_features: dict
    acoustic_features: dict

class RiskScore(BaseModel):
    risk_score: float          # 0–100
    risk_category: str         # LOW | MODERATE | HIGH | ELEVATED
    module_scores: dict
    normative_deviations: dict # z-scores vs normative sample
    confidence: float
    feature_importances: dict

def build_feature_vector(req: PredictionRequest) -> np.ndarray:
    cf = req.clinical_features
    vf = req.visuospatial_features
    af = req.acoustic_features
    
    return np.array([
        # Clinical domain (normalized 0–1)
        cf.get('moca_adjusted', 0) / 30,
        cf.get('mmse_total', 0) / 30,
        cf.get('phq9_total', 0) / 27,
        cf.get('ad8_positive_count', 0) / 8,
        cf.get('katz_score', 0) / 6,
        cf.get('education_years', 0) / 20,
        float(cf.get('social_isolation', False)),
        float(cf.get('diabetes', False)),
        float(cf.get('hypertension', False)),
        
        # Visuospatial domain
        vf.get('stroke_velocity_mean', 0),
        vf.get('stroke_velocity_std', 0),
        vf.get('mean_pressure', 0),
        vf.get('trajectory_deviation', 0),
        vf.get('symmetry_index', 0),
        vf.get('execution_time_s', 0) / 300,
        vf.get('cdc_score', 0) / 4,
        
        # Acoustic domain
        af.get('word_count', 0) / 100,
        af.get('speech_rate', 0) / 4,
        af.get('type_token_ratio', 0),
        af.get('disfluency_rate', 0),
        af.get('pause_count', 0) / 20,
        af.get('mean_pause_duration_ms', 0) / 2000,
    ])

@app.post("/predict", response_model=RiskScore)
async def predict(req: PredictionRequest, token = Depends(security)):
    verify_token(token.credentials)
    
    features = build_feature_vector(req).reshape(1, -1)
    
    # Load baseline model (v0.02: trained on normative literature data)
    model: RandomForestClassifier = joblib.load('models/rf_baseline_v002.pkl')
    scaler: StandardScaler = joblib.load('models/scaler_v002.pkl')
    
    features_scaled = scaler.transform(features)
    proba = model.predict_proba(features_scaled)[0]  # [normal, mci, dementia]
    
    risk_score = float(proba[1] * 50 + proba[2] * 100)  # weighted composition
    
    # Normative deviation (z-scores vs literature means)
    norms = load_normative_norms()
    deviations = compute_z_scores(req, norms)
    
    # SHAP feature importance
    importances = compute_shap_values(model, features_scaled)
    
    return RiskScore(
        risk_score=round(risk_score, 2),
        risk_category=categorize_risk(risk_score),
        module_scores={
            'clinical': compute_module_score(req.clinical_features),
            'visuospatial': compute_module_score(req.visuospatial_features),
            'acoustic': compute_module_score(req.acoustic_features),
        },
        normative_deviations=deviations,
        confidence=float(max(proba)),
        feature_importances=importances,
    )

@app.get("/normative/{population_group}")
async def get_normative_data(population_group: str, token = Depends(security)):
    """Returns normative statistical baselines by group (rural/urban, age, education)"""
    return load_normative_norms(group=population_group)

@app.post("/export/research-dataset")
async def export_research_dataset(
    session_ids: list[str],
    anonymize: bool = True,
    token = Depends(security)
):
    """Export anonymized feature vectors for research analysis"""
    dataset = []
    for sid in session_ids:
        session = await fetch_session(sid)
        features = build_feature_vector(session)
        if anonymize:
            features = anonymize_features(features)  # Remove direct identifiers
        dataset.append({'session_id': sid if not anonymize else hash_id(sid), 
                        'features': features.tolist()})
    return {'dataset': dataset, 'n': len(dataset), 'version': '0.2.0'}
```

---

## 9. Database Schema

### 9.1 Supabase (PostgreSQL) — Core Tables

```sql
-- Enable Row-Level Security on all tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Patients
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fhir_id TEXT UNIQUE NOT NULL,
    
    -- PHI (stored AES-256 encrypted as base64)
    curp_encrypted TEXT NOT NULL,
    first_name_encrypted TEXT NOT NULL,
    last_name_encrypted TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    
    -- Demographics (non-PHI)
    sex VARCHAR(10) NOT NULL CHECK (sex IN ('male','female','other','unknown')),
    education_years INTEGER NOT NULL CHECK (education_years >= 0 AND education_years <= 30),
    occupation TEXT,
    residence_type VARCHAR(10) NOT NULL CHECK (residence_type IN ('rural','urban')),
    institution_id UUID NOT NULL,
    
    -- Risk factors
    social_isolation BOOLEAN DEFAULT false,
    family_history_dementia BOOLEAN DEFAULT false,
    diabetes BOOLEAN DEFAULT false,
    hypertension BOOLEAN DEFAULT false,
    depression_history BOOLEAN DEFAULT false,
    rural_exposure_over_20y BOOLEAN DEFAULT false,
    chronic_stress BOOLEAN DEFAULT false,
    post_trauma_history BOOLEAN DEFAULT false,
    sleep_hours_per_night NUMERIC(3,1),
    physical_activity_level VARCHAR(20),
    nutrition_risk VARCHAR(20),
    
    -- Consent
    consent_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    consent_fhir_id TEXT,
    consent_timestamp TIMESTAMPTZ,
    
    -- Meta
    enrolled_by UUID NOT NULL,              -- Clinician user_id
    enrollment_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Sessions
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fhir_encounter_id TEXT UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES patients(id),
    clinician_id UUID NOT NULL,
    session_type VARCHAR(30) NOT NULL,     -- 'clinician_led' | 'self_assessment'
    
    -- Module status
    consent_completed BOOLEAN DEFAULT false,
    clinical_completed BOOLEAN DEFAULT false,
    visuospatial_completed BOOLEAN DEFAULT false,
    acoustic_completed BOOLEAN DEFAULT false,
    
    -- Timing
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    administration_time_seconds INTEGER,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
    
    -- Results (JSONB for flexibility — indexed GIN)
    clinical_result JSONB,
    visuospatial_result JSONB,
    acoustic_result JSONB,
    risk_score JSONB,
    
    -- Integrity
    clinician_notes TEXT,
    clinician_signature TEXT,          -- SHA-256 of clinician credentials + session hash
    data_checksum TEXT NOT NULL,
    device_id TEXT NOT NULL,
    app_version TEXT NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- MoCA responses (normalized for analysis)
CREATE TABLE moca_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id),
    patient_id UUID NOT NULL REFERENCES patients(id),
    
    visuospatial_executive INTEGER NOT NULL CHECK (visuospatial_executive BETWEEN 0 AND 5),
    naming INTEGER NOT NULL CHECK (naming BETWEEN 0 AND 3),
    attention INTEGER NOT NULL CHECK (attention BETWEEN 0 AND 6),
    language INTEGER NOT NULL CHECK (language BETWEEN 0 AND 3),
    abstraction INTEGER NOT NULL CHECK (abstraction BETWEEN 0 AND 2),
    delayed_recall INTEGER NOT NULL CHECK (delayed_recall BETWEEN 0 AND 5),
    orientation INTEGER NOT NULL CHECK (orientation BETWEEN 0 AND 6),
    
    raw_total INTEGER GENERATED ALWAYS AS (
        visuospatial_executive + naming + attention + language + 
        abstraction + delayed_recall + orientation
    ) STORED,
    education_years INTEGER NOT NULL,
    education_adjustment_applied BOOLEAN DEFAULT false,
    adjusted_total INTEGER NOT NULL,
    
    administration_time_seconds INTEGER,
    completed_at TIMESTAMPTZ NOT NULL,
    item_responses JSONB                 -- Full QuestionnaireResponse for FHIR
);

-- Stroke data (visuospatial module)
CREATE TABLE drawing_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id),
    task_type VARCHAR(30) NOT NULL,      -- 'clock_drawing' | 'copy_figure' | 'trail_making'
    
    -- Aggregate metrics
    stroke_count INTEGER NOT NULL,
    execution_time_seconds NUMERIC(8,2),
    stroke_velocity_mean NUMERIC(10,4),
    stroke_velocity_std NUMERIC(10,4),
    mean_pressure NUMERIC(6,4),
    trajectory_deviation NUMERIC(10,4),
    symmetry_index NUMERIC(6,4),
    lift_count INTEGER,
    total_path_length NUMERIC(12,4),
    
    -- Clock-specific
    cdc_score INTEGER CHECK (cdc_score BETWEEN 0 AND 4),
    circle_present BOOLEAN,
    numbers_present BOOLEAN,
    hands_present BOOLEAN,
    number_placement_error NUMERIC(8,4),
    clock_error_tags JSONB,
    
    -- Raw data + image
    stroke_data_jsonb JSONB NOT NULL,    -- Full List<DrawingStroke>
    image_png_fhir_media_id TEXT,
    
    completed_at TIMESTAMPTZ NOT NULL
);

-- Acoustic recordings
CREATE TABLE acoustic_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id),
    task_type VARCHAR(30) NOT NULL,
    
    audio_file_path TEXT NOT NULL,       -- GCS path (encrypted)
    fhir_media_id TEXT,
    recording_duration_seconds NUMERIC(8,2),
    sample_rate_hz INTEGER DEFAULT 44100,
    
    -- Client-side features
    word_count INTEGER,
    speech_rate NUMERIC(8,4),
    type_token_ratio NUMERIC(6,4),
    pause_count INTEGER,
    mean_pause_duration_ms NUMERIC(8,2),
    disfluency_rate NUMERIC(6,4),
    
    -- Server-side features (async)
    mfcc_coefficients NUMERIC[],         -- MFCC 1–13
    f0_mean NUMERIC(8,4),
    f0_std NUMERIC(8,4),
    server_processing_status VARCHAR(20) DEFAULT 'pending',
    
    completed_at TIMESTAMPTZ NOT NULL
);

-- Audit log (immutable — append only)
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    action VARCHAR(30) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    previous_hash TEXT NOT NULL,
    hash TEXT NOT NULL,
    metadata JSONB
);

-- Prevent updates/deletes on audit_log
CREATE RULE no_update_audit AS ON UPDATE TO audit_log DO INSTEAD NOTHING;
CREATE RULE no_delete_audit AS ON DELETE TO audit_log DO INSTEAD NOTHING;

-- Research export view (anonymized)
CREATE VIEW research_export AS
SELECT
    encode(sha256(p.id::text::bytea), 'hex') AS patient_hash,    -- Anonymized ID
    extract(year from age(p.date_of_birth)) / 10 * 10 AS age_decade,
    p.sex,
    p.education_years,
    p.residence_type,
    p.social_isolation,
    p.diabetes,
    p.hypertension,
    m.adjusted_total AS moca_score,
    d.stroke_velocity_mean,
    d.cdc_score,
    a.type_token_ratio,
    a.speech_rate,
    a.disfluency_rate,
    s.risk_score->>'risk_score' AS composite_risk_score,
    s.risk_score->>'risk_category' AS risk_category
FROM sessions s
JOIN patients p ON s.patient_id = p.id
LEFT JOIN moca_responses m ON m.session_id = s.id
LEFT JOIN drawing_sessions d ON d.session_id = s.id AND d.task_type = 'clock_drawing'
LEFT JOIN acoustic_sessions a ON a.session_id = s.id AND a.task_type = 'semantic_fluency'
WHERE s.status = 'completed'
  AND p.consent_status = 'signed';

-- Row-Level Security Policies
CREATE POLICY clinician_patients ON patients
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_roles ur 
            WHERE ur.user_id = auth.uid() 
            AND ur.role IN ('clinician', 'admin', 'super_admin')
        )
        OR (
            EXISTS (
                SELECT 1 FROM user_roles ur 
                WHERE ur.user_id = auth.uid() AND ur.role = 'patient'
            )
            AND id = (
                SELECT patient_id FROM patient_user_links 
                WHERE user_id = auth.uid()
            )
        )
    );
```

---

## 10. Analytical Engine (v0.02)

### 10.1 Normative Baseline Approach

In v0.02, without a proprietary dataset, the analytical engine uses:

1. **Literature-derived normative values** from validated Mexican population studies (Mejía-Arango et al., 2024; Custodio et al., 2023; Sosa-Ortiz et al., 2012)
2. **Education-adjusted MoCA norms** (+1 point correction for ≤12 years schooling, per Nasreddine et al., 2005 and Phase 1 validation)
3. **Stratified z-score computation** against normative means by age group, education level, and residence type

```python
# ml_service/normative_engine.py

NORMATIVE_BASELINES = {
    # Stratified by: (age_group, education_level, residence)
    # Source: Phase 1 data + Mejía-Arango (2024), Sosa-Ortiz (2012)
    ('60-70', 'low', 'rural'):   {'moca_mean': 19.8, 'moca_std': 5.2},
    ('60-70', 'low', 'urban'):   {'moca_mean': 23.1, 'moca_std': 3.8},
    ('60-70', 'high', 'urban'):  {'moca_mean': 25.9, 'moca_std': 2.9},
    ('70-80', 'low', 'rural'):   {'moca_mean': 18.2, 'moca_std': 5.8},
    ('70-80', 'low', 'urban'):   {'moca_mean': 21.5, 'moca_std': 4.4},
    ('>80', 'low', 'rural'):     {'moca_mean': 16.5, 'moca_std': 6.1},
    # ... extended table in normative_data.json
}

def compute_z_scores(session_data: dict, patient_profile: dict) -> dict:
    age_group = get_age_group(patient_profile['age'])
    edu_level = 'low' if patient_profile['education_years'] <= 8 else 'high'
    residence = patient_profile['residence_type']
    
    key = (age_group, edu_level, residence)
    norms = NORMATIVE_BASELINES.get(key, NORMATIVE_BASELINES[('60-70', 'low', 'urban')])
    
    moca = session_data.get('clinical_features', {}).get('moca_adjusted', 0)
    z_moca = (moca - norms['moca_mean']) / norms['moca_std']
    
    return {
        'moca_z': round(z_moca, 2),
        'moca_percentile': round(norm.cdf(z_moca) * 100, 1),
        'interpretation': interpret_z(z_moca),
        'normative_group': key,
    }
```

### 10.2 Risk Score Algorithm (v0.02)

```python
def compute_risk_score(features: dict) -> float:
    """
    v0.02 weighted composite score
    Weights derived from Phase 1 prevalence + SHAP importance from literature
    Will be replaced by trained RF model once pilot dataset reaches n≥50
    """
    weights = {
        'moca_normalized': 0.38,       # SHAP=0.38 from Phase 2 paper
        'lexical_diversity': 0.29,     # SHAP=0.29
        'drawing_precision': 0.24,     # SHAP=0.24
        'reaction_time': 0.09,         # Remaining weight
    }
    
    moca_normalized = 1 - (features.get('moca_adjusted', 30) / 30)
    lexical_div_deficit = 1 - features.get('type_token_ratio', 1.0)
    drawing_error = 1 - (features.get('cdc_score', 4) / 4)
    reaction_normalized = min(features.get('execution_time_s', 60) / 300, 1.0)
    
    risk = (
        moca_normalized * weights['moca_normalized'] +
        lexical_div_deficit * weights['lexical_diversity'] +
        drawing_error * weights['drawing_precision'] +
        reaction_normalized * weights['reaction_time']
    ) * 100
    
    return round(risk, 2)

def categorize_risk(score: float) -> str:
    if score < 30:   return 'LOW'
    if score < 50:   return 'MODERATE'
    if score < 70:   return 'HIGH'
    return 'ELEVATED'
```

---

## 11. UI/UX Design System

### 11.1 Theme Tokens

```dart
// lib/app/theme.dart

class McsfTheme {
  // Colors — medical-grade clarity
  static const primary = Color(0xFF1A5F9B);        // Deep medical blue
  static const primaryLight = Color(0xFFE8F2FF);
  static const secondary = Color(0xFF0D9E75);       // Teal — cognitive/neural
  static const warning = Color(0xFFE8891F);         // Amber — moderate risk
  static const danger = Color(0xFFD14030);          // Red — elevated risk
  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF5A6072);
  static const border = Color(0xFFE2E5EE);

  // Risk level colors — consistent across all widgets
  static const riskColors = {
    'LOW': Color(0xFF16A34A),
    'MODERATE': Color(0xFFE8891F),
    'HIGH': Color(0xFFD97706),
    'ELEVATED': Color(0xFFD14030),
  };

  // Typography
  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'DMSans', fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontFamily: 'DMSans', fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(fontFamily: 'DMSans', fontSize: 14, height: 1.5),
    labelLarge: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600),
  );
  
  // Spacing
  static const spacing = {
    'xs': 4.0, 'sm': 8.0, 'md': 16.0, 'lg': 24.0, 'xl': 32.0, 'xxl': 48.0,
  };
  
  // Accessibility — minimum touch targets
  static const minTouchTarget = 48.0;  // WCAG 2.1 AA
  static const minFontSizeAccessible = 16.0;
}
```

### 11.2 Patient vs Clinician UI Differentiation

**Clinician Interface**: Dense information architecture, data tables, keyboard shortcuts, multi-patient queue management, full scoring rubrics visible, FHIR export, cohort analytics.

**Patient Self-Assessment Interface**: Large tap targets (≥56px), plain language, one question per screen, progress indicator, bilingual (Spanish/English), TTS support, large font option, encouraging feedback, caregiver-assist mode.

```dart
// Adaptive UI based on role
Widget buildHomePage(UserRole role) => switch (role) {
  UserRole.clinician => const ClinicianDashboardPage(),
  UserRole.patient => const PatientPortalPage(),
  UserRole.researcher => const ResearchAnalyticsPage(),
  UserRole.admin => const AdminConsolePage(),
  _ => const LoginPage(),
};
```

### 11.3 Accessibility Requirements

- **WCAG 2.1 AA** compliance throughout
- **Semantic labels** on all interactive elements (Semantics widget)
- **Contrast ratio** ≥ 4.5:1 for normal text, ≥ 3:1 for large text
- **TTS integration** (`flutter_tts`) for all question prompts
- **Font scaling** support (respects system font size)
- **Reduced motion** mode (disables animations)
- **Caregiver mode**: Side-by-side clinician/patient view for in-clinic use
- **Offline indicator**: Clear visual state when working without connectivity

---

## 12. Project IDX Setup Guide

### 12.1 IDX Workspace Configuration

```nix
# .idx/dev.nix
{ pkgs, ... }: {
  channel = "stable-23.11";
  
  packages = [
    pkgs.flutter
    pkgs.dart
    pkgs.androidStudioPackages.stable
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.firebase-tools
    pkgs.nodejs_20
    pkgs.openssl
  ];

  env = {
    FLUTTER_ROOT = "${pkgs.flutter}";
    ANDROID_HOME = "$HOME/.android";
    JAVA_HOME = "${pkgs.jdk17}";
    PUB_CACHE = "$HOME/.pub-cache";
  };

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
      "ms-python.python"
      "ms-python.vscode-pylance"
      "GoogleCloudTools.cloudcode"
      "rangav.vscode-thunder-client"
    ];

    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "-d" "web-server" "--web-port" "3000" "--web-hostname" "0.0.0.0"];
          manager = "web";
        };
      };
    };

    workspace = {
      onCreate = {
        flutter-get = "flutter pub get";
        build-runner = "flutter pub run build_runner build --delete-conflicting-outputs";
        python-deps = "pip install -r ml_service/requirements.txt";
        firebase-init = "echo 'Run: firebase login && firebase init'";
      };
      onStart = {
        flutter-run = "flutter run -d chrome";
      };
    };
  };
}
```

### 12.2 Initial Project Bootstrap

```bash
# Step 1: Clone and open in IDX
git clone https://github.com/[your-org]/mcsf.git
# Open project.idx link or import into idx.google.com

# Step 2: Configure Firebase
firebase login
firebase init   # Select: Firestore, Functions, Storage, Auth, Hosting

# Step 3: Set environment variables in IDX
# Create .env (gitignored):
FIREBASE_PROJECT_ID=mcsf-pilot
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=xxxx
ML_SERVICE_URL=http://localhost:8000
GOOGLE_CLOUD_HEALTHCARE_API=https://healthcare.googleapis.com/v1/projects/mcsf-pilot/...

# Step 4: Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Step 5: Run ML service locally
cd ml_service && pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Step 6: Run app
flutter run -d chrome    # Web (IDX preview)
flutter run -d android   # Android (emulator or physical device)
flutter run -d ios       # iOS (requires macOS + Xcode)
```

### 12.3 Repository Structure

```
mcsf/
├── lib/                    # Flutter app (see Section 4)
├── ml_service/             # Python FastAPI analytical engine
│   ├── main.py
│   ├── normative_engine.py
│   ├── models/             # Trained .pkl files
│   ├── requirements.txt
│   └── tests/
├── functions/              # Firebase Cloud Functions (TypeScript)
│   ├── src/
│   └── package.json
├── firestore.rules
├── storage.rules
├── firebase.json
├── pubspec.yaml
├── .idx/
│   └── dev.nix
├── docs/
│   ├── MCSF_v0.02_Platform_Documentation.md  ← this file
│   ├── FHIR_resource_map.md
│   ├── HIPAA_compliance_checklist.md
│   └── IRB_protocol_template.md
└── README.md
```

---

## 13. Testing Strategy

### 13.1 Unit Tests

```dart
// test/unit/stroke_analyzer_test.dart
void main() {
  group('StrokeAnalyzer', () {
    test('computes mean velocity correctly', () {
      final points = [
        StrokePoint(x: 0, y: 0, timestampMs: 0, velocity: 2.0),
        StrokePoint(x: 10, y: 0, timestampMs: 100, velocity: 4.0),
        StrokePoint(x: 20, y: 0, timestampMs: 200, velocity: 6.0),
      ];
      final stroke = StrokeAnalyzer.processStroke(
        strokeId: 'test-1', points: points, startTimeMs: 0, endTimeMs: 200);
      expect(stroke.meanVelocity, closeTo(4.0, 0.01));
    });
  });
  
  group('MoCA Education Adjustment', () {
    test('applies +1 point adjustment for ≤12 years education', () {
      final response = MoCAResponse(
        visuospatialExecutive: 4, naming: 3, attention: 5,
        language: 2, abstraction: 1, delayedRecall: 3, orientation: 5,
        educationYears: 6, rawTotal: 23, adjustedTotal: 24,
        educationAdjustmentApplied: true, ...);
      expect(response.adjustedTotal, 24);
    });
  });
}
```

### 13.2 Widget Tests

```dart
// test/widget/consent_flow_test.dart
void main() {
  testWidgets('consent flow requires signature before proceeding', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ConsentBloc(),
        child: const ConsentPresentationPage(),
      ),
    );
    
    final nextButton = find.byKey(const Key('consent_next_button'));
    expect(nextButton, findsOneWidget);
    
    // Should be disabled before scrolling to bottom
    final button = tester.widget<ElevatedButton>(nextButton);
    expect(button.onPressed, isNull);
  });
}
```

### 13.3 Integration Tests

```dart
// test/integration/full_session_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete screening session end-to-end', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Login as clinician
    await _loginAsClinician(tester);
    
    // Select/create patient
    await _selectOrCreatePatient(tester);
    
    // Complete consent
    await _completeConsentFlow(tester);
    
    // Complete MoCA
    await _completeMoCA(tester);
    
    // Complete clock drawing
    await _completeClockDrawing(tester);
    
    // Complete speech task
    await _completeSpeechTask(tester);
    
    // Verify session results appear
    expect(find.byKey(const Key('risk_score_gauge')), findsOneWidget);
    expect(find.byKey(const Key('session_report_card')), findsOneWidget);
  });
}
```

---

## 14. Deployment & CI/CD

### 14.1 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: MCSF CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release --dart-define=ENV=production
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SA }}'

  ml-service:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: '${{ secrets.GCP_SA_KEY }}'
      - run: gcloud run deploy mcsf-ml --source ml_service/ --region us-central1
```

### 14.2 Environment Configuration

| Environment | Purpose | Data |
|---|---|---|
| `development` | Local IDX development | Synthetic test data only |
| `staging` | Integration testing | De-identified pilot data |
| `production` | Clinical deployment | Real PHI under full HIPAA controls |

---

## 15. Roadmap to v1.0

| Version | Milestone | Timeline |
|---|---|---|
| **v0.02** (current) | Framework scaffolding; literature-derived normatives; pilot data collection begins | Month 1–2 |
| **v0.05** | n≥30 pilot sessions; first RF model trained on local data; HL7 v2 adapter | Month 3–4 |
| **v0.07** | CNN clock drawing analysis integrated; OpenSMILE server-side MFCC extraction; Zarit caregiver module | Month 5–6 |
| **v0.10** | n≥100 sessions; model validation vs neurologist gold standard; SHAP explainability reports; caregiver portal | Month 7–9 |
| **v0.15** | Longitudinal tracking (3-month follow-up); Neural CDE time-series model; federated learning architecture designed | Month 10–12 |
| **v1.0** | n≥200 sessions; regulatory pre-submission package (COFEPRIS); full FHIR R4 interoperability; IRB-approved research dataset published | Month 13–18 |

### v1.0 Model Target Specifications

| Metric | v0.02 Baseline | v1.0 Target |
|---|---|---|
| AUC (binary) | Literature-derived | ≥0.88 |
| Sensitivity (MCI) | — | ≥85% |
| Specificity | — | ≥82% |
| RMSE (MoCA prediction) | — | ≤4.0 pts |
| Training set | 0 (normative only) | ≥200 sessions |
| Cross-validation | — | Stratified 10-fold |

---

## Ethical Statement

This platform is designed in full accordance with the ethical principles established in the NeuralHack Cognitive AI Phase 1 study (Castillo García, 2025) and under the oversight of the ISSSTE Geriatrics Department. All data collection activities require:

- Written informed consent (or designated representative) per institutional ethical committee protocols
- Direct supervision by licensed medical professionals
- Ethics committee approval from Tecnológico de Monterrey
- Compliance with the Declaration of Helsinki
- Mexican Federal Law on Protection of Personal Data Held by Private Parties (LFPDPPP)

**This platform does not constitute a medical device and must not be used as a standalone diagnostic tool.** Results are supplementary decision-support markers for licensed clinicians only.

---

*MCSF v0.02 — PrepaTec Irapuato · Tecnológico de Monterrey*
*Contact: a01353042@tec.mx*
*GitHub: github.com/[your-org]/mcsf*
*License: Apache 2.0*

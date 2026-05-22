# Data Pipeline & ML Ensemble Framework

## 1. Modality Pipelines

The framework orchestrates data collection across three primary channels. Each channel applies preliminary transformations before backend synchronization.

### 1.1 Clinical Data Pipeline
1.  **Input**: Digital forms capturing MoCA, MMSE, PHQ-9, AD8, and Katz ADL scores.
2.  **Processing**: Client-side validation and summation. Adjustment calculations (e.g., MoCA education adjustment).
3.  **Output**: `clinical_vec` containing discrete numerical arrays.
4.  **FHIR Mapping**: `Observation` and `QuestionnaireResponse` resources.

### 1.2 Visuospatial Data Pipeline
1.  **Input**: `flutter_drawing_board` continuous stroke collection (Clock Drawing, Figure Copying).
2.  **Raw Metrics**: `x`, `y`, `timestampMs`, `pressure`.
3.  **Processing (Client)**: 
    *   Calculate discrete velocities ($\Delta d / \Delta t$).
    *   Compute mean pressure, lift count, total path length.
4.  **Processing (Server/AI)**:
    *   CNN/Geometric analysis for clock "closure" and "time correct" validation.
5.  **Output**: `visuospatial_vec` and PNG Base64 rendering.
6.  **FHIR Mapping**: `Media` resource (image), encapsulated in `DiagnosticReport`.

### 1.3 Acoustic Data Pipeline
1.  **Input**: High-fidelity PCM WAV recording via `record` package. Prompt-based semantic fluency.
2.  **Processing (Client)**:
    *   Basic silence detection.
    *   Duration and pause counting using amplitude thresholding.
3.  **Processing (Server/AI)**:
    *   OpenSMILE feature extraction (MFCC 1-13, Fundamental Frequency $F_0$).
    *   Speech-to-text semantic analysis (Type-Token Ratio).
4.  **Output**: `acoustic_vec`.
5.  **FHIR Mapping**: `Media` resource (audio).

## 2. Late-Fusion Ensemble Model Architecture

The `FastAPI` AI microservice implements the ensemble framework.

### 2.1 Feature Engineering Matrix
Once all modules in a session are flagged `completed`, the system queries Supabase to construct the matrix $X$:

$$ X = [ ClinicalFeatures \oplus VisuospatialFeatures \oplus AcousticFeatures ] $$

### 2.2 Model Pipeline
1.  **Imputation & Scaling**: Missing values (if permitted) are handled via K-NN imputation. Standard scaling ($Z$-score normalization) is applied to continuous variables like `strokeVelocityMean` and `F0_mean`.
2.  **Dimensionality Reduction**: Optional PCA for acoustic MFCC variables to prevent overfitting on small pilot datasets.
3.  **Base Classifiers**:
    *   Random Forest Classifier (Primary predictor for feature importance).
    *   Support Vector Machine (RBF kernel).
    *   Logistic Regression (Baseline).
4.  **Meta-Classifier (Soft Voting)**:
    *   The probability outputs from base classifiers are averaged.
    *   Normative Statistical Deviation ($Z$-scores compared to healthy cohorts) acts as a heuristic multiplier.

### 2.3 Output Interpretation
The system generates a `RiskScore` (0.0 to 1.0) indicating the likelihood of deviation from normative cognitive aging. The platform does *not* output a diagnosis (e.g., "Alzheimer's"), but rather a "Cognitive Attrition Index" to alert the clinician.

## 3. Database Schema Mapping (Supabase/PostgreSQL)

```sql
-- Conceptual Mapping
CREATE TABLE patients (
  id UUID PRIMARY KEY,
  fhir_id VARCHAR UNIQUE,
  demographics JSONB,
  risk_factors JSONB
);

CREATE TABLE sessions (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES patients(id),
  clinician_id UUID,
  start_time TIMESTAMP,
  status VARCHAR,
  composite_hash VARCHAR -- SHA-256
);

CREATE TABLE clinical_results (
  session_id UUID REFERENCES sessions(id),
  moca_score INT,
  phq9_score INT,
  ad8_score INT
);

CREATE TABLE visuospatial_results (
  session_id UUID REFERENCES sessions(id),
  stroke_metrics JSONB,
  image_url VARCHAR
);

CREATE TABLE acoustic_results (
  session_id UUID REFERENCES sessions(id),
  prosody_metrics JSONB,
  audio_url VARCHAR
);
```

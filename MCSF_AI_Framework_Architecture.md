# MCSF — AI Framework & Deep Learning Architecture
## Cognitive Screening Pipeline Documentation
### Version: v0.02 → v1.0 Roadmap
**PrepaTec · Tecnológico de Monterrey · Campus Irapuato**
*NeuralHack Cognitive AI — Research Extension*

---

## Table of Contents

1. [Document Scope](#1-document-scope)
2. [Full Pipeline Overview](#2-full-pipeline-overview)
3. [Data Inputs — Complete Variable Taxonomy](#3-data-inputs--complete-variable-taxonomy)
4. [Standardized Clinical Instruments](#4-standardized-clinical-instruments)
5. [Biomarker Classification & Storage Schema](#5-biomarker-classification--storage-schema)
6. [v0.02 Data Collection Pipeline (Current)](#6-v002-data-collection-pipeline-current)
7. [v0.02 Analytical Logic — Rule-Based Engine](#7-v002-analytical-logic--rule-based-engine)
8. [Future AI Architecture — Full Ensemble (v1.0)](#8-future-ai-architecture--full-ensemble-v10)
9. [Transformer Module](#9-transformer-module)
10. [Bidirectional LSTM Module](#10-bidirectional-lstm-module)
11. [CNN Module (ResNet-lite)](#11-cnn-module-resnet-lite)
12. [Random Forest Module](#12-random-forest-module)
13. [Concatenation Layer](#13-concatenation-layer)
14. [Multi-Head Attention Fusion Layer](#14-multi-head-attention-fusion-layer)
15. [Deep Dense Network](#15-deep-dense-network)
16. [Multiclass Softmax Output](#16-multiclass-softmax-output)
17. [Continuous Sigmoid Risk Score](#17-continuous-sigmoid-risk-score)
18. [Normative Statistics & z-Score Engine](#18-normative-statistics--z-score-engine)
19. [Clinical Interpretation Engine (v0.02 Rule Layer)](#19-clinical-interpretation-engine-v002-rule-layer)
20. [Phase Transition: v0.02 → v1.0](#20-phase-transition-v002--v10)

---

## 1. Document Scope

This document defines the **complete AI and analytical framework** for the Multimodal Cognitive Screening Framework (MCSF), structured in two layers:

| Layer | Version | Purpose |
|---|---|---|
| **Data Collection Pipeline** | v0.02 (current) | Pilot data acquisition — structured collection of all clinical, biomarker, and demographic variables defined in NeuralHack Phase 1 & 2 |
| **Rule-Based Analysis Engine** | v0.02 (current) | Replicates the output structure of the full AI ensemble using validated clinical rules, z-scores, and decision trees — no training data required |
| **Full Deep Learning Ensemble** | v1.0 (target) | Transformer + Bi-LSTM + CNN + Random Forest → Concatenation → Multi-Head Attention → Dense Network → Softmax + Sigmoid |

**Design Philosophy**: The v0.02 rule-based engine is architecturally isomorphic to the v1.0 neural network. Every output field, confidence score, feature importance value, and diagnostic category produced by the rule engine occupies the same schema position as the neural network output will. This ensures zero breaking changes in the frontend, database, and FHIR resources during the transition to AI inference.

```
v0.02 Rule Engine Output Schema
        ↕  identical contract
v1.0 Ensemble Model Output Schema
```

---

## 2. Full Pipeline Overview

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MCSF COGNITIVE SCREENING PIPELINE                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  ┌─────────────────────────────────────────────────────────────────────┐    ║
║  │ LAYER 0 — PATIENT ENROLLMENT & CONSENT                              │    ║
║  │  Demographics · Risk Factors · CURP · Education · Residence         │    ║
║  └──────────────────────────────┬──────────────────────────────────────┘    ║
║                                 │                                            ║
║  ┌──────────────────────────────▼──────────────────────────────────────┐    ║
║  │ LAYER 1 — MULTIMODAL DATA ACQUISITION                               │    ║
║  │                                                                      │    ║
║  │  ┌─────────────┐  ┌───────────────┐  ┌────────────┐  ┌──────────┐  │    ║
║  │  │  CLINICAL   │  │ VISUOSPATIAL  │  │  ACOUSTIC  │  │ TABULAR  │  │    ║
║  │  │   MODULE    │  │    MODULE     │  │   MODULE   │  │  SCORES  │  │    ║
║  │  │             │  │               │  │            │  │          │  │    ║
║  │  │ MoCA        │  │ Clock Drawing │  │ Semantic   │  │ PHQ-9    │  │    ║
║  │  │ MMSE        │  │ Copy Figure   │  │ Fluency    │  │ AD8      │  │    ║
║  │  │ PHQ-9       │  │ Trail Making  │  │ Phonemic   │  │ Katz ADL │  │    ║
║  │  │ AD8         │  │               │  │ Fluency    │  │ Zarit    │  │    ║
║  │  │ Katz ADL    │  │ Stroke data:  │  │ Picture    │  │ UPDRS*   │  │    ║
║  │  │ Zarit       │  │ x,y,Δt,P,V   │  │ Description│  │          │  │    ║
║  │  └──────┬──────┘  └───────┬───────┘  └─────┬──────┘  └────┬─────┘  │    ║
║  └─────────┼─────────────────┼────────────────┼──────────────┼────────┘    ║
║            │                 │                │              │              ║
║  ┌─────────▼─────────────────▼────────────────▼──────────────▼────────┐    ║
║  │ LAYER 2 — FEATURE EXTRACTION & NORMALIZATION                        │    ║
║  │                                                                      │    ║
║  │  clinical_vec[9]   visu_vec[7]   acoustic_vec[8]   tabular_vec[15] │    ║
║  │       Z-score standardization · Education adjustment · One-hot      │    ║
║  └──────────────────────────────┬──────────────────────────────────────┘    ║
║                                 │                                            ║
║  ┌──────────────────────────────▼──────────────────────────────────────┐    ║
║  │ LAYER 3 — ANALYTICAL ENGINE                                          │    ║
║  │                                                                      │    ║
║  │  v0.02: Rule Engine + Decision Tree + Statistical Baseline           │    ║
║  │  v1.0:  Transformer + Bi-LSTM + CNN + RF → Attention → Dense        │    ║
║  │                                                                      │    ║
║  └──────────────────────────────┬──────────────────────────────────────┘    ║
║                                 │                                            ║
║  ┌──────────────────────────────▼──────────────────────────────────────┐    ║
║  │ LAYER 4 — CLASSIFICATION & SCORING OUTPUT                            │    ║
║  │                                                                      │    ║
║  │  Multiclass: Normal | MCI | AD | FTD | Vascular | LBD | Pseudo      │    ║
║  │  Risk Score: 0–100 (continuous)                                      │    ║
║  │  Module Scores: clinical[0–1] · visu[0–1] · acoustic[0–1]          │    ║
║  │  Z-deviations · Percentiles · Confidence · SHAP importances         │    ║
║  └──────────────────────────────┬──────────────────────────────────────┘    ║
║                                 │                                            ║
║  ┌──────────────────────────────▼──────────────────────────────────────┐    ║
║  │ LAYER 5 — CLINICAL REPORT & FHIR EXPORT                              │    ║
║  │  DiagnosticReport · Observation · SHAP explanation · PDF report      │    ║
║  └─────────────────────────────────────────────────────────────────────┘    ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 3. Data Inputs — Complete Variable Taxonomy

All variables are derived from **NeuralHack Phase 1 Table 1 & Phase 2 Table 4** (Castillo García, 2025).

### 3.1 Stream A — Demographic & Socioeconomic Variables

| Variable | Type | Range / Values | Feature Vector Position | FHIR Mapping |
|---|---|---|---|---|
| Age | Numerical | 60–120 years | `tabular[0]` | `Patient.birthDate` → computed |
| Sex | Categorical (one-hot) | male, female, other | `tabular[1–3]` | `Patient.gender` |
| Education Years | Numerical | 0–25 years | `tabular[4]` | Extension `edu-years` |
| Education Level | Categorical | low (≤6), mid (7–12), high (>12) | `tabular[5]` | Extension `edu-level` |
| Occupation | Categorical (encoded) | 0–9 occupational tiers | `tabular[6]` | Extension `occupation` |
| Residence Type | Binary | 0=urban, 1=rural | `tabular[7]` | Extension `residence-type` |
| Rural Exposure >20y | Binary | 0/1 | `tabular[8]` | Extension `rural-exposure` |
| Digital Competence | Ordinal (0–4) | none, low, mid, high, advanced | `tabular[9]` | Extension `digital-competence` |
| Cultural Preference | Categorical | es-MX-rural, es-MX-urban, bilingual | `tabular[10]` | Extension `cultural-pref` |

### 3.2 Stream B — Clinical Comorbidities & Risk Factors

| Variable | Type | Values | Feature Vector Position | Clinical Significance |
|---|---|---|---|---|
| Diabetes Mellitus T2 | Binary | 0/1 | `tabular[11]` | Accelerates epigenetic neurodegeneration |
| Hypertension | Binary | 0/1 | `tabular[12]` | Vascular cognitive impairment risk ×1.4 |
| Depression (PHQ-9 ≥10) | Binary | 0/1 | `tabular[13]` | Dementia risk ×1.65 (Livingston 2020) |
| Social Isolation | Binary | 0/1 | `tabular[14]` | Dementia risk ×1.3 (WHO 2023) |
| Family History Dementia | Binary | 0/1 | `tabular[15]` | APOE4 / LRRK2 / SNCA proxy |
| Post-Trauma History | Binary | 0/1 | `tabular[16]` | Stress-induced methylation marker |
| Chronic Stress | Binary | 0/1 | `tabular[17]` | Glucocorticoid neurotoxicity pathway |
| Nutrition Risk | Ordinal (0–3) | none/low/mod/high | `tabular[18]` | Omega-3 deficit, excess sugar |
| Sleep Hours/Night | Numerical | 0–12 | `tabular[19]` | <7h associated with Aβ accumulation |
| Physical Activity | Ordinal (0–3) | sedentary/low/mod/high | `tabular[20]` | BDNF protective factor |
| Environmental Exposure | Ordinal (0–3) | none/low/mod/high | `tabular[21]` | PM2.5 neuroinflamación (Calderón 2016) |
| Genomic/Epigenetic Flag | Binary | 0/1 | `tabular[22]` | Known mutations or methylation history |
| Caregiver Present | Binary | 0/1 | `tabular[23]` | Proxy informant quality flag |
| Sensory Deficits | Categorical (multi-hot) | visual, auditory, both, none | `tabular[24–27]` | Testing validity adjustment |

### 3.3 Stream C — Standardized Assessment Scores

| Instrument | Score Range | Features Extracted | Feature Vector | Notes |
|---|---|---|---|---|
| MoCA | 0–30 | 7 domain subscores + adjusted total | `clinical[0–8]` | +1 if ≤12yr education |
| MMSE | 0–30 | 5 domain subscores + total | `clinical[9–14]` | Ceiling effect in high education |
| PHQ-9 | 0–27 | 9 item scores + severity category | `clinical[15–24]` | Depression comorbidity |
| AD8 | 0–8 | 8 item binary + total | `clinical[25–33]` | Informant-based |
| Katz ADL | 0–6 | 6 domain scores + independence grade | `clinical[34–40]` | Functional capacity |
| Zarit Burden | 0–88 | 22 item scores + burden category | `clinical[41–63]` | Caregiver impact |
| UPDRS-III* | 0–132 | Motor subscale | `clinical[64–68]` | Parkinson screening (*optional) |

### 3.4 Stream D — Visuospatial / Drawing Biomarkers

| Feature | Computation | Type | Feature Vector | Cognitive Domain |
|---|---|---|---|---|
| Stroke velocity mean | μ(dx/dt) per stroke | Numerical | `visu[0]` | Psychomotor speed |
| Stroke velocity SD | σ(velocities) | Numerical | `visu[1]` | Motor consistency |
| Mean pen pressure | μ(pressure events) | Numerical | `visu[2]` | Fine motor control |
| Pressure variability | σ(pressure events) | Numerical | `visu[3]` | Motor steadiness |
| Total path length | Σ Euclidean distances | Numerical | `visu[4]` | Visuospatial planning |
| Trajectory deviation | DTW vs reference | Numerical | `visu[5]` | Executive function |
| Symmetry index | Fourier symmetry score | Numerical | `visu[6]` | Visuoconstructive ability |
| Pen lift count | # pointer-up events | Integer | `visu[7]` | Planning / hesitation |
| Execution time (s) | end_t − start_t | Numerical | `visu[8]` | Processing speed |
| CDC clock score | Shulman 0–4 heuristic | Ordinal | `visu[9]` | Clock Drawing Test |
| Circle closure | % closure measurement | Numerical | `visu[10]` | Motor control |
| Number placement error | Angular deviation (°) | Numerical | `visu[11]` | Numerical cognition |
| Hands present | Boolean detection | Binary | `visu[12]` | Executive function |
| Time correct (target) | Correctness flag | Binary | `visu[13]` | Working memory |
| Error tag vector | Multi-hot (12 error types) | Multi-hot | `visu[14–25]` | Qualitative error pattern |

### 3.5 Stream E — Acoustic / Speech Biomarkers

| Feature | Computation | Type | Feature Vector | Cognitive Domain |
|---|---|---|---|---|
| Word count | Token count | Integer | `acoustic[0]` | Verbal output |
| Speech rate | words/second | Numerical | `acoustic[1]` | Processing speed |
| Type-token ratio (TTR) | unique_words/total_words | Numerical | `acoustic[2]` | Lexical diversity |
| Disfluency rate | filler_words/total_words | Numerical | `acoustic[3]` | Language fluency |
| Pause count | # silent segments >200ms | Integer | `acoustic[4]` | Cognitive planning |
| Mean pause duration (ms) | μ(pause durations) | Numerical | `acoustic[5]` | Word retrieval |
| Total silence ratio | silence_ms/total_ms | Numerical | `acoustic[6]` | Verbal productivity |
| MFCC 1–13 | Cepstral coefficients | Vector[13] | `acoustic[7–19]` | Prosodic/vocal quality |
| F0 mean (Hz) | Fundamental frequency μ | Numerical | `acoustic[20]` | Prosodic quality |
| F0 standard deviation | Fundamental frequency σ | Numerical | `acoustic[21]` | Prosodic variability |
| Arousal score | Valence/arousal (Rutkowski 2019) | Numerical | `acoustic[22]` | Emotional processing |
| Valence score | Negative/positive affect | Numerical | `acoustic[23]` | Affective state |
| Semantic coherence* | Sentence embedding similarity | Numerical | `acoustic[24]` | Semantic memory (*v1.0) |

### 3.6 Stream F — Longitudinal / Temporal Variables

| Variable | Type | Collection | Purpose |
|---|---|---|---|
| Session number | Integer | Auto-increment | Longitudinal tracking |
| Days since enrollment | Integer | Computed | Trajectory modeling |
| ΔMoCA (session n − session 1) | Numerical | Computed | Decline rate |
| ΔMoCA slope | Numerical | Linear regression over sessions | Early decline detection |
| ΔZarit burden | Numerical | Computed | Caregiver trajectory |
| Medication changes | Categorical | Clinical log | Confound tracking |

---

## 4. Standardized Clinical Instruments

### 4.1 MoCA — Montreal Cognitive Assessment

**Purpose**: Primary screen for Mild Cognitive Impairment (MCI) and early dementia.
**Psychometrics**: Sensitivity 83–94% for MCI; Specificity 46–87%; AUC 0.84 (Nasreddine et al., 2005)
**Administration**: ~10–15 min; clinician-administered or supervised self-assessment.
**Education Adjustment**: +1 point if ≤12 years of formal education (validated for Mexican rural population; Castillo García Phase 1, 2025).
**Cutoff**: ≥26 = Normal; 18–25 = MCI; <18 = Dementia probable.

#### Domain Breakdown

| Domain | Max Score | Digital Task Equivalent | Biomarker Captured |
|---|---|---|---|
| **Visuospatial / Executive** | 5 | Trail-making canvas (A→1→B→2), cube copy, clock drawing | Stroke velocity, trajectory deviation, CDC score |
| **Naming** | 3 | Animal image cards + voice response | SpeechToText accuracy, response latency |
| **Attention** | 6 | Digit span (audio), tapping task, serial 7s | Tap timing, omission/commission errors |
| **Language** | 3 | Sentence repetition (TTS), F-words 60s | TTR, word count, pause count |
| **Abstraction** | 2 | Similarity pairs (category reasoning) | Response latency, correctness |
| **Delayed Recall** | 5 | 5-word list recall (no cue → category cue → recognition) | Recall score, cue dependency |
| **Orientation** | 6 | Date, month, year, day, place, city | GPS-verified location option; latency |

#### Storage Schema (FHIR QuestionnaireResponse + Observation)

```json
{
  "resourceType": "Observation",
  "code": { "coding": [{ "system": "http://loinc.org", "code": "72133-2", "display": "MoCA" }] },
  "valueInteger": 24,
  "component": [
    { "code": { "text": "Visuospatial/Executive" }, "valueInteger": 4 },
    { "code": { "text": "Naming" }, "valueInteger": 3 },
    { "code": { "text": "Attention" }, "valueInteger": 5 },
    { "code": { "text": "Language" }, "valueInteger": 2 },
    { "code": { "text": "Abstraction" }, "valueInteger": 1 },
    { "code": { "text": "Delayed Recall" }, "valueInteger": 4 },
    { "code": { "text": "Orientation" }, "valueInteger": 5 }
  ],
  "extension": [
    { "url": "edu-adjustment-applied", "valueBoolean": true },
    { "url": "raw-total", "valueInteger": 23 },
    { "url": "adjusted-total", "valueInteger": 24 },
    { "url": "administration-time-seconds", "valueInteger": 720 }
  ]
}
```

---

### 4.2 MMSE — Mini-Mental State Examination

**Purpose**: Global cognitive screen; established baseline; high specificity for confirmed dementia.
**Psychometrics**: Sensitivity 76–81%; Specificity 83–89%; AUC 0.76–0.85 (Folstein et al., 1975).
**Administration**: ~5–10 min.
**Limitation**: Ceiling effect in high-education patients; low sensitivity in early MCI — always pair with MoCA.
**Cutoff**: 24–30 = Normal; 18–23 = Mild dementia; 12–17 = Moderate; <12 = Severe.

#### Domain Breakdown

| Domain | Max Score | Items | Digital Biomarker |
|---|---|---|---|
| **Orientation in Time** | 5 | Year, season, month, date, day | Response latency per item |
| **Orientation in Place** | 5 | State, country, hospital, floor, city | GPS-assist optional |
| **Registration** | 3 | Repeat 3 words immediately | Repetition count, latency |
| **Attention & Calculation** | 5 | Serial 7s (100→93→86…) or WORLD backwards | Inter-response timing |
| **Recall** | 3 | Recall 3 words from Registration | Cue dependency flag |
| **Language** | 8 | Naming (2), Repetition (1), Follow command (3), Read & obey (1), Write (1) | Voice + drawing biomarkers |
| **Visuospatial (Copy)** | 1 | Copy intersecting pentagons | Stroke data captured |

#### Storage Schema

```json
{
  "resourceType": "Observation",
  "code": { "coding": [{ "system": "http://loinc.org", "code": "72107-6", "display": "MMSE" }] },
  "valueInteger": 26,
  "component": [
    { "code": { "text": "Orientation_Time" }, "valueInteger": 4 },
    { "code": { "text": "Orientation_Place" }, "valueInteger": 5 },
    { "code": { "text": "Registration" }, "valueInteger": 3 },
    { "code": { "text": "Attention_Calculation" }, "valueInteger": 4 },
    { "code": { "text": "Recall" }, "valueInteger": 2 },
    { "code": { "text": "Language" }, "valueInteger": 7 },
    { "code": { "text": "Visuospatial" }, "valueInteger": 1 }
  ]
}
```

---

### 4.3 PHQ-9 — Patient Health Questionnaire

**Purpose**: Depression screening and severity measurement; critical comorbidity for dementia.
**Psychometrics**: Sensitivity 88%; Specificity 88%; Cutoff ≥10 for moderate depression (Kroenke et al., 2001).
**Administration**: 3–5 min; self-administered or proxy.
**Relevance**: Depression in mid/late life increases dementia risk ×1.65 (Livingston 2020). PHQ-9 ≥10 is a feature input to the ensemble model.

#### Item Schema

| Item # | Question (ES) | Question (EN) | Score |
|---|---|---|---|
| 1 | Poco interés o placer en hacer las cosas | Little interest or pleasure in doing things | 0–3 |
| 2 | Sentirse desanimado, deprimido, o sin esperanza | Feeling down, depressed, or hopeless | 0–3 |
| 3 | Problemas para dormir, o dormir demasiado | Trouble falling/staying asleep, or sleeping too much | 0–3 |
| 4 | Sentirse cansado o con poca energía | Feeling tired or having little energy | 0–3 |
| 5 | Poco apetito o comer en exceso | Poor appetite or overeating | 0–3 |
| 6 | Sentirse mal consigo mismo | Feeling bad about yourself | 0–3 |
| 7 | Problemas para concentrarse | Trouble concentrating | 0–3 |
| 8 | Moverse o hablar tan despacio | Moving or speaking slowly | 0–3 |
| 9 | Pensamientos de hacerse daño | Thoughts of being better off dead | 0–3 |

**⚠ Safety Protocol**: Item 9 score ≥1 triggers immediate `SAFETY_ALERT` flag → automatic clinician notification → session suspended pending clinical review.

#### Severity Classification

| Total Score | Severity | Clinical Action |
|---|---|---|
| 0–4 | None/Minimal | Monitor |
| 5–9 | Mild | Monitor + lifestyle counseling |
| 10–14 | Moderate | Confirm diagnosis; treatment plan |
| 15–19 | Moderately Severe | Active treatment; frequent follow-up |
| 20–27 | Severe | Immediate psychiatric referral |

#### Storage Schema

```json
{
  "resourceType": "Observation",
  "code": { "coding": [{ "system": "http://loinc.org", "code": "44249-1", "display": "PHQ-9" }] },
  "valueInteger": 12,
  "interpretation": [{ "coding": [{ "code": "H", "display": "High" }] }],
  "component": [
    { "code": { "text": "PHQ9_Item1" }, "valueInteger": 2 },
    { "code": { "text": "PHQ9_Item9_Safety" }, "valueInteger": 0 }
  ],
  "extension": [{ "url": "phq9-severity", "valueString": "moderate" }]
}
```

---

### 4.4 AD8 — Ascertain Dementia 8

**Purpose**: Informant-based brief screen to detect dementia vs normal aging.
**Psychometrics**: Sensitivity 74–91%; Specificity 77–93%; Cutoff ≥2 (Galvin et al., 2005).
**Administration**: 2–3 min; administered to caregiver/family member (NOT the patient).
**Relevance**: Captures functional memory decline that self-report misses; critical for patients who lack insight into their own deficits.

#### Item Schema

| Item | Domain | Response Options |
|---|---|---|
| Problems with judgement | Executive function | Yes = Change / No Change / Don't Know |
| Reduced interest in hobbies | Motivation / apathy | Yes/No/DK |
| Repeats questions/stories | Episodic memory | Yes/No/DK |
| Trouble learning new things | Learning/memory | Yes/No/DK |
| Forgets month/year | Temporal orientation | Yes/No/DK |
| Trouble with finances | Executive/numerical | Yes/No/DK |
| Forgets appointments | Prospective memory | Yes/No/DK |
| Daily thinking/memory problems | Global cognition | Yes/No/DK |

**Scoring**: Each "Yes = Change" = 1 point. ≥2 = probable dementia.

#### Storage Schema

```json
{
  "resourceType": "QuestionnaireResponse",
  "questionnaire": "http://loinc.org/vs/LL358-3",
  "source": { "reference": "RelatedPerson/caregiver-001" },
  "item": [
    { "linkId": "AD8_1", "answer": [{ "valueString": "yes_change" }] },
    { "linkId": "AD8_score", "answer": [{ "valueInteger": 3 }] }
  ],
  "extension": [
    { "url": "ad8-interpretation", "valueString": "probable_dementia" },
    { "url": "informant-relationship", "valueString": "daughter" }
  ]
}
```

---

### 4.5 Katz ADL — Activities of Daily Living Index

**Purpose**: Functional independence assessment; staging severity of cognitive impairment impact.
**Psychometrics**: Established gold standard for functional capacity (Katz et al., 1963).
**Administration**: 5 min; clinician observation or caregiver report.
**Relevance**: Distinguishes normal aging from dementia (functional loss defines dementia severity); Katz score feeds directly into `tabular` feature vector.

#### Domain Schema

| Domain | Score 1 (Independent) | Score 0 (Dependent) | Feature |
|---|---|---|---|
| **Bathing** | Bathes self independently | Requires assistance | `katz[0]` |
| **Dressing** | Dresses/undresses independently | Requires assistance with dressing | `katz[1]` |
| **Toileting** | Goes to toilet independently | Requires assistance or uses bedpan | `katz[2]` |
| **Transferring** | Moves in/out of bed/chair independently | Requires assistance | `katz[3]` |
| **Continence** | Self-control of bladder/bowel | Partial or total incontinence | `katz[4]` |
| **Feeding** | Feeds self independently | Requires partial or full feeding assistance | `katz[5]` |

**Total Score Interpretation**:
- 6 = Full independence
- 4 = Moderate dependency
- 2 or less = Severe functional impairment

---

### 4.6 Zarit Burden Interview — Caregiver Burden Scale

**Purpose**: Measure psychological, physical, and financial burden on primary caregiver.
**Psychometrics**: Gold standard caregiver assessment; 22 items; 0–88 total (Zarit et al., 1980).
**Cutoffs**: 0–20 = Little/no burden; 21–40 = Mild-moderate; 41–60 = Moderate-severe; 61–88 = Severe.
**MCID**: ≥4 points = Minimal Clinically Important Difference (Phase 2 paper).
**Relevance**: Phase 2 demonstrated ΔZarit = −8.4 ± 9.6 in experimental group vs −3.7 ± 8.2 in control — caregiver burden is a primary outcome metric.

#### Item Categories

| Category | Items | Focus |
|---|---|---|
| **Time demands** | 1, 2, 3, 4, 5 | Hours of care, schedule disruption |
| **Emotional / psychological** | 6, 7, 8, 9, 10, 11, 12 | Stress, embarrassment, guilt, anger |
| **Social isolation** | 13, 14, 15 | Loss of personal time, social activities |
| **Financial** | 16, 17 | Costs, employment impact |
| **Global burden / wellbeing** | 18, 19, 20, 21, 22 | Overall burden perception, health impact |

```json
{
  "resourceType": "Observation",
  "code": { "coding": [{ "display": "Zarit Burden Interview" }] },
  "subject": { "reference": "RelatedPerson/caregiver-001" },
  "valueInteger": 45,
  "interpretation": [{ "coding": [{ "display": "Moderate-Severe Burden" }] }],
  "extension": [
    { "url": "zarit-category", "valueString": "moderate_severe" },
    { "url": "zarit-delta-from-baseline", "valueDecimal": -8.4 }
  ]
}
```

---

## 5. Biomarker Classification & Storage Schema

### 5.1 Biomarker Type Registry

| Biomarker Class | Subtypes | Raw Format | Processed Format | Storage Backend | FHIR Resource |
|---|---|---|---|---|---|
| **Clinical Score** | MoCA, MMSE, PHQ-9, AD8, Katz, Zarit | Integer per item | Vector[n], total, severity | Supabase normalized tables | `Observation`, `QuestionnaireResponse` |
| **Visuospatial Motor** | Clock drawing, trail-making, copy figure | Stroke point stream: `(x,y,t,P,V)` | Feature vector[26], PNG image | Supabase `drawing_sessions` + GCS | `Media` (image) + `Observation` |
| **Acoustic-Prosodic** | Semantic fluency, phonemic fluency, picture description | `.m4a` audio file (44.1kHz, mono) | Feature vector[25]: TTR, F0, MFCC×13, pause stats | GCS (encrypted) + Supabase `acoustic_sessions` | `Media` (audio) + `Observation` |
| **Linguistic** | Transcribed speech, word lists | Raw text string | Tokenized: word count, TTR, disfluency | Supabase `acoustic_sessions` JSON | `Observation` extension |
| **Demographic / Tabular** | Age, education, comorbidities | Form fields | One-hot / Z-score normalized vector[28] | Supabase `patients` | `Patient` + Extensions |
| **Temporal / Longitudinal** | ΔMoCA, ΔZarit, session sequence | Computed at analysis time | Slope, velocity of decline | Computed view | `Observation.series` |
| **Caregiver** | Zarit, AD8, behavioral observation | Form fields | Burden score, AD8 score | Supabase `caregiver_assessments` | `RelatedPerson` + `Observation` |

### 5.2 Audio File Storage Specification

```
File naming convention:
  {session_id}_{task_type}_{timestamp_ms}.m4a
  Example: a3f9e1b2_semantic_fluency_1720000000000.m4a

Storage path (GCS):
  gs://mcsf-clinical-data/sessions/{patient_hash}/{session_id}/acoustic/

Encryption:
  - AES-256 server-side encryption (GCS CMEK)
  - Client-side: file encrypted before upload using patient-derived key
  - Key stored in Google Cloud KMS; never persisted on device

Codec:     AAC-LC (AudioEncoder.aacLc)
Rate:      44,100 Hz
Channels:  Mono (1)
Bit rate:  128 kbps
Format:    .m4a (MPEG-4 Audio)
Max duration per task:  90 seconds
Max file size:          ~1.4 MB per recording

Metadata stored alongside (JSON sidecar):
{
  "session_id": "...",
  "task_type": "semantic_fluency | phonemic_fluency | picture_description",
  "duration_ms": 60000,
  "sample_rate": 44100,
  "word_count_client": 42,
  "pause_count_client": 7,
  "transcript_client": "perro gato caballo...",
  "recording_quality_flag": "ok | too_quiet | clipping | background_noise",
  "sha256": "...",
  "collected_at": "2025-09-01T10:30:00Z"
}
```

### 5.3 Drawing / Stroke File Storage Specification

```
File naming convention:
  {session_id}_{task_type}_{timestamp_ms}.json   ← raw stroke data
  {session_id}_{task_type}_{timestamp_ms}.png    ← rendered image

Storage path (GCS):
  gs://mcsf-clinical-data/sessions/{patient_hash}/{session_id}/visuospatial/

Stroke JSON Schema:
{
  "session_id": "...",
  "task_type": "clock_drawing | copy_figure | trail_making_a | trail_making_b",
  "canvas_width_px": 800,
  "canvas_height_px": 800,
  "device_dpi": 264,
  "input_type": "touch | stylus | mouse",
  "strokes": [
    {
      "stroke_id": "s1",
      "start_time_ms": 1250,
      "end_time_ms": 3840,
      "point_count": 187,
      "mean_velocity": 2.34,
      "velocity_std": 0.87,
      "mean_pressure": 0.62,
      "path_length_px": 412.5,
      "points": [
        { "x": 412, "y": 398, "t": 0, "p": 0.58, "v": null },
        { "x": 414, "y": 400, "t": 16, "p": 0.60, "v": 1.77 },
        ...
      ]
    }
  ],
  "aggregate": {
    "total_strokes": 12,
    "total_time_ms": 45230,
    "total_lift_count": 11,
    "total_path_length_px": 3840.2
  },
  "clock_analysis": {
    "circle_detected": true,
    "circle_closure_ratio": 0.94,
    "numbers_detected": true,
    "hands_detected": true,
    "hands_count": 2,
    "cdc_score": 3,
    "number_placement_error_deg": 12.4,
    "error_tags": ["slight_crowding_right"]
  },
  "sha256": "...",
  "collected_at": "2025-09-01T10:35:00Z"
}

PNG specification:
  Resolution:    800×800 px
  Color mode:    Grayscale (stroke) on white background
  Compression:   PNG lossless
  Max size:      ~150 KB
  Purpose:       CNN inference input (v1.0); clinician visual review (v0.02)
```

---

## 6. v0.02 Data Collection Pipeline (Current)

This is the **active pipeline** during the pilot phase. No trained ML model is required. The goal is to collect maximum-fidelity, properly-structured data that will be used to train the v1.0 ensemble.

```
PATIENT SESSION FLOW — v0.02

  [1] ENROLLMENT
      ↓
      Patient registration → Demographics → Risk factors → Consent (FHIR)
      
  [2] CLINICAL MODULE (Sequential screens)
      ↓
      MoCA (7 domains + education adjustment)
        → Visuospatial tasks → trigger Drawing Canvas → capture strokes
        → Naming tasks → trigger Microphone → capture audio + transcript
        → Attention → timed interactive tasks → capture latencies
      ↓
      MMSE (5 domains)
        → Copy pentagons → capture strokes
      ↓
      PHQ-9 → Safety check Item 9 → store item scores
      ↓
      AD8 → Caregiver mode → store informant responses
      ↓
      Katz ADL → 6-domain grid → store independence scores
      ↓
      Zarit Burden → 22-item form (caregiver) → store burden score
      
  [3] DEDICATED VISUOSPATIAL MODULE
      ↓
      Clock Drawing Test (standalone, standardized canvas 800×800)
        → 5-minute max → real-time stroke capture → immediate CDC scoring
      ↓
      Copy Figure (intersecting pentagons / Rey figure subset)
        → stroke capture → similarity analysis
        
  [4] DEDICATED ACOUSTIC MODULE
      ↓
      Semantic Fluency (60s, animals)
        → record + live transcript → word count → TTR → pause detection
      ↓
      Phonemic Fluency (60s, letter F)
        → same pipeline
      ↓
      Picture Description (90s, Cookie Theft scene)
        → record + transcript → extended linguistic features
        
  [5] FEATURE EXTRACTION (client-side v0.02)
      ↓
      Build feature vectors:
        clinical_vec[65]
        visuospatial_vec[26]
        acoustic_vec[25]
        tabular_vec[28]
      ↓
      Z-score normalization against normative baselines
      
  [6] ANALYTICAL ENGINE v0.02 (Rule-based — see Section 7)
      ↓
      Rule-based scoring → module risk scores → composite risk score
      Normative z-score comparison → percentile → interpretation
      Decision tree classification → diagnostic category
      
  [7] REPORT GENERATION
      ↓
      FHIR DiagnosticReport → PDF → Clinician dashboard
      Patient portal → plain-language summary
      Research export → anonymized feature vectors
      
  [8] AUDIT & SYNC
      ↓
      SHA-256 session checksum → audit log entry
      Offline queue → background FHIR sync → Supabase sync
```

### 6.1 Data Quality Gates

Before a session is marked `completed`, these quality checks must pass:

| Gate | Check | Failure Action |
|---|---|---|
| **Consent** | FHIR Consent resource signed and stored | Block session start |
| **MoCA completion** | All 7 domains answered; time recorded | Warn; allow continuation |
| **Drawing quality** | ≥2 strokes captured; canvas not blank | Repeat prompt; flag if still blank |
| **Audio quality** | Duration ≥10s; amplitude >-40dBFS | Re-record prompt; quality flag |
| **PHQ-9 Safety** | Item 9 = 0 | ≥1 → SAFETY_ALERT flow |
| **Checksum** | SHA-256 matches computed value | Mark session INTEGRITY_ERROR |
| **Clinician sign-off** | Digital signature captured | Required before FHIR export |

---

## 7. v0.02 Analytical Logic — Rule-Based Engine

This engine **mirrors the output structure of the v1.0 neural network** in every field but uses validated clinical rules, normative statistics, and decision trees instead of learned weights. This is the **simulated fully-connected dense output layer** — the classification and statistical analysis pipeline.

### 7.1 Architecture Analogy

```
v1.0 Neural Network                   v0.02 Rule Engine (equivalent)
─────────────────────────────────────────────────────────────────────
Transformer output (256D)    →   linguistic_score = f(TTR, speech_rate, pauses)
Bi-LSTM output (128D)        →   motor_score = f(velocity_std, execution_time)
CNN output (512D)            →   visuospatial_score = f(CDC_score, symmetry, closure)
Random Forest output (256D)  →   tabular_score = f(MoCA, MMSE, comorbidities)
                                 
Concatenated vector (704D)   →   [linguistic, motor, visuospatial, tabular]
                                 
Multi-head Attention         →   weighted_scores = alpha × [0.38, 0.24, 0.29, 0.09]
                                 (SHAP weights from Phase 2 paper)
                                 
Dense Network 512→256→128    →   three-tier normative z-score aggregation
                                 
Softmax (7 classes)          →   rule_based_classification()
Sigmoid (risk 0–100)         →   composite_risk_score()
```

### 7.2 Module Scoring Functions

#### Module 1 — Clinical Score

```python
def compute_clinical_module_score(features: dict) -> dict:
    """
    Computes normalized clinical score [0–1] from standardized assessments.
    0 = optimal cognition; 1 = maximum impairment
    """
    
    # MoCA sub-score (education-adjusted)
    moca_adj = features['moca_adjusted_total']   # 0–30
    moca_score = max(0, 1 - (moca_adj / 30))     # invert: higher MoCA = lower impairment
    
    # Apply education z-score correction
    edu_years = features['education_years']
    if edu_years <= 6:
        moca_norm_mean, moca_norm_std = 19.8, 5.2   # Rural low-education (Phase 1)
    elif edu_years <= 12:
        moca_norm_mean, moca_norm_std = 22.5, 4.3
    else:
        moca_norm_mean, moca_norm_std = 25.9, 2.9
    
    moca_z = (moca_adj - moca_norm_mean) / moca_norm_std
    moca_percentile = norm.cdf(moca_z) * 100
    
    # MMSE sub-score
    mmse = features['mmse_total']
    mmse_score = max(0, 1 - (mmse / 30))
    mmse_z = (mmse - 26.5) / 3.8   # Population norm (Folstein 1975 calibrated)
    
    # Depression penalty (PHQ-9 ≥10 adds risk weight)
    phq9 = features['phq9_total']
    depression_weight = min(phq9 / 27, 1.0) * 0.15   # max 15% additive weight
    
    # AD8 functional signal
    ad8 = features['ad8_positive_count']
    ad8_score = ad8 / 8
    
    # Katz functional capacity (inverted)
    katz = features['katz_total']
    katz_impairment = max(0, 1 - (katz / 6))
    
    # Weighted clinical composite
    clinical_composite = (
        moca_score * 0.45 +
        mmse_score * 0.25 +
        ad8_score * 0.15 +
        katz_impairment * 0.10 +
        depression_weight * 0.05
    )
    
    return {
        'module_score': round(clinical_composite, 4),   # 0–1
        'moca_z': round(moca_z, 2),
        'moca_percentile': round(moca_percentile, 1),
        'mmse_z': round(mmse_z, 2),
        'depression_flag': phq9 >= 10,
        'ad8_positive': ad8 >= 2,
        'katz_dependent': katz <= 4,
        'domain_scores': {
            'moca': moca_adj,
            'mmse': mmse,
            'phq9': phq9,
            'ad8': ad8,
            'katz': katz,
        }
    }
```

#### Module 2 — Visuospatial Score

```python
def compute_visuospatial_module_score(features: dict) -> dict:
    """
    Computes visuospatial impairment score [0–1].
    Replicates CNN output pathway using rule-based signal extraction.
    """
    
    # Clock Drawing Test — CDC heuristic score (0–4)
    cdc = features.get('cdc_score', 4)
    cdc_impairment = max(0, 1 - (cdc / 4))
    
    # Motor velocity: lower velocity = higher impairment
    v_mean = features.get('stroke_velocity_mean', 3.0)
    v_std = features.get('stroke_velocity_std', 0.5)
    # Normative: mean ~2.5–4.0 px/ms for adults 60–80 (Yamada 2022)
    velocity_z = (v_mean - 3.0) / 0.8
    velocity_impairment = max(0, 1 - norm.cdf(velocity_z))
    
    # Execution time: longer = more impairment
    exec_time_s = features.get('execution_time_s', 60)
    time_score = min(exec_time_s / 300, 1.0)   # normalize; >5 min = max impairment
    
    # Trajectory deviation: higher deviation = more impairment
    trajectory_dev = features.get('trajectory_deviation', 0.0)
    trajectory_score = min(trajectory_dev, 1.0)
    
    # Symmetry: lower symmetry = more impairment
    symmetry = features.get('symmetry_index', 0.8)
    symmetry_impairment = max(0, 1 - symmetry)
    
    # Number placement error (clock drawing)
    num_error = features.get('number_placement_error_deg', 0)
    num_score = min(num_error / 90, 1.0)   # normalize to 90° max error
    
    # Pen lift count (hesitation marker)
    lift_count = features.get('lift_count', 10)
    # Normative: ~10–15 lifts for clock; higher = hesitation
    lift_score = min(max(0, lift_count - 15) / 30, 1.0)
    
    # Weighted visuospatial composite
    visuospatial_composite = (
        cdc_impairment * 0.35 +
        velocity_impairment * 0.20 +
        trajectory_score * 0.15 +
        symmetry_impairment * 0.12 +
        time_score * 0.10 +
        num_score * 0.05 +
        lift_score * 0.03
    )
    
    return {
        'module_score': round(visuospatial_composite, 4),
        'cdc_score': cdc,
        'cdc_interpretation': interpret_cdc(cdc),
        'velocity_z': round(velocity_z, 2),
        'execution_time_s': exec_time_s,
        'clock_errors': features.get('error_tags', []),
        'domain_scores': {
            'cdc': cdc,
            'velocity_mean': round(v_mean, 3),
            'velocity_std': round(v_std, 3),
            'symmetry_index': round(symmetry, 3),
            'trajectory_deviation': round(trajectory_dev, 3),
        }
    }

def interpret_cdc(score: int) -> str:
    return {0: 'severe_impairment', 1: 'moderate_impairment',
            2: 'mild_impairment', 3: 'borderline', 4: 'normal'}[score]
```

#### Module 3 — Acoustic Score

```python
def compute_acoustic_module_score(features: dict) -> dict:
    """
    Computes acoustic/linguistic impairment score [0–1].
    Replicates Transformer output pathway using prosodic rule extraction.
    SHAP weight in Phase 2: lexical diversity = 0.29
    """
    
    # Type-Token Ratio: higher = better lexical diversity
    # Normative: 0.60–0.80 for normal aging adults (Lima et al., 2025)
    ttr = features.get('type_token_ratio', 0.65)
    ttr_z = (ttr - 0.65) / 0.12
    ttr_impairment = max(0, 1 - norm.cdf(ttr_z))
    
    # Semantic fluency word count (60s animals task)
    # Normative: 14–18 words normal; <11 = impaired (Custodio 2023, adjusted)
    word_count = features.get('word_count', 15)
    count_z = (word_count - 14) / 4
    count_impairment = max(0, 1 - norm.cdf(count_z))
    
    # Speech rate
    speech_rate = features.get('speech_rate', 1.5)   # words/second
    rate_z = (speech_rate - 1.5) / 0.5
    rate_impairment = max(0, 1 - norm.cdf(rate_z))
    
    # Pause burden: normalized total silence / recording duration
    pause_ratio = features.get('total_silence_ratio', 0.2)
    # Normative: <0.30 normal; >0.50 = significant impairment
    pause_score = min(max(0, pause_ratio - 0.20) / 0.40, 1.0)
    
    # Disfluency rate: higher = more impairment
    disfluency = features.get('disfluency_rate', 0.02)
    disfluency_score = min(disfluency * 20, 1.0)   # normalize
    
    # Mean pause duration: longer pauses = word retrieval difficulty
    mean_pause_ms = features.get('mean_pause_duration_ms', 500)
    pause_dur_score = min(max(0, mean_pause_ms - 500) / 2000, 1.0)
    
    # Weighted acoustic composite
    acoustic_composite = (
        ttr_impairment * 0.35 +
        count_impairment * 0.25 +
        pause_score * 0.15 +
        rate_impairment * 0.12 +
        disfluency_score * 0.08 +
        pause_dur_score * 0.05
    )
    
    return {
        'module_score': round(acoustic_composite, 4),
        'ttr_z': round(ttr_z, 2),
        'word_count_z': round(count_z, 2),
        'type_token_ratio': round(ttr, 3),
        'word_count': word_count,
        'domain_scores': {
            'ttr': round(ttr, 3),
            'speech_rate': round(speech_rate, 3),
            'word_count': word_count,
            'pause_count': features.get('pause_count', 0),
            'disfluency_rate': round(disfluency, 3),
        }
    }
```

### 7.3 Attention-Weighted Fusion (Rule-Based Equivalent)

```python
# SHAP-derived weights from Phase 2 paper (Castillo García, 2025)
# These replicate the multi-head attention ponderación
FUSION_WEIGHTS = {
    'clinical':      0.38,   # SHAP = 0.38 (MoCA digital highest contributor)
    'visuospatial':  0.24,   # SHAP = 0.24 (drawing precision)
    'acoustic':      0.29,   # SHAP = 0.29 (lexical diversity)
    'tabular_risk':  0.09,   # residual weight (demographics, comorbidities)
}

def compute_tabular_risk_score(patient_features: dict) -> float:
    """
    Risk score from demographic and comorbidity factors.
    Replicates Random Forest tabular pathway.
    Weights from Lancet Commission 2020 Population Attributable Fractions.
    """
    risk = 0.0
    
    if patient_features.get('education_years', 12) <= 8:
        risk += 0.20    # Low education: PAF ~19.1% (Lancet 2020)
    if patient_features.get('social_isolation'):
        risk += 0.15    # Social isolation: PAF ~11.0%
    if patient_features.get('diabetes'):
        risk += 0.10    # Diabetes: PAF ~6.7%
    if patient_features.get('hypertension'):
        risk += 0.08    # Hypertension: PAF ~7.0%
    if patient_features.get('depression_history'):
        risk += 0.12    # Depression: PAF ~9.8%
    if patient_features.get('physical_activity') in ['sedentary', 'low']:
        risk += 0.07    # Physical inactivity: PAF ~8.9%
    if patient_features.get('sleep_hours_per_night', 8) < 7:
        risk += 0.05    # Sleep deprivation
    if patient_features.get('family_history_dementia'):
        risk += 0.08    # Genetic predisposition
    if patient_features.get('rural_exposure_over_20y'):
        risk += 0.06    # Environmental exposure (PM2.5)
    if patient_features.get('chronic_stress'):
        risk += 0.06    # Chronic stress / epigenetic
    if patient_features.get('nutrition_risk', 0) >= 2:
        risk += 0.05    # Poor nutrition
    
    return min(risk, 1.0)   # Cap at 1.0

def fuse_module_scores(clinical: dict, visuospatial: dict, 
                        acoustic: dict, tabular_risk: float) -> dict:
    """
    Late fusion of module scores — replicates multi-head attention + dense layer output.
    """
    W = FUSION_WEIGHTS
    
    composite = (
        clinical['module_score'] * W['clinical'] +
        visuospatial['module_score'] * W['visuospatial'] +
        acoustic['module_score'] * W['acoustic'] +
        tabular_risk * W['tabular_risk']
    )
    
    risk_score_100 = round(composite * 100, 2)
    
    return {
        'composite_impairment': round(composite, 4),
        'risk_score': risk_score_100,
        'risk_category': categorize_risk(risk_score_100),
        'module_contributions': {
            'clinical': round(clinical['module_score'] * W['clinical'], 4),
            'visuospatial': round(visuospatial['module_score'] * W['visuospatial'], 4),
            'acoustic': round(acoustic['module_score'] * W['acoustic'], 4),
            'tabular': round(tabular_risk * W['tabular_risk'], 4),
        },
        'effective_weights': W,
    }
```

### 7.4 Classification Engine (Rule-Based Softmax Equivalent)

```python
def rule_based_classify(clinical: dict, visuospatial: dict,
                         acoustic: dict, patient: dict,
                         risk: dict) -> dict:
    """
    Multi-class diagnostic classification using validated clinical criteria.
    Replicates softmax output layer.
    Output matches exactly the v1.0 schema: 7 probability classes.
    
    Decision tree based on:
    - DSM-5 Neurocognitive Disorder criteria
    - NIA-AA criteria for Alzheimer's disease
    - NINDS-AIREN for vascular dementia
    - McKeith criteria for Lewy Body dementia
    - International FTD criteria
    """
    
    moca = clinical['domain_scores']['moca']
    mmse = clinical['domain_scores']['mmse']
    phq9 = clinical['domain_scores']['phq9']
    ad8 = clinical['domain_scores']['ad8']
    katz = clinical['domain_scores']['katz']
    cdc = visuospatial['cdc_score']
    ttr = acoustic['type_token_ratio']
    score = risk['risk_score']
    
    hypertension = patient.get('hypertension', False)
    depression = phq9 >= 10
    social_isolation = patient.get('social_isolation', False)
    family_hx = patient.get('family_history_dementia', False)
    
    # Initialize probability slots (will be normalized to sum=1)
    probs = {
        'Normal': 0.0,
        'MCI': 0.0,
        'Alzheimer': 0.0,
        'Frontotemporal': 0.0,
        'LewyBodies': 0.0,
        'Vascular': 0.0,
        'Pseudodementia': 0.0,
    }
    
    # ── Rule Set 1: Normal Cognition ──────────────────────────────────────
    if moca >= 26 and mmse >= 27 and ad8 <= 1 and katz >= 5 and cdc >= 3:
        probs['Normal'] = 0.85
        if score < 25:
            probs['Normal'] = 0.92
    
    # ── Rule Set 2: MCI (Petersen criteria, 2018) ─────────────────────────
    elif (18 <= moca <= 25) or (clinical['moca_z'] < -1.0 and katz >= 4):
        probs['MCI'] = 0.65
        probs['Normal'] = 0.10
        probs['Alzheimer'] = 0.15
        # Boost Alzheimer if memory domain impaired + family history
        if clinical['domain_scores'].get('moca_delayed_recall', 5) <= 2 and family_hx:
            probs['Alzheimer'] += 0.10
            probs['MCI'] -= 0.10
    
    # ── Rule Set 3: Probable Alzheimer's (NIA-AA) ─────────────────────────
    elif (moca < 18 and ad8 >= 2 and
          clinical['domain_scores'].get('moca_delayed_recall', 5) <= 1):
        probs['Alzheimer'] = 0.60
        probs['MCI'] = 0.15
        probs['Vascular'] = 0.10
        if family_hx:
            probs['Alzheimer'] += 0.10
    
    # ── Rule Set 4: Vascular Dementia (NINDS-AIREN) ───────────────────────
    elif (moca < 22 and hypertension and
          clinical['domain_scores'].get('moca_attention', 6) <= 2):
        probs['Vascular'] = 0.55
        probs['Alzheimer'] = 0.25
        probs['MCI'] = 0.10
    
    # ── Rule Set 5: Frontotemporal (behavioral/language) ──────────────────
    elif (moca < 22 and ttr < 0.45 and
          clinical['domain_scores'].get('moca_language', 3) <= 1 and
          katz < 5):
        probs['Frontotemporal'] = 0.50
        probs['Alzheimer'] = 0.25
        probs['MCI'] = 0.15
    
    # ── Rule Set 6: Pseudodementia (depression-driven) ────────────────────
    elif (18 <= moca <= 25 and phq9 >= 15 and
          ad8 <= 2 and katz >= 4):
        probs['Pseudodementia'] = 0.60
        probs['MCI'] = 0.25
        probs['Normal'] = 0.10
    
    # ── Default: ambiguous presentation ───────────────────────────────────
    else:
        probs['MCI'] = 0.40
        probs['Alzheimer'] = 0.20
        probs['Normal'] = 0.20
        probs['Vascular'] = 0.10
        probs['Frontotemporal'] = 0.10
    
    # Normalize to sum = 1.0
    total = sum(probs.values())
    probs = {k: round(v / total, 4) for k, v in probs.items()}
    
    top_class = max(probs, key=probs.get)
    confidence = probs[top_class]
    
    return {
        'predicted_class': top_class,
        'confidence': confidence,
        'class_probabilities': probs,
        'clinical_stage': classify_stage(moca, ad8, katz),
        'engine_version': 'rule_v0.02',   # will become 'ensemble_v1.0'
        'requires_clinical_confirmation': confidence < 0.70,
    }

def classify_stage(moca: int, ad8: int, katz: int) -> str:
    if moca >= 26 and ad8 <= 1:       return 'normal'
    if moca >= 18 and ad8 <= 2:       return 'mci'
    if moca >= 10 and katz >= 3:      return 'mild_dementia'
    if moca >= 5 and katz >= 2:       return 'moderate_dementia'
    return 'advanced_dementia'
```

### 7.5 Final Output Schema (v0.02 = v1.0 compatible)

```json
{
  "session_id": "a3f9e1b2-...",
  "engine_version": "rule_v0.02",
  "computed_at": "2025-09-01T11:00:00Z",
  
  "risk_score": 58.4,
  "risk_category": "MODERATE",
  "clinical_stage": "mci",
  
  "predicted_class": "MCI",
  "confidence": 0.65,
  "class_probabilities": {
    "Normal": 0.10,
    "MCI": 0.65,
    "Alzheimer": 0.14,
    "Frontotemporal": 0.04,
    "LewyBodies": 0.02,
    "Vascular": 0.03,
    "Pseudodementia": 0.02
  },
  
  "module_scores": {
    "clinical": 0.412,
    "visuospatial": 0.338,
    "acoustic": 0.510,
    "tabular_risk": 0.420
  },
  
  "module_contributions": {
    "clinical": 0.156,
    "visuospatial": 0.081,
    "acoustic": 0.148,
    "tabular": 0.038
  },
  
  "normative_deviations": {
    "moca_z": -1.54,
    "moca_percentile": 6.2,
    "mmse_z": -0.88,
    "ttr_z": -1.12,
    "velocity_z": -0.43
  },
  
  "feature_importances": {
    "moca_score": 0.38,
    "lexical_diversity": 0.29,
    "drawing_precision": 0.24,
    "reaction_time": 0.09
  },
  
  "flags": {
    "requires_clinical_confirmation": true,
    "depression_flag": false,
    "safety_alert": false,
    "low_confidence": true,
    "education_adjustment_applied": true
  },
  
  "clinical_recommendation": "REFER_SPECIALIST",
  "follow_up_interval_days": 90,
  
  "interpretation": {
    "summary": "Resultados sugieren deterioro cognitivo leve. MoCA por debajo del percentil 10 para grupo normativo (rural, 6 años escolaridad, 65–75 años). Se recomienda evaluación neurológica especializada.",
    "summary_en": "Results suggest mild cognitive impairment. MoCA below 10th percentile for normative group. Specialist neurological evaluation recommended.",
    "moca_interpretation": "Ajustado por educación: 24/30 — dentro del rango MCI.",
    "acoustic_interpretation": "Diversidad léxica reducida (TTR=0.48) — posible dificultad de recuperación léxica.",
    "visuospatial_interpretation": "CDC=3/4 — reloj borderline; presencia de aglomeración de números."
  }
}
```

---

## 8. Future AI Architecture — Full Ensemble (v1.0)

This section documents the complete deep learning ensemble that the rule-based engine will be replaced by once the pilot dataset reaches **n ≥ 100 sessions** (target: n ≥ 200 for full validation).

### 8.1 Total Parameter Count

| Component | Parameters | Role |
|---|---|---|
| Transformer (BERT-based) | ~110,000,000 | Language embeddings + multi-head attention |
| Bidirectional LSTM | ~65,000 | Temporal motor sequence modeling |
| CNN ResNet-lite | ~23,000,000 | Spatial drawing feature extraction |
| Random Forest | ~50,000 eff. | Tabular/clinical structured data |
| Fusion attention layer | ~400,000 | Inter-modality weighting |
| Dense network 512→128 | ~200,000 | Final decision representation |
| **Total** | **~133,800,000** | **Full ensemble** |

### 8.2 Training Strategy

```
Dataset composition target (v1.0):
  DementiaBank (voice): n=291 (public, English — transfer learning source)
  ADNI Mexico-Hispano:  n=187 (neuroimaging + cognitive; Hispanic subsample)
  MCSF Pilot (local):   n≥200 (primary training set; Guanajuato population)
  
  Total balanced (SMOTE): n≈850 samples
  
  Class balance:
    Normal:           33% (~280)
    MCI:              33% (~280)  
    Dementia (mixed): 34% (~290)
  
  Split:
    Training:   70% (595)
    Validation: 15% (128)
    Test:       15% (128) — temporal holdout (most recent sessions)
  
  Cross-validation: Stratified 10-fold
  Framework: TensorFlow 2.14 + scikit-learn
  Hardware: 4× GPU A100 (Google Cloud)
  Duration: ~72h training run
  Hyperopt: Optuna (200 trials, Bayesian optimization)
  
  Regularization:
    Dropout 0.3 (dense layers)
    L2 = 0.01 (weight decay)
    Early stopping (patience=10, monitor=val_AUC)
    Learning rate: 1e-3 (optimal per Bayesian search; stable region: 5e-4 to 5e-3)
```

---

## 9. Transformer Module

**Input**: BERT 512-dimensional semantic embedding vectors of speech transcripts.
**Parameters**: ~110 million
**Purpose**: Captures linguistic context, semantic coherence, lexical diversity, and narrative structure in patient speech — early markers of AD and FTD.

### Architecture

```
Input: BERT embeddings [batch, seq_len, 512]
         ↓
Multi-Head Self-Attention (8 heads, d_k=64)
  Attention(Q,K,V) = softmax(QKᵀ / √d_k) · V
         ↓
Add & LayerNorm
         ↓
Feed-Forward Network (512 → 2048 → 512)
         ↓
Add & LayerNorm
         ↓  (×6 transformer blocks)
Global Average Pooling
         ↓
Dense(512 → 256) + ReLU
         ↓
Output: linguistic_embedding [batch, 256]
```

### Input Preparation

```python
from transformers import BertTokenizer, BertModel

tokenizer = BertTokenizer.from_pretrained('dccuchile/bert-base-spanish-wwm-cased')
# Spanish BERT model — critical for Mexican Spanish population

def prepare_speech_embeddings(transcript: str, max_length: int = 512) -> torch.Tensor:
    """
    Encodes speech transcript into BERT embeddings.
    Uses Spanish BERT pre-trained on BETO corpus (Spanish Wikipedia + news).
    """
    inputs = tokenizer(
        transcript,
        max_length=max_length,
        padding='max_length',
        truncation=True,
        return_tensors='pt'
    )
    with torch.no_grad():
        outputs = bert_model(**inputs)
    
    # Use [CLS] token representation as sentence embedding
    cls_embedding = outputs.last_hidden_state[:, 0, :]   # [1, 768]
    
    # Project to 512D for ensemble compatibility
    return projection_layer(cls_embedding)   # [1, 512]
```

### Feature Extraction (v0.02 substitute)

In v0.02, instead of running BERT inference, the client-side prosody extractor produces the `acoustic_vec[25]` which is passed directly to the rule engine. The Transformer module is invoked server-side once audio processing is complete.

---

## 10. Bidirectional LSTM Module

**Input**: Time series of accelerometry / stroke motor data `[batch, seq_len, 3]` (x, y, Δt axes).
**Parameters**: ~65,000
**Purpose**: Captures temporal dependencies in motor behavior — bradykinesia, tremor, hesitation patterns, stroke velocity curves.

### Architecture

```
Input: motor_sequence [batch, T, 3]   (T = variable length, padded)
         ↓
Bidirectional LSTM (hidden=64, bidirectional → 128 features)
  Forward:  h_t = LSTM(x_t, h_{t-1})
  Backward: h_t = LSTM(x_t, h_{t+1})
  Concat:   h_t_bi = [h_t_fwd; h_t_bwd]   → dim 128
         ↓
Bidirectional LSTM Layer 2 (hidden=64 → 128)
         ↓
Attention over temporal steps (Luong-style)
  score(h_t) = tanh(W_a · h_t)
  α_t = softmax(score)
  context = Σ α_t · h_t
         ↓
Dense(128 → 64) + ReLU
         ↓
Output: motor_embedding [batch, 64]   (concatenated as 128D after padding)
```

### Data Preparation

```python
def prepare_stroke_sequences(strokes: list[dict], max_len: int = 500) -> np.ndarray:
    """
    Converts raw stroke data into padded time series for LSTM input.
    Each timestep: [normalized_x, normalized_y, delta_t_ms_normalized]
    """
    sequences = []
    for stroke in strokes:
        for i, pt in enumerate(stroke['points']):
            if i == 0:
                delta_t = 0.0
            else:
                delta_t = (pt['t'] - stroke['points'][i-1]['t']) / 1000.0
            sequences.append([
                pt['x'] / canvas_width,   # normalize to [0, 1]
                pt['y'] / canvas_height,
                min(delta_t, 1.0),         # cap at 1s
            ])
    
    # Pad/truncate to max_len
    seq_array = np.array(sequences[:max_len])
    if len(seq_array) < max_len:
        padding = np.zeros((max_len - len(seq_array), 3))
        seq_array = np.vstack([seq_array, padding])
    
    return seq_array   # shape: [max_len, 3]
```

---

## 11. CNN Module (ResNet-lite)

**Input**: RGB drawing images `[batch, 224, 224, 3]`.
**Parameters**: ~23 million
**Purpose**: Extracts spatial features from Clock Drawing Test and copy figure tasks — circle quality, number placement, hand positioning, overall gestalt.

### Architecture

```
Input: drawing_image [batch, 224, 224, 3]
         ↓
Conv2D(64, 7×7, stride=2) + BN + ReLU   → [112, 112, 64]
MaxPool(3×3, stride=2)                   → [56, 56, 64]
         ↓
ResNet Block × 2 (64 filters)
  X → Conv(64,3×3) → BN → ReLU → Conv(64,3×3) → BN
  Skip: X
  Output: X + skip                        → [56, 56, 64]
         ↓
ResNet Block × 2 (128 filters, stride=2) → [28, 28, 128]
ResNet Block × 2 (256 filters, stride=2) → [14, 14, 256]
ResNet Block × 2 (512 filters, stride=2) → [7, 7, 512]
         ↓
Global Average Pooling                   → [512]
         ↓
Dense(512 → 256) + ReLU + Dropout(0.3)
         ↓
Output: visuospatial_embedding [batch, 256]

Convolution operation:
  X^(l+1) = ReLU(W^(l) * X^(l) + b^(l))
  where * denotes 2D cross-correlation

Loss (training, auxiliary head):
  L = -Σᵢ Σ_c y_ic · log(p_ic)   [categorical cross-entropy]
```

### GRAD-CAM Explainability

```python
def generate_gradcam(model, image_tensor, target_class_idx):
    """
    Generates gradient-weighted class activation map for clinical transparency.
    Highlights image regions that drove the CNN classification.
    Used in clinical reports to show WHAT the model saw in the clock drawing.
    """
    gradients = []
    activations = []
    
    # Hook the last convolutional layer
    def backward_hook(module, grad_input, grad_output):
        gradients.append(grad_output[0])
    def forward_hook(module, input, output):
        activations.append(output)
    
    # ... register hooks, run forward/backward pass ...
    
    # Compute weighted activation map
    weights = torch.mean(gradients[0], dim=[2, 3])   # [batch, C]
    cam = torch.sum(weights[:, :, None, None] * activations[0], dim=1)
    cam = F.relu(cam)
    cam = F.interpolate(cam.unsqueeze(1), size=(224, 224), mode='bilinear')
    
    return cam   # Overlay on original image for report
```

### Image Preprocessing

```python
def preprocess_drawing_image(png_bytes: bytes) -> np.ndarray:
    """
    Prepares drawing canvas image for CNN inference.
    - Resize to 224×224
    - Convert grayscale strokes to RGB (stroke in black, background white → inverted to white strokes on black = neural convention)
    - ImageNet normalization
    """
    img = Image.open(io.BytesIO(png_bytes)).convert('RGB')
    img = img.resize((224, 224), Image.LANCZOS)
    
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])
    return transform(img).unsqueeze(0)   # [1, 3, 224, 224]
```

---

## 12. Random Forest Module

**Input**: Tabular feature vector of 28 standardized variables.
**Parameters**: 100 trees, ~50,000 effective parameters.
**Purpose**: Clinical structured data — demographics, comorbidities, standardized test scores, functional assessments.

### Configuration

```python
from sklearn.ensemble import RandomForestClassifier

rf_model = RandomForestClassifier(
    n_estimators=100,
    criterion='gini',          # Gini(t) = 1 − Σᵢ pᵢ²
    max_depth=None,            # Grow until pure leaves
    min_samples_split=5,
    min_samples_leaf=2,
    max_features='sqrt',       # √n features per split
    bootstrap=True,
    class_weight='balanced',   # Handle class imbalance without SMOTE
    random_state=42,
    n_jobs=-1,
    oob_score=True,            # Out-of-bag validation
)

# Decision tree (interpretable baseline for v0.02)
from sklearn.tree import DecisionTreeClassifier, export_text

dt_model = DecisionTreeClassifier(
    criterion='gini',
    max_depth=8,               # Limited depth for interpretability
    min_samples_leaf=3,
    class_weight='balanced',
)
```

### Feature Vector Construction

```python
def build_tabular_vector(patient: dict, session: dict) -> np.ndarray:
    """
    Constructs the 28-feature tabular vector for RF input.
    All continuous features Z-score normalized.
    All categorical features one-hot encoded.
    """
    # === Continuous features (Z-score normalized) ===
    age = (patient['age'] - 71.2) / 8.4          # Phase 2 sample mean/std
    education = (patient['education_years'] - 6.8) / 4.2
    moca = (session['moca_adjusted'] - 21.2) / 5.8
    mmse = (session['mmse_total'] - 24.1) / 4.7
    phq9 = (session['phq9_total'] - 8.3) / 5.2
    zarit = (session.get('zarit_total', 42) - 42.6) / 16.5
    katz = (session['katz_total'] - 5.0) / 1.0
    sleep = (patient.get('sleep_hours', 7) - 7.0) / 1.5
    
    # === Binary features (0/1) ===
    binary_features = [
        int(patient.get('sex') == 'female'),
        int(patient.get('residence_type') == 'rural'),
        int(patient.get('social_isolation', False)),
        int(patient.get('diabetes', False)),
        int(patient.get('hypertension', False)),
        int(patient.get('family_history_dementia', False)),
        int(patient.get('post_trauma', False)),
        int(patient.get('chronic_stress', False)),
        int(patient.get('rural_exposure_20y', False)),
        int(patient.get('depression_history', False)),
    ]
    
    # === Ordinal features (normalized 0–1) ===
    activity = patient.get('physical_activity_level', 1) / 3   # 0–3
    nutrition = patient.get('nutrition_risk', 0) / 3
    env_exposure = patient.get('environmental_exposure', 0) / 3
    digital = patient.get('digital_competence', 2) / 4
    
    vector = np.array([
        age, education, moca, mmse, phq9, zarit, katz, sleep,
        *binary_features,
        activity, nutrition, env_exposure, digital,
    ])
    
    return vector   # shape: [28]
```

### Decision Tree Export (v0.02 Interpretability)

```python
# For clinical review and audit — print human-readable decision tree
tree_rules = export_text(dt_model, feature_names=FEATURE_NAMES)
print(tree_rules)
# Output example:
# |--- moca_z <= -1.50
# |   |--- phq9_total <= 9.50
# |   |   |--- ad8_positive_count <= 1.50
# |   |   |   |--- class: MCI (prob: 0.72)
# |   |   |--- ad8_positive_count > 1.50
# |   |   |   |--- class: Alzheimer (prob: 0.65)
# |   |--- phq9_total > 9.50
# |   |   |--- class: Pseudodementia (prob: 0.60)
# |--- moca_z > -1.50
# |   |--- class: Normal (prob: 0.88)
```

---

## 13. Concatenation Layer

### Description

After each specialized model produces its embedding, the outputs are **concatenated into a single feature vector** before the fusion attention layer.

```
Transformer output:    linguistic_embedding  [batch, 256]
Bi-LSTM output:        motor_embedding       [batch, 128]
CNN output:            visuospatial_embed    [batch, 256]
Random Forest output:  tabular_embedding     [batch, 64]
                                              ──────────
Concatenated vector:                         [batch, 704]
```

### Implementation

```python
def concatenate_modalities(linguistic, motor, visuospatial, tabular):
    """
    Concatenates embeddings from all four specialized models.
    No learnable parameters in this layer — pure tensor concatenation.
    """
    return torch.cat([
        linguistic,      # [batch, 256]
        motor,           # [batch, 128]
        visuospatial,    # [batch, 256]
        tabular,         # [batch,  64]
    ], dim=-1)           # → [batch, 704]
```

### v0.02 Equivalent

```python
def concatenate_module_scores_v002(clinical, visuospatial, acoustic, tabular_risk):
    """
    Rule-based equivalent of concatenation.
    Produces a 4-element 'embedding' representing each module's signal.
    This vector maps to the same schema position as the 704D neural embedding.
    """
    return np.array([
        clinical['module_score'],
        visuospatial['module_score'],
        acoustic['module_score'],
        tabular_risk,
    ])
```

---

## 14. Multi-Head Attention Fusion Layer

### Purpose

The multi-head attention layer **dynamically weights inter-modality relationships**, allowing the model to learn which biomarker streams are most informative for each patient's profile. This is the architectural equivalent of the SHAP importance weighting in the rule-based engine.

### Architecture

```
Input: fused_vector [batch, 704]
         ↓
Reshape to sequence: [batch, 4, 176]   (4 modality "tokens")
         ↓
Multi-Head Attention (H=4 heads, d_model=128, d_k=32)

  For each head h:
    Q_h = W_Q_h · input   [batch, 4, 32]
    K_h = W_K_h · input   [batch, 4, 32]
    V_h = W_V_h · input   [batch, 4, 32]
    
    head_h = softmax(Q_h · K_hᵀ / √32) · V_h
    
  MultiHead = Concat(head_1, ..., head_4) · W_O
         ↓
Add & LayerNorm
         ↓
Project to 512D
         ↓
Output: fused_embedding [batch, 512]
```

### Learned Head Specialization (Phase 2 findings)

| Attention Head | Learned Specialization |
|---|---|
| Head 1 | Prioritizes Speech + Drawing (linguistic + visuospatial) |
| Head 2 | Prioritizes temporal motor processing (Bi-LSTM features) |
| Head 3 | Prioritizes visuospatial spatial features (CNN) |
| Head 4 | Prioritizes tabular clinical data + speech scores |

```python
class MultiHeadModalityAttention(nn.Module):
    def __init__(self, d_model=128, num_heads=4, dropout=0.1):
        super().__init__()
        self.num_heads = num_heads
        self.d_k = d_model // num_heads   # 32
        
        self.W_Q = nn.Linear(d_model, d_model)
        self.W_K = nn.Linear(d_model, d_model)
        self.W_V = nn.Linear(d_model, d_model)
        self.W_O = nn.Linear(d_model, d_model)
        self.dropout = nn.Dropout(dropout)
        self.norm = nn.LayerNorm(d_model)
    
    def forward(self, x):
        # x: [batch, seq=4, d_model=128]
        residual = x
        
        Q = self.W_Q(x).view(batch, 4, self.num_heads, self.d_k).transpose(1,2)
        K = self.W_K(x).view(batch, 4, self.num_heads, self.d_k).transpose(1,2)
        V = self.W_V(x).view(batch, 4, self.num_heads, self.d_k).transpose(1,2)
        
        scores = torch.matmul(Q, K.transpose(-2,-1)) / math.sqrt(self.d_k)
        attn = F.softmax(scores, dim=-1)
        attn = self.dropout(attn)
        
        context = torch.matmul(attn, V)
        context = context.transpose(1,2).contiguous().view(batch, 4, -1)
        output = self.W_O(context)
        
        return self.norm(output + residual)   # residual connection
```

---

## 15. Deep Dense Network

### Purpose

The dense network **integrates the fused multi-modal representation** into a final decision space before the output heads.

### Architecture

```
Input: fused_embedding [batch, 512]
         ↓
Dense(512 → 256) + BatchNorm + ReLU + Dropout(0.3)
         ↓
Dense(256 → 128) + BatchNorm + ReLU + Dropout(0.3)
         ↓
Output: decision_embedding [batch, 128]
         ↓
      ┌──┴────────────────┐
      │                   │
      ▼                   ▼
Softmax Head        Sigmoid Head
(7 classes)         (continuous)
```

### Implementation

```python
class DenseIntegrationNetwork(nn.Module):
    def __init__(self, input_dim=512):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(input_dim, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(),
            nn.Dropout(0.3),
            
            nn.Linear(256, 128),
            nn.BatchNorm1d(128),
            nn.ReLU(),
            nn.Dropout(0.3),
        )
        # L2 regularization applied via optimizer weight_decay=0.01
    
    def forward(self, x):
        return self.network(x)   # [batch, 128]
```

---

## 16. Multiclass Softmax Output

### Purpose

Produces **probability distribution over 7 diagnostic classes**.

### Classes & ICD-10 Mapping

| Class | ICD-10-CM | Description |
|---|---|---|
| `Normal` | Z13.850 | No cognitive impairment detected |
| `MCI` | G31.84 | Mild Cognitive Impairment |
| `Alzheimer` | G30.9 | Alzheimer's disease dementia |
| `Frontotemporal` | G31.09 | Frontotemporal dementia |
| `LewyBodies` | G31.83 | Lewy Body dementia |
| `Vascular` | F01.51 | Vascular dementia, moderate severity |
| `Pseudodementia` | F32.9 | Depressive pseudodementia |

### Implementation

```python
class SoftmaxClassificationHead(nn.Module):
    def __init__(self, input_dim=128, num_classes=7):
        super().__init__()
        self.classifier = nn.Linear(input_dim, num_classes)
    
    def forward(self, x):
        logits = self.classifier(x)   # [batch, 7]
        probs = F.softmax(logits, dim=-1)
        
        # pᵢ = exp(zᵢ) / Σⱼ exp(zⱼ)
        return probs   # [batch, 7] — sum to 1.0

# Training loss
criterion = nn.CrossEntropyLoss(
    weight=class_weights,   # Inverse frequency weighting for rare subtypes
    label_smoothing=0.1,    # Prevent overconfidence
)
```

---

## 17. Continuous Sigmoid Risk Score

### Purpose

Produces a **continuous risk score 0–100** that quantifies cognitive impairment severity regardless of discrete class assignment. Enables longitudinal tracking (ΔRisk over time).

### Implementation

```python
class SigmoidRiskHead(nn.Module):
    def __init__(self, input_dim=128):
        super().__init__()
        self.risk_layer = nn.Linear(input_dim, 1)
    
    def forward(self, x):
        h = self.risk_layer(x)          # [batch, 1]
        risk = 100 * torch.sigmoid(h)   # Risk = 100 × σ(W·h + b)
        return risk.squeeze(-1)          # [batch]

# Risk = 100 × σ(W · h + b)
# σ(x) = 1 / (1 + e^−x)
# Output: continuous [0, 100]
# Interpretation:
#   0–29:  Low risk
#   30–49: Moderate risk
#   50–69: High risk
#   70–100: Elevated / critical

# Training target: regression loss on composite impairment index
risk_criterion = nn.MSELoss()
risk_target = compute_composite_impairment_index(clinical_labels, functional_scores)
```

---

## 18. Normative Statistics & z-Score Engine

### Normative Groups (stratified by residence × education × age)

```python
NORMATIVE_TABLE = {
    # Key: (age_group, education_group, residence)
    # Values: (mean, std) for MoCA adjusted total
    # Source: Phase 1 (Castillo García 2025) + Mejía-Arango (2024) + Sosa-Ortiz (2012)
    
    ('60-70', 'low',  'rural'):  (19.8, 5.2),   # Phase 1 direct observation
    ('60-70', 'low',  'urban'):  (23.1, 3.8),
    ('60-70', 'mid',  'rural'):  (21.5, 4.6),
    ('60-70', 'mid',  'urban'):  (24.4, 3.6),   # Phase 1 urban mean
    ('60-70', 'high', 'urban'):  (25.9, 2.9),
    
    ('70-80', 'low',  'rural'):  (18.2, 5.8),
    ('70-80', 'low',  'urban'):  (21.5, 4.4),
    ('70-80', 'mid',  'rural'):  (19.8, 5.0),
    ('70-80', 'mid',  'urban'):  (22.8, 4.1),
    ('70-80', 'high', 'urban'):  (24.5, 3.2),
    
    ('>80',   'low',  'rural'):  (16.5, 6.1),
    ('>80',   'low',  'urban'):  (19.2, 5.3),
    ('>80',   'mid',  'urban'):  (21.0, 4.8),
}

def get_age_group(age: int) -> str:
    if age < 70:  return '60-70'
    if age < 80:  return '70-80'
    return '>80'

def get_education_group(years: int) -> str:
    if years <= 6:   return 'low'
    if years <= 12:  return 'mid'
    return 'high'

def compute_normative_z(value: float, mean: float, std: float) -> float:
    return (value - mean) / std if std > 0 else 0.0

def percentile_from_z(z: float) -> float:
    from scipy.stats import norm
    return round(norm.cdf(z) * 100, 1)

def generate_normative_report(session: dict, patient: dict) -> dict:
    age_g = get_age_group(patient['age'])
    edu_g = get_education_group(patient['education_years'])
    res   = patient['residence_type']
    
    key = (age_g, edu_g, res)
    norm_mean, norm_std = NORMATIVE_TABLE.get(key, (22.0, 4.5))
    
    moca = session['moca_adjusted']
    z = compute_normative_z(moca, norm_mean, norm_std)
    
    return {
        'normative_group': key,
        'normative_mean': norm_mean,
        'normative_std': norm_std,
        'moca_z_score': round(z, 2),
        'moca_percentile': percentile_from_z(z),
        'interpretation': interpret_percentile(percentile_from_z(z)),
        'sample_n': 'literature_derived',
        'will_update_with': 'pilot_data_n≥30',
    }
```

---

## 19. Clinical Interpretation Engine (v0.02 Rule Layer)

### Interpretation Logic — Clinical Narrative Generation

```python
def generate_clinical_interpretation(output: dict, patient: dict) -> dict:
    """
    Generates human-readable clinical interpretation in Spanish and English.
    This is the final output layer — the "dense fully-connected clinical reasoning" —
    translating numerical scores into actionable clinical summaries.
    """
    
    moca = output['module_scores']['clinical_domain']['moca']
    risk = output['risk_score']
    category = output['risk_category']
    pred_class = output['predicted_class']
    z = output['normative_deviations']['moca_z']
    percentile = output['normative_deviations']['moca_percentile']
    stage = output['clinical_stage']
    
    RECOMMENDATIONS = {
        'normal':           ('MONITOR_ANNUAL', 365, 'LOW'),
        'mci':              ('REFER_SPECIALIST', 90, 'MODERATE'),
        'mild_dementia':    ('REFER_SPECIALIST', 60, 'HIGH'),
        'moderate_dementia':('IMMEDIATE_CARE', 30, 'ELEVATED'),
        'advanced_dementia':('IMMEDIATE_CARE', 14, 'ELEVATED'),
    }
    
    action, follow_up, priority = RECOMMENDATIONS.get(stage, ('MONITOR_ANNUAL', 365, 'LOW'))
    
    # Education-adjusted note
    edu_note_es = ""
    if patient['education_years'] <= 12:
        edu_note_es = " (Puntaje ajustado +1 punto por ≤12 años de escolaridad, validado para población mexicana)"
    
    # Build interpretation blocks
    moca_interp_es = (
        f"MoCA Ajustado: {moca}/30{edu_note_es}. "
        f"Percentil {percentile:.0f} vs grupo normativo "
        f"({patient.get('residence_type','')}, {patient.get('education_years',0)} años escolaridad, "
        f"{patient['age']} años). "
        f"Puntaje {'dentro del rango normal' if moca >= 26 else 'por debajo del rango esperado'}."
    )
    
    risk_interp_es = (
        f"Puntaje de riesgo compuesto: {risk}/100 — categoría {category}. "
        f"Clasificación preliminar: {pred_class}. "
        "Este resultado es un marcador de apoyo a la decisión clínica y "
        "no reemplaza la evaluación neurológica especializada."
    )
    
    flags_interp = []
    if output['flags']['depression_flag']:
        flags_interp.append("⚠ PHQ-9 ≥10: Depresión clínica probable — puede estar influyendo en el desempeño cognitivo.")
    if output['flags']['education_adjustment_applied']:
        flags_interp.append("ℹ Ajuste educativo aplicado (+1 punto MoCA, validado Castillo García 2025).")
    if output['flags']['requires_clinical_confirmation']:
        flags_interp.append("⚠ Confianza del modelo < 70%: Se requiere confirmación clínica.")
    
    return {
        'language': 'es-MX',
        'moca_interpretation': moca_interp_es,
        'risk_interpretation': risk_interp_es,
        'flags': flags_interp,
        'recommendation': translate_recommendation(action),
        'follow_up_interval_days': follow_up,
        'priority': priority,
        'summary': build_clinical_summary(pred_class, stage, risk, moca, patient),
        'caregiver_summary': build_caregiver_summary(output, patient),
        'disclaimer': (
            "AVISO: Este sistema es una herramienta de apoyo a la investigación clínica (v0.02). "
            "Los resultados NO constituyen un diagnóstico médico y deben interpretarse únicamente "
            "por un profesional de la salud certificado."
        ),
    }
```

### Recommendation Mapping

| Rule Trigger | Recommendation | Follow-up | Priority |
|---|---|---|---|
| MoCA ≥26 + AD8 ≤1 + Risk <30 | Annual monitoring | 365 days | LOW |
| MoCA 18–25 OR Risk 30–50 | Specialist referral | 90 days | MODERATE |
| MoCA <18 OR Risk 50–70 + AD8 ≥2 | Specialist referral urgent | 60 days | HIGH |
| MoCA <12 OR Risk >70 OR Katz ≤2 | Immediate care pathway | 14–30 days | ELEVATED |
| PHQ-9 ≥15 + pseudodementia flags | Depression treatment first; rescreen in 60d | 60 days | MODERATE |
| PHQ-9 Item 9 ≥1 | SAFETY_ALERT → clinician notified | Immediate | CRITICAL |

---

## 20. Phase Transition: v0.02 → v1.0

### Migration Checklist

| Milestone | Trigger | Action |
|---|---|---|
| n = 30 completed sessions | Pilot launch +2 months | First RF model trained on local data; replace literature normatives |
| n = 50 sessions | ~Month 3 | Validate RF vs decision tree; compare to rule engine outputs |
| n = 100 sessions | ~Month 6 | Clinical validation study (vs neurologist gold standard); CNN clock drawing pilot |
| n = 150 sessions | ~Month 9 | BERT fine-tuning on local Spanish speech transcripts; Bi-LSTM motor model |
| n = 200 sessions | ~Month 12 | Full ensemble training; replace rule engine; Phase 2 replication attempt |
| AUC ≥ 0.88 achieved | Validation study | COFEPRIS pre-notification; IRB research dataset publication |

### Schema Continuity Guarantee

The **output JSON schema does not change** between v0.02 and v1.0. The `engine_version` field indicates which engine produced the output. All frontend components, FHIR mappings, and database columns remain identical.

```
v0.02:  "engine_version": "rule_v0.02",  "confidence": 0.65  (rule-derived)
v0.05:  "engine_version": "rf_v0.05",    "confidence": 0.71  (local RF)
v1.0:   "engine_version": "ensemble_v1", "confidence": 0.91  (full ensemble)
```

### Data Readiness Requirements for v1.0

| Requirement | Status |
|---|---|
| n ≥ 200 labeled sessions (gold standard diagnosis) | ⬜ In collection |
| Audio files + server-side MFCC extraction | ⬜ Pipeline ready |
| Clock drawing PNGs + stroke JSON (all sessions) | ⬜ Pipeline ready |
| Tabular feature matrix (all 28 variables, all sessions) | ⬜ In collection |
| Neurologist gold standard diagnoses (DSM-5 + CDR) | ⬜ ISSSTE protocol |
| IRB approval for ML training use | ⬜ In submission |
| SMOTE class balancing to n≈850 | ⬜ Automated (scikit) |
| DementiaBank + ADNI transfer learning weights | ✅ Available (public) |

---

*MCSF AI Framework Documentation — v0.02*
*PrepaTec Irapuato · Tecnológico de Monterrey*
*NeuralHack Cognitive AI Research Extension*
*Contact: a01353042@tec.mx*
*License: Apache 2.0*

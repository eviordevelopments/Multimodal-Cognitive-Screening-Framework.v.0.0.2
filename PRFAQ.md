# Multimodal Cognitive Screening Framework (MCSF) - PRFAQ

## Press Release

**For Immediate Release**

**Irapuato, Mexico - May 21, 2026** - The ISSSTE Geriatrics Department, in collaboration with PrepaTec, Tecnológico de Monterrey, announces the release of the Multimodal Cognitive Screening Framework (MCSF) v0.02. This innovative open-source clinical data acquisition platform fundamentally transforms how cognitive biomarkers are collected and analyzed for neurodegenerative diseases.

"MCSF addresses the critical gap between qualitative clinical observations and quantitative, structured data required for advanced AI research," said Emiliano Castillo, Lead Researcher. "By digitizing speech, drawing tasks, and traditional clinical scales, we are enabling the next generation of ensemble machine learning models for early dementia detection."

Unlike traditional paper-based assessments, MCSF introduces a late-fusion modular design that independently processes clinical, visuospatial, and acoustic data. The platform ensures rigorous compliance with HIPAA, FDA 21 CFR Part 11, and COFEPRIS NOM-024-SSA3, guaranteeing patient data privacy through AES-256 encryption and offline-first capabilities—crucial for rural deployments. 

MCSF seamlessly maps all data structures directly to HL7 FHIR R4 resources, ensuring complete interoperability with existing health systems. Built with Flutter, the system is natively cross-platform across iOS, Android, and Web, providing a clinician-facing dashboard for supervised sessions and a secure portal for patient self-assessment.

## FAQ

**1. What is MCSF?**
MCSF is an open-source, research-grade platform to collect, standardize, and analyze cognitive biomarkers (speech, drawing, clinical scores) to support early screening for neurodegenerative diseases.

**2. Is this a medical device?**
No. It is a Clinical Information System (CIS) intended as a pilot data collection tool and decision-support mechanism for licensed clinicians. It does not replace clinical judgment or serve as a standalone diagnostic tool.

**3. What data does the application collect?**
- **Clinical Data**: Demographics, risk factors, MoCA, MMSE, PHQ-9, AD8, Katz ADL.
- **Visuospatial Data**: Stylus/touch stroke parameters (x, y, timestamp, pressure, velocity) from clock drawing and figure copying tasks.
- **Acoustic Data**: Speech recordings and prosodic features (pauses, disfluency rate, frequency).

**4. How does the system handle offline environments?**
The platform is built offline-first. It utilizes encrypted local storage (Hive, SQLite via drift) to cache all session data and syncs automatically with the backend via background processes when connectivity is restored.

**5. How is patient privacy maintained?**
MCSF implements AES-256-GCM encryption at rest, TLS 1.3 in transit, and role-based access control. All data writes are secured with SHA-256 immutable audit chains, complying with HIPAA and COFEPRIS guidelines.

**6. What is the architecture behind it?**
A late-fusion modular architecture where independent data pipelines (Clinical, Visuospatial, Acoustic) process inputs and feed them into a unified feature matrix. The ML engine (Random Forest) evaluates this matrix against normative deviation baselines.

**7. Who is the target audience?**
- **Clinicians**: Geriatricians at ISSSTE for patient screening and session management.
- **Patients**: For self-assessments and monitoring.
- **Researchers**: For analyzing anonymized biomarker datasets and training models.

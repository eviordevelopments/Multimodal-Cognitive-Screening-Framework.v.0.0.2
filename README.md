# Multimodal Cognitive Screening Framework (MCSF)

## Version: v.0.02
**Phase:** Pilot Data Collection / Framework Development  
**Institutional Affiliation:** PrepaTec, Tecnológico de Monterrey, Campus Irapuato

---

## Description
The **Multimodal Cognitive Screening Framework (MCSF)** is an open-source, research-oriented platform designed for the systematic collection, standardization, and statistical analysis of cognitive biomarkers in neurodegenerative diseases.

This framework serves as a clinical data acquisition layer, bridging the gap between raw biometric input—such as visuospatial performance (clock drawing), acoustic prosody (speech), and standardized clinical assessments—and structured digital analysis. By implementing a modular architecture, this repository facilitates the transition from qualitative observational data to high-fidelity quantitative analysis required for neurodegenerative screening.

## Objective
To provide a secure and reproducible infrastructure for medical professionals (in collaboration with the ISSSTE Geriatrics Department) to conduct standardized cognitive screening, enabling the future development and validation of ensemble machine learning models for early dementia detection.

## System Architecture
The framework employs a **Late-Fusion Modular Design**:

* **Clinical Module:** Captures standardized demographic and neuropsychological data (MoCA/MMSE).
* **Visuospatial Module:** Collects digital stroke-data (x, y coordinates, pressure, velocity) from tablet-based drawing tasks.
* **Acoustic Module:** Records standardized speech prompts to extract prosodic metadata.
* **Analytical Engine:** Uses baseline statistical deviations and Random Forest-based classification to compare patient performance against normative cognitive trends.

## Ethical Disclaimer

### Research Integrity & Ethical Oversight
This repository and the associated platform represent an early-stage pilot framework for the development of clinical decision support tools. All data collection is conducted under the direct supervision of licensed medical professionals at the ISSSTE Geriatrics Clinic, in accordance with institutional ethical guidelines and protocols for human subject participation.

### Medical Disclaimer
This project does not constitute a diagnostic medical device. The analytical results provided by the current version (v.0.02) are intended solely as supplementary decision-support markers for clinicians and should not be used as a standalone diagnostic tool. The author and collaborators assume no responsibility for clinical decisions made outside of established medical supervision.

## Contributions & Contact
This research is developed in collaboration with the Geriatrics and Aging Department of the ISSSTE Clinic, Irapuato, Mexico. 

For inquiries regarding the technical framework or research methodology, please contact the lead researcher via the institutional email a01353042@tec.mx provided in the manuscript documentation.

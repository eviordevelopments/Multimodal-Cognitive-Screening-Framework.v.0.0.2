# E-vior Orchestration: Multimodal Cognitive Screening Framework (MCSF)

## Orchestration Pattern: Sequential (Pipeline)
As defined in `/systemagentsworkflow`, this project uses a Sequential Pipeline pattern to ensure rigorous adherence to the NASA SE process (Requirement -> Design -> Implement -> Verify -> Validate -> Operate) and SOLID/KISS principles.

## Active Agents

### 1. E-vior ReqAgent (Requirements Engineer)
* **Focus**: NASA SE Steps 1-2.
* **Responsibilities**: Define the PRFAQ, establish constraints, parse `MCSF_v0.02_Platform_Documentation.md` into actionable tickets.
* **Artifacts**: `PRFAQ.md`, `REQUIREMENTS.md`

### 2. E-vior ArchAgent (System Architect)
* **Focus**: NASA SE Steps 3-4.
* **Responsibilities**: Define system architecture, data models, FHIR mapping schemas, ML pipeline architecture, backend integration logic, security protocols.
* **Artifacts**: `ARCHITECTURE.md`, `DATA_PIPELINE.md`

### 3. E-vior CodeAgent (Developer)
* **Focus**: SOLID, KISS. Implementation.
* **Responsibilities**: Execute TDD for the Flutter frontend (`mcsf/`), setup backend stubs, build data collection pipelines (voice, drawing, clinical forms).

### 4. E-vior TestAgent (QA/SDET)
* **Focus**: NASA SE Steps 7-8. Testing.
* **Responsibilities**: Write tests for data integrity, encryption, validation of biomarker extraction.

### 5. E-vior AI OpsAgent (DevOps/SRE)
* **Focus**: NASA SE Step 10. Operations.
* **Responsibilities**: Establish offline-first sync mechanism validation, encryption checks, deployment configuration.

## Execution Pipeline

1. **Phase 1: Requirements & Architecture (Current)**
   - [x] Create `AGENTS.md`
   - [ ] ReqAgent: Draft `PRFAQ.md`
   - [ ] ArchAgent: Draft `ARCHITECTURE.md`
   - [ ] ArchAgent: Draft `DATA_PIPELINE.md`
2. **Phase 2: Project Initialization**
   - [ ] CodeAgent: Scaffold `mcsf/` Flutter project
   - [ ] CodeAgent: Setup folder structure and `pubspec.yaml`
3. **Phase 3: Core Domain Implementation (TDD)**
   - [ ] TestAgent: Write unit tests for Data Models (FHIR)
   - [ ] CodeAgent: Implement Data Models
   - [ ] CodeAgent: Implement Offline Storage Layer
4. **Phase 4: Module Implementation**
   - [ ] CodeAgent: Implement Clinical Module (MoCA, etc.)
   - [ ] CodeAgent: Implement Visuospatial Module (Drawing)
   - [ ] CodeAgent: Implement Acoustic Module (Voice)
5. **Phase 5: Analytical Engine**
   - [ ] CodeAgent: Stub/Integration of ML Microservice payload structure.

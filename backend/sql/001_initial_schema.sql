-- Initial Schema for MCSF Backend (Supabase PostgreSQL)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: patients
-- Stores patient demographic and risk factor data. PHI (like curp) is encrypted.
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  fhir_id VARCHAR UNIQUE,
  curp VARCHAR, -- Encrypted at rest by client, stored as opaque string
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  date_of_birth DATE NOT NULL,
  sex VARCHAR(20),
  residence_type VARCHAR(20),
  institution_id VARCHAR(100),
  demographics JSONB,
  risk_factors JSONB,
  enrollment_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  consent_status VARCHAR(50),
  consent_fhir_id VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Table: sessions
-- Represents an assessment session (Encounter) containing multiple modalities.
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  fhir_encounter_id VARCHAR UNIQUE,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  clinician_id UUID NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  status VARCHAR(50) NOT NULL,
  session_type VARCHAR(50) NOT NULL,
  composite_hash VARCHAR, -- SHA-256 for audit
  clinician_notes TEXT,
  risk_score JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Table: clinical_results
-- Structured outputs from clinical surveys
CREATE TABLE clinical_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  moca_score INT,
  moca_details JSONB,
  mmse_score INT,
  phq9_score INT,
  phq9_severity VARCHAR(50),
  ad8_score INT,
  katz_score INT,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Table: visuospatial_results
-- Analyzed visuospatial output
CREATE TABLE visuospatial_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  task_type VARCHAR(50), -- e.g., 'clock_drawing'
  stroke_velocity_mean DECIMAL,
  stroke_velocity_std DECIMAL,
  mean_pressure DECIMAL,
  trajectory_deviation DECIMAL,
  symmetry_index DECIMAL,
  lift_count INT,
  total_path_length DECIMAL,
  image_url VARCHAR, -- URL to Cloud Storage
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Table: acoustic_results
-- Analyzed acoustic output
CREATE TABLE acoustic_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  task_type VARCHAR(50),
  word_count INT,
  speech_rate DECIMAL,
  pause_count INT,
  mean_pause_duration_ms DECIMAL,
  f0_mean DECIMAL,
  f0_std DECIMAL,
  type_token_ratio DECIMAL,
  disfluency_rate DECIMAL,
  audio_url VARCHAR, -- URL to Cloud Storage
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Row Level Security (RLS) policies would go here to restrict clinician access.

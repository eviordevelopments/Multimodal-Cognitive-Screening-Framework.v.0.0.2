import 'package:drift/drift.dart';

// These tables correspond to the offline representations of the backend schemas

class PatientsTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get fhirId => text().nullable()();
  TextColumn get curp => text()(); // Encrypted locally
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get sex => text()();
  TextColumn get demographicsJson => text()(); // Store complex nested objects as JSON strings locally
  TextColumn get riskFactorsJson => text()();
  DateTimeColumn get enrollmentDate => dateTime()();
  TextColumn get consentStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get fhirEncounterId => text().nullable()();
  TextColumn get patientId => text().references(PatientsTable, #id)();
  TextColumn get clinicianId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get sessionType => text()();
  TextColumn get compositeHash => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ClinicalResultsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(SessionsTable, #id)();
  IntColumn get mocaScore => integer().nullable()();
  TextColumn get mocaDetailsJson => text().nullable()();
  IntColumn get mmseScore => integer().nullable()();
  IntColumn get phq9Score => integer().nullable()();
  IntColumn get ad8Score => integer().nullable()();
  IntColumn get katzScore => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class VisuospatialResultsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(SessionsTable, #id)();
  TextColumn get taskType => text()();
  RealColumn get strokeVelocityMean => real()();
  RealColumn get meanPressure => real()();
  TextColumn get imageLocalPath => text()(); // Path to local storage before sync
  
  @override
  Set<Column> get primaryKey => {id};
}

class AcousticResultsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(SessionsTable, #id)();
  TextColumn get taskType => text()();
  IntColumn get wordCount => integer()();
  RealColumn get speechRate => real()();
  TextColumn get audioLocalPath => text()(); // Path to local storage before sync

  @override
  Set<Column> get primaryKey => {id};
}

// @DriftDatabase(tables: [PatientsTable, SessionsTable, ClinicalResultsTable, VisuospatialResultsTable, AcousticResultsTable])
// class OfflineDatabase extends _$OfflineDatabase { ... } 
// Implementation depends on drift generator, skipping boilerplate for now.

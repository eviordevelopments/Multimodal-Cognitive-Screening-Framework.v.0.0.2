import 'dart:math';
import '../models/stroke_data.dart';

class StrokeAnalyzer {
  /// Computes kinematic features from a raw sequence of pointer events (StrokePoints).
  /// This mathematical model derives velocity ($\Delta d / \Delta t$), pressure,
  /// and total path length which are critical biomarkers for visuospatial attrition.
  static DrawingStroke analyzeStroke(String strokeId, List<StrokePoint> rawPoints) {
    if (rawPoints.isEmpty) {
      throw ArgumentError('Cannot analyze an empty stroke.');
    }

    if (rawPoints.length == 1) {
      return DrawingStroke(
        strokeId: strokeId,
        points: rawPoints,
        startTimeMs: rawPoints.first.timestampMs,
        endTimeMs: rawPoints.first.timestampMs,
        meanVelocity: 0.0,
        velocityVariability: 0.0,
        meanPressure: rawPoints.first.pressure ?? 0.0,
        pathLength: 0.0,
      );
    }

    List<StrokePoint> enrichedPoints = [];
    double totalPathLength = 0.0;
    double totalVelocity = 0.0;
    double totalPressure = 0.0;
    int validVelocityCount = 0;
    int validPressureCount = 0;

    // First pass: calculate point-to-point velocities and lengths
    for (int i = 0; i < rawPoints.length; i++) {
      if (i == 0) {
        enrichedPoints.add(rawPoints[i].copyWith(velocity: 0.0));
        if (rawPoints[i].pressure != null) {
          totalPressure += rawPoints[i].pressure!;
          validPressureCount++;
        }
        continue;
      }

      final p1 = rawPoints[i - 1];
      final p2 = rawPoints[i];

      // Distance (Euclidean)
      final dx = p2.x - p1.x;
      final dy = p2.y - p1.y;
      final distance = sqrt(dx * dx + dy * dy);
      totalPathLength += distance;

      // Delta Time (ms)
      int dt = p2.timestampMs - p1.timestampMs;
      // Prevent division by zero if events fire concurrently
      if (dt <= 0) dt = 1;

      // Velocity (pixels / ms)
      final velocity = distance / dt;
      totalVelocity += velocity;
      validVelocityCount++;

      if (p2.pressure != null) {
        totalPressure += p2.pressure!;
        validPressureCount++;
      }

      enrichedPoints.add(p2.copyWith(velocity: velocity));
    }

    final meanVelocity = validVelocityCount > 0 ? (totalVelocity / validVelocityCount) : 0.0;
    final meanPressure = validPressureCount > 0 ? (totalPressure / validPressureCount) : 0.0;

    // Second pass: compute velocity variability (Standard Deviation)
    double sumSquaredDiffs = 0.0;
    for (int i = 1; i < enrichedPoints.length; i++) {
      final v = enrichedPoints[i].velocity ?? 0.0;
      final diff = v - meanVelocity;
      sumSquaredDiffs += diff * diff;
    }
    final velocityVariability = validVelocityCount > 1 
        ? sqrt(sumSquaredDiffs / (validVelocityCount - 1)) 
        : 0.0;

    return DrawingStroke(
      strokeId: strokeId,
      points: enrichedPoints,
      startTimeMs: rawPoints.first.timestampMs,
      endTimeMs: rawPoints.last.timestampMs,
      meanVelocity: meanVelocity,
      velocityVariability: velocityVariability,
      meanPressure: meanPressure,
      pathLength: totalPathLength,
    );
  }

  /// Aggregates multiple strokes into session-level biomarkers
  static Map<String, double> computeAggregateMetrics(List<DrawingStroke> strokes) {
    if (strokes.isEmpty) return {};

    double totalVelocity = 0.0;
    double totalPressure = 0.0;
    double totalLength = 0.0;

    for (var stroke in strokes) {
      totalVelocity += stroke.meanVelocity;
      totalPressure += stroke.meanPressure;
      totalLength += stroke.pathLength;
    }

    return {
      'strokeVelocityMean': totalVelocity / strokes.length,
      'meanPressure': totalPressure / strokes.length,
      'totalPathLength': totalLength,
      'liftCount': (strokes.length - 1).toDouble(), // N strokes means N-1 pen lifts
    };
  }
}

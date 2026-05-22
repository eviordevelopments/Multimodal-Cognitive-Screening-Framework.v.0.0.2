import 'package:freezed_annotation/freezed_annotation.dart';

part 'stroke_data.freezed.dart';
part 'stroke_data.g.dart';

@freezed
class StrokePoint with _$StrokePoint {
  const factory StrokePoint({
    required double x,
    required double y,
    required int timestampMs,
    double? pressure,
    double? velocity,
  }) = _StrokePoint;

  factory StrokePoint.fromJson(Map<String, dynamic> json) => _$StrokePointFromJson(json);
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

  factory DrawingStroke.fromJson(Map<String, dynamic> json) => _$DrawingStrokeFromJson(json);
}

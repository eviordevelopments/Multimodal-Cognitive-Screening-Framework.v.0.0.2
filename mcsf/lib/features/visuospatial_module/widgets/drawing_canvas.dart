import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class DrawingCanvasWidget extends StatefulWidget {
  final Function(List<Offset> points, double velocity, double pressure) onStrokeCompleted;
  
  const DrawingCanvasWidget({
    Key? key,
    required this.onStrokeCompleted,
  }) : super(key: key);

  @override
  _DrawingCanvasWidgetState createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  final DrawingController _drawingController = DrawingController();

  @override
  void initState() {
    super.initState();
    // In a full implementation, we would hook into pointer events to extract 
    // real-time delta-T and pressure from touch devices.
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DrawingBoard(
        controller: _drawingController,
        background: Container(
          width: 800,
          height: 600,
          color: Colors.white,
          // Optional: Add prompt background (e.g. clock circle or blank)
        ),
        showDefaultActions: true,
        showDefaultTools: true,
      ),
    );
  }
}

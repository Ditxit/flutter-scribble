import 'dart:convert';
import 'dart:ui';
import 'package:draw/Drawing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DrawingPainter extends CustomPainter {

  final drawing;
  DrawingPainter({this.drawing}) : super();

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for(Stroke stroke in drawing.strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = stroke.thickness;

      canvas.drawPath(stroke.path(), paint);
    }

    // for (var i = 0; i < offsets.length; i++) {
    //
    //   if(offsets[i] == null || offsets.length <= i + 1){
    //     continue;
    //   }else if(offsets[i + 1] == null) { // draw a dot
    //     canvas.drawPoints(PointMode.points, [offsets[i]], paint);
    //   }else if(offsets[i + 1] != null){ // draw a line
    //     canvas.drawLine(offsets[i], offsets[i + 1], paint);
    //
    //     // canvas.drawCircle(offsets[i], thickness / 2, paint);
    //     // canvas.drawCircle(offsets[i + 1], thickness / 2, paint);
    //   }
    // }

    // var path = Path();
    // for (var i = 0; i < offsets.length; i++) {
    //   if(offsets[i] == null) {
    //     //path.moveTo(offsets[i - 1].dx, offsets[i - 1].dy);
    //     //path.close();
    //     //path.reset();
    //   }else if(i == 0 || (i > 0 && offsets[i - 1] == null)){
    //     path.moveTo(offsets[i].dx, offsets[i].dy);
    //   }else{
    //     path.lineTo(offsets[i].dx, offsets[i].dy);
    //   }
    // }
    // canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

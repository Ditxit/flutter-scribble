import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DrawPad extends CustomPainter {

  final List<Offset> offsets;
  DrawPad(this.offsets) : super();

  final List<Path> paths = [];

  @override
  void paint(Canvas canvas, Size size) {

    const thickness = 10.0;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

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

    var path = Path();
    for (var i = 0; i < offsets.length; i++) {

      if(offsets[i] == null) {
        path.moveTo(offsets[i - 1].dx, offsets[i - 1].dy);
        path.close();
      }else if(i == 0 || (i > 0 && offsets[i - 1] == null)){
        path.moveTo(offsets[i].dx, offsets[i].dy);
      }else{
        path.lineTo(offsets[i].dx, offsets[i].dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

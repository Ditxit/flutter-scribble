import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

class Stroke {
  final Color color;
  final double thickness;
  final List<Offset> points = [];

  // True when stroke is complete,
  // False when stroke is ongoing.
  // Initial value is always false.
  bool isComplete = false;

  // Constructor.
  Stroke({this.color, this.thickness});

  void add(Offset point) => points.add(point);

  void addAll(List<Offset> points) => this.points.addAll(points);

  Path path() {
    Path path = Path();
    path.moveTo(this.points.first.dx, this.points.first.dy);
    for (Offset point in this.points) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  // This method returns a map
  Map<String, dynamic> toJson() => {
        'color': this.color.value,
        'thickness': this.thickness,
        'points': jsonEncode(this.points),
      };
}

class Drawing {
  // The "strokes" list holds all the strokes in the canvas
  // in form of "Stroke" class object
  List<Stroke> strokes = [];

  // Default color and thickness of the brush
  // for drawing in the canvas
  Color color = Colors.black;
  double thickness = 10.0;

  // The "add" function adds the new point to the "points" list.
  // If the passed param "point" is type null, it created the path object
  // and append to the "paths" list and clears the "points" list.
  void add(Offset point) {
    if (point == null) {
      this.strokes.last.isComplete = true;
      return;
    }

    // If it is first point or if the last stroke
    // is complete, we need to start new stroke
    if (this.strokes.length == 0 || this.strokes.last.isComplete) {
      // The color and thickness of brush is
      // stroke based and not point based.
      Stroke stroke = Stroke(
        color: this.color,
        thickness: this.thickness,
      );
      this.strokes.add(stroke);
    }

    this.strokes.last.add(point);
  }

  // This method removes the last n
  // strokes from the list
  void undo({int last = 1}) {
    while (last > 0 && this.strokes.length > 0) {
      this.strokes.removeLast();
      last--;
    }
  }

  // The "wipe" function clears the "strokes" list.
  void wipe() => this.strokes.clear();

  // This method returns a formatted list of
  // every strokes in the canvas with resp.
  // color and thickness of them.
  List get() {
    List _strokes = [];
    for (Stroke stroke in this.strokes) {
      final Map<String, dynamic> _stroke = {
        'color': stroke.color.value,
        'thickness': stroke.thickness,
        'points': [],
      };
      for (Offset point in stroke.points) {
        _stroke['points'].add({'dx': point.dx, 'dy': point.dy});
      }
      _strokes.add(_stroke);
    }
    return _strokes;
  }

  void set(List strokes) {
    this.strokes.clear();
    for (var stroke in strokes) {
      List<Offset> _points = [];

      for (var _point in stroke['points']) {
        _points.add(Offset(_point['dx'], _point['dy']));
      }

      Stroke _stroke = Stroke(
        color: Color(stroke['color']),
        thickness: stroke['thickness'],
      )
        ..addAll(_points)
        ..isComplete = true;

      this.strokes.add(_stroke);
    }
  }
}

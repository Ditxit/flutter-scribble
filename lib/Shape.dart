import 'dart:ui';

import 'package:flutter/material.dart';

class Shape {
  List<Offset> points = [];
  final Path path = Path();
  final Color color;
  final double thickness;

  var isComplete = false;

  Shape({Offset point, this.color, this.thickness}) {
    this.path.moveTo(point.dx, point.dy);
  }

  // Call this to add new points in the shape
  void extend(Offset point) {
    this.path.lineTo(point.dx, point.dy);
  }

  // Call this if the user lifts the finger up
  void freeze() {
    //this.path.moveTo(this.points.last.dx, this.points.last.dy);
    //this.path.close();
    this.isComplete = true;
  }

  // Check if the point lies in this shape
  bool contains(Offset point) => this.path.contains(point);
}

class _Stroke {
  // The "points" will hold all offsets cords from finger-down to finger-up.
  // Once the finger is up, the offsets are converted into path and
  // stored in "path" list. And the "point" list is cleared to null.
  List<Offset> points = [];

  // The "path" list holds all the strokes in the canvas in form of path object
  List<Path> paths = [];

  // The "add" function adds the new point to the "points" list.
  // If the passed param "point" is type null, it created the path object
  // and append to the "paths" list and clears the "points" list.
  void add(Offset point) {
    if (point != null) {
      this.points.add(point);
    } else {
      Path path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (Offset point in this.points) {
        path.lineTo(point.dx, point.dy);
      }
      this.points.clear();
      this.paths.add(path);
    }
  }

  // The "wipe" function clears the "points"
  void wipe() {
    this.points.clear();
    this.paths.clear();
  }
}

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

}

class Canvas {

  // The "strokes" list holds all the strokes in the canvas
  // in form of "Stroke" class object
  List<Stroke> strokes = [];

  // The "add" function adds the new point to the "points" list.
  // If the passed param "point" is type null, it created the path object
  // and append to the "paths" list and clears the "points" list.
  void add(Offset point) {
    if (point == null) {
      strokes.last.isComplete = true;
      return;
    }

    if (strokes.last.isComplete) {
      Stroke stroke = Stroke(
        color: Color(0x000000),
        thickness: 10.0,
      );
      strokes.add(stroke);
    }

    strokes.last.add(point);
  }

  // The "wipe" function clears the "points" and "strokes" list.
  void wipe() => this.strokes.clear();

}

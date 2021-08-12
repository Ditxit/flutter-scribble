import 'dart:ui';

class Shape {

  final Path path;
  final Color color;
  final double thickness;

  var isComplete = false;

  Shape(this.path, this.color, this.thickness);

  // Call this if the user lifts the finger up
  void lock() {
    this.path.close();
    this.isComplete = true;
  }

  // Check if the point lies in this shape
  bool contains(Offset point) => this.path.contains(point);

}
import 'package:vector_math/vector_math_64.dart';

class Position {
  double x;
  double y;
  double z;

  Position({
    required this.x,
    required this.y,
    required this.z,
  });


  String asString(int decimals) {
    return "X: ${x.toStringAsFixed(decimals)}, Y: ${y.toStringAsFixed(decimals)}, Z: ${z.toStringAsFixed(decimals)}";
  }

  String asTxtString() {
    return "$x $y $z";
  }

  Vector3 toVector3() {
    return Vector3(x, y, z);
  }

  double distanceTo(Position other) {
    return toVector3().distanceTo(other.toVector3());
  }

}
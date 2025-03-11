import 'package:vector_math/vector_math_64.dart';

class Rotation {
  double w;
  double x;
  double y;
  double z;

  Rotation({
    required this.w,
    required this.x,
    required this.y,
    required this.z,
  });

  String asTxtString() {
    return "$w $x $y $z";
  }

  toVector4() {
    return Vector4(x, y, z, w);
  }

  toQuaternion() {
    return Quaternion(x, y, z, w);
  }

}
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' as vm;


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

  vm.Vector4 toVector4() {
    return vm.Vector4(x, y, z, w);
  }

  vm.Vector3 toVector3Euler() {
    final vm.Vector3 euler = vm.Vector3.zero();

    euler.x = atan2(2.0 * (w * x + y * z), 1.0 - 2.0 * (x * x + y * y));
    euler.y = asin(2.0 * (w * y - z * x));
    euler.z = atan2(2.0 * (w * z + x * y), 1.0 - 2.0 * (y * y + z * z));

    return euler;
  }

}
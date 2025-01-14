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

}
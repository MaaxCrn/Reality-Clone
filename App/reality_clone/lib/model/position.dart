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

}
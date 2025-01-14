class CameraInfo {
  static const CAMERA_TYPE = "PINHOLE";
  final int imageWidth;
  final int imageHeight;
  final double fx;
  final double fy;
  late double cx;
  late double cy;

  CameraInfo({
    required this.imageWidth,
    required this.imageHeight,
    required this.fx,
    required this.fy,
  }){
    cx = imageWidth / 2;
    cy = imageHeight / 2;
  }

  @override
  String toString() {
    return "$CAMERA_TYPE $imageWidth $imageHeight $fx $fy $cx $cy";
  }
}
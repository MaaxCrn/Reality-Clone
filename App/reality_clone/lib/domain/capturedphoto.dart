class CapturedPhoto {
  final int id;
  final String path;
  final String name;
  final Map<String, double> position;
  final Map<String, double> rotation;

  CapturedPhoto({
    required this.id,
    required this.path,
    required this.name,
    required this.position,
    required this.rotation,
  });
}

class GaussianModel {
  final int id;
  final String name;
  final String date;
  final String pathImage;

  GaussianModel({
    required this.id,
    required this.name,
    required this.date,
    required this.pathImage,
  });

  factory GaussianModel.fromJson(Map<String, dynamic> json) {
    return GaussianModel(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      pathImage: json['pathImage'],
    );
  }
}

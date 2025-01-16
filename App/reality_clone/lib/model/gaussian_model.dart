class GaussianModel {
  final int id;
  final String name;
  final String date;
  final String pathImage;

  GaussianModel({
    required this.id,
    this.name = "Unknown Name",
    this.date = "Unknown Date",
    this.pathImage = "",
  });

  factory GaussianModel.fromJson(Map<String, dynamic> json) {
    return GaussianModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown Name",
      date: json['date'] ?? "Unknown Date",
      pathImage: json['pathImage'] ?? "",
    );
  }
}

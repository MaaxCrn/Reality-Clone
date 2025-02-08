import 'package:reality_clone/services/file_service.dart';

class GaussianModel {
  final int id;
  final String name;
  final String date;
  String imageUrl;

  GaussianModel({
    required this.id,
    this.name = "Unknown Name",
    this.date = "Unknown Date",
    this.imageUrl = "",
  });

  factory GaussianModel.fromJson(Map<String, dynamic> json) {
    return GaussianModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown Name",
      date: json['date'] ?? "Unknown Date",
      imageUrl: json['image'] ?? "",
    );
  }
}

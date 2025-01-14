import 'package:flutter/material.dart';
import 'package:reality_clone/repo/app_repository.dart';
import '../model/gaussian_model.dart';

class HomePageNotifier extends ChangeNotifier {
  final AppRepository api;
  List<GaussianModel> _models = [];
  bool _isLoading = false;

  HomePageNotifier(this.api);

  List<GaussianModel> get models => List.unmodifiable(_models);
  bool get isLoading => _isLoading;

  Future<void> fetchGaussianList() async {
    _isLoading = true;
    notifyListeners();

    try {
      _models = await api.getGaussianList();
    } catch (e) {
      debugPrint("Error fetching Gaussian models: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

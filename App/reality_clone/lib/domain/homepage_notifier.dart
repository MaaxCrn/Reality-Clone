import 'package:flutter/material.dart';
import 'package:reality_clone/repo/app_repository.dart';
import 'package:reality_clone/services/file_service.dart';
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
      final list = await api.getGaussianList();

      final ip = await appRepository.getIP();
      print(ip);
      for (final model in list) {
        model.imageUrl = ip + "/static/" +  FileService().removeFirstDirectory(model.imageUrl);
        print(model.imageUrl);
      }

      _models = list;
    } catch (e) {
      debugPrint("Error fetching Gaussian models: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveName(String id, String newName) async {
    _isLoading = true;
    notifyListeners();

    try {
      await api.editGaussianName(id, newName);

      final index = _models.indexWhere((model) => model.id == id);
      if (index != -1) {
        _models[index] = _models[index].copyWith(name: newName);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating name: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:reality_clone/data_source/api_provider.dart';
import 'package:reality_clone/model/gaussian_model.dart';
import 'package:reality_clone/model/project.dart';
import 'package:reality_clone/data_source/preferences_data_source.dart';
import '../model/project.dart';

final appRepository = AppRepository();

class AppRepository {
  Future<void> computeGaussian(File zipFile, String projectName, bool useArPositions) async {
    await apiProvider.computeGaussian(zipFile, projectName, useArPositions);
  }

  Future<List<GaussianModel>> getGaussianList() async {
    try {
      final response = await apiProvider.getGaussianList();
      print("Raw response: $response");
      return List<GaussianModel>.from(response);
    } catch (e) {
      print("Error fetching Gaussian list: $e");
      throw Exception("Failed to fetch Gaussian list");
    }
  }

  Future<void> deleteGaussian(String id) async {
    try {
      await apiProvider.deleteGaussian(id);
    } catch (e) {
      print("Error deleting Gaussian model: $e");
      throw Exception("Failed to delete Gaussian model");
    }
  }

  Future<void> editGaussianName(String id, String name) async {
    try {
      await apiProvider.editGaussianName(id, name);
    } catch (e) {
      print("Error editing Gaussian model name: $e");
      throw Exception("Failed to edit Gaussian model name");
    }
  }

  Future<void> saveIP(String value) async {
    await preferencesDataSource.saveIP(value);
  }

  Future<String> getIP() async {
    return await preferencesDataSource.loadIP();
  }

  Future<bool> pingServer() async {
    try {
      final response = await apiProvider.ping();
      if(response.response.statusCode == HttpStatus.ok)
        return true;

      return false;
    } catch (e) {
      return false;
    }
  }
}

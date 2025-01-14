import 'dart:io';

import 'package:dio/dio.dart';
import 'package:reality_clone/data_source/api_provider.dart';
import 'package:reality_clone/model/gaussian_model.dart';
import '../model/project.dart';

final appRepository = AppRepository();

class AppRepository {
  //
  // Future<List<Project>> getProjects() async {
  //   final response = await apiProvider.get();
  //   return response;
  // }


  Future<void> computeGaussian(File zipFile) async {
      await apiProvider.computeGaussian(zipFile);
  }

  Future<List<GaussianModel>> getGaussianList() async {
    try {
      final response = await apiProvider.getGaussianList();

      final List<dynamic> responseData = response;
      print(response);

      return responseData.map((json) => GaussianModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching Gaussian list: $e");
      throw Exception("Failed to fetch Gaussian list");
    }
  }


}
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:reality_clone/data_source/api_provider.dart';
import 'package:reality_clone/data_source/preferences_data_source.dart';
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


  Future<void> saveIP(String value) async {
    await preferencesDataSource.saveIP(value);
  }

  Future<String> getIP() async {
    return await preferencesDataSource.loadIP();
  }






}
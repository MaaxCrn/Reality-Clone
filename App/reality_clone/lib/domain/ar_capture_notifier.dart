import 'package:flutter/material.dart';
import 'package:reality_clone/model/gaussian_archive.dart';
import 'package:reality_clone/repo/app_repository.dart';

import '../model/captured_image.dart';

class ArCaptureNotifier extends ChangeNotifier {
  GaussianArchive _gaussianArchive = GaussianArchive();


  void _addPictureToArchive(CapturedImage capturedImage) {
    _gaussianArchive.addPicture(capturedImage);
    notifyListeners();
  }

  Future<void> _sendArchive() async {
    final archive = await _gaussianArchive.asFile();
    AppRepository().computeGaussian(archive);
    _gaussianArchive.asFile();
    notifyListeners();
  }





  

}
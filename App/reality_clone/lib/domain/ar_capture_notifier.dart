import 'package:flutter/material.dart';
import 'package:reality_clone/repo/app_repository.dart';

import '../model/capture_list.dart';
import '../model/captured_image.dart';

class ArCaptureNotifier extends ChangeNotifier {
  static const MIN_IMAGE_COUNT = 3;
  final CaptureList _captureList = CaptureList();


  int get pictureCount => _captureList.length;

  List<CapturedImage> get capturedImages => _captureList.capturedImages;

  bool isEmpty() => _captureList.length == 0;


  void addCapturedImage(CapturedImage capturedImage) {
    _captureList.addPicture(capturedImage);
    notifyListeners();
  }


  Future<void> _sendArchive() async {
    final archive = await _captureList.getZipFile();
    await AppRepository().computeGaussian(archive);
  }


  bool hasEnoughImages() {
    return _captureList.length >= MIN_IMAGE_COUNT;
  }

  Future<void> saveAndSendImages() async {
    if (hasEnoughImages()) {
      await _sendArchive();
    }
  }

  void removeAtIndex(int index) {
    _captureList.removeAtIndex(index);
    notifyListeners();
  }

  void clear() {
    _captureList.clear();
    notifyListeners();
  }



  

}
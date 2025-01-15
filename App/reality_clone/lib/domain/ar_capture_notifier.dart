import 'package:flutter/material.dart';
import 'package:reality_clone/model/camera_info.dart';
import 'package:reality_clone/repo/app_repository.dart';
import 'package:my_custom_plugin/my_custom_plugin.dart';

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
      final cameraInfo = _getCameraInfo();
      if (cameraInfo == null) throw Exception("Camera info is null");

      _captureList.archive.addCameraInfo(cameraInfo);
      _captureList.archive.addPoints3DFile();
      _captureList.archive.addImagesFile(_captureList.capturedImages);
      await _sendArchive();
    }
  }

  Future<CameraInfo?> _getCameraInfo() async {
    final sampleImage = _captureList.first();
    final focalLengths = await MyCustomPlugin.getFocalLengths();

    print("Sample image details: ${sampleImage?.toString()}");
    print("Focal lengths: $focalLengths");

    if (sampleImage != null && focalLengths != null) {
      final cameraInfo = CameraInfo(
        imageWidth: sampleImage.imageWidth,
        imageHeight: sampleImage.imageHeight,
        fx: focalLengths['fx'] ?? 0.0,
        fy: focalLengths['fy'] ?? 0.0,
      );
      print("CameraInfo created: $cameraInfo");
      return cameraInfo;
    }
    print("No valid sample image or focal lengths found.");
    return null;
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
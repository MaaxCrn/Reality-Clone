import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../model/captured_image.dart';
import '../model/position.dart';

class PictureNotifier extends ChangeNotifier {
  final List<CapturedImage> _capturedPhotos = [];
  int _photoCount = 0;

  List<CapturedImage> get capturedPhotos => List.unmodifiable(_capturedPhotos);

  void addCapturedPhoto(CapturedImage image) {
    _capturedPhotos.add(image);
    _photoCount++;
    notifyListeners();
  }

  void removeCapturedPhoto(CapturedImage image) {
    _capturedPhotos.remove(image);
    notifyListeners();
  }

  void clearCapturedPhotos() {
    _capturedPhotos.clear();
    _photoCount = 0;
    notifyListeners();
  }

  Future<void> capturePhoto(
      GlobalKey repaintKey,
      Future<Position> Function() getPosition,
      ) async {
    try {
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        final position = await getPosition();
        final imageName = 'image_${_photoCount + 1}.png';

        CapturedImage capturedImage = CapturedImage(
          id: _photoCount + 1,
          bytedata: byteData,
          name: imageName,
          position: position,
          rotation: {},
        );

        addCapturedPhoto(capturedImage);
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    }
  }
}

import 'dart:io';

import 'package:reality_clone/model/captured_image.dart';
import 'package:reality_clone/model/gaussian_archive.dart';

class CaptureList {
  final List<CapturedImage> _capturedImages = [];
  final GaussianArchive _archive = GaussianArchive();

  CaptureList();

  void addPicture(CapturedImage capturedImage) {
    _capturedImages.insert(0, capturedImage);
    final file = _archive.addPicture(capturedImage);
    capturedImage.archiveFile = file;
  }

  removeAtIndex(int index) {
    final image = _capturedImages.removeAt(index);
    _archive.removePicture(image.archiveFile!);
  }

  List<CapturedImage> get capturedImages => _capturedImages;

  int get length => _capturedImages.length;

  Future<File> getZipFile() async {
    return await _archive.asFile();
  }

  void clear() {
    _capturedImages.clear();
  }


}
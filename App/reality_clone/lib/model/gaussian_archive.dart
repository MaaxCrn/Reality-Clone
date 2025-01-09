import 'dart:io';

import 'package:archive/archive.dart';
import 'package:reality_clone/model/capturedphoto.dart';

class GaussianArchive {
  late Archive _archive;
  int _imageCount = 0;

  GaussianArchive( ){
    _archive = Archive();
  }


  void addPicture(CapturedImage capturedPhoto) {
    //todo
    // ArchiveFile file = ArchiveFile();
    // _archive.addFile(file);
    // _imageCount++;
  }


  Future<File> toZip() async{
    // File('archive_with_folder.zip').writeAsBytes(_archive.toZip());
    return File("path");
  }
}
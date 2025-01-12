import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:reality_clone/model/captured_image.dart';
import 'package:reality_clone/services/file_service.dart';

class GaussianArchive {
  late Archive _archive;

  GaussianArchive( ){
    _archive = Archive();
  }


  void addPicture(CapturedImage capturedImage) {
    {
      Uint8List bytesList = capturedImage.getBytesAsList();
      ArchiveFile file = ArchiveFile(capturedImage.name, bytesList.length, bytesList);
      _archive.addFile(file);
    }
  }



  Future<File> asFile() async{
    final encoder = ZipEncoder();
    final bytes = encoder.encode(_archive);

    if(bytes==null){
      throw Exception("No images to save");
    }

    final file = await FileService().createZipFile("gaussian.zip");
    await file.writeAsBytes(Uint8List.fromList(bytes));
    return file;
  }

}
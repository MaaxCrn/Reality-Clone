import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:reality_clone/model/camera_info.dart';
import 'package:reality_clone/model/captured_image.dart';
import 'package:reality_clone/services/file_service.dart';

class GaussianArchive {
  late Archive _archive;

  GaussianArchive( ){
    _archive = Archive();
  }

   ArchiveFile addPicture(CapturedImage capturedImage) {
      Uint8List bytesList = capturedImage.getBytesAsList();
      ArchiveFile file = ArchiveFile("images/${capturedImage.name}", bytesList.length, bytesList);
      _archive.addFile(file);
      return file;
  }

  void addCameraInfo(CameraInfo cameraInfo) {
    final fileContent = cameraInfo.toString();
    Uint8List fileContentBytes = Uint8List.fromList(fileContent.codeUnits);

    final archiveFile = ArchiveFile("sparse/cameras.txt", fileContentBytes.length, fileContentBytes);
    _archive.addFile(archiveFile);
  }

  void addPoints3DFile(){
    final fileContent = "";
    Uint8List fileContentBytes = Uint8List.fromList(fileContent.codeUnits);
    final archiveFile = ArchiveFile("sparse/points3D.txt", fileContentBytes.length, fileContentBytes);
    _archive.addFile(archiveFile);
  }

  void addImagesFile(List<CapturedImage> capturedImages){
    String fileContent = "";

    for (var capturedImage in capturedImages) {
      fileContent += capturedImage.asTxtString() + "\n\n";
    }

    Uint8List fileContentBytes = Uint8List.fromList(fileContent.codeUnits);
    final archiveFile = ArchiveFile("sparse/images.txt", fileContentBytes.length, fileContentBytes);
    _archive.addFile(archiveFile);
  }



  void removePicture(ArchiveFile fileToRemove) {
      _archive.removeFile(fileToRemove);
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

  void clear() {
    print("Clearing archive");
    _archive = Archive();
  }
}
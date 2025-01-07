import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileService {
  static final FileService _singleton = FileService._internal();
  FileService._internal();

  factory FileService() {
    return _singleton;
  }

  Future<Directory?>  get _localPath async {
    return await getExternalStorageDirectory();
  }


  // Future<File> getEmptyZipFile() async {
  //   return Archive();
  // }
  //   Directory? appPath = await _localPath;
  //   if(appPath == null) {
  //     throw Exception("Error: Unable to access external storage");
  //   }
  //
  //   final File outputFile = File(appPath.path+"/"+'empty.zip');
  //   print("file created at : "+outputFile.path);
  //
  //   var encoder = ZipFileEncoder();
  //   encoder.create(outputFile.path);
  //   encoder.close();
  //
  //
  //   return outputFile;
  // }


  Future<File> zipFolderContents(String folderPath, String zipFileName) async {
    final Directory inputDirectory = Directory(folderPath);

    if (!inputDirectory.existsSync()) {
      throw Exception("Folder does not exist: $folderPath");
    }

    // Get the output zip file path
    Directory? appPath = await _localPath;
    if(appPath == null) {
      throw Exception("Error: Unable to access external storage");
    }
    final File outputFile = File(appPath.path + '/' + zipFileName);

    print("Zipping folder contents from: $folderPath");
    print("Output file: ${outputFile.path}");

    // Initialize the encoder
    final encoder = ZipFileEncoder();
    encoder.create(outputFile.path);

    // Recursively add files and subdirectories without the root folder
    for (var entity in inputDirectory.listSync(recursive: true)) {
      if (entity is File) {
        final String relativePath = entity.path.substring(folderPath.length + 1);
        encoder.addFile(entity, relativePath);
      } else if (entity is Directory) {
        // Ensure directories are added implicitly when files are added
        encoder.addDirectory(entity);
      }
    }

    // Close the encoder
    encoder.close();

    print("Folder zipped successfully at: ${outputFile.path}");
    return outputFile;
  }


}


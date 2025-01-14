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

  Future<Directory?>  get cachePath async {
    return await getApplicationCacheDirectory();
  }



  Future<File> createZipFile(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    return tempFile;
  }


}


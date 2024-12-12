import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive.dart';

class ZipService {
  static final ZipService _singleton = ZipService._internal();
  ZipService._internal();

  factory ZipService() {
    return _singleton;
  }

  Future<Directory>  get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<File> getEmptyZipFile() async {
    Directory appPath = await _localPath;
    final File outputFile = File(appPath.path+"/"+'empty.zip');
    print("file created at : "+outputFile.path);

    var encoder = ZipFileEncoder();
    encoder.create(outputFile.path);
    encoder.close();


    return outputFile;
  }
}


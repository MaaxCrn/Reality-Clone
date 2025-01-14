
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:reality_clone/model/position.dart';
import 'package:reality_clone/model/quaternion.dart';

class CapturedImage {
  static const int CAMERA_ID = 1;
  final int id;
  // final String path;
  final String name;
  final ByteData bytedata;
  ArchiveFile? archiveFile;
  final int imageWidth;
  final int imageHeight;
  final Position position;
  final Rotation rotation;

  CapturedImage({
    required this.id,
    required this.bytedata,
    required this.imageWidth,
    required this.imageHeight,
    // required this.path,
    required this.name,
    required this.position,
    required this.rotation,
  });



  Uint8List getBytesAsList() {
    return bytedata.buffer.asUint8List();
  }

  asTxtString() {
    return "$id ${rotation.asTxtString()} ${position.asTxtString()} $CAMERA_ID $name";
  }

}

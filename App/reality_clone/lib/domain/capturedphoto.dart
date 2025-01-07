
import 'dart:typed_data';

import 'package:reality_clone/model/position.dart';

class CapturedImage {
  final int id;
  // final String path;
  final String name;
  final ByteData bytedata;
  final Position position;
  final Map<String, double> rotation;

  CapturedImage({
    required this.id,
    required this.bytedata,
    // required this.path,
    required this.name,
    required this.position,
    required this.rotation,
  });


  Uint8List getBytesAsList() {
    return bytedata.buffer.asUint8List();
  }

}

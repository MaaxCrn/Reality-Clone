
import 'dart:typed_data';

class CapturedPhoto {
  final int id;
  // final String path;
  final String name;
  final ByteData bytedata;
  final Map<String, double> position;
  final Map<String, double> rotation;

  CapturedPhoto({
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

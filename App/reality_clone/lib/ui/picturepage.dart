import 'dart:io';
import 'dart:ui';

import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:image/image.dart' as img;

import '../domain/capturedphoto.dart';
import 'imagelistepage.dart';

class ARPage extends StatefulWidget {
  const ARPage({super.key});

  @override
  _ARPageState createState() => _ARPageState();
}

class _ARPageState extends State<ARPage> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  List<CapturedPhoto> capturedPhotos = [];
  int _photoCount = 0;
  GlobalKey _repaintKey = GlobalKey();

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _capturePhotosWithPositions() async {
      final position = await _getCameraPosition();
      await _takeScreenshot(position);
      await Future.delayed(const Duration(seconds: 1));
  }

  Future<Map<String, double>> _getCameraPosition() async {
    final cameraPose = await arSessionManager.getCameraPose();
    final cameraPosition = cameraPose!.getTranslation();

    return {
      'x': cameraPosition.x,
      'y': cameraPosition.y,
      'z': cameraPosition.z,
    };
  }

  Future<void> _takeScreenshot(Map<String, double> position) async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      final cameraPose = await arSessionManager.getCameraPose();
      final rotationMatrix = cameraPose!.getRotation();
      final quaternion = Quaternion.fromRotation(rotationMatrix);
      quaternion.inverse();

      Map<String, double> rotation = {
        'qx': quaternion.x,
        'qy': quaternion.y,
        'qz': quaternion.z,
        'qw': quaternion.w,
      };

      image.toByteData(format: ImageByteFormat.png).then((byteData) async {
        if (byteData != null) {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/image_${_photoCount + 1}.jpg';
          final imageName = 'image_${_photoCount + 1}.jpg';

          final List<int> compressedBytes =
          await FlutterImageCompress.compressWithList(
            byteData.buffer.asUint8List(),
            minWidth: 800,
            minHeight: 600,
            quality: 80,
          );

          final file = File(filePath);
          await file.writeAsBytes(compressedBytes);

          capturedPhotos.add(
            CapturedPhoto(
              id: _photoCount + 1,
              path: filePath,
              name: imageName,
              position: position,
              rotation: rotation,
            ),
          );
          _photoCount++;
          debugPrint('Screenshot saved to $filePath');
        }
      });
    } catch (e) {
      debugPrint("Error capturing screenshot: $e");
    }
  }

  void _showCapturedPhotos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGalleryPage(capturedPhotos: capturedPhotos),
      ),
    );
  }

  Future<void> _saveAllCapturedPhotos() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint("Error: Unable to access external storage");
        return;
      }

      final rootDirectory = Directory('${directory.path}/Gaussian');
      final sparseDirectory = Directory('${rootDirectory.path}/sparse');
      final imagesDirectory = Directory('${rootDirectory.path}/images');

      if (!await rootDirectory.exists()) await rootDirectory.create(recursive: true);
      if (!await sparseDirectory.exists()) await sparseDirectory.create(recursive: true);
      if (!await imagesDirectory.exists()) await imagesDirectory.create(recursive: true);

      final points3DFilePath = '${sparseDirectory.path}/points3D.txt';
      final points3DFile = File(points3DFilePath);
      await points3DFile.create(recursive: true);

      StringBuffer cameraDataBuffer = StringBuffer();

      int x = 0;
      for (var photo in capturedPhotos) {
        final file = File(photo.path);

        final imageBytes = await file.readAsBytes();

        final decodedImage = img.decodeImage(imageBytes);

        final imageFilePath = '${imagesDirectory.path}/${photo.name}';
        await file.copy(imageFilePath);


        if (decodedImage != null && x == 0) {
          final width = decodedImage.width;
          final height = decodedImage.height;
          final centerX = width / 2;
          final centerY = height / 2;
          final focalLength = 1804.80;


          cameraDataBuffer.write(
            '1 PINHOLE $width $height $focalLength $focalLength $centerX $centerY\n',
          );
        } else {
          debugPrint("Error decoding image: ${photo.path}");
        }
        x += 1;
      }

      final cameraFilePath = '${sparseDirectory.path}/cameras.txt';
      final cameraFile = File(cameraFilePath);
      await cameraFile.writeAsString(cameraDataBuffer.toString());

      StringBuffer imageDataBuffer = StringBuffer();
      for (var photo in capturedPhotos) {
        imageDataBuffer.write(
          '${photo.id} ${photo.rotation['qw']} ${photo.rotation['qx']} ${photo.rotation['qy']} ${photo.rotation['qz']} ${photo.position['x']} ${photo.position['y']} ${photo.position['z']} 1 ${photo.name}\n\n',
        );
      }

      final imageFilePath = '${sparseDirectory.path}/images.txt';
      final imageFile = File(imageFilePath);
      await imageFile.writeAsString(imageDataBuffer.toString());

      debugPrint('All images and metadata saved to ${rootDirectory.path}');
    } catch (e) {
      debugPrint("Error saving images and metadata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Experience')),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: ARView(
              onARViewCreated: onARViewCreated,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _capturePhotosWithPositions,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.camera_alt, size: 30),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _showCapturedPhotos,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.photo_library, size: 30),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _saveAllCapturedPhotos,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.save, size: 30),
              ),
            ),
          )

        ],
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;

    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: false,
          showWorldOrigin: false,
          handleTaps: false,
        );
  }
}

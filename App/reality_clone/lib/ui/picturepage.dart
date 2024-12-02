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

  late CameraController _cameraController;
  List<CameraDescription> _cameras = [];
  CameraDescription? _camera;

  List<CapturedPhoto> capturedPhotos = [];
  int _photoCount = 0;
  GlobalKey _repaintKey = GlobalKey();

  @override
  void dispose() {
    arSessionManager.dispose();
    _initializeCamera();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    _camera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _cameraController = CameraController(
      _camera!,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();

    _getCameraInfo();
  }

  Future<void> _getCameraInfo() async {
    try {
      final cameraId = 1;
      final model = _camera?.lensDirection.toString() ?? 'Unknown';
      final width = _cameraController.value.previewSize?.width ?? 0.0;
      final height = _cameraController.value.previewSize?.height ?? 0.0;

      debugPrint('Camera ID: $cameraId');
      debugPrint('Camera Model: $model');
      debugPrint('Camera Width: $width');
      debugPrint('Camera Height: $height');

    } catch (e) {
      debugPrint('Error retrieving camera info: $e');
    }
  }

  Future<void> _capturePhotosWithPositions() async {
    int photosToCapture =
        50 + (100 - 50) * (DateTime.now().millisecondsSinceEpoch % 50) ~/ 50;

    for (int i = 0; i < 1; i++) {
      final position = await _getCameraPosition();
      await _takeScreenshot(position);

      await Future.delayed(const Duration(seconds: 1));
    }
    debugPrint('Captured $photosToCapture photos.');
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

  Future<void> _saveAllCapturedPhotosDataToFile() async {
    try {
      StringBuffer dataBuffer = StringBuffer();

      for (var photo in capturedPhotos) {
        final cameraPose = await arSessionManager.getCameraPose();

        final cameraPosition = Vector3(photo.position['x']!, photo.position['y']!, photo.position['z']!);
        final rotationMatrix = cameraPose!.getRotation();
        final quaternion = Quaternion.fromRotation(rotationMatrix);

        int imageId = photo.id;
        String cameraId = '1';
        String imageName = photo.name;

        dataBuffer.write('$imageId,'
            '${quaternion.w},'
            '${quaternion.x},'
            '${quaternion.y},'
            '${quaternion.z},'
            '${cameraPosition.x},'
            '${cameraPosition.y},'
            '${cameraPosition.z},'
            '$cameraId,'
            '$imageName\n');
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint("Error: Unable to access external storage");
        return;
      }

      final downloadDirectory = Directory('${directory.path}/Download');
      if (!await downloadDirectory.exists()) {
        await downloadDirectory.create(recursive: true);
      }

      final filePath = '${downloadDirectory.path}/all_captured_photos_data_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(filePath);

      await file.writeAsString(dataBuffer.toString());

      await file.writeAsString(dataBuffer.toString());

      debugPrint('All camera data saved to ${file.path}');
    } catch (e) {
      debugPrint("Error saving camera data for all photos: $e");
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
                onPressed: _saveAllCapturedPhotosDataToFile,
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

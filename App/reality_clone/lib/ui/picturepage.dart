import 'dart:io';
import 'dart:ui';

import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> _capturePhotosWithPositions() async {
    int photosToCapture = 50 + (100 - 50) * (DateTime.now().millisecondsSinceEpoch % 50) ~/ 50;

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
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      image.toByteData(format: ImageByteFormat.png).then((byteData) async {
        if (byteData != null) {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/screenshot_${_photoCount + 1}.png';

          final List<int> compressedBytes = await FlutterImageCompress.compressWithList(
            byteData.buffer.asUint8List(),
            minWidth: 800,
            minHeight: 600,
            quality: 80,
          );

          final file = File(filePath);
          await file.writeAsBytes(compressedBytes);

          capturedPhotos.add(CapturedPhoto(path: filePath, position: position));
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

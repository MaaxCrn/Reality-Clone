import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/capturedphoto.dart';
import 'imagelistepage.dart';

class ARPage extends StatefulWidget {
  const ARPage({super.key});

  @override
  _ARPageState createState() => _ARPageState();
}

class _ARPageState extends State<ARPage> with SingleTickerProviderStateMixin {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  List<CapturedPhoto> capturedPhotos = [];
  int _photoCount = 0;
  GlobalKey _repaintKey = GlobalKey();
  bool _isTakingPhoto = false;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    arSessionManager.dispose();
    super.dispose();
  }

  Future<void> _capturePhotosWithPositions() async {
    setState(() {
      _isTakingPhoto = true;
    });

    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _animationController.reverse();

    final position = await _getCameraPosition();
    await _takeScreenshot(position);

    setState(() {
      _isTakingPhoto = false;
    });
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

      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/image_${_photoCount + 1}.png';
        final imageName = 'image_${_photoCount + 1}.png';

        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());

        capturedPhotos.add(
          CapturedPhoto(
            id: _photoCount + 1,
            path: filePath,
            name: imageName,
            position: position,
            rotation: {},
          ),
        );
        _photoCount++;
        debugPrint('Screenshot saved to $filePath');
      }
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
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.white.withOpacity(_opacityAnimation.value),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _capturePhotosWithPositions,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.camera_alt, size: 30),
                ),
                ElevatedButton(
                  onPressed: _showCapturedPhotos,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.photo_library, size: 30),
                ),
              ],
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
      showWorldOrigin: true,
      handleTaps: false,
    );
  }
}

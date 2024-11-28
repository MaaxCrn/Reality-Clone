import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';

List<CameraDescription> cameras = [];

class PicturePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const PicturePage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<PicturePage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final List<Map<String, dynamic>> capturedPhotosData = [];
  int _photoCount = 0;

  late ArCoreController arCoreController;

  @override
  void initState() {
    super.initState();
    _initCamera(widget.cameras.first);
  }

  Future<void> _initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Erreur d\'initialisation de la caméra : $e');
    }
  }

  // Future<void> _initializeAR() async {
  //   arCoreController = ArCoreController(
  //     id: 1,
  //   );
  //
  //   arCoreController.onPlaneDetected = (ArCorePlane plane) {
  //     print("Plane detected at position: ${plane}");
  //   };
  //
  //   await arCoreController.init();
  // }

  @override
  void dispose() {
    _cameraController?.dispose();
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera and AR')),
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _capturePhoto,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.camera_alt, size: 30),
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _capturePhoto() async {
    if (_photoCount < 10) {
      try {
        final XFile photo = await _cameraController!.takePicture();

        final position = await _getCameraPosition();

        print("Coordonnées de la caméra : x: ${position['x']}, y: ${position['y']}, z: ${position['z']}");

        capturedPhotosData.add({
          'photoPath': photo.path,
          'position': position,
        });

        debugPrint('Photo capturée : ${photo.path}');
        _photoCount++;

      } catch (e) {
        debugPrint('Erreur lors de la capture de la photo : $e');
      }
    }
  }


  Future<Map<String, double>> _getCameraPosition() async {
    return {
      'x': 1.0,
      'y': 1.0,
      'z': 1.0,
    };
  }
}

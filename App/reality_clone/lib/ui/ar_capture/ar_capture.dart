import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/ar_capture_notifier.dart';

class ArCapture extends StatefulWidget {
  const ArCapture({super.key});

  @override
  State<ArCapture> createState() => _ArCapture();
}




class _ArCapture extends State<ArCapture> {

  late ARSessionManager arSessionManager;


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


  @override
  Widget build(BuildContext context) {
    final arCaptureNotifier = context.watch<ArCaptureNotifier>();


    return Scaffold(
      appBar: AppBar(title: const Text('AR capture')),
      body: Stack(
        children: [
          RepaintBoundary(
            child: ARView(
              onARViewCreated: onARViewCreated,
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
                  onPressed: () => _capturePhoto(pictureNotifier),
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
}
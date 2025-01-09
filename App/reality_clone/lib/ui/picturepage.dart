import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/picture_notifier.dart';
import '../model/position.dart';
import 'images_list/imagelistepage.dart';

class ARPage extends StatefulWidget {
  const ARPage({super.key});

  @override
  _ARPageState createState() => _ARPageState();
}

class _ARPageState extends State<ARPage> with SingleTickerProviderStateMixin {
  late ARSessionManager arSessionManager;

  final GlobalKey _repaintKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    arSessionManager.dispose();
    super.dispose();
  }

  Future<Position> _getCameraPosition() async {
    final cameraPose = await arSessionManager.getCameraPose();
    final cameraPosition = cameraPose!.getTranslation();

    return Position(
      x: cameraPosition.x,
      y: cameraPosition.y,
      z: cameraPosition.z,
    );
  }

  void _capturePhoto(PictureNotifier pictureNotifier) async {
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _animationController.reverse();

    await pictureNotifier.capturePhoto(_repaintKey, _getCameraPosition);
  }

  void _showCapturedPhotos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGalleryPage(
          capturedPhotos: context.read<PictureNotifier>().capturedPhotos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pictureNotifier = context.read<PictureNotifier>();

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

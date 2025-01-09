import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';

class ArManager {
  late ARSessionManager _arSessionManager;

  ArManager();

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;

    _arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: true,
      handleTaps: false,
    );
  }

  void dispose() {
    _arSessionManager.dispose();
  }

/*
  Future<Position> getCameraPose() async {
    final cameraPose = await _arSessionManager.getCameraPose();
    final cameraPosition = cameraPose!.getTranslation();

    return Position(
      x: cameraPosition.x,
      y: cameraPosition.y,
      z: cameraPosition.z,
    );*/
}

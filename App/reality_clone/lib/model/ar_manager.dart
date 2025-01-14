import 'dart:typed_data';
import 'dart:ui';

import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'captured_image.dart';
import 'position.dart';

class ArManager {
  late ARSessionManager _arSessionManager;
  int currentId = 0;

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

  Future<Matrix4> getCameraPose() async {
    final cameraPose = await _arSessionManager.getCameraPose();

    if (cameraPose == null) {
      return Matrix4.zero();
    }

   return cameraPose;
  }



  Future<Position> getCameraPosition() async {
    final cameraPose = await _arSessionManager.getCameraPose();
    final cameraPosition = cameraPose!.getTranslation();

    return Position(
      x: cameraPosition.x,
      y: cameraPosition.y,
      z: cameraPosition.z,
    );
  }

  /*
  Future<Position> getCameraPosition() async {
    final cameraPose = await _arSessionManager.getCameraPose();
    final cameraRotation = cameraPose!.getRotation();

    return Position(
      x: cameraRotation..x,
      y: cameraRotation.y,
      z: cameraRotation.z,
      w: cameraRotation.w,
    );
  }*/


  Future<CapturedImage?> takeScreenshot(GlobalKey repaintKey) async {
      final int currentIdCopy = currentId++;
      RenderRepaintBoundary boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final position = await getCameraPosition();

        final imageName = 'image_$currentIdCopy.png';

        CapturedImage capturedImage = CapturedImage(
          id: currentIdCopy,
          bytedata: byteData,
          name: imageName,
          position: position,
          rotation: {},
        );
        return capturedImage;
      }
    return null;
  }

}

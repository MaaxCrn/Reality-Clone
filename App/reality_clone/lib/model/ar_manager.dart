import 'dart:typed_data';
import 'dart:ui';

import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:reality_clone/model/quaternion.dart';
import 'package:vector_math/vector_math_64.dart';

import 'captured_image.dart';
import 'position.dart';

class ArManager {
  late ARSessionManager _arSessionManager;
  late ARObjectManager _arObjectManager;
  List<ARNode> _arNodes = [];
  int currentId = 0;

  ArManager();

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;

    _arObjectManager = arObjectManager;

    _arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showAnimatedGuide: false,
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


  Future<Rotation> getCameraRotation({required invert}) async {
    final cameraPose = await _arSessionManager.getCameraPose();
    final cameraRotationMatrix = cameraPose!.getRotation();

    final quaternion = Quaternion.fromRotation(cameraRotationMatrix);
    if(invert) quaternion.inverse();

    return Rotation(
      w: quaternion.w,
      x: quaternion.x,
      y: quaternion.y,
      z: quaternion.z,
    );
  }


  Future<CapturedImage?> takeScreenshot(GlobalKey repaintKey) async {
      final int currentIdCopy = currentId++;
      await _removeAllNodes();

      RenderRepaintBoundary boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final position = await getCameraPosition();
        final rotation = await getCameraRotation(invert: false);
        addImageNode(position, rotation);

        final imageName = 'image_$currentIdCopy.png';

        CapturedImage capturedImage = CapturedImage(
          id: currentIdCopy,
          bytedata: byteData,
          name: imageName,
          imageWidth: image.width,
          imageHeight: image.height,
          position: position,
          rotation: rotation,
        );
        return capturedImage;
      }
    return null;
  }



  Future<void> hideAllNodes() async {
    await _removeAllNodes();
  }

  Future<void> showAllNodes() async {
    await _addAllNodes();
  }

  Future<void> _removeAllNodes()async {
    for(final node in _arNodes) {
      await _arObjectManager.removeNode(node);
    }
  }

  Future<void> _addAllNodes() async{
    for(final node in _arNodes) {
      await _arObjectManager.addNode(node);
    }
  }

  void addImageNode(Position position, Rotation rotation) async {
    const modelScale = 1.0;

    Quaternion originalQuaternion = rotation.toQuaternion();
    // Quaternion rotationX = Quaternion.axisAngle(Vector3(1, 0, 0), radians(-90));

    // Quaternion rotatedQuaternion = rotationX * originalQuaternion;
    Quaternion rotatedQuaternion = originalQuaternion.inverted();

    Vector4 resultVector4 = Vector4(
      rotatedQuaternion.x,
      rotatedQuaternion.y,
      rotatedQuaternion.z,
      rotatedQuaternion.w,
    );
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: "Models/camera.gltf",
      scale: Vector3(modelScale, modelScale, modelScale),
      position: position.toVector3(),
      rotation: resultVector4,
    );
    _arNodes.add(node);

  }


  Future<ImageProvider> getFrame() async{
    return await _arSessionManager.snapshot();
  }

}

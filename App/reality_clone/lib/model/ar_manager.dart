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



  void addImageNode(Position position, Rotation rotation) async {
    // final node = ARNode(
    //   type: NodeType.localGLTF2,
    //   uri: "assets/models/camera.glb",
    //   scale: Vector3(1, 1, 1),
    //   position: position.toVector3(),
    //   rotation: rotation.toVector4(),
    // );


    final ode = ARNode(
      type: NodeType.webGLB, // Optionnel si besoin d'un modèle 3D, sinon utiliser un matériau
      geometry: PlaneGeometry(width: 0.1, height: 0.1), // 10 cm x 10 cm
      position: Vector3(0.0, 0.0, -0.5), // 50 cm devant l'utilisateur
      rotation: Vector3.zero(), // Pas de rotation
      material: ARMaterial(
        color: Colors.blue, // Couleur du plan (facultatif)
        metallic: 0.5,
      ),
    );

    await _arObjectManager.addNode(node);
  }

}

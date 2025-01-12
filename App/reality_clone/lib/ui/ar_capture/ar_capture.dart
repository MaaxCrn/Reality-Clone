import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reality_clone/model/ar_manager.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture_picture_list.dart';

import '../../domain/ar_capture_notifier.dart';

class ArCapture extends StatefulWidget {
  const ArCapture({super.key});

  @override
  State<ArCapture> createState() => _ArCaptureState();
}




class _ArCaptureState extends State<ArCapture> {

  final ArManager arManager = ArManager();
  final GlobalKey _repaintKey = GlobalKey();
  bool shouldExit = false;


  void onCaptureButtonPressed() async {
    final arCaptureNotifier = context.read<ArCaptureNotifier>();
    final capturedImage = await arManager.takeScreenshot(_repaintKey, arCaptureNotifier.pictureCount);
    if(capturedImage != null){
      arCaptureNotifier.addCapturedImage(capturedImage);
    }else{
     throw Exception("stop");
    }
  }

  void onImageListButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArCapturePictureList()),
    );
  }



  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to quit? All captured images will be lost."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Quit"),
            ),
          ],
        );
      },
    ) ?? false;
  }



  @override
  Widget build(BuildContext context) {
    final arCaptureNotifier = Provider.of<ArCaptureNotifier>(context);

    return PopScope(
      canPop: arCaptureNotifier.isEmpty(),
      onPopInvokedWithResult: (result, dynamic) async {
        shouldExit = await _showExitConfirmationDialog();
        if(shouldExit){
          Navigator.of(context).pop();
          arCaptureNotifier.clear();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('AR capture ${arCaptureNotifier.pictureCount}')),
        body: Stack(
          children: [
            RepaintBoundary(
              key: _repaintKey,
              child: ARView(
                onARViewCreated: arManager.onARViewCreated,
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
                    onPressed: onCaptureButtonPressed,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.camera_alt, size: 30),
                  ),
                  ElevatedButton(
                    onPressed: onImageListButtonPressed,
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
      ),
    );
  }


  @override
  void dispose() {
    context.read<ArCaptureNotifier>().clear();
    super.dispose();
  }
}
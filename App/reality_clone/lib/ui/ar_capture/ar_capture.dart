import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:reality_clone/model/ar_manager.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture_picture_list.dart';
import 'package:reality_clone/ui/ar_capture/list_notification_button.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import '../../domain/ar_capture_notifier.dart';

class ArCapture extends StatefulWidget {
  const ArCapture({super.key});

  @override
  State<ArCapture> createState() => _ArCaptureState();
}

class _ArCaptureState extends State<ArCapture> with SingleTickerProviderStateMixin {
  final ArManager arManager = ArManager();
  final GlobalKey _repaintKey = GlobalKey();
  bool shouldExit = false;
  late Ticker _ticker;

  vector_math.Vector3 _currentPosition = vector_math.Vector3(0, 0, 0);
  vector_math.Vector3 _lastImagePosition = vector_math.Vector3(0, 0, 0);
  double _currentSpeed=0;
  double _currentDistance =0;
  static const double MINIMAL_PICTURE_DISTANCE = 0.1;
  static const double MINIMAL_PICTURE_SPEED = 0.2;
  bool isAutoCaptureEnabled = false;

  void onCaptureButtonPressed() async {
    final arCaptureNotifier = context.read<ArCaptureNotifier>();
    final capturedImage = await arManager.takeScreenshot(_repaintKey);
    if (capturedImage != null) {
      arCaptureNotifier.addCapturedImage(capturedImage);
    } else {
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
              content: Text(
                  "Are you sure you want to quit? All captured images will be lost."),
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
        ) ??
        false;
  }

  void _onFrame(Duration elapsed) {
    if(isAutoCaptureEnabled == false) {
      return;
    }

    arManager.getCameraPosition().then((position) {
      setState(() {
        final previousFramePosition = _currentPosition;
        _currentPosition = position.toVector3();

        _currentSpeed = _currentPosition.distanceTo(previousFramePosition)*1000;
        _currentDistance = _currentPosition.distanceTo(_lastImagePosition);
      });


      if(_currentDistance > MINIMAL_PICTURE_DISTANCE && _currentSpeed < MINIMAL_PICTURE_SPEED) {
        setState(() {
          _lastImagePosition = _currentPosition;
        });
        onCaptureButtonPressed();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onFrame);
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    final arCaptureNotifier = Provider.of<ArCaptureNotifier>(context);

    return PopScope(
      canPop: arCaptureNotifier.isEmpty(),
      onPopInvokedWithResult: (result, dynamic) async {
        shouldExit = await _showExitConfirmationDialog();
        if (shouldExit) {
          Navigator.of(context).pop();
          arCaptureNotifier.clear();
        }
      },
      child: Scaffold(
        appBar:
            AppBar(
                title: Text('AR capture'),
                actions: [
                  Text(
                    arCaptureNotifier.pictureCount.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),

              ],
            ),
        body: Stack(
          children: [
            RepaintBoundary(
              key: _repaintKey,
              child: ARView(
                onARViewCreated: arManager.onARViewCreated,
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Picture count: ${arCaptureNotifier.pictureCount}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("Speed: ${_currentSpeed.toStringAsFixed(4)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("Distance: ${_currentDistance.toStringAsFixed(4)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Switch(
                      value: isAutoCaptureEnabled,
                      onChanged: (value) {
                        setState(() {
                          isAutoCaptureEnabled = value; // Update the state
                        });
                      },
                    ),


                  ],
                ),
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
                  ListNotificationButton(
                      initialNotificationCount: arCaptureNotifier.pictureCount,
                      onPressed: onImageListButtonPressed),
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
    _ticker.dispose();
    super.dispose();
  }
}

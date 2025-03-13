import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reality_clone/model/ar_manager.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture_picture_list.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import '../../domain/ar_capture_notifier.dart';

class ArCapture extends StatefulWidget {
  const ArCapture({super.key});

  @override
  State<ArCapture> createState() => _ArCaptureState();
}

class _ArCaptureState extends State<ArCapture>
    with SingleTickerProviderStateMixin {
  final ArManager arManager = ArManager();
  final GlobalKey _repaintKey = GlobalKey();
  bool shouldExit = false;
  late Ticker _ticker;

  bool isSnackbarVisible = false;

  vector_math.Vector3 _currentPosition = vector_math.Vector3(0, 0, 0);
  vector_math.Vector3 _lastImagePosition = vector_math.Vector3(0, 0, 0);
  Stopwatch stopwatch = Stopwatch()..start();

  vector_math.Vector3 _lastFramePosition = vector_math.Vector3(0, 0, 0);
  double _currentSpeed = 0;
  double _currentDistance = 0;
  static const double MINIMAL_PICTURE_DISTANCE = 0.1;
  static const double MINIMAL_PICTURE_SPEED = 0.2;
  bool isAutoCaptureEnabled = false;

  void onCaptureButtonPressed() async {
    setState(() {
      _lastImagePosition = _currentPosition;
    });
    final arCaptureNotifier = context.read<ArCaptureNotifier>();
    final capturedImage = await arManager.takeScreenshot(_repaintKey);
    if (capturedImage != null) {
      arCaptureNotifier.addCapturedImage(capturedImage);
      HapticFeedback.vibrate();
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
    arManager.getCameraPosition().then((position) {
      double deltaTime = stopwatch.elapsedMicroseconds / 1e6;

      stopwatch.reset();

      double distance = position.toVector3().distanceTo(_lastFramePosition);

      setState(() {
        _currentPosition = position.toVector3();


        if (deltaTime > 0) {
          _currentSpeed = distance / deltaTime;
        }
        _currentDistance = _currentPosition.distanceTo(_lastImagePosition);
        _lastFramePosition = position.toVector3();

      });

      if (isAutoCaptureEnabled &&
          _currentDistance > MINIMAL_PICTURE_DISTANCE &&
          _currentSpeed < MINIMAL_PICTURE_SPEED) {
        onCaptureButtonPressed();
      }

      if (_currentSpeed > 3 && isSnackbarVisible == false) {
        isSnackbarVisible = true;

        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text("Please avoid moving too fast"),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: "OK",
                  onPressed: () {},
                ),
              ),
            )
            .closed
            .then((reason) {
          isSnackbarVisible = false;
        });
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
        appBar: AppBar(
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
                    Text(
                      "Picture count: ${arCaptureNotifier.pictureCount}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Speed: ${_currentSpeed.toStringAsFixed(4)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Distance: ${_currentDistance.toStringAsFixed(4)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "Auto-capture",
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
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Auto-capture",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
                    ElevatedButton(
                      onPressed: onCaptureButtonPressed,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.camera_alt, size: 30),
                    ),
                    OutlinedButton(
                      onPressed: onImageListButtonPressed,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                      ),
                      child: Icon(Icons.photo_library_outlined,
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),
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

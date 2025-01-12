import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reality_clone/ui/ar_capture/images_list/save_button.dart';

import '../../domain/ar_capture_notifier.dart';
import 'images_list/image_card.dart';

class ArCapturePictureList extends StatefulWidget {
  const ArCapturePictureList({super.key});

  @override
  State<ArCapturePictureList> createState() => _ArCapturePictureListState();
}

class _ArCapturePictureListState extends State<ArCapturePictureList> {
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);

  Future<void> onSaveImagesButtonPressed() async {
    if(_isSaving.value) return;
    final arCaptureNotifier = context.read<ArCaptureNotifier>();
    if (arCaptureNotifier.hasEnoughImages()) {
      _isSaving.value = true;
      try {
        await arCaptureNotifier.saveAndSendImages();
      } catch (e) {
        print('Error saving images: $e');
      }
      _isSaving.value = false;
    } else {
      _showMinimumImagesCountNotSatisfiedDialog();
    }
  }

  void _showMinimumImagesCountNotSatisfiedDialog() {
    const minImagesToSave = ArCaptureNotifier.MIN_IMAGE_COUNT;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Not enough images'),
          content: const Text(
            'You need at least $minImagesToSave images to save. Please capture more images.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final arCaptureNotifier = Provider.of<ArCaptureNotifier>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Captured images'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  arCaptureNotifier.pictureCount.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: arCaptureNotifier.isEmpty()
            ? const Center(child: Text('No photos captured yet.'))
            : GridView.builder(
                itemCount: arCaptureNotifier.pictureCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final capturedPhoto = arCaptureNotifier.capturedImages[index];
                  return ImageCard(
                    image: capturedPhoto,
                    onDelete: () => {},
                  );
                },
              ),
        floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: _isSaving,
          builder: (context, isSaving, child) {
            return SaveButton(
              isSaving: isSaving,
              onPressed: onSaveImagesButtonPressed,
            );
          },
        ));
  }
}

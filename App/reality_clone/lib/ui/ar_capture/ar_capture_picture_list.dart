import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/ar_capture_notifier.dart';
import 'images_list/image_card.dart';

class ArCapturePictureList extends StatefulWidget {
  const ArCapturePictureList({super.key});

  @override
  State<ArCapturePictureList> createState() => _ArCapturePictureList();
}




class _ArCapturePictureList extends State<ArCapturePictureList> {


  void onSaveImagesButtonPressed(){
    final arCaptureNotifier = context.read<ArCaptureNotifier>();
    if(arCaptureNotifier.canSave()){
      arCaptureNotifier.saveAndSendImages();
    }else{
      //todo : show error message;
    }
  }




  @override
  Widget build(BuildContext context) {
    // final arCaptureNotifier = context.read<ArCaptureNotifier>();
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

        floatingActionButton: FloatingActionButton(
          onPressed: ()=>{},
          tooltip: 'Save all photos',
          child: const Icon(Icons.save),
        ),
    );
  }
}
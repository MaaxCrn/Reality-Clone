import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:reality_clone/repo/app_repository.dart';
import 'package:reality_clone/services/zip_service.dart';
import '../../domain/capturedphoto.dart';
import 'image_card.dart';

class PhotoGalleryPage extends StatefulWidget {
  final List<CapturedImage> capturedPhotos;

  const PhotoGalleryPage({super.key, required this.capturedPhotos});

  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  static const int minImagesToSave = 3;

  Future<void> _saveAllCapturedPhotos() async {
    /*


    if (widget.capturedPhotos.length < minImagesToSave) {
      _showInsufficientImagesDialog();
      return;
    }

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint("Error: Unable to access external storage");
        return;
      }

      final rootDirectory = Directory('${directory.path}/Gaussian');
      final sparseDirectory = Directory('${rootDirectory.path}/sparse');
      final imagesDirectory = Directory('${rootDirectory.path}/images');

      if (!await rootDirectory.exists()) await rootDirectory.create(recursive: true);
      if (!await sparseDirectory.exists()) await sparseDirectory.create(recursive: true);
      if (!await imagesDirectory.exists()) await imagesDirectory.create(recursive: true);

      final points3DFilePath = '${sparseDirectory.path}/points3D.txt';
      final points3DFile = File(points3DFilePath);
      await points3DFile.create(recursive: true);

      StringBuffer cameraDataBuffer = StringBuffer();
      int x = 0;


      for (var photo in widget.capturedPhotos) {
        final file = File(photo.path);

        if (!file.existsSync()) {
          debugPrint("File does not exist: ${photo.path}");
          continue;
        }

        final imageBytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);

        final imageFilePath = '${imagesDirectory.path}/${photo.name}';
        await file.copy(imageFilePath);

        if (decodedImage != null && x == 0) {
          final width = decodedImage.width;
          final height = decodedImage.height;
          final centerX = width / 2;
          final centerY = height / 2;
          final focalLength = 1804.80;

          cameraDataBuffer.write(
            '1 PINHOLE $width $height $focalLength $focalLength $centerX $centerY\n',
          );
        } else {
          debugPrint("Error decoding image: ${photo.path}");
        }
        x += 1;
      }

      final cameraFilePath = '${sparseDirectory.path}/cameras.txt';
      final cameraFile = File(cameraFilePath);
      await cameraFile.writeAsString(cameraDataBuffer.toString());

      StringBuffer imageDataBuffer = StringBuffer();
      for (var photo in widget.capturedPhotos) {
        imageDataBuffer.write(
          '${photo.id} ${photo.rotation['qw']} ${photo.rotation['qx']} ${photo.rotation['qy']} ${photo.rotation['qz']} ${photo.position['x']} ${photo.position['y']} ${photo.position['z']} 1 ${photo.name}\n\n',
        );
      }

      final imageFilePath = '${sparseDirectory.path}/images.txt';
      final imageFile = File(imageFilePath);
      await imageFile.writeAsString(imageDataBuffer.toString());

      debugPrint('All images and metadata saved to ${rootDirectory.path}');
      _showSaveSuccessDialog();

      File zipFile = await FileService().zipFolderContents(rootDirectory.path, "gaussian.zip");
      print("Zip file created at: ${zipFile.path}");
      await appRepository.computeGaussian(zipFile);

    } catch (e) {
      debugPrint("Error saving images and metadata: $e");
    }
    */
  }

  void _showInsufficientImagesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insufficient Photos'),
          content: const Text(
            'You need at least $minImagesToSave photos to save. Please capture more images.',
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

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Photos Saved Successfully'),
          content: const Text('All captured photos and metadata have been saved.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Photos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${widget.capturedPhotos.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: widget.capturedPhotos.isEmpty
          ? const Center(child: Text('No photos captured yet.'))
          : GridView.builder(
        itemCount: widget.capturedPhotos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final capturedPhoto = widget.capturedPhotos[index];
          return ImageCard(
            image: capturedPhoto,
            onDelete: () => _deletePhoto(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAllCapturedPhotos,
        tooltip: 'Save all photos',
        child: const Icon(Icons.save),
      ),
    );
  }

  void _deletePhoto(BuildContext context, int index) {
    setState(() {
      widget.capturedPhotos.removeAt(index);
    });
  }
}

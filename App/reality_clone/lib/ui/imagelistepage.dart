import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../domain/capturedphoto.dart';

class PhotoGalleryPage extends StatefulWidget {
  final List<CapturedPhoto> capturedPhotos;

  const PhotoGalleryPage({super.key, required this.capturedPhotos});

  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Photos')),
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
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Center(
                    child: Image.file(
                      File(capturedPhoto.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        _deletePhoto(context, index);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      color: Colors.black54,
                      child: Text(
                        'X: ${capturedPhoto.position['x']?.toStringAsFixed(2)}, Y: ${capturedPhoto.position['y']?.toStringAsFixed(2)}, Z: ${capturedPhoto.position['z']?.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deletePhoto(BuildContext context, int index) {
    setState(() {
      widget.capturedPhotos.removeAt(index);
    });
  }
}

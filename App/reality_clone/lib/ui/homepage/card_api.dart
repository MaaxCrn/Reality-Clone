import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reality_clone/model/gaussian_model.dart';

import '../../repo/app_repository.dart';

class CardApi extends StatelessWidget {
  final GaussianModel photo;

  const CardApi({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      elevation: 0,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photo.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200, // Adjust as necessary
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.name ?? "Unknown Name",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      photo.date ?? "Unknown Date",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              backgroundColor: Color(0xFFB71C1C),
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                onPressed: () async {
                  bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text("Are you sure you want to delete this model?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    await appRepository.deleteGaussian(photo.id.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Model deleted.')),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

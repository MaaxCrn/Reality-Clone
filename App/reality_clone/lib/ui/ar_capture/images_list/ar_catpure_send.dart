import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/ar_capture_notifier.dart';

class ArCatpureSendPage extends StatefulWidget {
  @override
  _ArCaptureSendPageState createState() => _ArCaptureSendPageState();
}

class _ArCaptureSendPageState extends State<ArCatpureSendPage> {
  static const DEFAULT_PROJECT_NAME = 'New gaussian project';
  bool isUseArPositionEnabled = false;
  final TextEditingController _projectNameController = TextEditingController();

  bool _isSaving = false;

  _sendToServer() async {
    String projectName = _projectNameController.text;
    final useArPosition = isUseArPositionEnabled;

    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    if(projectName.isEmpty) {
      projectName = DEFAULT_PROJECT_NAME;
    }

    final arCaptureNotifier = context.read<ArCaptureNotifier>();
    try {
      await Future.delayed(const Duration(seconds: 1));
      await arCaptureNotifier.saveAndSendImages(projectName, useArPosition);
    } catch (e) {
      print('Error saving images: $e');
      _showErrorDialog();
    }


    setState(() {
      _isSaving = false;
    });
  }




  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('An error occurred'),
          content: const Text(
            'An error occurred while sending images to the server. Make sure the server is running and reachable.',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to server'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: DEFAULT_PROJECT_NAME,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListTile(
              onTap: () {
                setState(() {
                  isUseArPositionEnabled = !isUseArPositionEnabled;
                });
              },
              leading: Icon(Icons.view_in_ar),
              title: Text("Use positions from AR"), // Titre
              trailing: Switch(
                value: isUseArPositionEnabled,
                onChanged: (bool value) {
                  setState(() {
                    isUseArPositionEnabled = value;
                  });
                },
              ),
            ),
            const Text(
                "Using AR positions will be faster to compute, but less accurate.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Expanded(child: SizedBox(height: 24)),
            Column(
              children: [
                const Text(
                    "Images will be sent to the server to compute Gaussian Splatting. This might take a while.",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _sendToServer,
                    label: const Text("Send"),
                    icon: _isSaving
                        ? Transform.scale(
                            scale: 0.5,
                            child: const CircularProgressIndicator(
                                color: Colors.white),
                          )
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

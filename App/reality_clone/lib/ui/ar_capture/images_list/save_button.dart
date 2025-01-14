import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: widget.onPressed,
      tooltip: 'Save all images',
      child: widget.isSaving
          ? const CircularProgressIndicator()
          : const Icon(Icons.save),
    );
  }
}

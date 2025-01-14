import 'package:flutter/material.dart';

class ListNotificationButton extends StatefulWidget {
  final int initialNotificationCount;
  final VoidCallback onPressed;

  const ListNotificationButton({
    Key? key,
    required this.initialNotificationCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  _ListNotificationButtonState createState() => _ListNotificationButtonState();
}

class _ListNotificationButtonState extends State<ListNotificationButton> {
  late int notificationCount;

  @override
  void initState() {
    super.initState();
    notificationCount = widget.initialNotificationCount;
  }

  void updateNotificationCount(int newCount) {
    setState(() {
      notificationCount = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.photo_library, size: 30),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Visibility(
            visible: notificationCount > 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

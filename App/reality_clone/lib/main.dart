import 'package:flutter/material.dart';
import 'package:my_custom_plugin/my_custom_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Focal Length Example'),
        ),
        body: Center(
          child: FutureBuilder<double>(
            future: MyCustomPlugin.getFocalLength(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text('Focal Length: ${snapshot.data}');
              }
            },
          ),
        ),
      ),
    );
  }
}

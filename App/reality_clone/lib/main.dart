import 'package:flutter/material.dart';

import 'package:my_custom_plugin/my_custom_plugin.dart';

import 'package:provider/provider.dart';
import 'package:reality_clone/domain/ar_capture_notifier.dart';
import 'package:reality_clone/theme/app_theme.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture_picture_list.dart';
import 'package:reality_clone/ui/homepage.dart';
import 'package:reality_clone/ui/loginpage.dart';
import 'package:reality_clone/ui/settingpage.dart';

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

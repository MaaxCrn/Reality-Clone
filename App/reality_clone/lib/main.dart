import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:reality_clone/domain/ar_capture_notifier.dart';
import 'package:reality_clone/domain/homepage_notifier.dart';
import 'package:reality_clone/repo/app_repository.dart';
import 'package:reality_clone/theme/app_theme.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture.dart';
import 'package:reality_clone/ui/ar_capture/ar_capture_picture_list.dart';
import 'package:reality_clone/ui/homepage/homepage.dart';
import 'package:reality_clone/ui/settingpage.dart';

void main() {
  runApp(const RealityCloneApp());
}

class RealityCloneApp extends StatelessWidget {
  const RealityCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = AppTheme(TextTheme());

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ArCaptureNotifier()),
          ChangeNotifierProvider(create: (context) => HomePageNotifier(AppRepository())),
        ],
        child: MaterialApp(
          title: 'Reality Clone',
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(),
            '/setting': (context) => SettingsPage(),
            '/capture': (context) => ArCapture(),
            '/capture/list': (context) => ArCapturePictureList(),
          },
          theme: materialTheme.light(),
        ));
  }
}
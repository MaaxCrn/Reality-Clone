import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:reality_clone/theme/app_theme.dart';
import 'package:reality_clone/ui/homepage.dart';
import 'package:reality_clone/ui/loginpage.dart';
import 'package:reality_clone/ui/picturepage.dart';
import 'package:reality_clone/ui/settingpage.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = AppTheme(TextTheme());

    return MaterialApp(
      title: 'Reality Clone',
      initialRoute: '/login',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/setting': (context) => SettingsPage(),
        '/picture': (context) => PicturePage(cameras: cameras),
      },
      theme: materialTheme.light(),
    );
  }
}
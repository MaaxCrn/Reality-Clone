import 'package:flutter/material.dart';
import 'package:reality_clone/theme/app_theme.dart';
import 'package:reality_clone/ui/homepage.dart';
import 'package:reality_clone/ui/loginpage.dart';

void main() {
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
      },
      //home: LoginPage(),
      theme: materialTheme.light(),
    );
  }
}

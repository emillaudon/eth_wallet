import 'package:flutter/material.dart';
import 'views/wallet/home_page.dart';
import 'views/wallet/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        theme: ThemeData.dark().copyWith(
            primaryColor: Color(0xFF1D1E33),
            accentColor: Colors.purple,
            scaffoldBackgroundColor: Color(0xFF1D1E33)));
  }
}
//HomePage()

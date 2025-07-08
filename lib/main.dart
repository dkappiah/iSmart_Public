import 'package:flutter/material.dart';
import 'package:mini_mobile_digital_wallet/pages/login.dart';
import 'package:mini_mobile_digital_wallet/pages/signUp.dart';
import 'package:mini_mobile_digital_wallet/pages/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // initial route to auth pages
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
      // login safety net (might take it out )
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}
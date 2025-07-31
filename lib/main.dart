import 'package:flutter/material.dart';
import 'package:mini_mobile_digital_wallet/pages/auth.dart'; 
import 'package:mini_mobile_digital_wallet/pages/HomePage.dart';
import 'package:mini_mobile_digital_wallet/providers/themeProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Digital Wallet',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // initial route to the authentication page
            initialRoute: '/auth',
            routes: {
              '/auth': (context) => const AuthPage(isSignIn: true), // Sign-in and sign-up page
              '/home': (context) => const HomePage(), // Home page after login
            },
            // login safety net
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const AuthPage(isSignIn: true),
              );
            },
          );
        },
      ),
    );
  }
}
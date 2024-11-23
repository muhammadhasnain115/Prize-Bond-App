import 'package:flutter/material.dart';
import 'db_.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'reset_password_page.dart';
import 'add_number.dart';
import 'show_bond.dart';
import 'home.dart';

const String apiUrl = "https://checkprizebond.pythonanywhere.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseHelper dbHelper = DatabaseHelper();
  bool isLoggedIn = await dbHelper.getLoginFlag();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prize Bond Check',
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/reset': (context) => const ResetPasswordPage(),
        '/home': (context) => const HomePage(),
        '/add_number': (context) =>  BondPage(),
        '/show_number': (context) => const BondCheckPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

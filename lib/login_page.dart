import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'db_.dart'; // Import your DatabaseHelper class
import 'main.dart'; // Import the main.dart file to access apiUrl

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Initialize DatabaseHelper

  String email = ''; // Initialize email

  // Fetch email based on username
  Future<void> _fetchEmail(String username) async {
    var url = Uri.parse('https://checkprizebond.pythonanywhere.com/api/user/email/$username'); // Define the endpoint to get email by username

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        setState(() {
          email = responseData['email']; // Store email once fetched
        });
      } else {
        print('Failed to fetch email: ${response.body}');
      }
    } catch (e) {
      print('Error fetching email: $e');
    }
  }

  // Handle login process
  void _handleLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Fetch email before login to ensure email is available
    await _fetchEmail(username);

    var requestBody = json.encode({
      'action': 'login',
      'username': username,
      'password': password,
    });

    var url = Uri.parse('$apiUrl/api/user'); // Access apiUrl here

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['flag'] == 1) {
        // Set login flag and store username and email in database
        await _dbHelper.setLoginFlag(true);
        await _dbHelper.setUsername(username);
        await _dbHelper.setEmail(email);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushNamed(context, '/home'); // Navigate to home page after login
      } else {
        // Show error message from the response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } catch (e) {
      // Handle error if server is unreachable or any other issue
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Server is busy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Username text field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Password text field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true, // Obscure password input
            ),
            const SizedBox(height: 16.0),
            // Login button
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            // Forgot password link
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reset');
              },
              child: const Text('Forgot Password?'),
            ),
            // Sign up link
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

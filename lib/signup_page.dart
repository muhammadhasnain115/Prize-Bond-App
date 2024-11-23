import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Ensure this file contains the correct `apiUrl`
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.endsWith('.com');
  }

  bool _isValidPassword(String password) {
    return password.length >= 7;
  }

  void _handleSignup() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phone = _phoneController.text;
    String address = _addressController.text;

    // Validate email
    if (!_isValidEmail(email)) {
      setState(() {
        _emailErrorMessage = 'Invalid email. It should contain "@" and end with ".com"';
      });
      return;
    }

    // Validate password
    if (!_isValidPassword(password)) {
      setState(() {
        _passwordErrorMessage = 'Password must be at least 7 characters long';
      });
      return;
    }

    var requestBody = json.encode({
      'action': 'signup',
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address
    });

    var url = Uri.parse('$apiUrl/api/user'); // Update with your API URL

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Request Headers: ${response.request?.headers}');
      print('Request Body: $requestBody');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['flag'] == 1) {
          print('Signup successful!');
          Navigator.pushNamed(context, '/'); // Navigate to home page
        } else {
          print('Signup failed: ${responseData['message']}');
        }
      } else if (response.statusCode == 400) {
        var responseData = json.decode(response.body);
        print('Signup failed: ${responseData['message']}');
      } else {
        print('Something went wrong');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Page'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              errorText: _emailErrorMessage,
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Address (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              errorText: _passwordErrorMessage,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _handleSignup,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

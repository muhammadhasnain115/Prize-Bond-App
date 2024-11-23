// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:convert';
// import 'dart:async';
//
// const String clientId = 'YOUR_CLIENT_ID';
// const String clientSecret = 'YOUR_CLIENT_SECRET';
// const String redirectUri = 'http://localhost:8080/';
// const String authorizationEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
// const String tokenEndpoint = 'https://oauth2.googleapis.com/token';
//
// class GoogleLoginPage extends StatelessWidget {
//   const GoogleLoginPage({super.key});
//
//   Future<void> _signInWithGoogle(BuildContext context) async {
//     final authUrl = Uri.parse(
//       '$authorizationEndpoint?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=email profile',
//     );
//
//     await launchUrl(authUrl);
//
//     // Handle the authorization code response in your redirect URI handler.
//   }
//
//   Future<void> _exchangeCodeForToken(String code) async {
//     final response = await http.post(
//       Uri.parse(tokenEndpoint),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {
//         'code': code,
//         'client_id': clientId,
//         'client_secret': clientSecret,
//         'redirect_uri': redirectUri,
//         'grant_type': 'authorization_code',
//       },
//     );
//
//     final responseData = json.decode(response.body);
//     final accessToken = responseData['access_token'];
//     // Use the access token to fetch user information.
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Google Login'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _signInWithGoogle(context),
//           child: const Text('Continue with Google'),
//         ),
//       ),
//     );
//   }
// }

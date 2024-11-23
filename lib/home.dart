import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'db_.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  String _searchQuery = '';
  int _selectedFilter = 100;
  final List<int> _filterOptions = [100, 200, 750, 1500, 7500, 15000];

  String? userName;
  String? userEmail;
  String? message;
  String? date;
  String? position;

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    userName = await dbHelper.getUsername();
    userEmail = await dbHelper.getEmail();
  }

  Future<void> _searchNumber(String number) async {
    String url = '$apiUrl/api/data/$number/$_selectedFilter';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          message = 'Congratulations!';
          date = data['date'] ?? 'N/A';
          position = data['position']?.toString() ?? 'N/A';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          message = 'Sorry, no bond found.';
          date = null;
          position = null;
        });
      } else {
        setState(() {
          message = 'Error: Unable to fetch data.';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        message = 'No internet connection.. Error: $e';
      });
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'This app was made by Hasnain. It helps users manage and check their bonds efficiently. ',
                  style: TextStyle(color: Colors.black), // Dark text
                ),
                TextSpan(
                  text: 'For more details, visit our website.',
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Replace with your website URL
                      const url = 'https://checkprizebond.pythonanywhere.com/';
                      launchUrl(Uri.parse(url));
                    },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(userName ?? ""),
                accountEmail: Text(userEmail ?? ""),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: NetworkImage('https://example.com/user-pic.jpg'),
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
                title: Text(_isDarkMode ? 'Light Mode' : 'Dark Mode'),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.line_style),
                title: const Text('Add My Bond Number'),
                onTap: () {
                  Navigator.pushNamed(context, '/add_number');
                },
              ),
              ListTile(
                leading: const Icon(Icons.line_style),
                title: const Text('Bonds I Have'),
                onTap: () {
                  Navigator.pushNamed(context, '/show_number');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: _showAboutDialog,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  dbHelper.setLoginFlag(false);
                  Navigator.pushNamed(context, '/');
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 140, left: 50),
                child: ListTile(
                  title: Text(
                    'Made by Hasnain',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  const Text('Filter:'),
                  const SizedBox(width: 16.0),
                  DropdownButton<int>(
                    value: _selectedFilter,
                    items: _filterOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String number = _searchQuery;
                  _searchNumber(number);
                },
                child: const Text('Search Number'),
              ),
              const SizedBox(height: 16.0),
              if (message != null)
                Column(
                  children: <Widget>[
                    Text(message!),
                    if (date != null && position != null)
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            children: [
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Number'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(_searchQuery),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Date'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('$date'),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Position'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('$position'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

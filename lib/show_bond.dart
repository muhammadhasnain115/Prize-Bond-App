import 'package:flutter/material.dart';
import 'db_.dart'; // Import the database helper
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class BondCheckPage extends StatefulWidget {
  const BondCheckPage({super.key});

  @override
  _BondCheckPageState createState() => _BondCheckPageState();
}

class _BondCheckPageState extends State<BondCheckPage> {
  List<Map<String, dynamic>> _bonds = [];
  final List<Map<String, dynamic>> _status = [];
  bool _isChecking = false;
  double _progress = 0.0; // Percentage of bonds checked

  @override
  void initState() {
    super.initState();
    _fetchBonds();
  }

  Future<void> _fetchBonds() async {
    List<Map<String, dynamic>> bonds = await DatabaseHelper().getBonds();
    setState(() {
      _bonds = bonds;
    });
  }

  Future<void> _checkBonds() async {
    setState(() {
      _isChecking = true;
      _status.clear();
    });

    int totalBonds = _bonds.length;
    int bondsChecked = 0;

    for (var bond in _bonds) {
      await _searchNumber(bond['bondNumber'], bond['price']);
      bondsChecked++;

      // Update progress
      setState(() {
        _progress = bondsChecked / totalBonds;
      });

      // Wait a bit before processing the next bond
      await Future.delayed(const Duration(milliseconds: 500)); // Adjust delay as needed
    }

    setState(() {
      _isChecking = false;
    });
  }

  Future<void> _searchNumber(String number, String price) async {
    String url = '$apiUrl/api/data/$number/$price';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _status.add({
            'bondNumber': number,
            'status': 'Congratulations! 🎉',
            'date': data['date'] ?? 'N/A',
            'position': data['position']?.toString() ?? 'N/A',
            'found': true,
          });
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _status.add({
            'bondNumber': number,
            'status': 'Sorry, no bond hit. 😔',
            'date': null,
            'position': null,
            'found': false,
          });
        });
      } else {
        setState(() {
          _status.add({
            'bondNumber': number,
            'status': 'Error: Unable to fetch data. ⚠️',
            'date': null,
            'position': null,
            'found': false,
          });
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _status.add({
          'bondNumber': number,
          'status': 'No internet connection. 🌐',
          'date': null,
          'position': null,
          'found': false,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Bonds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_isChecking)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${(_progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkBonds,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Check All Bonds'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isChecking && _status.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _status.isEmpty
                  ? const Center(child: Text('No bonds have been checked yet.'))
                  : ListView.builder(
                itemCount: _status.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Bond Number: ${_status[index]['bondNumber']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${_status[index]['status']}'),
                          Text('Date: ${_status[index]['date']}'),
                          Text('Position: ${_status[index]['position']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

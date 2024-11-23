import 'package:flutter/material.dart';
import 'db_.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'dart:convert';

class BondPage extends StatefulWidget {
  @override
  _BondPageState createState() => _BondPageState();
}

class _BondPageState extends State<BondPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _bondNumberController = TextEditingController();
  final TextEditingController _startRangeController = TextEditingController();
  final TextEditingController _endRangeController = TextEditingController();
  String _selectedPrice = '100';
  List<Map<String, dynamic>> _bonds = [];
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadBonds();
    _checkPremiumStatus();
  }

  Future<void> _loadBonds() async {
    var bonds = await dbHelper.getBonds();
    setState(() {
      _bonds = bonds;
    });
  }

  Future<void> _checkPremiumStatus() async {
    String? username = await dbHelper.getUsername();
    if (username != null) {
      print(username);
      var response = await http.get(Uri.parse('$apiUrl/api/user/premium/$username'));
      if (response.statusCode == 200) {
        setState(() {
          _isPremium = true;
        });
      }
      if (response.statusCode == 100) {
        setState(() {
          _isPremium = true;
        });
      }
    }
  }

  Future<void> _addBond() async {
    if (!_isPremium && _bonds.length >= 10) {
      _showUpgradeDialog();
      return;
    }

    String bondNumber = _bondNumberController.text;
    String price = _selectedPrice;

    if (await dbHelper.bondExists(bondNumber)) {
      String? existingPrice = await dbHelper.getBondPrice(bondNumber);
      if (existingPrice == price) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bond with the same number and price already exists')),
        );
        return;
      } else {
        await dbHelper.updateBondPrice(bondNumber, price);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bond price updated')),
        );
      }
    } else {
      await dbHelper.insertBond(bondNumber, price);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bond added')),
      );
    }

    _bondNumberController.clear();
    _selectedPrice = '100';
    await _loadBonds();
  }

  Future<void> _addBondRange() async {
    if (!_isPremium && _bonds.length + (int.parse(_endRangeController.text) - int.parse(_startRangeController.text) + 1) > 10) {
      _showUpgradeDialog();
      return;
    }

    int startRange = int.parse(_startRangeController.text);
    int endRange = int.parse(_endRangeController.text);
    String price = _selectedPrice;

    for (int i = startRange; i <= endRange; i++) {
      String bondNumber = i.toString();
      if (await dbHelper.bondExists(bondNumber)) {
        String? existingPrice = await dbHelper.getBondPrice(bondNumber);
        if (existingPrice != price) {
          await dbHelper.updateBondPrice(bondNumber, price);
        }
      } else {
        await dbHelper.insertBond(bondNumber, price);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bonds added/updated in range')),
    );

    _startRangeController.clear();
    _endRangeController.clear();
    _selectedPrice = '100';
    await _loadBonds();
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to Premium'),
        content: Text('You have reached the limit of 10 bonds. Please purchase a premium subscription to add more bonds.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBond(String bondNumber) async {
    await dbHelper.deleteBond(bondNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bond deleted')),
    );
    await _loadBonds();
  }

  Future<void> _deleteAllBonds() async {
    await dbHelper.deleteAllBonds();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All bonds deleted')),
    );
    await _loadBonds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bond Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                controller: _bondNumberController,
                label: 'Bond Number',
                icon: Icons.numbers,
              ),
              _buildDropdown(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addBond,
                child: Text('Add Bond'),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _startRangeController,
                label: 'Start Range',
                icon: Icons.linear_scale,
              ),
              _buildTextField(
                controller: _endRangeController,
                label: 'End Range',
                icon: Icons.linear_scale,
              ),
              _buildDropdown(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addBondRange,
                child: Text('Add Bond Range'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteAllBonds,
                child: Text('Delete All Bonds'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              _buildBondList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPrice,
      items: ['100', '200', '750', '1500', '7500', '15000', '40000']
          .map((price) => DropdownMenuItem<String>(
        value: price,
        child: Text(price),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedPrice = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Price',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBondList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _bonds.length,
      itemBuilder: (context, index) {
        var bond = _bonds[index];
        return ListTile(
          title: Text('Bond Number: ${bond['bondNumber']}'),
          subtitle: Text('Price: ${bond['price']}'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteBond(bond['bondNumber']);
            },
          ),
        );
      },
    );
  }
}

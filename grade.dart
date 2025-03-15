import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserFormPage extends StatefulWidget {
  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _status = '';

  Future<void> _saveUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('users') ?? [];

    Map<String, String> userData = {
      'email': _emailController.text,
      'phone': _phoneController.text,
      'status': _status,
    };

    users.add(jsonEncode(userData));
    await prefs.setStringList('users', users);

    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _status = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User data saved successfully!')),
    );
  }

  void _handleSubmit() {
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        _phoneController.text.isEmpty ||
        _phoneController.text.length < 10 ||
        _status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    _saveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Info')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            Row(
              children: [
                Text('Status: '),
                Radio(
                  value: 'Active',
                  groupValue: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                Text('Active'),
                if (_status == 'Active') Icon(Icons.check_circle, color: Colors.green),
                Radio(
                  value: 'Deactive',
                  groupValue: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                Text('Deactive'),
                if (_status == 'Deactive') Icon(Icons.cancel, color: Colors.red),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

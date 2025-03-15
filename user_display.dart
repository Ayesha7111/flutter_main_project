import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDisplayPage extends StatefulWidget {
  @override
  _UserDisplayPageState createState() => _UserDisplayPageState();
}

class _UserDisplayPageState extends State<UserDisplayPage> {
  List<Map<String, String>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('users') ?? [];
    setState(() {
      _users = users.map((user) => Map<String, String>.from(jsonDecode(user))).toList();
    });
  }

  Future<void> _clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('users');
    setState(() {
      _users.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearUserData,
          ),
        ],
      ),
      body: _users.isEmpty
          ? Center(child: Text('No users found'))
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          bool isActive = user['status']?.toLowerCase() == 'active';
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(user['email'] ?? 'No Email'),
              subtitle: Text('Phone: ${user['phone'] ?? 'No Phone'}\nStatus: ${user['status'] ?? 'Unknown'}'),
              trailing: Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                color: isActive ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}

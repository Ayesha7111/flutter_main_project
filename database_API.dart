import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7), // Light background color
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[100], // Light app bar color
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[300], // Lighter button color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[400]!),
          ),
        ),
      ),
      home: const DatabaseApi(),
    );
  }
}

class DatabaseApi extends StatefulWidget {
  const DatabaseApi({Key? key}) : super(key: key);

  @override
  State<DatabaseApi> createState() => _DatabaseApiState();
}

class _DatabaseApiState extends State<DatabaseApi> {
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = false;
  String _selectedFilter = 'None';

  final _courseList = ['OS', 'OOAD', 'ICTC', 'OOP', 'DLD' , 'AD' , 'DSA'];
  final _semesterList = List<String>.generate(8, (i) => (i + 1).toString());
  final _creditHoursList = List<String>.generate(6, (i) => i.toString());

  String? _selectedCourse;
  String? _selectedSemester;
  String? _selectedCreditHours;
  final TextEditingController _marksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.fetchData();
    if (mounted) {
      setState(() {
        _grades = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAndSaveData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://bgnuerp.online/api/gradeapi'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          await DatabaseHelper.instance.resetDatabase();
          for (var item in data) {
            await DatabaseHelper.instance.insertData({
              'student_name': item['studentname'] ?? 'Unknown',
              'father_name': item['fathername'] ?? 'Unknown',
              'department_name': item['progname'] ?? 'Unknown',
              'shift': item['shift'] ?? 'Unknown',
              'rollno': item['rollno'] ?? 'Unknown',
              'course_code': item['coursecode'] ?? 'Unknown',
              'course_title': item['coursetitle'] ?? 'Unknown',
              'credit_hours': item['credithours'] ?? 'Unknown',
              'obtained_marks': item['obtainedmarks'] ?? 'Unknown',
              'semester': item['mysemester'] ?? 'Unknown',
              'consider_status': item['consider_status'] ?? 'Unknown',
            });
          }
          await _loadLocalData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data loaded successfully!'), backgroundColor: Colors.green),
            );
          }
        } else {
          throw Exception('API returned empty data');
        }
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_selectedCourse != null && _selectedSemester != null && _selectedCreditHours != null &&
        _marksController.text.isNotEmpty) {
      final int? marks = int.tryParse(_marksController.text);
      if (marks != null && marks >= 0 && marks <= 100) {
        await DatabaseHelper.instance.insertData({
          'student_name': 'Manual Entry',
          'father_name': '-',
          'department_name': '-',
          'shift': '-',
          'rollno': '-',
          'course_code': '-',
          'course_title': _selectedCourse,
          'credit_hours': _selectedCreditHours,
          'obtained_marks': marks.toString(),
          'semester': _selectedSemester,
          'consider_status': '-',
        });
        _marksController.clear();
        setState(() {
          _selectedCourse = null;
          _selectedSemester = null;
          _selectedCreditHours = null;
        });
        await _loadLocalData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid marks (0-100)')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields')));
    }
  }

  Future<void> _deleteRow(int id) async {
    setState(() => _isLoading = true);
    await DatabaseHelper.instance.deleteRow(id);
    await _loadLocalData();
  }

  Future<void> _resetDatabase() async {
    setState(() => _isLoading = true);
    await DatabaseHelper.instance.resetDatabase();
    await _loadLocalData();
  }

  List<Map<String, dynamic>> get _filteredGrades {
    List<Map<String, dynamic>> filtered = [..._grades];
    switch (_selectedFilter) {
      case 'A-Z':
        filtered.sort((a, b) => a['student_name'].compareTo(b['student_name']));
        break;
      case 'Z-A':
        filtered.sort((a, b) => b['student_name'].compareTo(a['student_name']));
        break;
      case 'Highest Marks':
        filtered.sort((a, b) => int.parse(b['obtained_marks'].toString()).compareTo(int.parse(a['obtained_marks'].toString())));
        break;
      case 'Lowest Marks':
        filtered.sort((a, b) => int.parse(a['obtained_marks'].toString()).compareTo(int.parse(b['obtained_marks'].toString())));
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40, width: 40),
            const SizedBox(width: 10),
            const Text('Student Grades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCourse,
                      items: _courseList.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                      onChanged: (value) => setState(() => _selectedCourse = value),
                      decoration: InputDecoration(
                        labelText: 'Select Course',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[200]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSemester,
                      items: _semesterList.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                      onChanged: (value) => setState(() => _selectedSemester = value),
                      decoration: InputDecoration(
                        labelText: 'Select Semester',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[200]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCreditHours,
                      items: _creditHoursList.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                      onChanged: (value) => setState(() => _selectedCreditHours = value),
                      decoration: InputDecoration(
                        labelText: 'Credit Hours',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[200]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _marksController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Marks (0-100)',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[200]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Submit'),
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              items: ['None', 'A-Z', 'Z-A', 'Highest Marks', 'Lowest Marks']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) => setState(() => _selectedFilter = value ?? 'None'),
              decoration: InputDecoration(
                labelText: 'Sort by',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue[200]!),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Load Data'),
                  onPressed: _fetchAndSaveData,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Reset All'),
                  onPressed: _resetDatabase,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGrades.isEmpty
                ? const Center(child: Text('No data available.'))
                : _buildDataTable(),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: Colors.blue[100], // Lighter footer background
            child: const Text(
              'Baba Guru Nanak University',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateProperty.all(Colors.blue[200]!),
          headingTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(label: Text('Student Name')),
            DataColumn(label: Text('Father Name')),
            DataColumn(label: Text('Department')),
            DataColumn(label: Text('Shift')),
            DataColumn(label: Text('Roll No')),
            DataColumn(label: Text('Course Code')),
            DataColumn(label: Text('Course Title')),
            DataColumn(label: Text('Credit Hours')),
            DataColumn(label: Text('Marks')),
            DataColumn(label: Text('Semester')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: _filteredGrades.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['student_name'] ?? 'Unknown')),
                DataCell(Text(item['father_name'] ?? 'Unknown')),
                DataCell(Text(item['department_name'] ?? 'Unknown')),
                DataCell(Text(item['shift'] ?? 'Unknown')),
                DataCell(Text(item['rollno']?.toString() ?? 'Unknown')),
                DataCell(Text(item['course_code'] ?? 'Unknown')),
                DataCell(Text(item['course_title'] ?? 'Unknown')),
                DataCell(Text(item['credit_hours']?.toString() ?? 'Unknown')),
                DataCell(Text(item['obtained_marks']?.toString() ?? 'Unknown')),
                DataCell(Text(item['semester']?.toString() ?? 'Unknown')),
                DataCell(Text(item['consider_status']?.toString() ?? 'Unknown')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRow(item['id']),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OnlineApiPage extends StatefulWidget {
  const OnlineApiPage({super.key});

  @override
  State<OnlineApiPage> createState() => _OnlineApiPageState();
}

class _OnlineApiPageState extends State<OnlineApiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  String? _selectedCourseName;
  String? _selectedSemester;
  String? _selectedCreditHours;

  bool _isSubmitting = false;
  bool _isFetching = false;
  bool _isSuccess = false;
  String _responseMessage = '';
  String _sortOrder = 'oldest';

  List<dynamic> _gradesData = [];
  List<String> _courseNames = [];

  final List<String> _semesterOptions = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _creditHourOptions = ['1', '2', '3', '4'];

  final String _postUrl = 'https://devtechtop.com/management/public/api/grades';
  final String _getUrl = 'https://devtechtop.com/management/public/api/select_data';
  final String _coursesUrl = 'https://bgnuerp.online/api/get_courses?user_id=12122';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(_coursesUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            _courseNames = data.map((course) => course['subject_name'].toString()).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load course list: $e");
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _responseMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_postUrl),
        body: {
          'user_id': _userIdController.text.trim(),
          'course_name': _selectedCourseName!,
          'semester_no': _selectedSemester!,
          'credit_hours': _selectedCreditHours!,
          'marks': _marksController.text.trim(),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          _isSuccess = true;
          _responseMessage = 'Data Submitted Successfully!';
        });
        _formKey.currentState!.reset();
        _userIdController.clear();
        _marksController.clear();
        _selectedCourseName = null;
        _selectedSemester = null;
        _selectedCreditHours = null;
        _fetchData();
      } else {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _isSuccess = false;
          _responseMessage = jsonResponse['message'] ?? 'Submission failed.';
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _responseMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isFetching = true);

    try {
      final response = await http.get(Uri.parse(_getUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() => _gradesData = jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          setState(() => _gradesData = jsonData['data']);
        } else {
          setState(() {
            _responseMessage = 'Unexpected response format';
            _gradesData = [];
          });
        }
      } else {
        setState(() {
          _responseMessage = 'Failed to load data';
          _gradesData = [];
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _gradesData = [];
      });
    } finally {
      setState(() => _isFetching = false);
    }
  }

  List<dynamic> _getSortedData() {
    List<dynamic> sorted = List.from(_gradesData);
    sorted.sort((a, b) {
      int idA = int.tryParse(a['id'].toString()) ?? 0;
      int idB = int.tryParse(b['id'].toString()) ?? 0;
      return _sortOrder == 'oldest' ? idA.compareTo(idB) : idB.compareTo(idA);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online API Call System'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isFetching ? null : _fetchData,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(labelText: 'User ID'),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Enter User ID' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCourseName,
                        decoration: const InputDecoration(labelText: 'Course Name'),
                        items: _courseNames
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCourseName = val),
                        validator: (value) => value == null ? 'Select course' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        decoration: const InputDecoration(labelText: 'Semester No'),
                        items: _semesterOptions
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSemester = val),
                        validator: (value) => value == null ? 'Select semester' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCreditHours,
                        decoration: const InputDecoration(labelText: 'Credit Hours'),
                        items: _creditHourOptions
                            .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCreditHours = val),
                        validator: (value) => value == null ? 'Select credit hours' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _marksController,
                        decoration: const InputDecoration(labelText: 'Marks (0-100)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter marks';
                          final marks = int.tryParse(value);
                          if (marks == null || marks < 0 || marks > 100) {
                            return 'Marks must be between 0 and 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Data'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isFetching ? null : _fetchData,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Load Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 20),
            if (_responseMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_isSuccess ? Icons.check : Icons.error,
                        color: _isSuccess ? Colors.green : Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_responseMessage)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.w600)),
                DropdownButton<String>(
                  value: _sortOrder,
                  onChanged: (val) => setState(() => _sortOrder = val!),
                  items: const [
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                    DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _gradesData.isEmpty
                ? const Text('No data loaded yet.')
                : Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Course')),
                    DataColumn(label: Text('Sem')),
                    DataColumn(label: Text('CH')),
                    DataColumn(label: Text('Marks')),
                  ],
                  rows: _getSortedData().map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['id'].toString())),
                      DataCell(Text(row['user_id'].toString())),
                      DataCell(Text(row['course_name'].toString())),
                      DataCell(Text(row['semester_no'].toString())),
                      DataCell(Text(row['credit_hours'].toString())),
                      DataCell(Text(row['marks'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

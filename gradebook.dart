import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InputPage(),
    );
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? selectedSubject;
  String? selectedCreditHour;
  TextEditingController marksController = TextEditingController();

  List<String> subjects = ['Entrepreneurship', 'Operating System', 'Theory of Automata', 'Software Engineering', 'Numerical Computing'];
  List<String> creditHours = ['1', '2', '3', '4'];

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int marks = int.tryParse(marksController.text) ?? 0;
    double cgpa = calculateCGPA(marks);
    String grade = determineGrade(marks);

    await prefs.setString('subject', selectedSubject ?? '');
    await prefs.setString('marks', marksController.text);
    await prefs.setString('creditHour', selectedCreditHour ?? '');
    await prefs.setDouble('cgpa', cgpa);
    await prefs.setString('grade', grade);
  }

  double calculateCGPA(int marks) {
    if (marks >= 90) return 4.0;
    if (marks >= 70) return 3.5;
    if (marks >= 60) return 3.0;
    if (marks >= 50) return 2.5;
    return 0.0;
  }

  String determineGrade(int marks) {
    if (marks >= 90) return 'A';
    if (marks >= 70) return 'B';
    if (marks >= 60) return 'C';
    if (marks >= 50) return 'D';
    return 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GradeBook', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.blue[50],
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GradeBook', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 24),
                DropdownButtonFormField(
                  value: selectedSubject,
                  hint: Text('Select Subject', style: TextStyle(color: Colors.deepPurple)),
                  style: TextStyle(color: Colors.deepPurple),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value as String?;
                    });
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: marksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Marks',
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedCreditHour,
                  hint: Text('Select Credit Hour', style: TextStyle(color: Colors.deepPurple)),
                  style: TextStyle(color: Colors.deepPurple),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: creditHours.map((hour) {
                    return DropdownMenuItem(
                      value: hour,
                      child: Text(hour),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCreditHour = value as String?;
                    });
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color set to black
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40),
                  ),
                  onPressed: () async {
                    // Saving data
                    await saveData();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DisplayPage()),
                    );
                  },
                  child: Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)), // Text color set to white for visibility
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  String subject = '';
  String marks = '';
  String creditHour = '';
  String grade = '';
  double cgpa = 0.0;

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      subject = prefs.getString('subject') ?? '';
      marks = prefs.getString('marks') ?? '';
      creditHour = prefs.getString('creditHour') ?? '';
      grade = prefs.getString('grade') ?? '';
      cgpa = prefs.getDouble('cgpa') ?? 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GradeBook', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.green[50],
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('GradeBook', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 24),
                Text('Subject: $subject', style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
                SizedBox(height: 6),
                Text('Marks: $marks', style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
                SizedBox(height: 6),
                Text('Credit Hour: $creditHour', style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
                SizedBox(height: 6),
                Text('Grade: $grade', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 6),
                Text('CGPA: $cgpa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
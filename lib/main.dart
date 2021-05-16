import 'package:flutter/material.dart';
import 'package:flutter_with_db/model/student.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'db/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  Future<List<Student>>? _studentsList;
  String? _studentName;
  bool isUpdate = false;
  late int studentIdForUpdate;

  @override
  void initState() {
    super.initState();
    updateStudentList();
  }

  updateStudentList() {
    setState(() => {
      _studentsList = DBProvider.db.getStudents()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('SQLite CRUD Demo'),
        backgroundColor: Colors.black,
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formStateKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if(value == null) {
                          return 'Please enter student name';
                        }
                        if (value.trim() == "") {
                          return "Only space is not Valid!!!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _studentName = value;
                      },
                      controller: _studentNameController,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 2.0,
                            style: BorderStyle.solid
                          ),
                        ),
                        labelText: "Student Name",
                        icon: Icon(
                          Icons.people,
                          color: Colors.black,
                        ),
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      if(isUpdate) {
                        if(_formStateKey.currentState!.validate()) {
                          _formStateKey.currentState!.save();
                          DBProvider.db.updateStudent(Student(studentIdForUpdate, _studentName))
                          .then((data) {
                            setState(() {
                              isUpdate = false;
                            });
                          });
                        }
                      } else {
                        if(_formStateKey.currentState!.validate()) {
                          _formStateKey.currentState!.save();
                          DBProvider.db.insertStudent(Student(null, _studentName));
                        }
                      }

                      _studentNameController.text = '';
                      updateStudentList();
                    },
                    child: Text(
                      (isUpdate ? 'UPDATE': 'ADD'),
                      style: const TextStyle(
                        color: Colors.white
                      ),
                    ),
                ),
                const Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

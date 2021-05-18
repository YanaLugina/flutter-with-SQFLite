import 'package:flutter/material.dart';
import 'package:flutter_with_db/model/student.dart';

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formStateKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if(value == null || value.isEmpty) {
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

                        _studentNameController.text = '';
                        updateStudentList();
                      }

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
                  onPressed: () {
                    _studentNameController.text = '';

                    setState(() {
                      isUpdate = false;
                      // studentIdForUpdate = null;
                    });
                  },
                  child: Text(
                    (isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
                const Divider(
                  height: 5.0,
                ),
                Expanded(
                    child: FutureBuilder(
                        future: _studentsList,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.data == null) {
                              return const Text('No Data Found');
                            }
                            else if (snapshot.hasData) {
                              return generateList(snapshot.data);
                            }
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                ),
              ],
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  SingleChildScrollView generateList(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('NAME')),
            DataColumn(label: Text('DELETE'))
          ],
          rows: List<DataRow>.generate(
              students.length,
                  (int index) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(students[index].name!),
                          onTap: () {
                            setState(() {
                              isUpdate = true;
                              studentIdForUpdate = students[index].id!;
                            });
                            _studentNameController.text = students[index].name!;
                          },
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              DBProvider.db.deleteStudent(students[index].id!);
                              updateStudentList();
                            },
                          ),
                        )
                      ]
                  )
          )!,
          /*rows: students.map(
                  (student) =>  DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(student.name),
                          onTap: () {
                            setState(() {
                              isUpdate = true;
                              studentIdForUpdate = student.id;
                            });
                            _studentNameController.text = student.name;
                            },
                        ),
                        DataCell(
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                DBProvider.db.deleteStudent(student.id);
                                updateStudentList();
                              },
                            ),
                        )
                      ]
                  ),
          ),*/
        ),
      ),
    );
  }

}

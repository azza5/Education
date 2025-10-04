import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAssignmentPage extends StatefulWidget {
  final String matiereName;

  const AddAssignmentPage(
      {super.key, required this.matiereName, required int studentId});

  @override
  _AddAssignmentPageState createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  int? _selectedStudentId;
  String? _selectedMatiereName;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _loadStudents();
    _loadMatieres();
  }

  Future<void> _loadStudents() async {
    try {
      final studentsResponse = await http.get(Uri.parse(
          "http://192.168.101.43/StudentsApi/students/get_students.php"));

      if (studentsResponse.statusCode == 200) {
        setState(() {});
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _loadMatieres() async {
    try {
      final matieresResponse = await http.get(Uri.parse(
          "http://192.168.101.43/StudentsApi/matiere/get_matieres.php"));

      if (matieresResponse.statusCode == 200) {
        setState(() {});
      } else {
        print("Erreur lors de la récupération des matières");
      }
    } catch (e) {
      print("Erreur réseau lors du chargement des matières : $e");
    }
  }

  Future<void> _addAssignment() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final url = Uri.parse(
            "http://192.168.101.43/StudentsApi/devoir/add_devoir.php");
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'title': 'Devoir pour la matière',
            'description': _descriptionController.text,
            'student_id': _selectedStudentId,
            'matiere_name': _selectedMatiereName,
            'date': _selectedDate?.toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(responseData['message'] ?? "Ajout réussi")),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? "Échec")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur serveur (${response.statusCode})')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${error.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();
    if (picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un devoir"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description du devoir',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: _selectedDate == null
                            ? 'Sélectionner la date'
                            : 'Date sélectionnée: ${_selectedDate!.toLocal()}'
                                .split(' ')[0],
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'Veuillez sélectionner une date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Ajouter le devoir"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

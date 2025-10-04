import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateStudentPage extends StatefulWidget {
  final Map<String, dynamic> student;

  const UpdateStudentPage({super.key, required this.student});

  @override
  _UpdateStudentPageState createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _classeController;
  late TextEditingController _adresseController;
  late TextEditingController _prenomController;
  late TextEditingController _dateNaissanceController;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.student['nom']);
    _emailController = TextEditingController(text: widget.student['email']);
    _classeController = TextEditingController(text: widget.student['classe']);
    _adresseController = TextEditingController(text: widget.student['adresse']);
    _prenomController = TextEditingController(text: widget.student['prenom']);
    _dateNaissanceController =
        TextEditingController(text: widget.student['dateNaissance']);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _classeController.dispose();
    _adresseController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<bool> _updateStudentData() async {
    var url = Uri.parse(
        'http://192.168.101.43/StudentsApi/students/update_student.php');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': widget.student['id'],
          'nom': _nomController.text,
          'email': _emailController.text,
          'classe': _classeController.text,
          'adresse': _adresseController.text,
          'prenom': _prenomController.text,
          'dateNaissance': _dateNaissanceController.text,
        }),
      );

      var data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Erreur"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFFA726),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.orangeAccent,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFFFFA726),
              selectionColor: Color(0xFFFFA726),
              selectionHandleColor: Color(0xFFFFA726),
            ),
            primaryTextTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.black),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFA726),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFFFA726),
                ),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA726),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ).copyWith(secondary: const Color(0xFFFFA726)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre à jour'),
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'email est requis';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _classeController,
                decoration: const InputDecoration(labelText: 'Classe'),
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              TextFormField(
                controller: _dateNaissanceController,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today,
                        color: Color(0xFFFFA726)),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La date de naissance est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool success = await _updateStudentData();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mise à jour réussie'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      Navigator.pop(context, true);
                    } else {
                      _showErrorDialog("Erreur lors de la mise à jour.");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                ),
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

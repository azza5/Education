import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddStudentForm extends StatefulWidget {
  final Function onStudentAdded; //Fonction callback pour notifier l'ajout

  const AddStudentForm({super.key, required this.onStudentAdded});

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isStudent = true;

  Future<void> _addStudent(BuildContext context) async {
    var url =
        Uri.parse("http://192.168.101.43/StudentsApi/students/add_student.php");
    try {
      var body = json.encode({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'adresse': _adresseController.text,
        'dateNaissance': _dateController.text,
        'role': 'Etudiant',
        'classe': _classeController.text,
      });

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Étudiant ajouté avec succès")),
          );
          widget.onStudentAdded();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Erreur inconnue")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur serveur : ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau ou serveur indisponible")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter "),
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFA726),
                Color(0xFFFFCC80),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 10)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 10),
                  _buildTextField(_nomController, 'Nom :'),
                  _buildTextField(_prenomController, 'Prénom :'),
                  _buildTextField(_emailController, 'Email :'),
                  _buildPasswordField(_passwordController, 'Password :'),
                  _buildTextField(_classeController, 'Classe :'),
                  _buildTextField(_adresseController, 'Adresse :'),
                  _buildDateField(_dateController, 'Date de naissance :'),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isStudent,
                        onChanged: (bool? value) {
                          setState(() {
                            _isStudent = true;
                          });
                        },
                      ),
                      const Text(
                        'Etudiant ',
                        style: TextStyle(
                          color: Color(0xFFFFA726),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _addStudent(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFFFA726),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(120),
                      ),
                    ),
                    child: const Text("Ajouter l'étudiant"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFFFA726)),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFA726)),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFFFA726)),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFA726)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFFFFA726),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2101),
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
                  ).copyWith(secondary: Colors.grey),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0];
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xFFFFA726)),
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFA726)),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFFA726),
                ),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2101),
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
                          ).copyWith(secondary: Colors.grey),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    controller.text = "${pickedDate.toLocal()}".split(' ')[0];
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

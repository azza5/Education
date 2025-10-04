import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateAdminPage extends StatefulWidget {
  final Map<String, dynamic> admin;

  const UpdateAdminPage({super.key, required this.admin});

  @override
  _UpdateAdminPageState createState() => _UpdateAdminPageState();
}

class _UpdateAdminPageState extends State<UpdateAdminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _adresseController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.admin['nom']);
    _prenomController = TextEditingController(text: widget.admin['prenom']);
    _emailController = TextEditingController(text: widget.admin['email']);
    _adresseController = TextEditingController(text: widget.admin['adresse']);
    _dateNaissanceController =
        TextEditingController(text: widget.admin['dateNaissance']);
    _roleController = TextEditingController(text: widget.admin['role']);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _updateAdmin() async {
    if (_formKey.currentState?.validate() ?? false) {
      var url = Uri.parse('http://192.168.101.43/StudentsApi/update_admin.php');
      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': widget.admin['id'],
            'nom': _nomController.text,
            'prenom': _prenomController.text,
            'email': _emailController.text,
            'adresse': _adresseController.text,
            'dateNaissance': _dateNaissanceController.text,
            'role': _roleController.text,
          }),
        );

        var data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Administrateur mis à jour avec succès')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur inconnue')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur de réseau ou serveur indisponible')),
        );
      }
    }
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
              labelStyle: const TextStyle(color: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre à jour Administrateur'),
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
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              _buildDateField(_dateNaissanceController, 'Date de naissance'),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Rôle'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateAdmin,
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

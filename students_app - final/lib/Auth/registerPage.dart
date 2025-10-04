import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _codeSecretController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();
  String _selectedRole = 'etudiant';
  final String _adminCode = '0000'; // Code secret pour admin
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == 'admin' &&
          _codeSecretController.text != _adminCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code secret incorrect pour admin')),
        );
        return;
      }

      var url = Uri.parse('http://192.168.101.43/StudentsApi/register.php');
      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': _emailController.text,
            'password': _passwordController.text,
            'nom': _nomController.text,
            'prenom': _prenomController.text,
            'dateNaissance': _dateNaissanceController.text,
            'adresse': _adresseController.text,
            'role': _selectedRole,
            'classe': _selectedRole == 'etudiant' ? _classeController.text : '',
          }),
        );
        var data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscription réussie')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur inconnue')),
          );
        }
      } catch (e) {
        print('Erreur : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur réseau ou serveur indisponible')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFFA726),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Color(0xFFFFA726),
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA726),
              onSurface: Colors.black,
            ).copyWith(secondary: const Color(0xFFFFA726)),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateNaissanceController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'S’inscrire',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
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
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.orange),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Confirmer votre mot de passe',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _adresseController,
                        label: 'Adresse',
                        icon: Icons.home,
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _dateNaissanceController,
                            label: 'Date de naissance',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _selectedRole == 'etudiant'
                          ? _buildTextField(
                              controller: _classeController,
                              label: 'Classe de l\'étudiant',
                              icon: Icons.class_,
                            )
                          : Container(),
                      const SizedBox(height: 16.0),
                      _selectedRole == 'admin'
                          ? _buildTextField(
                              controller: _codeSecretController,
                              label: 'Code secret admin',
                              icon: Icons.security,
                              obscureText: true,
                            )
                          : Container(),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRoleOption('Etudiant', 'etudiant'),
                          _buildRoleOption('Admin', 'admin'),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: const Text(
                          'S’inscrire',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    );
  }

  Widget _buildRoleOption(String title, String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        groupValue: _selectedRole,
        onChanged: (value) {
          setState(() {
            _selectedRole = value!;
          });
        },
      ),
    );
  }
}

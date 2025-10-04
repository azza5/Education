import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddPresencePage extends StatefulWidget {
  final int studentId;
  final Function(Map<String, dynamic>) onPresenceAdded;

  const AddPresencePage({
    Key? key,
    required this.studentId,
    required this.onPresenceAdded,
  }) : super(key: key);

  @override
  _AddPresencePageState createState() => _AddPresencePageState();
}

class _AddPresencePageState extends State<AddPresencePage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'Absent';
  int? _matiereId;
  List<Map<String, dynamic>> _matieres = [];
  String currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchMatieres();
  }

  Future<void> fetchMatieres() async {
    try {
      final url =
          "http://192.168.101.43/StudentsApi/matiere/get_matiere.php?student_id=${widget.studentId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        if (data is List) {
          setState(() {
            _matieres = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map && data.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur inconnue')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Format de réponse inattendu.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur (${response.statusCode})')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    }
  }

  Future<void> _addPresence() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.post(
          Uri.parse(
              "http://192.168.101.43/StudentsApi/presence/add_presence.php"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'student_id': widget.studentId,
            'matiere_id': _matiereId,
            'status': _status,
            'date': currentDate,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData['success'] == true) {
            widget.onPresenceAdded({
              'student_id': widget.studentId,
              'matiere_id': _matiereId,
              'status': _status,
              'date': currentDate,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? 'Succès')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? 'Échec')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur serveur (${response.statusCode})')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une présence"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Date et Heure actuelle : $currentDate',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _status,
                decoration:
                    const InputDecoration(labelText: 'Statut de présence'),
                items: ['Présent', 'Absent']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value ?? 'Absent';
                  });
                },
              ),
              const SizedBox(height: 20),
              _matieres.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: _matiereId,
                      decoration: const InputDecoration(
                          labelText: 'Sélectionnez la matière'),
                      items: _matieres
                          .map((matiere) => DropdownMenuItem<int>(
                                value:
                                    int.tryParse(matiere['id'].toString()) ?? 0,
                                child: Text(matiere['matiere'] ?? 'Inconnue'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _matiereId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une matière';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPresence,
                child: const Text('Ajouter la présence'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

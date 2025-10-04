import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListMatieres extends StatefulWidget {
  final int studentId;

  const ListMatieres({super.key, required this.studentId});

  @override
  _ListMatieresState createState() => _ListMatieresState();
}

class _ListMatieresState extends State<ListMatieres> {
  List<dynamic> _matieres = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMatieres();
  }

  Future<void> _fetchMatieres() async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/matiere/get_matiere.php?student_id=${widget.studentId}");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _matieres = [];
          if (data is List) {
            _matieres = data.map((item) {
              item['id'] = int.tryParse(item['id'].toString()) ?? 0;
              return item;
            }).toList();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur HTTP ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau ou serveur indisponible")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUpdateMatiereDialog(int matiereId, String currentMatiere) {
    final TextEditingController matiereController =
        TextEditingController(text: currentMatiere);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mettre à jour la matière"),
          content: TextField(
            controller: matiereController,
            decoration: const InputDecoration(
              labelText: "Nom de la matière",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Mettre à jour"),
              onPressed: () async {
                if (matiereController.text.isNotEmpty) {
                  final url = Uri.parse(
                      "http://192.168.101.43/StudentsApi/matiere/update_matiere.php");
                  try {
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({
                        'student_id': widget.studentId,
                        'id': matiereId,
                        'nom': matiereController.text,
                      }),
                    );

                    if (response.statusCode == 200) {
                      final responseData = json.decode(response.body);
                      if (responseData['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(responseData['message'])),
                        );
                        Navigator.of(context).pop();
                        _fetchMatieres();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erreur : ${responseData['message']}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur serveur')),
                      );
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${error.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Veuillez entrer un nom de matière")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMatiereDialog() {
    final TextEditingController matiereController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter une matière"),
          content: TextField(
            controller: matiereController,
            decoration: const InputDecoration(
              labelText: "Nom de la matière",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Ajouter"),
              onPressed: () async {
                if (matiereController.text.isNotEmpty) {
                  final url = Uri.parse(
                      "http://192.168.101.43/StudentsApi/matiere/add_matiere.php");
                  try {
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({
                        'student_id': widget.studentId,
                        'nom': matiereController.text,
                      }),
                    );

                    if (response.statusCode == 200) {
                      final responseData = json.decode(response.body);
                      if (responseData['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(responseData['message'])),
                        );
                        matiereController.clear();
                        Navigator.of(context).pop();
                        _fetchMatieres();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erreur : ${responseData['message']}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur serveur')),
                      );
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${error.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Veuillez entrer un nom de matière")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMatiere(int matiereId) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/matiere/delete_matiere.php");

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': matiereId,
          'student_id': widget.studentId,
        }),
      );

      var data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Matière supprimée")),
        );
        _fetchMatieres();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Échec de la suppression")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau ou serveur indisponible")),
      );
    }
  }

  void _showDeleteConfirmationDialog(int matiereId, String matiereName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: Text(
              "Êtes-vous sûr de vouloir supprimer la matière : '$matiereName' ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMatiere(matiereId);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  void _showAddDevoirDialog(int studentId, int matiereId) {
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter un devoir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: "Description du devoir"),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date du devoir",
                  hintText: "Sélectionnez une date",
                ),
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
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

                  if (selectedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                    dateController.text = formattedDate;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _addAssignment(
                  studentId,
                  matiereId,
                  descriptionController.text,
                  dateController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAssignment(
      int studentId, int matiereId, String description, String date) async {
    var url =
        Uri.parse("http://192.168.101.43/StudentsApi/devoir/add_devoir.php");
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'matiere_id': matiereId,
          'description': description,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Devoir ajouté")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? "Erreur lors de l'ajout")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur HTTP ${response.statusCode}")),
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
        title: const Text("Liste des matières"),
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _matieres.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.white,
                    shadowColor: Colors.grey.shade200,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        _matieres[index]['matiere'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.assignment,
                                color: Colors.blue),
                            onPressed: () {
                              _showAddDevoirDialog(
                                  widget.studentId, _matieres[index]['id']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              _showUpdateMatiereDialog(_matieres[index]['id'],
                                  _matieres[index]['matiere']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  _matieres[index]['id'],
                                  _matieres[index]['matiere']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFA726),
        onPressed: _showAddMatiereDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListDevoirs extends StatefulWidget {
  final int studentId;

  const ListDevoirs({super.key, required this.studentId});

  @override
  _ListDevoirsState createState() => _ListDevoirsState();
}

class _ListDevoirsState extends State<ListDevoirs> {
  List<dynamic> _devoirs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDevoirs();
  }

  Future<void> _fetchDevoirs() async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/devoir/get_devoirs.php?studentId=${widget.studentId}");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _devoirs = data['devoirs'] ?? [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Erreur inconnue")),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddDevoirDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController matiereNameController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

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
                decoration: const InputDecoration(
                  labelText: "Description du devoir",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: matiereNameController,
                decoration: const InputDecoration(
                  labelText: "Nom de la matière",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              _buildDateField(
                  dateController, "Date du devoir", const Color(0xFFFFA726)),
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
                String description = descriptionController.text.trim();
                String matiereName = matiereNameController.text.trim();
                String date = dateController.text.trim();
                if (description.isNotEmpty &&
                    matiereName.isNotEmpty &&
                    date.isNotEmpty) {
                  _addDevoir(description, matiereName, date);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Veuillez remplir tous les champs")),
                  );
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDevoir(
      String description, String matiereName, String date) async {
    var url =
        Uri.parse("http://192.168.101.43/StudentsApi/devoir/add_devoir.php");

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': description,
          'matiere_name': matiereName,
          'student_id': widget.studentId,
          'date': date,
        }),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Devoir ajouté")),
          );
          _fetchDevoirs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Échec de l'ajout")),
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

  Future<void> _deleteDevoir(int id) async {
    var url =
        Uri.parse("http://192.168.101.43/StudentsApi/devoir/delete_devoir.php");

    try {
      var response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'devoir_id': id,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Devoir supprimé avec succès")),
          );
          _fetchDevoirs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? "Échec de la suppression")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur HTTP ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau")),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer le devoir ?"),
          content: const Text("Êtes-vous sûr de vouloir supprimer ce devoir ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteDevoir(id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(
      int id, String currentDescription, String currentDate) {
    final TextEditingController updateController =
        TextEditingController(text: currentDescription);
    final TextEditingController dateController =
        TextEditingController(text: currentDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modifier le devoir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: updateController,
                decoration: const InputDecoration(
                  labelText: "Nouvelle description",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildDateField(
                  dateController, "Nouvelle date", const Color(0xFFFFA726)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                String newDescription = updateController.text.trim();
                String newDate = dateController.text.trim();
                if (newDescription.isNotEmpty && newDate.isNotEmpty) {
                  _updateDevoir(id, newDescription, newDate);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Veuillez remplir tous les champs")),
                  );
                }
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, Color calendarColor) {
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
                  primaryColor: calendarColor,
                  buttonTheme: const ButtonThemeData(
                    textTheme: ButtonTextTheme.primary,
                    buttonColor: Colors.orangeAccent,
                  ),
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: calendarColor,
                    selectionColor: calendarColor,
                    selectionHandleColor: calendarColor,
                  ),
                  primaryTextTheme: const TextTheme(
                    titleLarge: TextStyle(color: Colors.black),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: calendarColor,
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: calendarColor,
                      ),
                    ),
                  ),
                  colorScheme: ColorScheme.light(
                    primary: calendarColor,
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
              labelStyle:
                  const TextStyle(color: Color.fromARGB(255, 36, 36, 36)),
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
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
                          primaryColor: calendarColor,
                          buttonTheme: const ButtonThemeData(
                            textTheme: ButtonTextTheme.primary,
                            buttonColor: Colors.orangeAccent,
                          ),
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: calendarColor,
                            selectionColor: calendarColor,
                            selectionHandleColor: calendarColor,
                          ),
                          primaryTextTheme: const TextTheme(
                            titleLarge: TextStyle(color: Colors.black),
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: calendarColor,
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: calendarColor,
                              ),
                            ),
                          ),
                          colorScheme: ColorScheme.light(
                            primary: calendarColor,
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

  Future<void> _updateDevoir(
      int id, String newDescription, String newDate) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/devoir/update_devoir.php?devoir_id=$id");

    try {
      var response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': newDescription,
          'date': newDate,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Devoir mis à jour avec succès")),
          );
          _fetchDevoirs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Erreur inconnue")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur HTTP ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des devoirs'),
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
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _devoirs.length,
                      itemBuilder: (context, index) {
                        var devoir = _devoirs[index];
                        return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            color: Colors.white,
                            shadowColor: Colors.grey.shade200,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.assignment,
                                  color: Color(0xFFFFA726)),
                              title: Text(
                                  devoir['matiere_nom'] ?? "Matière inconnue"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(devoir['description'] ??
                                      "Sans description"),
                                  const SizedBox(height: 4),
                                  Text(
                                    devoir['date'] != null
                                        ? "Date: ${devoir['date']}"
                                        : "Date inconnue",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _showUpdateDialog(
                                        devoir['id'],
                                        devoir['description'],
                                        devoir['date']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _confirmDelete(devoir['id']),
                                  ),
                                ],
                              ),
                            ));
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDevoirDialog,
        backgroundColor: const Color(0xFFFFA726),
        tooltip: "Ajouter un devoir",
        child: const Icon(Icons.add),
      ),
    );
  }
}

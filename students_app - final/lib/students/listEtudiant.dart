import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:students_app/Students/EtudiantDetailPage.dart';
import 'package:students_app/Students/addEtudiant.dart';
import 'package:students_app/Presence/AddPresencePage.dart';

class ListStudents extends StatefulWidget {
  const ListStudents({super.key});

  @override
  _ListStudentsState createState() => _ListStudentsState();
}

class _ListStudentsState extends State<ListStudents> {
  Map<String, List<dynamic>> _studentsByClass = {};
  List<dynamic> _filteredStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/students/get_students.php");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _studentsByClass = {}; // Réinitialise la carte des classes
          var students = data['students'] ?? [];
          // Trie les étudiants par classe
          for (var student in students) {
            String className = student['classe'] ?? 'Classe inconnue';
            if (!_studentsByClass.containsKey(className)) {
              _studentsByClass[className] = [];
            }
            _studentsByClass[className]!.add(student);
          }
          _filteredStudents = students;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur lors du chargement des étudiants")),
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

  Future<void> _deleteStudent(int studentId) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/students/delete_student.php");
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': studentId}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _studentsByClass.forEach((className, students) {
              students.removeWhere((student) => student['id'] == studentId);
            });
            _filteredStudents = _filteredStudents
                .where((student) => student['id'] != studentId)
                .toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Étudiant supprimé")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(data['message'] ?? "Erreur lors de la suppression")),
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

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = _studentsByClass.values
          .expand((students) => students) // yfusionni les listes des etudiants
          .where((student) {
        String name = '${student['nom']} ${student['prenom']}'.toLowerCase();
        String className = (student['classe'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase()) ||
            className.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des étudiants'),
        backgroundColor: const Color(0xFFFFA726),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: _filterStudents,
                decoration: InputDecoration(
                  hintText: 'Rechercher un étudiant...',
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.orange.shade600,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.orange.shade800, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          var student = _filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            color: Colors.white,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFFFA726),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(student['nom'] ?? "Nom inconnu"),
                              subtitle:
                                  Text(student['email'] ?? "Email inconnu"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.blue),
                                    onPressed: () {
                                      int studentId = student['id'];
                                      _showAddPresencePage(studentId);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _confirmDeleteStudent(student);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () async {
                                bool? updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentDetailPage(student: student),
                                  ),
                                );
                                if (updated == true) {
                                  _fetchStudents();
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: const Color(0xFFFFA726),
        elevation: 10,
        highlightElevation: 20,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  void _confirmDeleteStudent(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: Text("Voulez-vous vraiment supprimer ${student['nom']} ?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteStudent(student['id']);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter un étudiant"),
          content: AddStudentForm(onStudentAdded: _fetchStudents),
        );
      },
    );
  }

  void _showAddPresencePage(int studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPresencePage(
          studentId: studentId,
          onPresenceAdded: (newPresence) {
            setState(() {});
          },
        ),
      ),
    );
  }
}

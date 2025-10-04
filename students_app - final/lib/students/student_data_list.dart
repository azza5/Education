import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentDataList extends StatefulWidget {
  const StudentDataList({super.key});

  @override
  StudentDataListState createState() => StudentDataListState();
}

class StudentDataListState extends State<StudentDataList> {
  Map<String, List<dynamic>> _studentsByClass = {};
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
        List<dynamic> students = data['students'] ?? [];
        //grouppement des etudiants par classe
        Map<String, List<dynamic>> groupedStudents = {};
        for (var student in students) {
          String className = student['classe'] ?? 'Inconnue';
          if (!groupedStudents.containsKey(className)) {
            groupedStudents[className] = [];
          }
          groupedStudents[className]!.add(student);
        }

        setState(() {
          // Mise à jour de l'état avec les données groupées
          _studentsByClass = groupedStudents;
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

  Map<String, List<dynamic>> _filteredStudentsByClass() {
    if (_searchQuery.isEmpty) {
      return _studentsByClass;
    } else {
      Map<String, List<dynamic>> filteredStudents = {};

      _studentsByClass.forEach((className, students) {
        List<dynamic> filteredList = students.where((student) {
          if (className.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return true;
          }

          String fullName =
              "${student['prenom']} ${student['nom']}".toLowerCase();
          return fullName.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredList.isNotEmpty) {
          filteredStudents[className] = filteredList;
        }
      });

      return filteredStudents;
    }
  }

  Future<void> _updatePresence(
      int studentId, int matiereId, int presenceId, String status) async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/presence/update_presence.php");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'studentId': studentId,
          'matiereId': matiereId,
          'presenceId': presenceId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          String message = responseData['message'] ?? 'Mise à jour réussie';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          await _fetchStudents();
        } catch (jsonError) {
          print('JSON Decode Error: $jsonError');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur de parsing de la réponse")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Échec de la mise à jour (Code: ${response.statusCode})")),
        );
      }
    } catch (e) {
      print('Request Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau ou serveur indisponible")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Rechercher par nom, prénom ou classe...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
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
            : ListView(
                children: _filteredStudentsByClass().entries.map((entry) {
                  String className = entry.key;
                  List<dynamic> students = entry.value;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        className,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      children: students.map((student) {
                        return StudentCard(
                          studentId: student['id'],
                          studentFirstName: student['prenom'],
                          studentLastName: student['nom'],
                          updatePresence: _updatePresence,
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final int studentId;
  final String studentFirstName;
  final String studentLastName;
  final Future<void> Function(int, int, int, String) updatePresence;

  const StudentCard({
    super.key,
    required this.studentId,
    required this.studentFirstName,
    required this.studentLastName,
    required this.updatePresence,
  });

  Future<List<dynamic>> _fetchMatieres(int studentId) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/matiere/get_matiere.php?student_id=$studentId");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data
          .map((matiere) => {
                'id': int.tryParse(matiere['id'].toString()) ?? 0,
                'matiere': matiere['matiere']
              })
          .toList();
    } else {
      throw Exception("La liste des matières est vide");
    }
  }

  Future<List<dynamic>> _fetchPresences(int studentId, int matiereId) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/presence/get_presences.php?studentId=$studentId&matiereId=$matiereId");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['presences'] ?? [];
    } else {
      throw Exception("Erreur de chargement des présences");
    }
  }

  Future<List<dynamic>> _fetchDevoirs(int studentId, int matiereId) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/devoir/get_matiere_devoir.php?studentId=$studentId&matiereId=$matiereId");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return (data['devoirs'] as List)
          .map((devoir) => {
                'id': int.tryParse(devoir['id'].toString()) ?? 0,
                'description': devoir['description'] ?? "Aucune description",
                'matiere_nom': devoir['matiere_nom'] ?? "Inconnue",
                'student_id': int.tryParse(devoir['student_id'].toString()) ?? 0
              })
          .toList();
    } else {
      return [];
    }
  }

  Future<void> _showUpdateDialog(BuildContext context, int studentId,
      int matiereId, int presenceId) async {
    String status = 'présent';

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mettre à jour la présence'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: status,
                onChanged: (String? newStatus) {
                  if (newStatus != null) {
                    setState(() {
                      status = newStatus;
                    });
                  }
                },
                items: <String>['présent', 'absent']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Mettre à jour'),
              onPressed: () {
                updatePresence(studentId, matiereId, presenceId, status);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      shadowColor: Colors.grey.shade200,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text('$studentFirstName $studentLastName'),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFA726),
          child: Icon(Icons.person, color: Colors.white),
        ),
        children: [
          FutureBuilder<List<dynamic>>(
            future: _fetchMatieres(studentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text("Erreur de chargement des matières");
              }

              var matieres = snapshot.data ?? [];
              return ListView.builder(
                shrinkWrap: true,
                itemCount: matieres.length,
                itemBuilder: (context, index) {
                  var matiere = matieres[index];
                  int matiereId = matiere['id'];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            matiere['matiere'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<dynamic>>(
                            future: _fetchPresences(studentId, matiereId),
                            builder: (context, presenceSnapshot) {
                              if (presenceSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (presenceSnapshot.hasError) {
                                return const Text(
                                    "Erreur de chargement des présences");
                              }

                              var presences = presenceSnapshot.data ?? [];
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: presences.length,
                                itemBuilder: (context, index) {
                                  var presence = presences[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    color: Colors.grey.shade100,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Présence : ${presence['status']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Date: ${presence['date']}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _showUpdateDialog(
                                                context,
                                                studentId,
                                                matiereId,
                                                presence['id'],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          FutureBuilder<List<dynamic>>(
                            future: _fetchDevoirs(studentId, matiereId),
                            builder: (context, devoirSnapshot) {
                              if (devoirSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (devoirSnapshot.hasError) {
                                return const Text(
                                    "Erreur de chargement des devoirs");
                              }

                              var devoirs = devoirSnapshot.data ?? [];
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: devoirs.length,
                                itemBuilder: (context, index) {
                                  var devoir = devoirs[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    color: Colors.grey.shade200,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            devoir['matiere_nom'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(devoir['description']),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
